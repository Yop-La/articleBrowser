# script chargé au démarrage pour s'authentifier auprès de l'UMLS - délivre les tickets pour utiliser l'UMLS
# script aussi chargé de requêter l'UMLS
# créé le 12/06/2017
# ce script est appelé dans server.R. 

# récupérer un ticket-granting ticket qui est valide 8 heures
# chaque utilisateur en récupéra un au démarrage (on part du principe qu'un client utilisera moins de 8h l'app)
get_gtg<-function(){
  #soumission de la requête
  url <- "https://utslogin.nlm.nih.gov/cas/v1/api-key"
  body <- list(apikey = "d4e57fbf-ba80-4821-92f9-82d51d34f8c6")
  
  r <- POST(url, body=body, encode = "form")
  warn_for_status(r)
  body_rep<-content(r,"text")
  
  #extraction de la réponse
  url_service_ticket<-str_match(body_rep, ".*action=\\\"(.*cas)\"")[, 2] #valid 8 hours
  return(url_service_ticket)
}

# récupérer un ticket de service (utilisable qu'une seule fois)
# ce ticket sera délivré avant l'utilisation d'un service
get_service_ticket<-function(url_service_ticket){
  body_ticket = list(service = "http://umlsks.nlm.nih.gov")
  r <- POST(url_service_ticket, body=body_ticket, encode = "form")
  warn_for_status(r)
  service_ticket<-content(r,"text") #expires after one use or 5 minutes
  return(service_ticket)
}


# lancer une recherche avec mot clé
research_term<-function(search_term){
  retour<-NULL
  url= "https://uts-ws.nlm.nih.gov/rest/search/current"
  save(url_service_ticket,file="url_service_ticket.RData")

  service_ticket = get_service_ticket(url_service_ticket)
  pars = list(ticket=service_ticket, string = search_term)
  save(pars,file="query.RData")

  r<-GET(url,query=pars)
  save(r,file="request.RData")
  warn_for_status(r)
  search_results<-httr::content(r,"text")
  result <- jsonlite::fromJSON(search_results)
  df<-as.data.frame(result$result$results)
  if(df[1,1]!="NONE"){
    retour<-df
  }
  return(retour)
}

#5°) récupérer la définition d'un concept et ses atomes
# on considère le premier concept du tableau de résultat

get_info_concept<-function(url_info_concept){
  service_ticket = get_service_ticket(url_service_ticket)
  query = list(ticket=service_ticket)
  r<-GET(url_info_concept,query=query)
  warn_for_status(r)
  retour = list()
  search_results<-content(r,"text") #résultat de la recherche au format json
  search_results<-fromJSON(search_results)
  
  #infos sur le concept
  retour$concept <- list()
  retour$concept$cui <- search_results$result$ui
  retour$concept$name <- search_results$result$name
  url_def_concept <- search_results$result$definitions
  url_atoms_concept <- search_results$result$atoms
  
  #infos sur le sem type du concept
  retour$semTypes <- data.frame()
  retour$semTypes <- search_results$result$semanticTypes
  
  #infos sur les définitions
  retour$definitions <- data.frame()
  if(url_def_concept == "NONE"){
    retour$definitions <- NULL
  }else{
    # soumisssion de la requête pour avoir les définitions
    search_results <- get_defs_concept(url_def_concept)
    retour$definitions <- search_results$result
  }
  
  #infos sur les synonymes
  retour$atoms <- data.frame()
  if(url_atoms_concept == "NONE"){
    retour$atoms <- NULL
  }else{
    # soumisssion de la requête pour avoir les définitions
    search_results <- get_atoms_concept(url_atoms_concept)
    retour$atoms <- search_results$result
  }
  return(retour)
}

#pour récupérer les définitions d'un concept
get_defs_concept<-function(url_def_concept){
  service_ticket = get_service_ticket(url_service_ticket)
  query = list(ticket=service_ticket)
  r<-GET(url_def_concept,query=query)
  warn_for_status(r)
  search_results<-content(r,"text") #résultat de la recherche au format json
  search_results<-fromJSON(search_results)
  return(search_results)
}

#pour récupérer les définitions des atomes
get_atoms_concept<-function(url_atoms_concept){
  service_ticket = get_service_ticket(url_service_ticket)
  query = list(ticket=service_ticket)
  r<-GET(url_atoms_concept,query=query)
  warn_for_status(r)
  search_results<-content(r,"text") #résultat de la recherche au format json
  search_results<-fromJSON(search_results)
  # on récupère le nombre de pages pour ensuite récupérer tous les atoms
  pageCount <- search_results$pageCount
  # on soumet la même requête en précisant qu'on veux tous les résultats sur une même page
  service_ticket = get_service_ticket(url_service_ticket)
  query = list(ticket=service_ticket, pageSize = pageCount*25, language = "ENG")
  r<-GET(url_atoms_concept,query=query)
  warn_for_status(r)
  search_results<-content(r,"text") #résultat de la recherche au format json
  search_results<-fromJSON(search_results)
  #suppresion d'un element de la liste pour transformation en data.frame
  search_results$result$contentViewMemberships<-NULL  
  return(search_results)
}



url_service_ticket <- get_gtg()
