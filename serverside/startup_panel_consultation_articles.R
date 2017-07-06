# code du panel "Consultation des articles" server side à chargé au début
# créé le 23/06/2017 à 18h56

articles_research<-NULL #contient les résultats de la recherche d'articles
articles.medline <-"" #contient le chemin vers le fichier contenant les articles au format medline
#contient le chemin vers le fichier contenant 
#les articles au format medline sans caractères non ascii
articles_ascii.medline <- "" 
# devra être remis à NULL à la fin du parsing pour savoir si un future mapping a bien été retrouvé sur le serveur
pathMapping<-""
stateMapping <- "noProcess"
#si idMapping vaut NULL ou -1 au moment du parsage du Mapping, il faudra

pathParsingDone <- ""
pathParsing <- ""
pathDownloadDone <- ""
beginDownload<-NULL
idMapping <- NULL
mappingTable<-data.frame()
