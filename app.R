#
# Code relating to the preprints in response to COVID-19 timeline 
# Maintained by the team @preLights
# 
# Last update: 30/03/2020
#
# Jonny Coates, jc2216@cam.ac.uk

#Load relevant libraries
library(shiny)
library(timevis)

#Import data
readRDS("final_data.rds") -> final_data
readRDS("infotable.rds") -> info_table
readRDS("resources.rds") -> resources


#Define UI
shinyApp(
  ui = navbarPage("Preprints & COVID-19",
                  tabPanel("Timeline",
                           fluidPage(
                             
                             titlePanel("Landmark preprints in response to COVID-19, maintained by the @preLights team"),
                             
                             tags$style(
                               ".event { background: darksalmon; }
      .preprint { background: darkturquoise; }
      .bad { background: moccasin; }"
                             ),
                             timevisOutput("timeline"),
                             
                             #Add buttons to allow user to control view
                             actionButton("btn", "Fit all items"),
                             actionButton("btn2", "Center on first reported case"),
                             actionButton("btn3", "Center on 1st Feb"),
                             actionButton("btn4", "Center on 1st March"),
                             
                             #Add rows underneath containing additional text
                             br(),
                             br(),
                             
                             fluidRow(
                               column(2,
                                      h4(" ")),
                               h3("Key: Orange = Event, Teal = Preprint, yellow = Important caveat/comment on preprint (see table). Last updated: 30/03/2020")),
                             
                             #br(),
                             
                             fluidRow(
                               column(2,
                                      h4("")),
                               br(),
                               h3("This work is being maintained by Gautam Dey, Srivats Venkataramanan, Sundar Naganathan, Debbie Ho, Zhang-He, Kirsty Hooper, Lars Hubatsch, Mariana De Niz, Sejal Davla, Mate Palfy & Jonny Coates. For questions or queries please contact prelights@biologists.com")),
                             
                             br(),
                             
                             fluidRow(
                               column(2,
                                      h4("")),
                               h4("To use the timeline, navigate by clicking and dragging or through the use of the buttons. Hovering the mouse over an item will reveal more details pertaining to that point. Navigate between the timeline view and the table view using the navigation buttons at the top of this page")),
                           
                             br(),
                             
                             img(src = "prelights.png", height = 70, width = 200),
                             
                             fluidRow(
                               column(2,
                                      h4("")),
                               p("preLights is a community service supported by The Company of Biologists, the not-for-profit publisher of Development, Journal of Cell Science, Journal of Experimental Biology, Disease Models & Mechanisms and Biology Open. The Company of Biologists is also a UK charity, providing grants and other support for the scientific community. 
                                 Follow preLights on Twitter at https://twitter.com/preLights"))
                           )),
                  
                  
                  
                  
                  # Page 2
                  
                  tabPanel("Table",
                           DT::dataTableOutput("table")
                  ),
                  
                  #Page 3
                  tabPanel("Resources",
                           DT::dataTableOutput("resources")
                  )
                  
                  
                  # Close UI
  ),
  
  
  # Server settings  
  server <- function(input, output, session) {
    output$timeline <- renderTimevis({
      timevis(final_data)
    })
    
    output$table <- DT::renderDataTable({
      DT::datatable(info_table, list(lengthMenu = c(10, 25, 30, 50, 75, 100), pageLength = 50))
    })
    
    output$resources <- DT::renderDataTable({
      DT::datatable(resources, list(lengthMenu = c(5, 10, 15, 20), pageLength = 10))
    })
    
    #Make buttons work
    observeEvent(input$btn, {
      fitWindow("timeline", list(animation = TRUE))
    })
    observeEvent(input$btn2, {
      centerItem("timeline", 1, (animation = TRUE))
    })
    observeEvent(input$btn3, {
      centerTime("timeline", "02-01-2020", (animation = TRUE))
    })
    observeEvent(input$btn4, {
      centerTime("timeline", "03-01-2020", (animation = TRUE))
    })
  }
)
