# fonctions chargés de mettre les articles au format MedLine
# créé le 26/06/2017
# ce script est appelé dans server.R. 


saveArticlesToMedlineFormat<-function(dataframe){
  toSave<-apply(X = dataframe, 
        MARGIN = 1, 
        FUN = function(x){
          PMID = paste("PMID",x[1],sep="- ")
          title = paste("TI  ",x[2],sep="- ")
          abstract = paste("AB  ",x[5],sep="- ")          
          abstract = paste(abstract,"\n",sep="")
          return(c(PMID,title,abstract))
        })
  articles.medline<-generateFileName(toSave,"medline")
  write(toSave, articles.medline,sep="\n")
  return(articles.medline)
}


