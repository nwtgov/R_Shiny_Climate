# aboutModule



# UI function
aboutUI <- function(id) {
  ns <- NS(id)
  tagList(
    div(
      style = "padding: 20px; max-width: 900px; margin: 0 auto;",
      uiOutput(ns("about_content"))
    ),
    uiOutput(ns("footer_curve"))
  )
}

# Server function
aboutServer <- function(id, language) {
  moduleServer(id, function(input, output, session) {
    output$about_content <- renderUI({
      req(language())
      create_about_content(language())
    })
    output$footer_curve <- renderUI({
      req(language())
      gnwt_footer_ui(language())
    })
  })
}

##
##
##
