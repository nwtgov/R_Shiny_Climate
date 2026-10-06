# downloadModule.R
# Download tab: select network, station, year, parameters -> download CSV

# ---------- UI ----------
downloadUI <- function(id) {
  ns <- NS(id)

  tagList(
    fluidPage(
      tags$head(tags$style(HTML("
        .download-container {
          padding: 20px;
          max-width: 800px;
          margin: 0 auto;
        }
        .download-controls-section {
          background-color: #f8f9fa;
          padding: 20px;
          border-radius: 5px;
          border-left: 4px solid #0066cc;
          margin-bottom: 20px;
          margin-top: 20px;
          box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }
        .disclaimer-section {
          background-color: #f8f9fa;
          padding: 20px;
          border-radius: 5px;
          border-left: 4px solid #0066cc;
          margin-bottom: 20px;
          font-size: 14px;
        }
        .param-box {
          max-height: 220px;
          overflow-y: auto;
          border: 1px solid #ddd;
          padding: 10px;
          background: white;
          border-radius: 4px;
        }
        .climate-download-grid {
          display: grid;
          grid-template-columns: 160px 1fr;
          row-gap: 12px;
          align-items: center;
        }
      "))),

      div(class = "download-container",

          # --- Top: download controls ---
          div(class = "download-controls-section",

              tags$div(
                style = "margin-bottom: 14px;",
                tags$h2(
                  style = "font-size: 22px; font-weight: bold; margin-bottom: 10px; margin-top: 0; color: #000000;",
                  "Download Climate Data"
                ),
                tags$p(
                  style = "font-size: 15px; line-height: 1.5; margin-bottom: 0;",
                  "Select a network, station, year, and parameters, then click Download Data."
                )
              ),

              tags$div(
                class = "climate-download-grid",

                tags$div(style = "grid-column: 1;", tags$strong("Network")),
                tags$div(
                  style = "grid-column: 2;",
                  selectInput(ns("network"), label = NULL,
                              choices = c("ECC (territorial)" = "ECC",
                                          "ECCC (federal)"    = "ECCC"),
                              width = "100%")
                ),

                tags$div(style = "grid-column: 1;", tags$strong("Station")),
                tags$div(
                  style = "grid-column: 2;",
                  selectInput(ns("station"), label = NULL, choices = NULL, width = "100%")
                ),

                tags$div(style = "grid-column: 1;", tags$strong("Year")),
                tags$div(
                  style = "grid-column: 2;",
                  selectInput(ns("year"), label = NULL, choices = NULL, width = "100%")
                ),

                tags$div(style = "grid-column: 1; align-self: start; padding-top: 6px;",
                         tags$strong("Parameters")),
                tags$div(
                  style = "grid-column: 2;",
                  div(class = "param-box",
                      checkboxGroupInput(ns("parameters"), label = NULL, choices = NULL)
                  )
                )
              ),

              tags$div(
                style = "display: flex; justify-content: flex-end; margin-top: 16px;",
                downloadButton(ns("download_csv"), "Download Data",
                               class = "btn-primary")
              )
          ),

          # --- Bottom: disclaimer ---
          # div(class = "disclaimer-section",
          #     uiOutput(ns("disclaimer_content"))
          # )
          div(class = "disclaimer-section",
              create_climate_disclaimer_content()
          )
      )
    ),
    uiOutput(ns("footer_curve"))
  )
}
# ---------- Server ----------
downloadServer <- function(id, ecc_stations, ecc_data_files, eccc_sites, eccc_data, language) {
  moduleServer(id, function(input, output, session) {

    output$footer_curve <- renderUI({
      req(language())
      gnwt_footer_ui(language())
    })

    # ---- Station list reacts to selected network ----
    observe({
      req(input$network)

      if (input$network == "ECC") {
        stns <- ecc_stations()
        choices <- sort(unique(stns$STATION_NAME))
      } else {
        sites <- eccc_sites()
        choices <- sort(unique(sites$merged_name))
      }

      updateSelectInput(session, "station", choices = choices)
    })

    # ---- Load the data for the selected station ----
    station_data <- reactive({
      req(input$network, input$station)

      if (input$network == "ECC") {
        # Find the matching RDS file
        files <- ecc_data_files()
        # Match on station name embedded in the file
        for (f in files) {
          tryCatch({
            df <- readRDS(f)
            if (input$station %in% unique(df$STATION_NAME)) return(df)
          }, error = function(e) NULL)
        }
        return(NULL)

      } else {
        # ECCC: filter the merged dataset
        df <- eccc_data()
        req(df)
        df %>% filter(merged_name == input$station)
      }
    })

    # ---- Available years for selected station ----
    observe({
      df <- station_data()
      req(df)

      if (input$network == "ECC") {
        years <- sort(unique(df$CD_YEAR), decreasing = TRUE)
      } else {
        years <- sort(unique(df$year), decreasing = TRUE)
      }
      updateSelectInput(session, "year",
                        choices = as.character(years),
                        selected = as.character(years[1]))
    })

    # ---- Available parameters for selected station + year ----
    observe({
      df <- station_data()
      req(df, input$year)

      yr <- as.numeric(input$year)

      if (input$network == "ECC") {
        df_yr <- df %>% filter(CD_YEAR == yr)
        param_cols <- names(ecc_param_labels)
        present <- param_cols[
          sapply(param_cols, function(p) p %in% names(df_yr) && sum(!is.na(df_yr[[p]])) > 0)
        ]
        choices <- setNames(present, ecc_param_labels[present])
      } else {
        df_yr <- df %>% filter(year == yr)
        param_cols <- names(eccc_param_labels)
        present <- param_cols[
          sapply(param_cols, function(p) p %in% names(df_yr) && sum(!is.na(df_yr[[p]])) > 0)
        ]
        choices <- setNames(present, eccc_param_labels[present])
      }

      updateCheckboxGroupInput(session, "parameters",
                               choices = choices,
                               selected = choices)
    })

    # ---- Download handler ----
    output$download_csv <- downloadHandler(
      filename = function() {
        paste0(input$network, "_", input$station, "_", input$year, ".csv")
      },
      content = function(file) {
        df <- station_data()
        req(df)
        yr <- as.numeric(input$year)
        params <- input$parameters

        if (length(params) == 0) {
          write.csv(
            data.frame(Message = "No parameters selected."),
            file, row.names = FALSE
          )
          return()
        }

        if (input$network == "ECC") {
          # Subset to year, keep wide format (one column per parameter)
          df_yr <- df %>% filter(CD_YEAR == yr)

          # Select ID columns + chosen parameter and flag columns
          flag_cols <- paste0(params, "_flag")
          keep_cols <- c("STATION_NAME", "CD_YEAR", "CD_MONTH", "CD_DAY", "CD_TIME",
                         params, intersect(flag_cols, names(df_yr)))
          out <- df_yr %>% select(any_of(keep_cols))

        } else {
          # ECCC -- wide format
          df_yr <- df %>% filter(year == yr)

          flag_cols <- paste0(params, "_flag")
          keep_cols <- c("merged_name", "date", "year", "month", "day",
                         params, intersect(flag_cols, names(df_yr)))
          out <- df_yr %>% select(any_of(keep_cols))
        }

        write.csv(out, file, row.names = FALSE, na = "")
      }
    )
  })
}
