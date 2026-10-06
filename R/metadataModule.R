# mapModule.R
# Map / Metadata tab: Leaflet map with ECC and ECCC stations
# Click a station marker to see a popup with metadata

# ---------- UI ----------
metadataUI <- function(id) {
  ns <- NS(id)

  tagList(
    tags$style(HTML(sprintf("
      #%s { height: calc(100vh - 80px) !important; width: 100%% !important; }
      .legend-panel {
        background: white;
        padding: 10px 14px;
        border-radius: 5px;
        box-shadow: 0 0 15px rgba(0,0,0,0.2);
        font-size: 13px;
        line-height: 1.6;
      }
      .legend-dot {
        display: inline-block;
        width: 12px; height: 12px;
        border-radius: 50%%;
        border: 1px solid black;
        margin-right: 6px;
        vertical-align: middle;
      }
    ", ns("map")))),

    leafletOutput(ns("map"), height = "100%")
  )
}

# ---------- Server ----------
metadataServer <- function(id, ecc_metadata, eccc_metadata, preloaded_data) {
  moduleServer(id, function(input, output, session) {

    # ---- Build the leaflet map ----
    output$map <- renderLeaflet({
      ecc  <- ecc_metadata()
      eccc <- eccc_metadata()

      req(preloaded_data())
      shps <- preloaded_data()
      nwt_boundary    <- shps$nwt_boundary
      mackenzie_basin <- shps$mackenzie_basin
      slave <- shps$slave; snare <- shps$snare; YKriver <- shps$YKriver
      peel <- shps$peel; hay <- shps$hay; liard <- shps$liard
      lamartre <- shps$lamartre; willow <- shps$willow; camsell <- shps$camsell
      greatbear <- shps$greatbear; arcticred <- shps$arcticred
      hareind <- shps$hareind; taltson <- shps$taltson


      map <- leaflet() %>%
        carto_tiles(style = "light_all", group = "CartoDB") %>%
        addProviderTiles(providers$Esri.WorldImagery, group = "ESRI Satellite") %>%
        addPolylines(data = nwt_boundary,     weight = 2, color = "#000000", opacity = 0.8, group = "NWT boundary") %>%
        addPolylines(data = mackenzie_basin,  weight = 2, color = "#888888", opacity = 0.8, group = "Mackenzie Basin") %>%
        addPolylines(data = slave,            weight = 2, color = "#999999", opacity = 0.8, group = "Slave Basin") %>%
        addPolylines(data = snare,            weight = 2, color = "#999999", opacity = 0.8, group = "Snare Basin") %>%
        addPolylines(data = YKriver,          weight = 2, color = "#999999", opacity = 0.8, group = "Yellowknife River Basin") %>%
        addPolylines(data = peel,             weight = 2, color = "#999999", opacity = 0.8, group = "Peel Basin") %>%
        addPolylines(data = hay,              weight = 2, color = "#999999", opacity = 0.8, group = "Hay Basin") %>%
        addPolylines(data = liard,            weight = 2, color = "#999999", opacity = 0.8, group = "Liard Basin") %>%
        addPolylines(data = lamartre,         weight = 2, color = "#999999", opacity = 0.8, group = "La Martre River Basin") %>%
        addPolylines(data = willow,           weight = 2, color = "#999999", opacity = 0.8, group = "Willowlake Basin") %>%
        addPolylines(data = camsell,          weight = 2, color = "#999999", opacity = 0.8, group = "Camsell River Basin") %>%
        addPolylines(data = greatbear,        weight = 2, color = "#999999", opacity = 0.8, group = "Great Bear Lake Basin") %>%
        addPolylines(data = arcticred,        weight = 2, color = "#999999", opacity = 0.8, group = "Arctic Red River Basin") %>%
        addPolylines(data = hareind,          weight = 2, color = "#999999", opacity = 0.8, group = "Hare Indian River Basin") %>%
        addPolylines(data = taltson,          weight = 2, color = "#999999", opacity = 0.8, group = "Taltson River Basin") %>%
        setView(lng = -120, lat = 64, zoom = 5)

      # --- ECC markers (blue) ---
      if (!is.null(ecc) && nrow(ecc) > 0) {
        ecc_valid <- ecc %>% filter(!is.na(LATITUDE) & !is.na(LONGITUDE))

        ecc_popup <- build_climate_popup_content(ecc_valid, "ECC")

        map <- map %>%
          addCircleMarkers(
            data = ecc_valid,
            lng = ~LONGITUDE, lat = ~LATITUDE,
            radius = 7, color = "black", fillColor = "#457B9D",
            fillOpacity = 0.8, weight = 1, opacity = 0.8,
            popup = ecc_popup,
            label = ~STATION_NAME,
            group = "ECC Stations",
            popupOptions = popupOptions(autoPan = TRUE,
                                        keepInView = TRUE)
          )
      }

      # --- ECCC markers (blue) ---
      if (!is.null(eccc) && nrow(eccc) > 0) {
        eccc_valid <- eccc %>% filter(!is.na(lat) & !is.na(lon))

        eccc_popup <- build_climate_popup_content(eccc_valid, "ECCC")

        map <- map %>%
          addCircleMarkers(
            data = eccc_valid,
            lng = ~lon, lat = ~lat,
            radius = 7, color = "black", fillColor = "#E63946",
            fillOpacity = 0.8, weight = 1, opacity = 0.8,
            popup = eccc_popup,
            label = ~merged_name,
            group = "ECCC Stations",
            popupOptions = popupOptions(autoPan = TRUE,
                                        keepInView = TRUE)
          )
      }

      # Layer + legend controls
      map <- map %>%
        addLayersControl(
          baseGroups   = c("CartoDB", "ESRI Satellite"),
          overlayGroups = c(
            "ECC Stations",
            "ECCC Stations",
            "NWT boundary",
            "Mackenzie Basin",
            "Arctic Red River Basin",
            "Camsell River Basin",
            "Great Bear Lake Basin",
            "Hare Indian River Basin",
            "Hay Basin",
            "La Martre River Basin",
            "Liard Basin",
            "Peel Basin",
            "Slave Basin",
            "Snare Basin",
            "Taltson River Basin",
            "Willowlake Basin",
            "Yellowknife River Basin"
          ),
          options = layersControlOptions(collapsed = TRUE)
        ) %>%
        hideGroup(c(
          "Slave Basin",
          "Snare Basin",
          "Yellowknife River Basin",
          "Liard Basin",
          "Peel Basin",
          "Hay Basin",
          "La Martre River Basin",
          "Willowlake Basin",
          "Camsell River Basin",
          "Great Bear Lake Basin",
          "Arctic Red River Basin",
          "Hare Indian River Basin",
          "Taltson River Basin"
        )) %>%
        addControl(
          html = paste0(
            '<div class="legend-panel">',
            '<b>Station Networks</b><br/>',
            '<span class="legend-dot" style="background:#457B9D;"></span> ECC (territorial)<br/>',
            '<span class="legend-dot" style="background:#E63946;"></span> ECCC (federal)',
            '</div>'
          ),
          position = "bottomleft"
        )%>%
        htmlwidgets::onRender("
  function(el, x) {
    var map = this;
    map.on('popupopen', function(e) {
      var popup = e.popup.getElement();
      if (popup) {
        popup.classList.add('metadata-popup');
        var wrapper = popup.querySelector('.leaflet-popup-content-wrapper');
        if (wrapper) {
          wrapper.classList.add('metadata-popup-wrapper');
        }
      }
      setTimeout(function() {
        if (e.popup && e.popup._adjustPan) {
          e.popup._adjustPan();
        }
      }, 80);
    });
  }
")

      map
    })
  })
}
