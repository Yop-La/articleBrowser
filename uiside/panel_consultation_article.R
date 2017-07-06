## code de l'ui du panel "Elaboration de la requête"
## créé le 12/06/2017 à 14h51

tabPanel("Consultation des articles",
         fluidPage( 
           sidebarLayout(
             sidebarPanel(
               h4("Les résultats de votre recherche"),
               p("Ici s'affiche les résultats de la recherche d'articles 
                 lancée dans l'onglet \"sélection des mots clés\". Vous pouvez consulter 
                 les articles en cliquant dessus. Si un article ne convient pas,
                 retirer le de la sélection. Il faudra ensuite lancer le mapping pour
                 analyser les articles"),
               h4("Lancer le mapping des articles"),
               fluidRow(
                 column(12, 
                        align="center",
                        actionButton("startMapping", "Lancer le mapping")
                 )
               ),
               h4("Statut du mapping"),
               div("Le mapping peut durer quelques heures à quelques minutes. 
                   Tout dépend de l'activité sur les serveurs. L'onglet statut du mapping
                    permet d'avoir une estimation du temps restant."),
               div(DT::dataTableOutput('mapping_statut'),align="center")
             ),
             mainPanel(
               tabsetPanel(
                 tabPanel("Résulats de la recherche d'articles", 
                          div(DT::dataTableOutput('articles_research'),align="center")),
                 tabPanel("Statut du mapping", 
                          htmlOutput("statutMapping"),
                          htmlOutput("infosStatut"),
                          div(DT::dataTableOutput('statutTable'),align="center"),
                          div(DT::dataTableOutput('parsingTable'),align="center"))
               )
             )
           )
         )
)