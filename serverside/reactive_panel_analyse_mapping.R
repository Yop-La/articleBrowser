# code réactive du panel "Analyse du mapping" server side
# créé le 12/06/2017 à 14h51
# ce script est appelé dans server.R. Il utilisent d'ailleurs deux variables de server.R que sont :
# output et input de la fonction shinyServer 

getAllData <- reactive({
  input$cell
  input$gngm 
  input$aapp
  input$phrase
  isolate({
    withProgress({
      setProgress(message = "Processing data...")
      semTypes<-getSemType(input$cell, input$gngm, input$aapp)
      df <- getData(semTypes, input$phrase)
      df
    })
  })
  
})

getNbOccurenceConcept <- reactive({
  df<-getAllData()
  isolate({
    withProgress({
      nbOccuDf<-getNbOccuConcept(df)
      
    })
  })
  
  
})

output$plot <- renderImage({
  
  outfile <- tempfile(fileext='.png')
  
  png(outfile, width=1000, height=1000)
  
  
  nbOccuDf = getNbOccurenceConcept()
  wordcloud(nbOccuDf[[1]], nbOccuDf[[3]], scale=c(5,0.5),
            min.freq = 2,max.words = 100,
            colors=brewer.pal(8, "Dark2"))
  dev.off()
  
  # Return a list containing the filename
  list(src = outfile,
       width = 1000,
       height = 1000,
       alt = "This is alternate text")
  
  
  
}, deleteFile = TRUE)

output$table <- DT::renderDataTable({
  dfNbOccu <- getNbOccurenceConcept()
  datatable(dfNbOccu[,c(1,2,3)], selection = 'single',rownames = FALSE)
  
})

# pour afficher les articles contenant le concept sélectionné dans le dataframe

articlesResult <- reactiveValues(
  str="Cliquez sur un concept dans l'onglet tab pour voir les textes mentionnant le concept de votre choix ici !",
  empty=TRUE
)

getArticles <- reactiveValues(articlesHiglighted=NULL)

output$htmlArticles<-renderUI({
  if(articlesResult$empty){
    articlesResult$str
  }else{
    articlesToPrint = character() 
    indicesArticles = articlesResult$indicesArticles
    articlesHiglighted = getArticles$articlesHiglighted
    #   allPMID = "|"
    for(i in 1:length(indicesArticles)){
      articlesToPrint[i] = paste(articlesHiglighted[[indicesArticles[i]]],collapse = "<br/>")
      PMID = paste("PMID -",indicesArticles[i],sep="")
      #      allPMID = paste(allPMID,indicesArticles[i],"|",sep = "")
      articlesToPrint[i] = paste(PMID,articlesToPrint[i],sep = "<br/>")
    }
    
    
    #  fileConn<-file("tampon.txt")
    #  writeLines(allPMID, fileConn)
    #  close(fileConn)
    HTML(paste(articlesToPrint,collapse = "<br/><br/>"))
  }
})

observeEvent(input$table_rows_selected, {
  #get the dataframe of the NbOccurenceConcept
  dfNbOccu <- getNbOccurenceConcept()
  
  #get the concept clicked
  
  concept = dfNbOccu[[1]][input$table_rows_selected]
  
  showModal(modalDialog(
    title = paste("Recherche du concept '",concept,"' dans la base d'articles"),
    "Les articles correspondants sont visibles dans l'onglet \"articles\"",
    easyClose = TRUE,
    footer = NULL
  ))
  
  #get the token and the words related to the concept
  allData <- getAllData()
  
  ConceptTokenWords = allData[which(allData$concept == concept),c("phraseText","PMID")]
  #highligth the words related to the concept in the token
  res=apply(ConceptTokenWords,MARGIN = 1,hilightToken)
  ConceptTokenWords$highLighted<-res
  
  #replace the token in artible by the token highlighted
  
  getArticles$articlesHiglighted = dclone(articlesBase)#get the article
  articlesHiglighted = getArticles$articlesHiglighted
  indicesArticle = unique(ConceptTokenWords$PMID)
  
  
  for(i in 1:length(indicesArticle)){
    PMID = indicesArticle[i]
    #get the original and higlighted token
    tokens<-ConceptTokenWords[which(ConceptTokenWords$PMID == PMID),c("phraseText","highLighted")]
    for(j in 1:nrow(tokens)){
      #replace by the token highlighted
      article = articlesHiglighted[[PMID]]
      articlesHiglighted[[PMID]] = str_replace_all(article,regex(escapeRegex(tokens$phraseText[j]),ignore_case = TRUE),regex(tokens$highLighted[j]))      
    }
  }
  getArticles$articlesHiglighted = articlesHiglighted
  articlesResult$indicesArticles <- indicesArticle
  articlesResult$empty = FALSE
  
})