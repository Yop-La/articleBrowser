# script de fonctions implémentant des pipeline de données depuis les bases Entrez du NCBI
# et vers ces même bases ou shiny
# créé le 16/06/2017
# ce script est appelé dans server.R. 


# trouve tous les pmid d'articles mentionnant les concepts clés passés en paramètres
# la recherche se fait sur pubmed
# on récupère tous les pmid sur pubmed 
# enregistre le résultat sur server history
findPMIDArticles<-function(concepts_key){
  res_esearch <- pSearchTerms(concepts_key) #on stocke tous les PMID sur server history
  if(res_esearch$toomucharticle){
    return(NULL)
  }
  return(res_esearch)
}


# trouve tous les articles mentionnant les concepts clés
# ces fonctions renvoie pour chaque article mentionnant les concepts clés
#   - son abstract et son title sur pubmed
#   - l'article complet si il est aussi sur pubmed central
getXmlPubmedArticles<-function(concepts_key){
  res_esearch <- findPMIDArticles(concepts_key)
  if(is.null(res_esearch)){
    return(NULL)
  }
  downloadArticlesWithUi("pubmed", res_esearch$webenv, res_esearch$querykey)
  return(res_esearch)
}

# # trouve tous les uid d'articles mentionnant les concepts clés passés en paramètres
# # la recherche se fait d'abord sur pubmed
# # on récupère tous les pmid sur pubmed 
# # on récupère ensuite les pmcid des articles présent sur pubmedcentral
# # si un article est présent sur pubmed et pubmed central, on récupère son PMID et son PMCID
# # un article aura donc un pmid et un pmcid si il est sur pubmed central
# # sinon il aura jsute un pmid
# 
# findUIDArticles<-function(concepts_key){
#   res_esearch <- pSearchTerms(concepts_key) #on stocke tous les PMID sur server history
#   if(res_esearch$toomucharticle){
#     return(NULL)
#   }
#   res_elink <- linkPMCID(res_esearch$webenv,res_esearch$querykey)
#   return(list(res_esearch=res_esearch,res_elink=res_elink))
# }
# 
# 
# # trouve tous les articles mentionnant les concepts clés
# # ces fonctions renvoie pour chaque article mentionnant les concepts clés
# #   - son abstract et son title sur pubmed
# #   - l'article complet si il est aussi sur pubmed central
# findArticles<-function(concetps_key){
#   uidArticles <- findUIDArticles(concetps_key)
#   if(is.null(uidArticles)){
#     return(NULL)
#   }
#   res_esearch <- uidArticles[[1]] #contient un webenvironnement avec les pmid
#   res_elink <-   uidArticles[[2]] #contient un webenvironnement avec les pmcid
#   downloadArticlesWithUi("pubmed", res_esearch$webenv, res_esearch$querykey)
#   return(uidArticles)
# }



