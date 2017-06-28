# fonctions chargés gérer les fichiers localement (sauvegarde, chargement, supression)
# créé le 28/06/2017
# ce script est appelé dans server.R. 

generateFileName <- function(data,extension) {
  # Create a unique file name
  fileName <- sprintf(paste("%s_%s",extension,sep="."), as.integer(Sys.time()), digest::digest(data))
  # return the file to the local system
  fileName <- file.path("response", fileName)
  return(fileName)
}
