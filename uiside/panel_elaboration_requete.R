## code de l'ui du panel "Elaboration de la requête"
## créé le 12/06/2017 à 14h51

tabPanel("Sélection des mots clés",
         fluidPage( 
           sidebarLayout(
             sidebarPanel(
               h4("Que faire ici ?"),
               p("On élabore ici la requête de recherche à soumettre à pubmed. 
                 Il s'agit donc de choisir les concepts à chercher dans les articles de pubmed.
                 Suivez les étapes pour y arriver :)"),
               h4("Step 1 - Recherchez un concept"),
               p("Trouvez ici les concepts à inclure dans la requête."),
               fluidRow(
                 column(9,
                        textInput("term", 
                                  NULL, 
                                  value = "", 
                                  width = NULL, 
                                  placeholder = "Saisir les termes puis cliquez sur go")),
                 column(3,
                        actionButton("search", "Go !"))),
               h4(HTML("Step 3 - Utiliser les concepts choisis")),
               htmlOutput("keyConcepts"),
               actionButton("findArticles", "Lancer la recherche d'articles")
             ),
             mainPanel(
               tabsetPanel(
                 tabPanel("Concept à choisir", 
                          h4("Step 2 - Choisir un concept "),
                          div("Cliquez sur un concept pour le découvrir. Vous pouvez ensuite le choisir avec le bouton \"Ajouter\". On peut ajouter plusieurs concepts en renouvellant Step 1 ou/et Step 2."),
                          HTML("</br>"),
                          fluidRow(
                            column(3,
                                   div(DT::dataTableOutput('concepts_res'),align="center")
                            ),
                            column(9,
                                   fluidRow(
                                     column(6,
                                            div(
                                              strong("Concept sélectionné :"),
                                              htmlOutput("conceptName", inline = TRUE),
                                              HTML("</br>"),
                                              div(
                                                strong("Type sémantique :"),
                                                htmlOutput("semType", inline = TRUE)
                                              )
                                            )
                                            
                                     ),
                                     column(6,
                                            actionButton("addKeyConcept", HTML("Ajouter le concept </br> sélectionné !"))
                                     )
                                   ),
                                   fluidRow(
                                     column(7,
                                            div(
                                              div(DT::dataTableOutput('concept_defs'),align="center")
                                            )
                                            
                                     ),
                                     column(5,
                                            div(
                                              div(DT::dataTableOutput('concept_atoms'),align="center")
                                            )
                                            
                                     )
                                   )
                                   
                                   
                            )
                          )
                 )
               )
             )
           )
         )
)
