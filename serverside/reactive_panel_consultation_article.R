# code réactive du panel "Consultation articles" server side
# créé le 23/06/2017 à 14h51
# ce script est appelé dans server.R. Il utilise d'ailleurs deux variables de server.R que sont :
# output et input de la fonction shinyServer 

source("./serverside/formatToMedline.R",local=TRUE, encoding="utf-8")
source("./serverside/mappArticles.R",local=TRUE, encoding="utf-8")



refreshInfosStatut<-function(msg){
  output$infosStatut <- renderUI({
    msg
  })
}

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



rStatutMapping <- reactiveValues()

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
    showModal(modalDialog(
      title = "Lancement du mapping ....",
      div("Le mappage des articles sera bientôt lancé. Vous pouvez avoir voir l'avcancement
          du mapping et le temps restant dans la partie \"Statut Mapping\". Attention !! La fermeture
          de l'application stoppe toute l'opération !!"),
      easyClose = TRUE,
      footer = NULL
    ))
    clearDirectory("./response/")
    articles.medline <<- saveArticlesToMedlineFormat(articles_research)
    plan(multisession)
    jobMapping %<-% {
      mappArticles(articles.medline)
    }
    stateMapping <<- "mappingInProgress"
    pathMapping <<- generateFileName(sample(c("a","b","c","d","e","f"), 20, replace=T),"xml")
    pathDownloadDone <<- generateFileName(sample(c("a","b","c","d","e","f"), 20, replace=T),"RData")
  }
})



