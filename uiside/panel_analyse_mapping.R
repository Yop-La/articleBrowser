# code de l'ui du panel "Analyse du mapping"
# créé le 12/06/2017 à 14h51

tabPanel("Analyse du mapping", 
         fluidPage(
           tags$head(
             tags$style(HTML("
                             img{
                             border: 1px solid black;
                             padding : 0px
                             marging : 0px;
                             max-width: 80%; 
                             width: 80%; 
                             height: auto;
                             }"
             )
             )
           ),
           sidebarLayout(
             
             sidebarPanel(
               h4("C'est quoi ?"),
               p("ArticleBrowser permet de naviguer parmi les concepts des 129 textes taggués 'TLS' de PubMed. 
                 Il permet de connaître le nombre d'occurence des concepts dans ces 129 articles 
                 mais aussi d'afficher les articles contenant un certain concept. 
                 Les critères ci dessous permettent de spécifier les concepts à considérer
                 (ils sont tous considérés par défaut)"),
               h4("Resteindre à un ou plusieurs types sémantique"),
               p("L'onglet 'type sémantique' permet de spécifier la ou les familles de concept à considérer. 
                 Par défaut, tous les concepts sont considérés. 
                 Cela permet de ne considérer que les concepts de la famille cellule par exemple."),
               inputPanel(
                 checkboxInput("cell", "Cell", value = FALSE, width = NULL),
                 checkboxInput("gngm", "Gene or Genome", value = FALSE, width = NULL),
                 checkboxInput("aapp", "Amino Acid, Peptide, or Protein", value = FALSE, width = NULL)
               ),
               h4("Resteindre les concepts au phrase taggués 'TLS"),
               p("Cette option permet de resteindre les concepts à ceux contenus dans les phrases contenant 
                 le concept 'TLS' (par défaut, tous les concepts sont considérés).
                 Cette option permet de mesurer la force d'association du concept TLS à d'autres concepts"),
               inputPanel(
                 checkboxInput("phrase", "Phrase with concept", value = FALSE, width = NULL)
               )
             ),
             
             mainPanel(
               tabsetPanel(
                 tabPanel("CloudWord", 
                          h3("Nuage de mots des fréquences d'apparition des concepts"),
                          div("C'est un nuage dynamique qui se met à jour en fonction des critères spécifiés.
                     Le tableau de données correspondant à ce nuage de mots se trouve dans l'onglet tab."),
                          div(img(plotOutput('plot')),align="center")), 
                 tabPanel("Tab", 
                          h3("Tableau des fréquences d'apparition des concepts"),
                          div("C'est un tableau dynamique qui se met à jour en fonction des critères spécifiés.Ce tableau de données donne la fréquence d'apparition des concepts en fonction des critères. Cliquez sur un concept pour afficher les articles mentionnant ce concept dans l'onglet articles. PS : vous pouvez trier ce tableau et faire des recherches dedans. Bonne recherche :)"),
                          div(DT::dataTableOutput('table'),align="center")), 
                 tabPanel("Textes", 
                          h3("Textes contenant le concept en surbrillannce de l'onglet Tab"),
                          div("Il sera bientôt possible de supprimer les textes pas pertinents afin de ne sélectionner 
                     que ceux qui comptent. Est ce une fonctionnalité intéressante ?"),
                          htmlOutput("htmlArticles"))
               )
             )
             
           )
         )
)