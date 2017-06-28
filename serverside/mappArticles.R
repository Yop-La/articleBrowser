# fonctions chargés de faire le mapping des articles
# créé le 26/06/2017
# ce script est appelé dans server.R. 


removeNonAsciiCharacter<-function(file){
  articles_ascii.medline<<-generateFileName("articles_ascii.medline","medline")
  shell_command <- paste("java -jar replace_utf8.jar",file,">",articles_ascii.medline,sep=" ")
  system(shell_command)
}

mappArticles<-function(){
  #pour gérer les caractères non ASCII
  print("dedans")
  removeNonAsciiCharacter(articles.medline)
  .jinit('.')
  .jaddClassPath(dir( "./lib/", full.names=TRUE ))
  obj=.jnew("TextMapper")
  res=.jcall(obj,"Ljava/lang/String;","mapp",as.character(articles_ascii.medline))
  return(res)
}
