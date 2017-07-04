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
    saveArticlesToMedlineFormat(articles_research,"./articles.medline")
    pathMapping<<-generateFileName(sample(c("a","b","c","d","e","f"), 20, replace=T),"xml")
    pathDownloadDone<<-generateFileName(sample(c("a","b","c","d","e","f"), 20, replace=T),"text")
    plan(multisession)
    jobMapping %<-% {
      mappArticles(pathMapping)
      write("mapping downloaded",file=pathDownloadDone)
    }
    stateMapping <<- "mappingInProgress"
  }
})



observe({
  invalidateLater(5000)
  tableStatus<-data.frame()
  parsingTable<-data.frame()
  if(stateMapping == "mappingInProgress"){
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
  }
  
  
  if(stateMapping == "mappingInProgress"){
    statutInDiv<- h4("Mapping en cours ...")
    if(file.exists(pathMapping)){
      stateMapping <<- "downloadInProgress"
      startDownload <<- Sys.time()
    }
    
  }else if(stateMapping == "downloadInProgress"){
    
    output$statutTable <- DT::renderDataTable({
      datatable(data.frame(), 
                selection = 'none',
                rownames = FALSE,
                options=list(
                  bLengthChange = FALSE,
                  searching = FALSE
                )
      )
    })
    
    statutInDiv<- h4("Téléchargement en cours ...")
    sizeMapping <- utils:::format.object_size(file.size(pathMapping), "auto")
    dureeDownload <- difftime(
      Sys.time(),
      startDownload, 
      units = "mins"
    )
    debit<-
      debit<- utils:::format.object_size((file.size(pathMapping)/as.double(dureeDownload)), 
                                         "auto")
    
    output$infosDownload <- renderUI({
      HTML(paste(
        paste(sizeMapping, " téléchargé sur 169 M en ",dureeDownload," minutes",sep=""),
        paste("Soit ",debit," par minute.",sep=""),
        sep="</br> "
      ))
    })
    
    
    
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
      parseMapping(pathMapping,pathParsing)
      write("parsing done",file=pathParsingDone)
    }
    
  }else if(stateMapping == "parsingInProgress"){
    if(file.exists(pathParsingDone)){
      stateMapping <<- "parsingDone"
    }
    statutInDiv<- h4("Parsing en cours ...")
    
  }else if(stateMapping == "parsingDone"){
    statutInDiv<- h4(HTML("Parsing terminé !"))
    parsingTable <- read.csv(pathParsing,header = FALSE)
    parsingTable<-unique.data.frame(parsingTable)
    output$parsingTable <- DT::renderDataTable({
      datatable(parsingTable, 
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
  }else if(stateMapping == "noProcess"){
    statutInDiv<- h4("Pas de mapping en cours")
  }
  
  output$statutMapping <- renderUI({
    statutInDiv
  })
  
  
  
  
  
  
  
})
