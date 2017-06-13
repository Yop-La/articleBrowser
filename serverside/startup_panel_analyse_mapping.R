# code du panel "Analyse du mapping" server side à chargé au début
# créé le 12/06/2017 à 14h51


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
  colnames(statDesCui)<-c("Nom du concept","Présence dans les textes (en %)","Nombre d'apparition dans les textes")
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