session$onSessionEnded(function(){
  print("Lancement du mapping")
  if(ordreMapping){
    ret<-mappArticles()  
    print(ret)
  }
  print("Mapping terminé")
  stopApp()
})