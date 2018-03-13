server <- function(input, output, session) {
  
  ##########################
  # connect to google sheets
  gsheet <- "retrieve_shinyhandwriting_training"
  fields <- c("label", paste0("pixel", 1:784))
  formData <- reactive({
    c(input$label, rep(0, 784))
  })
  saveData <- function(data) {
    sheet <- gs_title(gsheet)
    gs_add_row(sheet, input = data)}
  gs_auth(token = "token.rds")
  
  ##########################
  
  
  
  
  vals = reactiveValues(x=NULL, y=NULL)
  draw = reactiveVal(FALSE)
  result = reactiveVal(NULL)
  rendered = reactiveVal(NULL)
  database = reactiveVal(NULL)
  
  
  
  
  observeEvent(input$click, handlerExpr = {
    temp <- draw()
    draw(!temp)
    if(!draw()) {
      vals$x <- c(vals$x, NA)
      vals$y <- c(vals$y, NA)
    } 
  })
  
  # reset the plot on DEL click
  observeEvent(input$reset, handlerExpr = {
    vals$x <- NULL; vals$y <- NULL
    draw(FALSE)
  })
  
  # on hover, record.
  observeEvent(input$hover, {
    if (draw()) {
      vals$x <- c(vals$x, input$hover$x)
      vals$y <- c(vals$y, input$hover$y)
    }
  })
  
  # plot function to do the smoothing and resizing
  myplot = reactive({
    ggplot() + 
      geom_path(aes(x=vals$x, y=vals$y), size=input$mywidth, color="white", alpha=1) + 
      xlim(0, 28) + ylim(0,28) + 
      theme_custom() %+replace% theme(panel.background = element_rect(fill='black'), axis.line=element_blank())
  })
  
  # basic plot to be as quick as possible
  output$plot= renderPlot({
    plot(x=vals$x, y=vals$y, xlim=c(0, 28), ylim=c(0, 28), ylab="y", xlab="x", type="l", lwd=input$mywidth)
  })
  
  # resized and smoothed plot
  output$plot2828 = renderPlot({
    if (is.null(rendered())) {return(NULL)}
    plot(rendered())
  })
  
 
  observeEvent(input$send, {
    current.label <- as.numeric(input$label)
    g=myplot()
    ggsave("out.png", g, width = 5, height = 5)

    x = "out.png" %>%
      readImage %>%
      resize(w=28, h=28) %>%
      extract.matrix %>%
      # t %>%
      as.vector %>%
      matrix(ncol=1) %>%
      round(2)
    
    updateRadioButtons(session, "label", selected="")
    
    if (   all(x==0) | is.na(current.label)   ){
      showModal(modalDialog(title="Error", h4("Please draw a number AND choose a 0-9 label")))
    } else {
      showNotification("please wait 10 seconds to generate the rendered image and store it")
      saveData(c(current.label, x))
      # reset the plot
      vals$x <- NULL; vals$y <- NULL
    }
        # test = gs_read_csv(sheet)
    
  })
  
#################
  # TAB 2
  
  observeEvent(input$import, {
    showNotification("please wait 10 seconds to import the whole data")
    gsheet <- "retrieve_shinyhandwriting_training"
    sheet <- gs_title(gsheet)
    temp <- data.frame(gs_read_csv(sheet)) %>% mutate(label=as.character(label))
    database(   temp  )
  })
  
  output$nb = renderText({
    paste0("The database has ", nrow(database()), " observations")
  })
  
  output$hist = renderPlot({
    if (is.null(database())) { return(NULL) }
    barplot(table(database()$label))
  })
  
  output$digit_select_UI = renderUI({
    selectInput("digit_select", "select digit to see its average smoothed plot", 0:9, selected=NULL)
  })
  
  output$mean_plot = renderPlot({
    if (is.null(database())) { return(NULL) }
    toplot = database() %>% filter(label==input$digit_select) %>% select(-label) %>% as.matrix
    toplot = colMeans(toplot)
    m <- matrix(toplot, nrow=28, byrow=TRUE)
    m <- apply(m, 2, rev)
    image(t(m), col=grey.colors(255), axes=FALSE)
  })
  
  #################
  # PREDICTIOn
  
observeEvent(input$predict, ignoreInit = TRUE, handlerExpr = {
  g=myplot()
  ggsave("out.png", g, width = 5, height = 5)
  x = "out.png" %>%
    readImage %>%
    resize(w=28, h=28) %>%
    extract.matrix %>%
    # t %>%
    as.vector %>%
    matrix(ncol=1) %>%
    round(2)
  dim(x) <- c(28, 28, 1, ncol(x))
  m2.preds <- predict(m2, x)
  m2.preds.value <- max.col(t(m2.preds)) - 1
  showModal(modalDialog(title="prediction value", m2.preds.value))
  
})
    
}

