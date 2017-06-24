# fonctions chargés de parser les xmls renvoyés par les bases Entrez
# créé le 20/06/2017
# ce script est appelé dans server.R. 

# renvoie tous les infos utiles des articles pubmed
extrctPubmedArticle<-function(xmlFile){
  xmlTree<-xmlParse(file=xmlFile)
  abstracts=xpathApply(
    xmlTree,
    "//PubmedArticle",
    formArticle)
  return(abstracts)
}

formArticle<-function(ArticleNode){
  abstract<-formAbstract(ArticleNode)


  titles=xpathSApply(
    ArticleNode,
    "MedlineCitation/Article/ArticleTitle",
    xmlValue,
    simplify=)

  PMID=xpathSApply(
    ArticleNode,
    "MedlineCitation/PMID",
    xmlValue)

  DateCreated=xpathSApply(
    ArticleNode,
    "MedlineCitation/DateCreated",
    xmlValue)

  AbbrJournal=xpathSApply(
    ArticleNode,
    "MedlineCitation/Article/Journal/ISOAbbreviation",
    xmlValue)

  return(c(PMID, titles, DateCreated, AbbrJournal,abstract))
}

# renvoie tous les abstracts d'un fichier xml de pubmed
extrctPubmedAbstract<-function(xmlFile){
  xmlTree<-xmlParse(file="pubmedRecord.xml")
  abstracts=xpathApply(
    xmlTree,
    "//Abstract",
    formAbstract)
  return(abstracts)
}

formAbstract<-function(AbstractNode){
  abstract=xpathSApply(
    AbstractNode,
    "MedlineCitation/Article/Abstract/AbstractText", 
    xmlValue)
  abstract=paste(abstract,collapse = "<br/> <br/>")
  return(abstract)
}


extrctPubmedTitle<-function(xmlFile){
  xmlTree<-xmlParse(file="pubmedRecord.xml")
  titles=xpathApply(
    xmlTree,
    "//ArticleTitle", 
    xmlValue)
  return(titles)
}


extrctPMID<-function(xmlFile){
  xmlTree<-xmlParse(file="pubmedRecord.xml")
  PMID=xpathApply(
    xmlTree,
    "//MedlineCitation/PMID", 
    xmlValue)
  return(PMID)
}

extrctPDateCreated<-function(xmlFile){
  xmlTree<-xmlParse(file="pubmedRecord.xml")
  DateCreated=xpathApply(
    xmlTree,
    "//DateCreated", 
    xmlValue)
  return(DateCreated)
}

extrctPAbbrJournal<-function(xmlFile){
  xmlTree<-xmlParse(file="pubmedRecord.xml")
  AbbrJournal=xpathApply(
    xmlTree,
    "//Journal/ISOAbbreviation", 
    xmlValue)
  return(AbbrJournal)
}
