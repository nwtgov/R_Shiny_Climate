# summary map module
# summaryModule.R
# v1: latest ECC air temperature from Update_Climate (no historical context yet)

summaryUI <- function(id) {
  ns <- NS(id)

  tagList(
    tags$style(HTML(sprintf("
      #%s { height: calc(100vh - 80px) !important; width: 100%% !important; }
    ", ns("summary_map")))),
    div(
      style = "position: relative;",
      absolutePanel(
        top = 10, left = 10, width = 220,
        style = "background: white; padding: 8px; border-radius: 4px; box-shadow: 0 1px 4px rgba(0,0,0,0.3); z-index: 1000;",
        selectInput(
          ns("map_view"), NULL,
          choices = c(
            "Latest air temperature" = "latest",
            "Compared with average" = "average"
          ),
          selected = "latest"
        )
      ),
      leafletOutput(ns("summary_map"), height = "100%")
    )
  )
}

summaryServer <- function(id, ecc_latest, ecc_metadata, swob_latest, preloaded_data, language = NULL) {
  moduleServer(id, function(input, output, session) {

    map_data <- reactive({
      latest <- ecc_latest()
      meta   <- ecc_metadata()
      req(latest, meta)
      req(nrow(latest) > 0)

      #variable <- unique(latest$parameter)[1]

      meta %>%
        dplyr::mutate(STATION_NAME = as.character(STATION_NAME)) %>%
        dplyr::inner_join(latest, by = "STATION_NAME") %>%
        dplyr::filter(!is.na(LATITUDE), !is.na(LONGITUDE), !is.na(T_AIR_HIGH_C))
    })

    output$summary_map <- renderLeaflet({
      df <- map_data()
      req(nrow(df) > 0)
      req(preloaded_data())

      shps <- preloaded_data()

      swob_df <- swob_latest()
      if (is.null(swob_df) || nrow(swob_df) == 0) {
        swob_df <- NULL
      } else {
        swob_df <- swob_df %>%
          dplyr::filter(!is.na(lat), !is.na(lon), !is.na(air_temp))
        if (nrow(swob_df) == 0) swob_df <- NULL
      }

      temps <- df$T_AIR_HIGH_C
      if (!is.null(swob_df)) temps <- c(temps, swob_df$air_temp)

      temp_ticks <- pretty(temps, n = 5)
      pal <- colorNumeric(
        palette = c("#4575B4", "#91BFDB", "#E0F3F8", "#FFFFBF", "#FEE090", "#FC8D59", "#D73027"),
        domain = range(temp_ticks),
        na.color = "#CCCCCC"
      )
      legend_ticks <- rev(temp_ticks)

      popup_html <- paste0(
        "<div class='metadata-header'>", df$STATION_NAME, "</div>",
        "<table class='metadata-table'>",
        "<tr><td>Air temperature:</td><td>", round(df$T_AIR_HIGH_C, 1), " \u00b0C</td></tr>",
        "<tr><td>Observed at:</td><td>", df$obs_time, "</td></tr>",
        "<tr><td>Network:</td><td>ECC (territorial)</td></tr>",
        "</table>"
      )

      map <- leaflet() %>%
        carto_tiles(style = "light_all", group = "CartoDB") %>%
        addProviderTiles(providers$Esri.WorldImagery, group = "ESRI Satellite") %>%
        setView(lng = -120, lat = 64, zoom = 5) %>%
        addPolylines(data = shps$nwt_boundary, weight = 2, color = "#000000",
                     opacity = 0.8, group = "NWT boundary") %>%
        addPolylines(data = shps$mackenzie_basin, weight = 2, color = "#888888",
                     opacity = 0.8, group = "Mackenzie Basin") %>%
        addCircleMarkers(
          data = df,
          lng = ~LONGITUDE, lat = ~LATITUDE,
          radius = 7, color = "black", weight = 1,
          fillColor = pal(df$T_AIR_HIGH_C),
          fillOpacity = 0.85, opacity = 0.8,
          label = ~STATION_NAME,
          popup = popup_html,
          group = "ECC",
          popupOptions = popupOptions(
            autoPan = TRUE, keepInView = TRUE,
            autoPanPaddingTopLeft = c(40, 80),
            autoPanPaddingBottomRight = c(40, 40)
          )
        )

      if (!is.null(swob_df)) {
        swob_popup <- paste0(
          "<div class='metadata-header'>", swob_df$merged_name, "</div>",
          "<table class='metadata-table'>",
          "<tr><td>Air temperature:</td><td>", round(swob_df$air_temp, 1), " \u00b0C</td></tr>",
          "<tr><td>Observed at:</td><td>", swob_df$obs_time, "</td></tr>",
          "<tr><td>Network:</td><td>ECCC (federal)</td></tr>",
          "</table>"
        )

        map <- map %>%
          addCircleMarkers(
            data = swob_df,
            lng = ~lon, lat = ~lat,
            radius = 7, color = "black", weight = 1,
            fillColor = pal(swob_df$air_temp),
            fillOpacity = 0.85, opacity = 0.8,
            label = ~merged_name,
            popup = swob_popup,
            group = "ECCC",
            popupOptions = popupOptions(
              autoPan = TRUE, keepInView = TRUE,
              autoPanPaddingTopLeft = c(40, 80),
              autoPanPaddingBottomRight = c(40, 40)
            )
          )
      }

      map %>%
        addLegend(
          position = "bottomright",
          colors = pal(legend_ticks),
          labels = legend_ticks,
          title = "Air temp (\u00b0C)",
          opacity = 1
        ) %>%
        addLayersControl(
          baseGroups = c("CartoDB", "ESRI Satellite"),
          overlayGroups = c("ECC", "ECCC", "NWT boundary", "Mackenzie Basin"),
          options = layersControlOptions(collapsed = TRUE)
        ) %>%
        htmlwidgets::onRender("
  function(el, x) {
    var map = this;
    setTimeout(function() {
      var zoomControl = el.querySelector('.leaflet-control-zoom');
      if (zoomControl) {
        zoomControl.style.cssText = 'position: fixed !important; bottom: 20px !important; left: 10px !important; top: auto !important; z-index: 1000 !important;';
      }
    }, 500);
    map.on('popupopen', function(e) {
      var popup = e.popup.getElement();
      if (popup) {
        popup.classList.add('metadata-popup');
        var wrapper = popup.querySelector('.leaflet-popup-content-wrapper');
        if (wrapper) wrapper.classList.add('metadata-popup-wrapper');
      }
      setTimeout(function() {
        if (e.popup && e.popup._adjustPan) e.popup._adjustPan();
      }, 80);
    });
  }
")
    })


  })
}
