# fonctions chargés de mettre en forme le parsage xml renvoyés les fonctions xmlParser.R
# but : enregistrer les résultas de parsing sous la forme de dataframe
# créé le 20/06/2017
# ce script est appelé dans server.R. 


# pour mettre en forme un dataframe qui contient
#   - le titre des articles pubmed 
#   - le PMID des articles pubmed 
#   - la date de création des articles pubmed 
# cela concerne les articles renvoyés par la recherche d'articles
setDataFramePArticles<-function(){
  articles <- extrctPubmedArticle(articles.xml)
  ret <- data.frame(matrix(unlist(articles), 
                                 nrow=length(articles), 
                                 byrow=T),stringsAsFactors = FALSE)

  ret[[3]]<-as.Date(
    sapply(
      ret[[3]],
      function(x) {
        paste(substring(x,c(1,5,7),c(4,6,8)),collapse = "-") 
      }
    )
  )
  colnames(ret)<-c("PMID","title","creationDate","AbbrJournal","Abstract")
  return(ret)
}

processXmlPubmed<-function(){
  tab_articles<-setDataFramePArticles()
  return(tab_articles)
}