# fonctions chargés de retourner le statut des jobs soumis au serveur MetaMap
# créé le 30/06/2017
# ce script est appelé dans server.R. 

getMappingStatus<-function(){
  theurl <- getURL("https://ii.nlm.nih.gov/Batch/batch_stats.shtml")
  tables <- readHTMLTable(theurl)
  return(tables[[3]])
}