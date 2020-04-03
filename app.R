#
# Code relating to the preprints in response to COVID-19 timeline (www.covidpreprints.com)
# Maintained by the team @preLights (full team details in About page)
# 
#
# Thanks to Dean Attali for developing the timevis library and writing an excellent clear guide to hosting a shiny app website on Digital Ocean.
# The code and data used to create this site is hosted on github: https://github.com/coatesj/shiny-server 
# 
# Last code update: 03/04/2020
#
#
# This code also supports part of the manuscript "Preprinting a pandemic: the role of preprints in the COVID-19 pandemic", 27/03/2020. 
#
#
# For questions or quiries please contact Jonny Coates, jc2216@cam.ac.uk

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
                             actionButton("btn5", "Center on 1st April"),
                             actionButton("btn6", "Center on 1st May"),
                             
                             #Add rows underneath containing additional text
                             br(),
                             br(),
                             
                             fluidRow(
                               column(2,
                                      h4(" ")),
                               h3("Key: Orange = Event, Teal = Preprint, yellow = Important caveat/comment on preprint (see further information). Last updated: 01/04/2020")),
                             
                             #br(),
                             
                             fluidRow(
                               column(2,
                                      h4("")),
                               br(),
                               h3("This work is being maintained by Gautam Dey, Srivats Venkataramanan, Sundar Naganathan, Debbie Ho, Zhang-He Goh, Kirsty Hooper, Lars Hubatsch, Mariana De Niz, Sejal Davla, Mate Palfy & Jonny Coates. For questions or queries please contact prelights@biologists.com or Jonny Coates jc2216@cam.ac.uk")),
                             
                             br(),
                             
                             fluidRow(
                               column(2,
                                      h4("")),
                               h4("To use the timeline, navigate by clicking and dragging or through the use of the buttons. Hovering the mouse over an item will reveal more details pertaining to that point. Navigate between the timeline view and the table view using the navigation buttons at the top of this page. This timeline will be updated weekly.")),
                           
                             br(),
                             
                             img(src = "prelights.png", height = 70, width = 200),
                             
                             fluidRow(
                               column(2,
                                      h4("")),
                               p("preLights is a community service supported by The Company of Biologists, the not-for-profit publisher of Development, Journal of Cell Science, Journal of Experimental Biology, Disease Models & Mechanisms and Biology Open. The Company of Biologists is also a UK charity, providing grants and other support for the scientific community. 
                                 Follow preLights on Twitter at https://twitter.com/preLights"))
                           )),
                  
                  
                  
                  
                  # Page 2
                  
                  tabPanel("Further information",
                           DT::dataTableOutput("table")
                  ),
                  
                  # Page 3
                  tabPanel("Resources",
                           DT::dataTableOutput("resources")
                  ),
                  
                  # Page 4 - About
                  tabPanel("About",
                           fluidRow(
                             column(2,
                                    h4("")),
                             br(),
                             h3("We'd like to thank the tremendous effort of our team who are maintaining this database (twitter handles): Gautam Dey (@Dey_Gautam), Srivats Venkataramanan (@srivatsv), Sundar Naganathan (@Sundar_Ram_07), Debbie Ho, Zhang-He Goh (@zhanghe_goh), Kirsty Hooper (@KirstyHooper13), Lars Hubatsch (@LarsHubatsch), Mariana De Niz (@mariana_deniz), Sejal Davla (@JustABrainThing), Mate Palfy (@mate_palfy) & Jonny Coates (@JACoates91). In addition, our thanks go out to the wider scientific community who are diligently assessing and communicating important preprints during this difficult time. For questions or queries please contact prelights@biologists.com  or Jonny Coates jc2216@cam.ac.uk"),
                             br(),
                             h3("Please also find a curated prelist of interesting COVID-19 related preprints ",
                             a("here ", 
                               href = "https://prelights.biologists.com/prelists/wuhan-coronavirus-2019-ncov/"),
                             ("or visit the preLights website "),
                             a("here.",
                               href = "https://prelights.biologists.com"))),
                           
                           br(),
                           
                           fluidRow(
                             column(2,
                                    h4("")),
                             p("preLights is a community service supported by The Company of Biologists, the not-for-profit publisher of Development, Journal of Cell Science, Journal of Experimental Biology, Disease Models & Mechanisms and Biology Open. The Company of Biologists is also a UK charity, providing grants and other support for the scientific community. 
                                 Follow preLights on Twitter at https://twitter.com/preLights")),
                           br(),
                           
                           img(src = "prelights.png", height = 70, width = 200))
                           
                  # Close UI
  ),
  
  
  # Server settings  
  server <- function(input, output, session) {
    output$timeline <- renderTimevis({
      timevis(final_data, fit = FALSE)
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
    observeEvent(input$btn5, {
      centerTime("timeline", "04-01-2020", (animation = TRUE))
    })
    observeEvent(input$btn6, {
      centerTime("timeline", "05-01-2020", (animation = TRUE))
    })
  }
)
