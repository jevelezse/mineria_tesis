#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(shinythemes)

library(DT)


blc <- read.csv('/home/jennifer/Escritorio/Datos/prueba.csv', stringsAsFactors = FALSE)

ui <- fluidPage(theme = shinytheme("cerulean"),
                h1("Variantes Muestra poblacional Colobiana"),
                mainPanel(
                  p("A new p() command starts a new paragraph. Supply a style attribute to change the format of the entire paragraph."),
                  DT::dataTableOutput("mytable")
                ))

server <- function(input, output) {
  output$mytable = DT::renderDataTable({
    blc
  })
}

shinyApp(ui, server)
