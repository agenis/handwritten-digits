library(shiny)
library(mxnet)
library(ggplot2)
library(EBImage)
library(dplyr)
library(googlesheets)

ui <- fluidPage(
  h2("Draw digits to feed a neural network image recognition algorithm!"),
  sidebarLayout(
    sidebarPanel(
      h4("Draw ONE SINGLE digit: Click on plot to start drawing, click again to pause."),
      hr(),
      sliderInput("mywidth", "width of the pencil", min=1, max=30, step=1, value=15),
      actionButton("reset", "reset drawing"),
      actionButton("send", "generate vignette"),
      h5("Careful: clicking 'generate vignette' will write the image in the database and affect future predictions!", style="color:red"),
      h3("prediction of convolution model"),
      actionButton("predict", "predict on your plot"),
      hr(),
      radioButtons("label", "Label your drawing with 0-9 digit:", choices=c(NA, 0:9), selected=NA, inline=TRUE)
    ),
    mainPanel(
      tabsetPanel(
        tabPanel(title="Draw!",
                 plotOutput("plot", width = "500px", height = "500px",
                            hover=hoverOpts(id = "hover", delay = 100, delayType = "throttle", clip = TRUE, nullOutside = TRUE),
                            click="click"),
                 h4("28x28 vignette for neural network input:"),
                 plotOutput("plot2828",width = "28px", height = "28px")
        ),
        tabPanel(title="Check Database",
                 actionButton("import", "Import database"),
                 textOutput("nb"),
                 p("number of observations per digit:"),
                 plotOutput("hist"),
                 p("Please draw the ones that are the least present in the data..."),
                 hr(),
                 p("see average image"),
                 uiOutput("digit_select_UI"),
                 plotOutput("mean_plot", width = "280px", height = "280px")
        )
        
        
        
      )
      
    )
  )
)

