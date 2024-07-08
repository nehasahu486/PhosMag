library(shiny)
library(bslib)
library(ggplot2)
library(dplyr)

# Load your dataframe 'test'
test <- read.delim("long_data.tsv")
head(test)
############################################################################################
ui <- fluidPage(
  theme = bs_theme(version = 5, bootswatch = "minty"), # shiny theme of the page
  titlePanel("PhosMag",
  windowTitle = "PhosMag"),
  
  sidebarLayout(
    sidebarPanel(
      # First sidebar panel for protein_id input
      textInput("protein_id", "Enter MGG ID:", placeholder = "e.g., MGG_00001"),
      
      # Second sidebar panel for checkbox options
      checkboxGroupInput("variable_selection", "Type of Abundances:", choices = unique(test$type), selected = NULL),
      
      # Third sidebar panel for Positions_in_Master_Proteins selection
      uiOutput("position_selector"), # Removed the label text
      
      actionButton("submit", "Submit"),
      
      # Add the text to the sidebar panel
      tags$p("PhosMag is a resource for quantitative phosphoproteomics data during early appressoria development in <b>Magnaporthe oryzae<b> showing phosphopeptide abundances across biological replicates of guy11 and Δpmk1 strains at various time points.", style = "font-size: 10px;"),
      tags$p(strong("The phosphorylation landscape of infection-related development by the rice blast fungus"), style = "font-size: 8px;"),
      tags$p(em("Neftaly Cruz-Mireles, Miriam Osés-Ruiz, Paul Derbyshire, Clara Jégousse, Lauren S. Ryder, Mark Jave Bautista, Alice Bisola Eseola, Jan Sklenar, Bozeng Tang, Xia Yan, Weibin Ma, Kim C. Findlay, Vincent Were, Dan MacLean, Nicholas J. Talbot, Frank L.H. Menke"), style = "font-size: 8px;"),
      tags$a("https://www.biorxiv.org/content/10.1101/2023.08.19.553964v1", href = "https://www.biorxiv.org/content/10.1101/2023.08.19.553964v1", style = "font-size: 8px;color:seagreen2;")
    ),
    mainPanel(
      id = "mainPanel", # Add an ID to the main panel
      fluidRow(
        column(
          width = 12,
          plotOutput("gene_expression_plot", height = "500px"), # Set the height to match A4 size
          tableOutput("filtered_data_table")  # Display filtered data table
        )
      )
    )
  )
)


server <- function(input, output, session) {
  
  filtered_data <- reactive({
    req(input$submit)
    req(input$protein_id)
    req(input$variable_selection)
    req(input$position_selection) # Add this line
    
    test %>%
      filter(Master_Protein_Accessions == input$protein_id & 
               type %in% input$variable_selection &
               Positions_in_Master_Proteins == input$position_selection) # Update this line
  })
  
  output$position_selector <- renderUI({
    req(input$protein_id)
    req(input$variable_selection)
    
    positions <- unique(test$Positions_in_Master_Proteins[test$Master_Protein_Accessions == input$protein_id & test$type %in% input$variable_selection])
    
    checkboxGroupInput("position_selection", "Select Positions:", choices = positions)
  })
  
  output$gene_expression_plot <- renderPlot({
    req(input$submit)
    
    ggplot(filtered_data(), aes(x = time, y = Abundances, fill = sample, alpha = replicate, color = sample)) +
      geom_bar(stat = "identity", position = position_dodge()) +
      facet_grid(label+Modifications~sample, scales="free")+
      scale_fill_manual(values = c("green4","grey5"))+
      scale_color_manual(values = c("green4","grey5"))+
      theme_bw()+
      theme(strip.background = element_blank(),
            strip.text = element_text(size=15,face="bold"),
            axis.title = element_text(size=10),
            axis.text.y= element_text(size=10),
            axis.text.x= element_text(size=10,angle=45,hjust=1),
            strip.text.y = element_text(angle = 0,size=10),
            legend.position = "bottom")+
      xlab("")+ylab("Abundances")
  })
  output$filtered_data_table <- renderTable({
    filtered_data()
  })
}



shinyApp(ui = ui, server = server)

