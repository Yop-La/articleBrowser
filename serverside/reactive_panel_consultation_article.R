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
    saveArticlesToMedlineFormat(articles_research,"./articles.medline")
    pathMapping<<-generateFileName(sample(c("a","b","c","d","e","f"), 20, replace=T),"xml")
    plan(multisession)
    jobMapping %<-% ({
      resMapping = mappArticles()
      write(resMapping,file=pathMapping)
      resMapping
    })
    mappingInProgress <<- TRUE
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



observe({
  statutInDiv<- h4("Pas de mapping en cours")
  invalidateLater(10000)
  if(mappingInProgress){
    mappingParsed <<- FALSE
    if(file.exists(pathMapping)){
      statutInDiv<- h4("Mapping terminé")
      mappingInProgress <<- FALSE
      #on fait le parsage du mapping et on stocke le tout dans un dataframe
      mappingParsed<<-TRUE
    }else{
      nitems <- nrow(articles_research)
      # mappingTable<-getMappingStatus()
      # load(file = "tampon.RData")
      # statutMapping <- mappingTable[mappingTable$`NumberOf Items`==nitems & mappingTable$M == "R",c(1,7)]
      statutInDiv<- h4("Mapping en cours ...")
    }
  }else{ # pas de mapping en cours
    if(mappingParsed){
      statutInDiv<- h4(HTML("Mapping terminé ! </br> Les résultats sont disponible dans \"Analyse du mapping\""))
    }
  }
  output$statutMapping <- renderUI({
    statutInDiv
  })
  output$statutTable <- DT::renderDataTable({
    datatable(getMappingStatus(), 
              selection = 'none',
              rownames = FALSE,
              options=list(
                bLengthChange = FALSE,
                searching = FALSE
              )
    )
  })
})
