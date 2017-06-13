#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#

library(shiny)

# Define UI for application that draws a histogram
shinyUI(
  navbarPage("ArticleBrowser",
             
             
             #####################    premier panel    ##############################
             
             
             source("./uiside/panel_elaboration_requete.R", encoding="utf-8")$value,
             
             #####################    deuxième panel    ###############################
             
             tabPanel("Soumission à MetaMap"),

             #####################    troisième panel    ###############################
                          
             source("./uiside/panel_analyse_mapping.R", encoding="utf-8")$value
             
  ) #navBarPage
) #sihnyUI
