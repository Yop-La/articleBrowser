# date création : 03/07/2017
# auteur : alexandre guillemine
# pour parser le résultat du mapping et faire une bdd

# entrée : semtypes
# sortie : base de donnée
# en colonne : PMID, portion de phrase, CUI, concept, SemType, booléen pour savoir si concept dans phrase avec TLS
# en ligne concepts des articles
# attention un même concept dans une même portion de phrase peut avoir plusieurs SemTypes

library(XML)

xmls=list()
file.names = dir("./mapping_results/", pattern =".xml")
for(i in 1:length(file.names)){
  
  xmls[[i]] = xmlParse(paste("./mapping_results/",file.names[i],sep=""))
}



getData=function(){
  retour = character()
  
  
  
  finalDf = data.frame(PMID=character(),
                        phraseText = character(),
                        CUI=character(),
                        concept = character(),
                        semTypes = character(),
                        linkToTLS = logical(),
                        stringsAsFactors = FALSE)
  for(i in 1:length(xmls)){
    
    
    
    xmlPathBase = paste("//Utterance/descendant::Phrase",sep = "")
    
    xmlPathPMID = "//Utterance/PMID"
    xmlPathPhraseText = paste(xmlPathBase,"/PhraseText",sep="")
    xmlPathNbMappings = paste(xmlPathBase,"/Mappings",sep="")
    xmlPathCui = paste(xmlPathBase,"/Mappings/Mapping[position() = 1]/descendant::Candidate/CandidateCUI",sep="")
    xmlPathPreferred = paste(xmlPathBase,"/Mappings/Mapping[position() = 1]/descendant::Candidate/CandidatePreferred",sep="")
    xmlPathSemTypes = paste(xmlPathBase,"/Mappings/Mapping[position() = 1]/descendant::Candidate/descendant::SemType",sep="")
    xmlPathMatched = paste(xmlPathBase,"/Mappings/Mapping[position() = 1]/descendant::Candidate/descendant::MatchedWord",sep="")
    xmlFinal = paste(xmlPathNbMappings,"|",xmlPathPMID,"|",xmlPathCui,"|",xmlPathPhraseText,"|",xmlPathPreferred,"|",xmlPathMatched,"|",xmlPathSemTypes)
    resPhraseText=xpathApply(xmls[[i]],xmlFinal)
    
    row = NULL
    firstUtterance = TRUE
    dfInter=NULL
    hasMappings=FALSE
    isLinkToTls = FALSE
    PMID = NULL
    phraseText = NULL
    
    for (j in seq_along(resPhraseText)){
      xmlNode = resPhraseText[[j]]
      xmlName = xmlName(xmlNode)
      xmlValue = xmlValue(xmlNode)
      xmlAttrs = xmlAttrs(xmlNode)
      
      
      if(xmlName=="PMID"){
        if(!firstUtterance){
          if(isLinkToTls){
            dfInter$linkToTLS[] = TRUE 
            isLinkToTls = FALSE
          }
          finalDf=rbind(finalDf,dfInter) 
        }
        firstUtterance=FALSE
        dfInter = data.frame(PMID=character(),
                              phraseText = character(),
                              CUI=character(),
                              concept = character(),
                              semTypes = character(),
                              linkToTLS = logical(),
                              stringsAsFactors = FALSE)
       
        
        PMID = xmlValue
      }
      if(xmlName=="PhraseText"){
        phraseText = xmlValue
      }
      if(xmlName=="Mappings"){
        if(xmlAttrs["Count"]=="0"){
          hasMappings = FALSE
        }else{
          hasMappings = TRUE
        }
        
      }
      if(hasMappings){
        if(xmlName=="CandidateCUI"){
          row = character(6)
          row[1] = PMID
          row[2] = phraseText
          row[3] = xmlValue
          if(xmlValue == "C4277544"){
            isLinkToTls = TRUE
          }
        }
        if(xmlName=="CandidatePreferred"){
          row[4] = xmlValue
        }
        if(xmlName=="SemType"){
          row[5] = xmlValue
          row[6] = FALSE
          dfInter[nrow(dfInter)+1,]=row
        }
      }
    }
  }
  return(finalDf)
}

df=getData()
save(df,file = "data.RData")

res<-df[df$CUI == "C4277544","PMID"]
length(unique(res))
