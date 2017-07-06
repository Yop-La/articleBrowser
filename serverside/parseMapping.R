# date création : 03/07/2017
# auteur : alexandre guillemine
# pour parser le résultat du mapping et faire une bdd

# entrée : semtypes
# sortie : base de donnée
# en colonne : PMID, portion de phrase, CUI, concept, SemType, booléen pour savoir si concept dans phrase avec TLS
# en ligne concepts des articles
# attention un même concept dans une même portion de phrase peut avoir plusieurs SemTypes


# Description de la lecture à faire :
#   
#   parcourir chaque balise Utterance
#     récupérer le <PMID>
#     récupérer <UttText> pour générer un identifiant de UttText
#     aller dans la balise <Phrases>
#       parcourir chaque <Phrase>
#         récupérer <PhraseText>
#           Aller dans la balise <Mappings>
#             Aller dans la première baslise <Mapping>
#               Aller dans la balise <MappingCandidates>
#                 Parcourir chaque <Candidate> ->>>> new row
#                   Récupérer <CandidateCUI>
#                   Récupérer <CandidateMatched>
#                   Aller dans <SemTypes>
#                     Parcourir <SemType> et récupérer le text
#         
write.row.csv<-function(row,pathParsing){
  write(paste('"',paste(row,collapse='","'),'"',sep=""),
        pathParsing,
        append = TRUE)
}

setSemTypes<-function(row,semType){
  firstIndiceSemTypes <- 6 # à changer si on ajoute des éléments à la ligne
  allSemTypes <-semTypesTable$aapp
  rowSemTypesToAdd <- allSemTypes == semType
  nbSemTypes <- length(allSemTypes)
  if(length(row) < nbSemTypes){
    return(c(row,rowSemTypesToAdd))
  }else{
    
    rowSemTypes = row[firstIndiceSemTypes:(firstIndiceSemTypes-1+nbSemTypes)]
    
    
    rowSemTypes = rowSemTypesToAdd | as.logical(rowSemTypes)
    row[firstIndiceSemTypes:(firstIndiceSemTypes-1+nbSemTypes)] <- rowSemTypes
  }
  return(row)
}

parseMapping<-function(pathMapping,pathParsing){
  if(file.exists(pathParsing)){
    file.remove(pathParsing)
  }
  file.create(pathParsing)
  xmlEventParse(pathMapping,
                handlers = list(
                  startElement=function(name, attrs,.state = state){
                    .state$name<- name
                    
                    
                    if(name == "UttText"){
                      .state$idUttText = .state$idUttText + 1
                      .state$row[2] <- .state$idUttText
                    }
                    
                    if(name == "Mappings"){
                      .state$inFirstMapping = FALSE
                      .state$indiceMapping = 0
                      
                    }
                    
                    if(name == "Mapping"){
                      .state$indiceMapping = .state$indiceMapping + 1
                      if(.state$indiceMapping == 1){
                        .state$inFirstMapping = TRUE
                      }else{
                        .state$inFirstMapping = FALSE
                      }
                      
                    }
                    
                    if(name == "SemTypes" & .state$inFirstMapping){
                      .state$nbSemType = attrs[1]
                      .state$indiceSemType = 0
                      if(.state$nbSemType == 0){
                        .state$row <- setSemTypes(.state$row,"pasunsemtype")
                        write.row.csv(.state$row,pathParsing)
                        .state$row=.state$row[1:5]
                      }
                    }
                    
                    
                    .state
                  },
                  text=function(content,.state = state){
                    
                    if(.state$name=="PMID"){
                      .state$row[1] <- content
                      
                    }
                    
                    if(.state$name=="PhraseText"){
                      .state$row[3] <- content
                    }
                    
                    if(.state$name=="CandidateCUI" & .state$inFirstMapping){
                      .state$row[4] <- content
                    }
                    if(.state$name=="CandidateMatched" & .state$inFirstMapping){
                      .state$row[5] <- content
                    }
                    if(.state$name=="SemType" & .state$inFirstMapping){
                      .state$row <- setSemTypes(.state$row,content)
                      .state$indiceSemType = .state$indiceSemType + 1
                      if(.state$nbSemType==.state$indiceSemType){
                        write.row.csv(.state$row,pathParsing)
                        .state$row=.state$row[1:5]
                      }
                    }
                    
                    
                    .state
                  }
                  # ,
                  # endElement=function(name, attrs,state=.state){
                  #   if(name=="SemTypes"){
                  # 
                  #   }
                  #   .state
                  # }
                ),
                state = list(idUttText=0,row=character(1),inFirstMapping=FALSE,count=0))
}

                     
                     
    # finalDf = data.frame(PMID=character(),
    #                      phraseText = character(),
    #                      CUI=character(),
    #                      concept = character(),
    #                      semTypes = character(),
    #                      linkToTLS = logical(),
    #                      stringsAsFactors = FALSE)
    # 
