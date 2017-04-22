#
# This is the server logic of a Shiny web application. You can run the 
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#

library(shiny)
library(DT)
library(XML)
library(wordcloud)
library(stringr)
library(stringi)
library(dclone)
library(Hmisc)
library(memoise)
# to load article
con = file("articles_cible.txt", "r")
indiceArticle = 1
indiceElementArticle = 1
articlesBase=list()
article=character()
PMID = NULL
while ( TRUE ) {
  line = readLines(con, n = 1)
  if ( length(line) == 0 ) {
    break
  }
  if(line==""){
    articlesBase[[indiceArticle]] = article
    names(articlesBase)[indiceArticle] = substring(PMID,7)
    article=character(0)
    indiceArticle=indiceArticle+1
    indiceElementArticle=1
  }else{
    if(indiceElementArticle==1){
      PMID = line
      indiceElementArticle=1+indiceElementArticle   
    }else{
      article[indiceElementArticle-1] = line
      indiceElementArticle=1+indiceElementArticle      
    }
    
  }
}

hilightToken<-function(x){
  tokenHighlighted <- x[1]
  tokenHighlighted <- paste(" <strong style=\"color:blue;\"> ",tokenHighlighted," </strong> ",sep="")
  return(tokenHighlighted)
}

percentOfArticle<-function(CUI,df){
  return(round(100*length(unique(df[df$CUI==CUI,"PMID"]))/length(unique(df$PMID)),2))
}

load(file = "data.RData")


getData<-memoise(function(SemTypes, onlyInPhrase){
  df1 <- df
  if(onlyInPhrase){
    df1 <- df[df$linkToTLS==TRUE,]
  }
  if(length(SemTypes)!=0){
    df1 <- df1[grepl(paste(SemTypes,sep="|"),df1$semTypes),]
  }
  return(df1)
})
getNbOccuConcept<-memoise(function(df){
  setProgress(message = "Processing data...")
  nbOccu = table(df$CUI)
  nbOccuDf = data.frame(nbOccu)
  colnames(nbOccuDf) <- c("CUI", "Frequence d'apparition")
  CUIs <- unique(df$CUI)
  percentOfCuiByArticle<- sapply(CUIs,percentOfArticle,simplify=TRUE,df)
  percentOfCuiByArticle <- data.frame(CUI=names(percentOfCuiByArticle),percentByArticle=percentOfCuiByArticle)
  
  statDesCui<-merge(percentOfCuiByArticle, nbOccuDf, by="CUI")
  conceptName <- df[,c("CUI","concept")]
  conceptName <- unique.data.frame(conceptName)
  statDesCui<-merge(conceptName, statDesCui, by="CUI")
  statDesCui$CUI<-NULL
  colnames(statDesCui)<-c("Nom du concept","Pourcentage par article","Fréquence d'apparition")
  statDesCui<-statDesCui[order(statDesCui[[2]],decreasing = T),]
  rownames(statDesCui)<-NULL
  return(statDesCui)
})


getSemType<-function(cell, gngm, aapp){
  Semtypes = c()
  if(cell){
    Semtypes = c(Semtypes,'cell')
  }
  if(gngm){
    Semtypes = c(Semtypes,'gngm')
  }
  if(aapp){
    Semtypes = c(Semtypes,'aapp')
  }
  return(Semtypes)
}

# Define server logic required to draw a histogram
shinyServer(function(input, output) {
  
  
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
    str="Cliquez sur un concept dans l'onglet tab pour voir les articles mentionnant le concept de votre choix ici !",
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
  
})
