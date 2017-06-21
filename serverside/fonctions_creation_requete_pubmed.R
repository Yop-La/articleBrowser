# fonctions de contruction des requetes esearch
# ces fonctions prennent une liste de concepts (avec ses atomes) et renvoie requête pubmed à soumettre
# créé le 15/06/2017
# ce script est appelé dans server.R dès que l'utilisateur clique sur "Lancer la recherche d'articles"

getPubmedQuery<-function(key_concepts){
  conceptsPQuery <- sapply(key_concepts, getConceptPQuery)
  conceptPsQuery = paste(conceptsPQuery,collapse = " AND ")
  conceptPsQuery<- gsub(" ","+",conceptPsQuery) # les espace sont encodés par un + dans pubmed
  return(conceptPsQuery)
}

getConceptPQuery<-function(concept){
  termEncoded<-sapply(concept$atoms$name, function(x) {URLencode(x,reserved = TRUE)})
  termEncoded<- gsub("%20","+",termEncoded) # les espace sont encodés par un + dans pubmed
  conceptPQuery = paste(termEncoded,collapse = "\"[All Fields] OR \"")
  conceptPQuery = paste("(\"",conceptPQuery,"\"[All Fields])",sep = "")
  return(conceptPQuery)
}