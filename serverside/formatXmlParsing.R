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
  titles <- extrctPubmedTitle("pubmedRecord.xml")
  dateCreated <- extrctPDateCreated("pubmedRecord.xml")
  PMID <- extrctPMID("pubmedRecord.xml")
  AbbrJournal<-extrctPAbbrJournal("pubmedRecord.xml")
  ret <- data.frame(
    as.character(PMID),
    as.character(titles),
    as.character(dateCreated),
    as.character(AbbrJournal)
  )
  ret[[3]]<-as.Date(
    sapply(
      ret[[3]],
      function(x) {
        paste(substring(x,c(1,5,7),c(4,6,8)),collapse = "-") 
      }
    )
  )
  colnames(ret)<-c("PMID","title","creationDate","AbbrJournal")
  return(ret)
}

savePAbstract<-function(){
  abstracts <- extrctPubmedAbstract("pubmedRecord.xml")
  save(abstracts,file = "abstracts.RData")  
}

processXmlPubmed<-function(){
  #savePAbstract()
  return(setDataFramePArticles())
}