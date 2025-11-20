# app.R
library(shiny)
library(tidyverse)
library(factoextra)
library(plotly)
library(DT)

ui <- fluidPage(
  titlePanel("Clustering Dashboard — Project UAS25"),
  sidebarLayout(
    sidebarPanel(
      numericInput("k", "Pilih jumlah cluster (k)", value = 3, min = 2, max = 10),
      actionButton("run", "Run K-Means"),
      hr(),
      selectInput("xvar","X axis", choices = NULL),
      selectInput("yvar","Y axis", choices = NULL)
    ),
    mainPanel(
      tabsetPanel(
        tabPanel("EDA", plotOutput("corr"), plotlyOutput("hist")),
        tabPanel("Clustering", plotlyOutput("cluster_plot"), DTOutput("cluster_table")),
        tabPanel("Summary", verbatimTextOutput("summary"))
      )
    )
  )
)

server <- function(input, output, session){
  df <- reactive({ read_csv("data/prepared_data.csv") })
  observe({
    num <- df() %>% select(where(is.numeric))
    updateSelectInput(session, "xvar", choices = names(num), selected = names(num)[1])
    updateSelectInput(session, "yvar", choices = names(num), selected = names(num)[2])
  })
  
  output$corr <- renderPlot({
    num <- df() %>% select(where(is.numeric))
    corrplot::corrplot(cor(num), method='color')
  })
  
  output$hist <- renderPlotly({
    num <- df() %>% select(where(is.numeric))
    p <- num %>% gather(var,val) %>% ggplot(aes(val)) + geom_histogram(bins=30) + facet_wrap(~var, scales='free')
    ggplotly(p)
  })
  
  cluster_res <- eventReactive(input$run, {
    num <- df() %>% select(where(is.numeric))
    set.seed(123)
    kmeans(num, centers = input$k, nstart = 25)
  })
  
  output$cluster_plot <- renderPlotly({
    req(cluster_res())
    num <- df() %>% select(where(is.numeric))
    km <- cluster_res()
    dfp <- num %>% mutate(cluster = factor(km$cluster))
    # PCA for 2D projection
    pca <- prcomp(num, scale.=TRUE)
    scores <- as.data.frame(pca$x[,1:2])
    scores$cluster <- factor(km$cluster)
    p <- ggplot(scores, aes(x=PC1, y=PC2, color=cluster)) + geom_point() + theme_minimal()
    ggplotly(p)
  })
  
  output$cluster_table <- renderDT({
    req(cluster_res())
    num <- df() %>% select(where(is.numeric))
    km <- cluster_res()
    out <- num %>% mutate(cluster = factor(km$cluster))
    datatable(out)
  })
  
  output$summary <- renderPrint({
    req(cluster_res())
    km <- cluster_res()
    print(km)
  })
}

shinyApp(ui, server)