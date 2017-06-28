# script chargé de requêter pubmed
# créé le 15/06/2017
# ce script est appelé dans server.R. 

eseachUrl = "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/esearch.fcgi?"
elinkhUrl = "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/elink.fcgi?"
efecthUrl = "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?"

# plan pour récupérer les abstracts et les textes complets sur pubmed après avoir saisi un certain nombre
# de concepts

# 1 - choisir les concepts pour construire la requête ( fait dans élaboration requête) 
# 2 - on élabore la requête en choisisant les concepts (fait après voir cliqué sur élaboration requête)
# 3 - on soumet la requête à Entrez system
#    - 1°) esearch dans pubmed pour récupérer les uid de la requête. On stocke sur server history
#    - 2°) elink pour trouver les uid dans pubmed central. On stocke sur server history
#    - 3°) esearch pour faire une différence entre les 2 requetes précédentes afin de récupérer
#          les uid présent dans pubmed seulement. stocker le résultat sur server history
#   - 4°) efetch ou esummary pour récupérer les enregistrements correspondants

#étape 3 - 1 : esearch pour trouver les articles correspondant aux concepts saisies
# ici pQueryEncoded représente la requête pubmed (on pourrait presque la saisir dans pubmed si 
#elle avait pas été encodé  pour envoi par http)
pSearchTerms<-function(key_concepts){
  pQueryEncoded <- getPubmedQuery(key_concepts)
  r<-GET(paste(eseachUrl,
               paste("db=pubmed",
                     paste("term",pQueryEncoded,sep = "="),
                     "usehistory=y",
                     "retmode=json",
                     sep="&"),
               sep = "?")
  )
  warn_for_status(r)
  res_esearch<-content(r,"text") #résultat de la recherche au format json
  res_esearch <- fromJSON(res_esearch)
  # la strucutre après passage dans fromJSON retournée par esearch est une liste de 2 élements :
  #   - $header : $type ,$version
  #   - $esearchresult : $count, $retmax, $retstart, $querykey, $webenv, $idlist, $translationset,
  #     translationstack (tableau qui donne les résulats de chaque élements de la requête).
  #     En effet, la requee est décomposé en requête élementaire
  #     et ce tableau donne pour chaque requête élementaire :
  #         $term, $field, $count, $explode
  res_esearch <- res_esearch[[2]]
  res_esearch$toomucharticle <- FALSE
  if(as.integer(res_esearch$count) > 10000){
    res_esearch$toomucharticle <- TRUE  
  }
  return(res_esearch)
}

#étape 3 - 2 : elink pour récupérer tous les uid des articles de l'étape 3-1 existants dans pubmed central
# c'est à dire les articles complets correspondants aux concepts sélectionnées. Cette requête va utiliser
# les uid de la la requête esearch écrite en 3 - 1 et stocké sur le server story

# elink.fcgi?dbfrom=initial_databasedb=target_database&WebEnv=webenv&query_key=key

#cette fonction trouve les PMCID des articles PubmedCentral dans une liste de PMID d'articles de Pubmed
# enregistré sur le server history par esearch et enregistre le tout sur le server history
linkPMCID<-function(webenv,querykey){
  r<-GET(paste(elinkhUrl,
               paste(
                 "cmd=neighbor_history",
                 "dbfrom=pubmed",
                 "db=pmc",
                 paste("WebEnv",webenv,sep = "="),
                 paste("query_key",querykey,sep = "="),
                 linkname="pubmed_pmc",
                 sep="&"),
               sep = "")
  )
  warn_for_status(r)
  res_esearch<-content(r,"text") #résultat de la recherche au format json
  res_esearch <- xmlToList(res_esearch)
  # la strucutre après passage dans xmlToList retournée par efecth est une liste de 7 élements :
  #   - $DbFrom
  #   - $IdList ( la liste des  id de la bdd de départ)
  #   - 4élements avec cette structure $LinkSetDbHistory : $DbTo, $LinkName, $QueryKey
  #     - ces élements correspondent aux différents liens possibles entre les bdd
  #     - le lien d'intérêt est ici : "pubmed_pmc" -> 1er élement des 4
  #   - $WebEnv
  
  #     translationstack (tableau qui donne les résulats de chaque élements de la requête).
  #     En effet, la requee est décomposé en requête élementaire
  #     et ce tableau donne pour chaque requête élementaire :
  #         $term, $field, $count, $explode
  return(res_esearch)
}

#cette fonction permet récupérer les articles de pubmed ou pudmed central
# grâce à une liste de pmid ou de pmcid sur server history
downloadArticlesWithUi<-function(db, webenv, querykey){
  r<-GET(paste(efecthUrl,
               paste(
                 paste("db",db,sep = "="),
                 "retmode=xml",
                 paste("WebEnv",webenv,sep = "="),
                 paste("query_key",querykey,sep = "="),
                 sep="&"),
               sep = "")
  )
  warn_for_status(r)
  res_efecth<-content(r,"text") #résultat de la recherche au format json
  articles.xml<<-generateFileName(res_efecth,"xml")
  write(res_efecth,file=articles.xml)
}