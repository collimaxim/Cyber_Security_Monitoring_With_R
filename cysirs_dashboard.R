

# Shiny Dashboard

library(shiny)
library(shinydashboard)




# Header

header <-  dashboardHeader( title = "CySirs SOC - Shiny Dashboard Demo",
  dropdownMenu(type = "messages",
               messageItem(
                 from = "Security Ops",
                 message = "Cyber Training in 10 days."
                 
               ),
               messageItem(
                 from = "AirFrye",
                 message = "Please update the audit report for June 2014",
                 icon = icon("bolt"),
                 time = "15:35"
               ),
               messageItem(
                 from = "CS Dept",
                 message = "Call volume has increased 45%",
                 icon = icon("arrow-up")
               )
               
  ),
  
  dropdownMenu(type = "notifications",
               notificationItem(
                 text = "5 new users today",
                 icon("users")
               ),
               notificationItem(
                 text = "12 items delivered",
                 icon("truck"),
                 status = "success"
               ),
               notificationItem(
                 text = "Server load at 86%",
                 icon = icon("exclamation-triangle"),
                 status = "warning"
               )
  )
  ,
  dropdownMenu(type = "tasks", badgeStatus = "success",
               taskItem(value = 90, color = "green",
                        "Documentation"
               ),
               taskItem(value = 17, color = "aqua",
                        "Project X"
               ),
               taskItem(value = 75, color = "yellow",
                        "Server deployment"
               ),
               taskItem(value = 80, color = "red",
                        "Overall project"
               )
  )

)
  
  sidebar <-  dashboardSidebar(
    
    sidebarMenu(
      menuItem("Dashboard", tabName = "dashboard", icon = icon("dashboard")),
      menuItem("Data Analysis", tabName = "dataanalysis", icon = icon("table"),
               badgeLabel = "new", badgeColor = "green"),
      menuItem("Tabbed Pages", tabName = "tabbedpage", icon= icon("th")),
      menuItem("Info Boxes", tabName ="infobox", icon = icon("th-large")),
      menuItem("Value Boxes", tabName = "valbox", icon = icon("info-circle")),
      menuItem("Event Logs", tabName = "elogbox", icon = icon("info-circle"))
    )
  )

body <-  dashboardBody(
  tabItems(
    
    ###
  tabItem(tabName = "dashboard",
           h2("Customizable Dashboard content section")
           ,
  
  fluidRow(
    box(
      title = "Title 1", width = 4, solidHeader = TRUE, status = "primary",
      "Box content"
    ),
    box(
      title = "Title 2", width = 4, solidHeader = TRUE,
      "Box content"
    ),
    box(
      title = "Title 1", width = 4, solidHeader = TRUE, status = "warning",
      "Box content"
    )
  )
  
  ),
  
  
  ###
  tabItem(tabName = "dataanalysis",
           h2("put a data table here")
    ),
  
  
  ###
  tabItem(tabName = "tabbedpage",
          h1("Example of tabbed page"),
          
          fluidRow(
            tabBox(
              title = "First tabBox",
              # The id lets us use input$tabset1 on the server to find the current tab
              id = "tabset1", height = "250px",
              tabPanel("Tab1", "First tab content"),
              tabPanel("Tab2", "Tab content 2")
            ),
            tabBox(
              side = "right", height = "250px",
              selected = "Tab3",
              tabPanel("Tab1", "Tab content 1"),
              tabPanel("Tab2", "Tab content 2"),
              tabPanel("Tab3", "Note that when side=right, the tab order is reversed.")
            )
          ),
          fluidRow(
            tabBox(
              # Title can include an icon
              title = tagList(shiny::icon("gear"), "tabBox status"),
              tabPanel("Tab1",
                       "Currently selected tab from first box:",
                       verbatimTextOutput("tabset1Selected")
              ),
              tabPanel("Tab2", "Tab content 2")
            )
          )
          ),
          
          
      ###    
      tabItem( tabName = "infobox",
              h2("Example of Info Boxes"),
              # infoBoxes with fill=FALSE
              fluidRow(
                # A static infoBox
                infoBox("New Orders", 10 * 2, icon = icon("credit-card")),
                # Dynamic infoBoxes
                infoBoxOutput("progressBox"),
                infoBoxOutput("approvalBox")
              ),
              
              # infoBoxes with fill=TRUE
              fluidRow(
                infoBox("New Orders", 10 * 2, icon = icon("credit-card"), fill = TRUE),
                infoBoxOutput("progressBox2"),
                infoBoxOutput("approvalBox2")
              ),
              
              fluidRow(
                # Clicking this will increment the progress amount
                box(width = 4, actionButton("count", "Increment progress"))
              )
        
              
      ),
  
            tabItem(tabName = "valbox",
                    hr("Example of a Value Box"),
                    
                    fluidRow(
                      # A static valueBox
                      valueBox(10 * 2, "New Orders", icon = icon("credit-card")),
                      
                      # Dynamic valueBoxes
                      valueBoxOutput("progressvBox"),
                      
                      valueBoxOutput("approvalvBox")
                    ),
                    fluidRow(
                      # Clicking this will increment the progress amount
                      box(width = 4, actionButton("counts", "Increment progress"))
                    )
                    
                    
              
            ),
  
  
  ###
  tabItem(tabName = "elogbox",
          hr("Event Log Monitor"),
          
          fluidRow(  
            # A static valueBox
          #  valueBox(10 * 2, "New Orders", icon = icon("credit-card")),
            
            # Dynamic valueBoxes
            valueBoxOutput("secWatchCTBox"),
            
            valueBoxOutput("appWatchCTBox"),
            valueBoxOutput("sysWatchCTBox")
            
          ),
          fluidRow(
            # Clicking this will increment the progress amount
            box(width = 4, actionButton("counts", "Increment progress"))
          ),
          
          fluidRow(
            
            # Clicking this will increment the progress amount
        # box(width = 12, "What is this" ,
                
                tabBox(
                  width = 12, 
                  
                  title = "Event Log details",
                  # The id lets us use input$evntlogtab on the server to find the current tab
                  id = "evntlogtab", height = "250px",
           # size of the data grids are too wide...
                  tabPanel("Security Log", 
                        box(width = 12,   h6(dataTableOutput("secWlogdt")    ))    ),
                  tabPanel("App Log",  
                        box(width = 12,   h6(dataTableOutput("appWlogdt")      )  )),
                  tabPanel("System Log", 
                        box(width = 12,   h6(dataTableOutput("sysWlogdt")    ) ))
               
                  
                   )
                
             
              #  )
            
            
            
            
          )
          
          
          
          
          
  )
  
  
  
  
  
  
    
  )
  
  )
 






