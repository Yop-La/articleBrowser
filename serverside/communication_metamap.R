# fonctions chargés de retourner le statut des jobs soumis au serveur MetaMap
# créé le 30/06/2017
# ce script est appelé dans server.R. 

getMappingStatus<-function(){
  theurl <- getURL("https://ii.nlm.nih.gov/Batch/batch_stats.shtml")
  tables <- readHTMLTable(theurl)
  return(tables[[3]])
}

setIdMapping<-function(tableStatus){
  nitems <- nrow(articles_research)
  idsMapping <- as.character(tableStatus[tableStatus$NumberOfItems == nitems,c(1)])
  if(is.null(idMapping)){ #idMapping pas encore défini
    if(length(idsMapping) == 1){
      idMapping <<- idsMapping
    }else if(length(idsMapping ) >= 2){
      idMapping <<- -1 
    }
  }
  return(idMapping)
}

connectToUMLS<-function(){
  url <- "https://utslogin.nlm.nih.gov/cas/login"
  r <- GET(url)
  body <- list("username" = "aarnoux",
               password="%Fabrice00",
               lt	= "e1s1",
               "_eventId" =	"submit",
               submit	= "Sign+In"
  )
  
  r <- POST(url, body=body, encode = "form")
  return(r)
}

downloadResMapping<-function(idMapping){
  if(idMapping != -1 & !is.null(idMapping)){
    pathMapping<<-generateFileName(sample(c("a","b","c","d","e","f"), 20, replace=T),"xml")
    cookies_rconnect<-cookies(connectToUMLS())  
    
    urlGetXml <- paste(
      "https://ii.nlm.nih.gov/Scheduler/foo",
      idMapping,
      sep="/"
    )
    
    r <- GET(
      urlGetXml
    )
    
    url <- r$all_headers[[1]]$headers$location
    cookies <- cookies(r)
    r <- GET(url,
             set_cookies(
               JSESSIONID=cookies_rconnect[1,"value"],
               CASTGC=cookies_rconnect[2,"value"]
               
             ),
             write_disk(pathMapping,overwrite = TRUE)
             
    )
    return(TRUE)
  }else{
    pathMapping<<-NULL
    return(FALSE)
  }
}