# code réactive du panel "Elaboration requete" server side
# créé le 12/06/2017 à 14h51
# ce script est appelé dans server.R. Il utilise d'ailleurs deux variables de server.R que sont :
# output et input de la fonction shinyServer 


source("./serverside/fonctions_creation_requete_pubmed.R",local=TRUE, encoding="utf-8")
source("./serverside/communication_pubmed.R",local=TRUE, encoding="utf-8")
source("./serverside/entrezDataPipeline.R",local=TRUE, encoding="utf-8")
source("./serverside/xmlParser.R",local=TRUE, encoding="utf-8")
source("./serverside/formatXmlParsing.R",local=TRUE, encoding="utf-8")


#pour lancer la recherche de concept quand sur le bouton "chercher"
get_search_results <- eventReactive(input$search, {
  research_term(input$term)
})

#pour afficher le dans une datable le résultat de la recherche de concept
output$concepts_res <- DT::renderDataTable({
  withProgress(message = 'Recherche des concepts en cours',{
    concepts_table <<- get_search_results()
  })
  
  if(is.null(concepts_table)){
    showModal(modalDialog(
      title = "Aucun résultat !",
      div("Aucun concept correspondant au terme saisi"),
      div("Vérifier l'orthographe. Avez vous bien écrit en anglais ?"),
      div("Renouvellez la recherche !"),
      footer = NULL,
      easyClose = TRUE
    ))
  }else{
    colnames(concepts_table)[4] <- c("Nom des concepts")
    datatable(concepts_table, 
              selection = 'single',
              rownames = FALSE,
              options=list(
                bLengthChange = FALSE,
                # paging = FALSE,
                # pageLength = 10,
                searching = FALSE,
                columnDefs = list(list(
                  visible=FALSE, 
                  targets=c(0,1,2)))
              )
    )
  }
})

# pour afficher les définitions et les synonymes du concept cliqué 
observeEvent(input$concepts_res_rows_selected, {
  input$table_rows_selected
  url_info_concept <- concepts_table[input$concepts_res_cell_clicked$row,3]
  withProgress(message = 'Recherche des infos sur le concept choisi ...',{
    concept_selectionne <<- get_info_concept(url_info_concept)
  })
  
  
  output$conceptName <-  renderUI({HTML(concept_selectionne$concept$name)}) #affichage nom concept choisi
  output$semType <-  renderUI({HTML(concept_selectionne$semTypes$name)}) #affichage nom type sémantique choisi
  
  output$concept_atoms <- DT::renderDataTable({
    datatable(concept_selectionne$atoms, 
              selection = 'none',
              colnames = c(paste("col",as.character(1:17),sep=""),"Synonymes du concept","col18"),
              rownames = FALSE,
              options=list(
                bLengthChange = FALSE,
                searching = FALSE,
                columnDefs = list(list(
                  visible=FALSE, 
                  targets=c(0:16,18)))
              )
    )
  })
  
  output$concept_defs <- DT::renderDataTable({
    datatable(concept_selectionne$definitions, 
              colnames = c("col1","col2","col3","Définitions du concept"),
              selection = 'none',
              rownames = FALSE,
              options=list(
                bLengthChange = FALSE,
                searching = FALSE,
                columnDefs = list(list(
                  visible=FALSE, 
                  targets=c(0,1,2)))
              )
    )
    
  })
  
})

# pour ajouter un concept au concept clés
observeEvent(input$addKeyConcept,{
  if(length(key_concepts) == 0){
    if(length(concept_selectionne) == 0){
      showModal(modalDialog(
        title = "Aucun concept à ajouter",
        div("Il faut d'abord rechercher un concept avant de l'ajouter aux concepts choisis"),
        div("Revenez à Step 1"),
        footer = NULL,
        easyClose = TRUE
      ))
      return()
    }
    key_concepts[[1]] <<- concept_selectionne
  }else{
    key_concepts <<- c(key_concepts, list(concept_selectionne))
  }
  names(key_concepts)[length(key_concepts)] <- concept_selectionne$concept$name
  key_concepts <<- key_concepts # pour que le changement de nom soit globale
  output$keyConcepts <-  renderUI({
    selectizeInput("conceptsKey",
                   label= "Concepts que l'on va chercher dans les articles",
                   choices = names(key_concepts),
                   selected = names(key_concepts),
                   multiple = TRUE,
                   options = NULL)
  })
  
})

# pour mettre à jour les concepts clés en cas de suppresion d'un de ses concepts par l'utilisateur
observeEvent(input$conceptsKey, ignoreNULL = FALSE, ignoreInit = FALSE,{
  concepts_deleted <- setdiff(names(key_concepts),input$conceptsKey)
  print(concepts_deleted)
  sapply(concepts_deleted, function(x) { key_concepts[[x]] <<- NULL })
  output$keyConcepts <-  renderUI({
    selectizeInput("conceptsKey",
                   label= "Concepts à trouver dans les textes",
                   choices = names(key_concepts),
                   selected = names(key_concepts),
                   multiple = TRUE,
                   options = NULL)
  })
})

# action du bouton "lancer la recherche d'articles"
# quand on lance la recherche, toute la requête élaborée par l'utilisateur est dans
# l'objet key_concepts qui est une liste des concepts choisis par l'utilisateur
# chaque élément de cette liste contient donc les infos d'un concept choisi par l'utilisateur
# les attributs d'un élement de cette liste sont :
# $concept ( $cui $name)
# $semTypes ( $name $uri)
# $definitions ($value ...)
# $atoms qui est un data frame avec comme colonne d'intérêt : name
# pour élaborer la requête, il faut récupérer tous les synonymes de chaque concept

observeEvent(input$findArticles,{
  if(length(key_concepts) == 0){
    showModal(modalDialog(
      title = "Aucun concept choisi",
      div("Il faut d'abord choisir des concepts pour lancer la recherche d'articles !"),
      div("Revenez à Step 2"),
      footer = NULL,
      easyClose = TRUE
    ))
  }else{
    #esearchRes<-pSearchTerms(getPubmedQuery(key_concepts))
    withProgress(message = 'Recherche des articles en cours',{
      res_esearch <- getXmlPubmedArticles(key_concepts) #res_esearch est null si plus de 10000 articles
      #cela enregistre le xml sur le disque
    })
    msg = "Mieux spécifier votre recherche car elle renvoie plus de 10000 articles"
    if(!is.null(res_esearch)){
      msg <- "Tout s'est bien passé : "  
      msg <- paste(msg, res_esearch$count," abstract trouvés sur pubmed",sep = "")
      msg <- HTML(paste(
        msg,
        "</br> Consultez le résultat de la recherche dans l'onglet \"Consultation des articles\"",
        sep = ""
      )
      )
      articles_research<<-processXmlPubmed()
      output$articles_research <- DT::renderDataTable({
        datatable(articles_research, 
                  selection = 'single',
                  rownames = FALSE,
                  options=list(
                    # bLengthChange = FALSE,
                    # paging = FALSE,
                    # pageLength = 10,
                    # searching = FALSE,
                    columnDefs = list(list(
                      visible=FALSE, 
                      targets=c(4)))
                  )
        )
      })
      
    }
    showModal(modalDialog(
      title = "En développement ....",
      msg, #getPubmedQuery(key_concepts)
      footer = NULL,
      easyClose = TRUE
    ))
  }
})