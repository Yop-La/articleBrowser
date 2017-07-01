# code réactive du panel "Consultation articles" server side
# créé le 23/06/2017 à 14h51
# ce script est appelé dans server.R. Il utilise d'ailleurs deux variables de server.R que sont :
# output et input de la fonction shinyServer 

source("./serverside/formatToMedline.R",local=TRUE, encoding="utf-8")
source("./serverside/mappArticles.R",local=TRUE, encoding="utf-8")


# pour afficher le résumé de l'article cliqué
observeEvent(input$articles_research_rows_selected, {
  input$table_rows_selected
  row_clicked = input$articles_research_cell_clicked$row
  abstract_in_modal <<- articles_research[row_clicked,5]
  title <- articles_research[row_clicked,2]
  showModal(modalDialog(
    title = title,
    HTML(
      paste(abstract_in_modal,"<br/> <br/>",sep="")
    ),
    fluidRow(
      column(12, 
             align="center",
             actionButton("getFullArticle", "Voir l'article complet"),
             actionButton("removeFromSelection", "Enlever de la sélection")
      )
    ),
    footer = NULL,
    easyClose = TRUE
  ))
})

output$statutMapping <- renderUI({
  "Aucun mapping en cours"
})

observeEvent(input$startMapping,{
  if(is.null(articles_research)){
    ordreMapping <<- FALSE
    showModal(modalDialog(
      title = "Impossible de lancer le mapping",
      div("Il faut d'abord chercher des articles avant de pouvoir les mapper"),
      easyClose = TRUE,
      footer = NULL
    ))
  }else{ 
    
    saveArticlesToMedlineFormat(articles_research,"./articles.medline")
    launchMapping<-function(){
      jobMapping %<-% future({
        resMapping = mappArticles()
        resMapping
      }) %plan% multiprocess
      print("passé")
      while (!resolved(jobMapping)) { #tant que le de job de mapping est en cours
        print(resolved(jobMapping))
        print(".")
        #on peut vérifier que le mapping est bien lancé
        #ici on récupère le statut du mapping et on l'affiche dans l'app avec le temps restant  
      }
      print("done")
      # resMapping <- value(jobMapping)
      return(jobMapping)
    }
    print(launchMapping())
    #on lance le mapping dans un bloc future
    
    
    showModal(modalDialog(
      title = "Lancement du mapping ....",
      div("Le mappage des articles sera bientôt lancé. Vous pouvez avoir voir l'avcancement
          du mapping et le temps restant dans la partie \"Statut Mapping\". Attention !! La fermeture
          de l'application stoppe toute l'opération !!"),
      easyClose = TRUE,
      footer = NULL
    ))
  }
})






# 
# 
# 
# 
# source("./serverside/fonctions_creation_requete_pubmed.R",local=TRUE, encoding="utf-8")
# source("./serverside/communication_pubmed.R",local=TRUE, encoding="utf-8")
# source("./serverside/entrezDataPipeline.R",local=TRUE, encoding="utf-8")
# source("./serverside/xmlParser.R",local=TRUE, encoding="utf-8")
# source("./serverside/formatXmlParsing.R",local=TRUE, encoding="utf-8")
# 
# 
# #pour lancer la recherche de concept quand sur le bouton "chercher"
# get_search_results <- eventReactive(input$search, {
#   research_term(input$term)
# })
# 
# #pour afficher le dans une datable le résultat de la recherche de concept
# output$concepts_res <- DT::renderDataTable({
#   withProgress(message = 'Recherche des concepts en cours',{
#     concepts_table <<- get_search_results()
#   })
#   
#   if(is.null(concepts_table)){
#     showModal(modalDialog(
#       title = "Aucun résultat !",
#       div("Aucun concept correspondant au terme saisi"),
#       div("Vérifier l'orthographe. Avez vous bien écrit en anglais ?"),
#       div("Renouvellez la recherche !"),
#       footer = NULL,
#       easyClose = TRUE
#     ))
#   }else{
#     colnames(concepts_table)[4] <- c("Nom des concepts")
#     datatable(concepts_table, 
#               selection = 'single',
#               rownames = FALSE,
#               options=list(
#                 bLengthChange = FALSE,
#                 # paging = FALSE,
#                 # pageLength = 10,
#                 searching = FALSE,
#                 columnDefs = list(list(
#                   visible=FALSE, 
#                   targets=c(0,1,2)))
#               )
#     )
#   }
# })
# 
# 
# 
# # pour ajouter un concept au concept clés
# observeEvent(input$addKeyConcept,{
#   if(length(key_concepts) == 0){
#     if(length(concept_selectionne) == 0){
#       showModal(modalDialog(
#         title = "Aucun concept à ajouter",
#         div("Il faut d'abord rechercher un concept avant de l'ajouter aux concepts choisis"),
#         div("Revenez à Step 1"),
#         footer = NULL,
#         easyClose = TRUE
#       ))
#       return()
#     }
#     key_concepts[[1]] <<- concept_selectionne
#   }else{
#     key_concepts <<- c(key_concepts, list(concept_selectionne))
#   }
#   names(key_concepts)[length(key_concepts)] <- concept_selectionne$concept$name
#   key_concepts <<- key_concepts # pour que le changement de nom soit globale
#   # key_concepts <- key_concepts_tempo
#   output$keyConcepts <-  renderUI({
#     selectizeInput("conceptsKey", 
#                    label= "Concepts que l'on va chercher dans les articles", 
#                    choices = names(key_concepts), 
#                    selected = names(key_concepts), 
#                    multiple = TRUE,
#                    options = NULL)
#   })
#   
# })
# 
# # pour mettre à jour les concepts clés en cas de suppresion d'un de ses concepts par l'utilisateur
# observeEvent(input$conceptsKey, ignoreNULL = FALSE, ignoreInit = FALSE,{
#   concepts_deleted <- setdiff(names(key_concepts),input$conceptsKey)
#   print(concepts_deleted)
#   sapply(concepts_deleted, function(x) { key_concepts[[x]] <<- NULL })
#   output$keyConcepts <-  renderUI({
#     selectizeInput("conceptsKey", 
#                    label= "Concepts à trouver dans les textes", 
#                    choices = names(key_concepts), 
#                    selected = names(key_concepts), 
#                    multiple = TRUE,
#                    options = NULL)
#   })
# })
# 
# # action du bouton "lancer la recherche d'articles"
# # quand on lance la recherche, toute la requête élaborée par l'utilisateur est dans
# # l'objet key_concepts qui est une liste des concepts choisis par l'utilisateur
# # chaque élément de cette liste contient donc les infos d'un concept choisi par l'utilisateur
# # les attributs d'un élement de cette liste sont :
# # $concept ( $cui $name)
# # $semTypes ( $name $uri)
# # $definitions ($value ...)
# # $atoms qui est un data frame avec comme colonne d'intérêt : name
# # pour élaborer la requête, il faut récupérer tous les synonymes de chaque concept
# 
