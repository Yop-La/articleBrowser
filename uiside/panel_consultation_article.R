## code de l'ui du panel "Elaboration de la requête"
## créé le 12/06/2017 à 14h51

tabPanel("Consultation des articles",
         fluidPage( 
           sidebarLayout(
             sidebarPanel(
               h4("Les résultats de votre recherche"),
               p("Ici s'affiche les résultats de la recherche d'articles 
                 lancée dans l'onglet \"sélection des mots clés\"")
             ),
             mainPanel(div(DT::dataTableOutput('articles_research'),align="center"))
           )
         )
)