ui <- dashboardPage( skin = "red", header, sidebar, body)
  
 
 
server <- function(input, output) {
  
  output$progressBox <- renderInfoBox({
    infoBox(
      "Progress", paste0(25 + input$count, "%"), icon = icon("list"),
      color = "purple"
    )
  })
  output$approvalBox <- renderInfoBox({
    infoBox(
      "Approval", "80%", icon = icon("thumbs-up", lib = "glyphicon"),
      color = "yellow"
    )
  })
  
  # Same as above, but with fill=TRUE
  output$progressBox2 <- renderInfoBox({
    infoBox(
      "Progress", paste0(25 + input$count, "%"), icon = icon("list"),
      color = "purple", fill = TRUE
    )
  })
  output$approvalBox2 <- renderInfoBox({
    infoBox(
      "Approval", "80%", icon = icon("thumbs-up", lib = "glyphicon"),
      color = "yellow", fill = TRUE
    )
  })
  
  output$progressvBox <- renderValueBox({
    valueBox(
      paste0(25 + input$counts, "%"), "Progress", icon = icon("list"),
      color = "purple"
    )
  })
  
  output$approvalvBox <- renderValueBox({
    valueBox(
      "80%", "Approval", icon = icon("thumbs-up", lib = "glyphicon"),
      color = "yellow"
    )
  })
  
  
  
  output$appWatchCTBox <- renderValueBox({
    valueBox(app_watch_ct,
             "App Log Alert Count",
      icon = icon("alert"),
      color = "purple"
    )
  })
  
  output$secWatchCTBox <- renderValueBox({
    valueBox(sec_watch_ct,
             "Sec Log Alert Count",
             icon = icon("thumbs-up", lib = "glyphicon"),
             color = "red"
    )
  })
  
  output$sysWatchCTBox <- renderValueBox({
    valueBox( sys_watch_ct,
      "System Log Alert Count",
      icon = icon("thumbs-up", lib = "glyphicon"),
      color = "yellow"
    )
  })
  
  output$secWlogdt <- renderDataTable(
    secevent_watch
    
  )
  
  output$appWlogdt <- renderDataTable(
    appevent_watch
    
  )
  
  output$sysWlogdt <- renderDataTable(
    sysevent_watch
    
  )
  
  
}

shinyApp(ui, server)








