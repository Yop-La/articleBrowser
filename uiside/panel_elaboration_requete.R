# code de l'ui du panel "Elaboration de la requête"
# créé le 12/06/2017 à 14h51

tabPanel("Sélection des mots clés",
         fluidPage( 
           sidebarLayout(
             sidebarPanel(
               h4("Que faire ici ?"),
               p("On élabore ici la requête de recherche à soumettre à pubmed. Il s'agit donc de choisir les concepts à chercher dans pubmed."),
               h4("Recherchez un concept"),
               p("Trouver ici les concepts à inclure dans la requête."),
               fluidRow(
                 column(9,
                        textInput("term", 
                                  NULL, 
                                  value = "", 
                                  width = NULL, 
                                  placeholder = "Saisir votre terme puis cliquez sur rechercher")),
                 column(3,
                        actionButton("search", "Rechercher"))),
               h4("Les concepts choisis"),
               selectizeInput("inputId", 
                              label= "Concepts à trouver dans les textes", 
                              choices = c("machin","truc"), 
                              selected = c("machin","truc"), 
                              multiple = TRUE,
                              options = NULL)
             ),
             mainPanel(
               tabsetPanel(
                 tabPanel("Concept à choisir", 
                          h3("Résultats de la recherche de concepts"),
                          div("Ici s'affiche l'ensemble des concepts correspondants aux termes saisies \"Recherchez un concept \""),
                          HTML("</br>"),
                          fluidRow(
                            column(3,
                                   div(DT::dataTableOutput('concepts_res'),align="center")
                            ),
                            column(9,div("texte"))
                          )
                 )
               )
             )
           )
         )
)