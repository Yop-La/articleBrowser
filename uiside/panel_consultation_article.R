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
               htmlOutput("statutMapping", inline = FALSE)
             ),
             mainPanel(div(DT::dataTableOutput('articles_research'),align="center"))
           )
         )
)
