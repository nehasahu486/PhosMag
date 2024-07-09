library(shiny)
library(shinythemes)
library(ggplot2)
library(dplyr)

# Load your dataframe 'test'
test <- read.delim("long_data.tsv")
head(test)
############################################################################################
ui <- fluidPage(
  titlePanel("PhosMag"),
  theme = shinythemes::shinytheme("sandstone"),
  
  sidebarLayout(
    sidebarPanel(
      textInput("protein_id", "Enter MGG ID:", placeholder = "e.g., MGG_00001"),
      
      checkboxGroupInput("variable_selection", "Type of Abundances:", choices = unique(test$type), selected = NULL),
      
      uiOutput("position_selector"), # Removed the label text
      
      actionButton("submit", "Submit"),
      hr(),
      tags$p(strong("How it works:"), style = "color:#1B9E77;"),
      tags$p("1. Type in any MGG ID",style = "font-size: 12px;"),
      tags$p("2. Choose between Normalized and Averaged LFQ Abundances (or both). RECOMMENDED: Normalized Abundances",style = "font-size: 12px;"),
      tags$p("3. Select a tick box for Positions in Master Sequence. RECOMMENDED: Select only one at a time",style = "font-size: 12px;"),
      tags$p("4. Click Submit",style = "font-size: 12px;"),
      hr(),
      tags$p(strong("PhosMag",style = "font-size: 14px; color:#1B9E77;"), "is a resource for quantitative phosphoproteomics data during early appressoria development in ",
             tags$em("Magnaporthe oryzae"),
             ". It displays plots of phosphopeptide abundances for a queried protein across biological replicates of Guy11 and Δ",
             tags$em("pmk1")," strains at various time points."),
      hr(),
      tags$p(strong("If you use this resource in your work, please cite:"), style = "font-size: 12px; color:#1B9E77;"),
      tags$p(strong("The phosphorylation landscape of infection-related development by the rice blast fungus"),style = "font-size: 11px;"),
      tags$p(em("Neftaly Cruz-Mireles, Miriam Osés-Ruiz, Paul Derbyshire, Clara Jégousse, Lauren S. Ryder, Mark Jave Bautista, Alice Bisola Eseola, Jan Sklenar, Bozeng Tang, Xia Yan, Weibin Ma, Kim C. Findlay, Vincent Were, Dan MacLean, Nicholas J. Talbot, Frank L.H. Menke"), style = "font-size: 10px;"),
      tags$a("https://doi.org/10.1016/j.cell.2024.04.007", href = "https://doi.org/10.1016/j.cell.2024.04.007", style = "font-size: 11px;color:#1B9E77;"),
      hr(),
      img(src='cover.jpg', height="50%", width="30%")
    ),
    mainPanel(
      id = "mainPanel", # Add an ID to the main panel
      fluidRow(
        column(
          width = 12,
          plotOutput("gene_expression_plot"), # Set the height to match A4 size
          hr(),
          tableOutput("filtered_data_table"),# Display filtered data table
          textOutput("protein_not_found_message") # Display protein not found message
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
    req(input$position_selection)
    
    filtered <- test %>%
      filter(Master_Protein_Accessions == input$protein_id & 
               type %in% input$variable_selection &
               Positions_in_Master_Proteins == input$position_selection)
    
    if (nrow(filtered) == 0) {
      output$protein_not_found_message <- renderText({
        ""
      })
    }
    
    return(filtered)
  })
  
  output$position_selector <- renderUI({
    req(input$protein_id)
    req(input$variable_selection)
    
    positions <- unique(test$Positions_in_Master_Proteins[test$Master_Protein_Accessions == input$protein_id & test$type %in% input$variable_selection])
    
    if (length(positions) == 0) {
      label <- "Oops! Looks like this protein was not there in the dataset. Double-check the ID or pick another protein"
    } else {
      label <- "Select Positions in Master Sequence:"
    }
    
    checkboxGroupInput("position_selection", label, choices = positions)
  })
  
  output$gene_expression_plot <- renderPlot({
    req(input$submit)
    
    ggplot(filtered_data(), aes(x = time, y = Abundances, fill = sample, alpha = replicate, color = sample)) +
      geom_bar(stat = "identity", position = position_dodge()) +
      facet_grid(label + Modifications ~ sample, scales = "free") +
      scale_fill_manual(values = c("green4", "grey5")) +
      scale_color_manual(values = c("green4", "grey5")) +
      theme_bw() +
      theme(strip.background = element_blank(),
            strip.text = element_text(size = 15, face = "bold.italic"),
            axis.title = element_text(size = 10),
            axis.text.y = element_text(size = 10),
            axis.text.x = element_text(size = 10, angle = 45, hjust = 1),
            strip.text.y = element_text(angle = 0, size = 10),
            legend.position = "bottom") +
      xlab("") +
      ylab("Abundances")
  })
  
  output$filtered_data_table <- renderTable({
    data <- filtered_data()
    
    # Pivot the data wider based on the time column using dplyr and tidyr
    data_wider <- reshape(data, idvar = c("Modifications","Master_Protein_Accessions",
                                          "Positions_in_Master_Proteins","label","sample","replicate",
                                          "type"), timevar = "time", direction = "wide")
    #turn the abundances into scientic notion/exponential values
    data_wider[c(8:13)] <- format(data_wider[c(8:13)],scientific=T)
    
    # Return the wider data
    data_wider
  })
}



shinyApp(ui = ui, server = server)