observe({
  invalidateLater(5000)
  parsingTable<-data.frame()
  
  tableStatus<-as.data.frame(getMappingStatus(),stringsAsFactors = FALSE)
  if(nrow(tableStatus) != 0){
    colnames(tableStatus) <- c("refNum",
                               "priority",
                               "M",
                               "NumberOfItems",
                               "ProcessedItems",
                               "NumberErros",
                               "ETOC",
                               "APT")
  }else{
    tableStatus<-data.frame("Aucun mapping en cours ...")
    colnames(tableStatus) <- "Activité sur le serveur"
  }
  output$statutTable <- DT::renderDataTable({
    datatable(tableStatus, 
              selection = 'none',
              rownames = FALSE,
              options=list(
                bLengthChange = FALSE,
                searching = FALSE
              )
    )
  })
  
  
  
  if(stateMapping == "mappingInProgress"){
    statutInDiv<- h4("Mapping en cours ...")
    refreshInfosStatut(HTML(paste("Le mapping des articles est en cours. Vous pouvez consulter l'avancement du mapping
                           à l'aide du tableau donné ci dessous. Ce tableau affiche tous les processus de mapping
                           en cours sur le serveur. Pour trouver votre processus, regarder le nombre d'items. Le
                           nombre d'items de votre tâche est : ",
                                  nrow(articles_research),
                                  "</br>",
                                  "Le tableau est mise à jour toutes les 5 secondes. Votre processus de mapping peut mettre une
                                  vingtaine de secondes à apparaitre dans ce tableau")))
    
    ret = setIdMapping(tableStatus)
    if(length(ret) != 0){
      if(ret==-1){
        stateMapping <<- "error"
      }else if(!is.null(idMapping)){
        
        idMappingBis <- tableStatus[tableStatus[[1]] == idMapping,1]
        if(length(as.character(idMappingBis)) == 0){
          stateMapping <<- "startupDownload"
          beginDownload <<- Sys.time()
        }
      }
    }
  }else if(stateMapping == "startupDownload"){
    statutInDiv <- h4("Demarrage du téléchargement")
    refreshInfosStatut(HTML("Le mapping est terminé. Les résultats sont en cours de téléchargement ..."))
    plan(multisession)
    
    downloadJob %<-% {
      result = tryCatch({
        downloadResMapping(idMapping,pathMapping)
        write(file = pathDownloadDone, "done")
      }, error = function(e) {
        write(file = pathDownloadDone, "fail")
      })
    }
    
    if(file.exists(pathMapping)){
      stateMapping <<- "downloadInProgress"
    }
    
    if(file.exists(pathDownloadDone)){

      if(readLines(pathDownloadDone) == "fail"){
        stateMapping <<- "error"
      }
    }
    
    
  }else if(stateMapping == "downloadInProgress"){
    statutInDiv<- h4("Téléchargement en cours ...")
    sizeMapping <- utils:::format.object_size(file.size(pathMapping), "auto")
    dureeDownload <- difftime(
      Sys.time(),
      beginDownload, 
      units = "mins"
    )
    debit<-
      debit<- utils:::format.object_size((file.size(pathMapping)/as.double(dureeDownload)), 
                                         "auto")
    
    msg<-HTML(paste(
      paste(sizeMapping, " téléchargé sur 169 M en ",dureeDownload," minutes",sep=""),
      paste("Soit ",debit," par minute.",sep=""),
      sep="</br> "))
    refreshInfosStatut(msg)
    
    
    
    if(file.exists(pathDownloadDone)){
      stateMapping <<- "downloadDone"
    }
    
  }else if(stateMapping == "downloadDone"){
    output$infosDownload <- renderUI({
      character(0)
    })
    statutInDiv<- h4("Téléchargement terminé !")
    stateMapping <<- "parsingInProgress"
    pathParsingDone <<-generateFileName(sample(c("a","b","c","d","e","f"), 20, replace=T),"txt")
    pathParsing <<-generateFileName(sample(c("a","b","c","d","e","f"), 20, replace=T),"txt")
    plan(multisession)
    jobMapping %<-% {
      semTypesTable
      # pathMapping="./response/1499378334_0685f72e019b14265e98542a33cc1b65.xml"
      parseMapping(pathMapping,pathParsing)
      write("parsing done",file=pathParsingDone)
    }
    
  }else if(stateMapping == "parsingInProgress"){
    if(file.exists(pathParsingDone)){
      stateMapping <<- "parsingDone"
    }
    refreshInfosStatut("Tout le mapping est bien téléchargé ! Le parsing est en maintenant en cours ...")
    statutInDiv<- h4("Parsing en cours ...")
    
  }else if(stateMapping == "parsingDone"){
    statutInDiv<- h4(HTML("Parsing terminé !"))
    refreshInfosStatut("")
    mappingTable<<-read.csv(pathParsing,
                            header = FALSE,
                            col.names = c("PMID","phraseID","token","CUI","concpteName",levels(semTypesTable$aapp)))
    refreshInfosStatut(paste("La table de mapping compte : ",nrow(mappingTable)," lignes"))
    output$parsingTable <- DT::renderDataTable({
      datatable(mappingTable[c(1,2),], 
                selection = 'none',
                rownames = FALSE,
                options=list(
                  bLengthChange = FALSE,
                  searching = FALSE
                )
      )
    })
    stateMapping <<- "resultReady"
    
  }else if(stateMapping == "resultReady"){
    statutInDiv<- h4(HTML("Mapping terminé ! </br> 
                            Les résultats sont disponible dans \"Analyse du mapping\""))
    idMapping <- NULL
  }else if(stateMapping == "noProcess"){
    statutInDiv<- h4("Pas de mapping en cours")
    idMapping <- NULL
  }else if(stateMapping == "error"){
    showModal(modalDialog(
      title = "Lancement du mapping ....",
      div("Quelque chose s'est mal déroulé ! Relancez la procédure !"),
      easyClose = TRUE,
      footer = NULL
    ))
    stateMapping <<- "noProcess"
    refreshInfosStatut("Erreur lors du téléchargement ou lors du lancement du mapping ... Relancez le mapping")
  }
  
  output$statutMapping <- renderUI({
    statutInDiv
  })
  
  
  
  
  
  
  
  
  
})
