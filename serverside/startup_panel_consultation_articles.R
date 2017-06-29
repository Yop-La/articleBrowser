# code du panel "Consultation des articles" server side à chargé au début
# créé le 23/06/2017 à 18h56

articles_research<-NULL #contient les résultats de la recherche d'articles
articles.medline <-"" #contient le chemin vers le fichier contenant les articles au format medline
#contient le chemin vers le fichier contenant 
#les articles au format medline sans caractères non ascii
articles_ascii.medline <- "" 
ordreMapping <- FALSE #pour lancer le mapping à la fermeture de l'application

