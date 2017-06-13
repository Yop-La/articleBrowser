# code réactive du panel "Elaboration requete" server side
# créé le 12/06/2017 à 14h51
# ce script est appelé dans server.R. Il utilise d'ailleurs deux variables de server.R que sont :
# output et input de la fonction shinyServer 


#pour lancer la recherche de concept quand sur le bouton "chercher"
get_search_results <- eventReactive(input$search, {
  research_term(input$term)
})

#pour afficher le dans une datable le résultat de la recherche de concept
output$concepts_res <- DT::renderDataTable({
  withProgress(message = 'Recherche des concepts en cours',{
    concepts_table <<- get_search_results()
  })
  
  if(is.null(concepts_table)){
    showModal(modalDialog(
      title = "Aucun résultat !",
      div("Aucun concept correspondant au terme saisi"),
      div("Renouvellez la recherche !"),
      footer = NULL,
      easyClose = TRUE
    ))
  }else{
  colnames(concepts_table)[4] <- c("Nom des concepts")
    datatable(concepts_table, 
              selection = 'single',
              rownames = FALSE,
              options=list(
                searching = FALSE,
                columnDefs = list(list(
                  visible=FALSE, 
                  targets=c(0,1,2)))
              )
    )
  }
})

# pour afficher les définitions et les synonymes du concept cliqué 
observeEvent(input$concepts_res_rows_selected, {
  input$table_rows_selected
  url_info_concept <- concepts_table[input$concepts_res_cell_clicked$row,3]
  info_concept <- get_info_concept(url_info_concept)
  print(info_concept$atoms )
  data_test <<-info_concept$atoms 
})