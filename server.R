#
# This is the server logic of a Shiny web application. You can run the 
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#
#
library(shiny)
library(DT)
library(XML)
library(wordcloud)
library(stringr)
library(stringi)
library(dclone)
library(Hmisc)
library(memoise)
library(httr)
library(rjson)
library(jsonlite)
library(rJava)
library(future)
library(mailR)


source("./serverside/communication_umls.R", encoding="utf-8")
source("./serverside/fileManager.R",local=TRUE, encoding="utf-8")

# Define server logic required to draw a histogram
shinyServer(function(input, output, session) {
  # source("./serverside/startup_panel_analyse_mapping.R", encoding="utf-8")
  source("./serverside/startup_panel_elaboration_requete.R", encoding="utf-8")
  source("./serverside/startup_panel_consultation_articles.R", encoding="utf-8")
  
  
  # source("./serverside/reactive_panel_analyse_mapping.R",local=TRUE, encoding="utf-8")
  source("./serverside/reactive_panel_elaboration_requete.R",local=TRUE, encoding="utf-8")
  source("./serverside/reactive_panel_consultation_article.R",local=TRUE, encoding="utf-8")
  
})
