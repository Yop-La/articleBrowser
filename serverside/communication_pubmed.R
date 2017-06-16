# script chargé de requêter pubmed
# créé le 15/06/2017
# ce script est appelé dans server.R. 

# Searching the UMLS - https://documentation.uts.nlm.nih.gov/rest/search/index.html
# Retrieving UMLS Concept Information - https://documentation.uts.nlm.nih.gov/rest/concept/index.html

# plan pour récupérer les abstracts et les textes complets sur pubmed

# 1 - choisir les concepts pour construire la requête ( fait dans élaboration requête) 
# 2 - on élabore la requête en choisisant les concepts (fait après voir cliqué sur élaboration requête)
# 3 - on soumet la requête à Entrez system
#    - 1°) esearch dans pubmed pour récupérer les uid de la requête. On stocke sur server history
#    - 2°) elink pour trouver les uid dans pubmed central. On stocke sur server history
#    - 3°) esearch pour faire une différence entre les 2 requetes précédentes afin de récupérer
#          les uid présent dans pubmed seulement. stocker le résultat sur server history
#   - 4°) efetch ou esummary pour récupérer les enregistrements correspondants
