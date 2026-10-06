# content functions for climate app

# Functions for footer_curve and links - About, Download and FAQ tabs

gnwt_footer_graphic <- function() {
  tags$div(
    class = "site-footer__graphic",
    tags$img(
      src = "footer_curve_new2.svg",
      class = "site-footer__curve",
      alt = "",
      `aria-hidden` = "true"
    )
  )
}

gnwt_footer_links <- function(lang = "en") {
  links <- if (lang == "fr") {
    list(
      phone        = c("Répertoire téléphonique", "http://rdirectory.gov.nt.ca/rDirectory.aspx"),
      terms        = c("Modalités d'utilisation", "https://www.gov.nt.ca/en/terms"),
      accessibility = c("Accessibilité", "https://www.gov.nt.ca/accessibility/"),
      contact      = c("Contact", "https://www.gov.nt.ca/contact-gnwt"),
      news         = c("Nouvelles", "https://www.gov.nt.ca/newsroom")
    )
  } else {
    list(
      phone        = c("Phone Directory", "http://rdirectory.gov.nt.ca/rDirectory.aspx"),
      terms        = c("Terms of use", "https://www.gov.nt.ca/en/terms"),
      accessibility = c("Accessibility", "https://www.gov.nt.ca/accessibility/"),
      contact      = c("Contact", "https://www.gov.nt.ca/contact-gnwt"),
      news         = c("News", "https://www.gov.nt.ca/newsroom")
    )
  }

  tags$nav(
    class = "gnwt-footer-links",
    `aria-label` = if (lang == "fr") "Liens du pied de page" else "Footer links",
    lapply(names(links), function(id) {
      tags$a(
        href = links[[id]][2],
        class = paste("gnwt-footer-link", paste0("gnwt-footer-link--", id)),
        links[[id]][1]
      )
    })
  )
}

gnwt_footer_branding <- function(lang = "en") {
  if (lang == "fr") {
    line_small <- "Gouvernement des"
    line_large <- "Territoires du Nord-Ouest"
  } else {
    line_small <- "Government of"
    line_large <- "Northwest Territories"
  }

  tags$div(
    class = "site-footer__branding",
    tags$a(
      href = "https://www.gov.nt.ca/",
      class = "site-footer__brand",
      tags$div(class = "site-footer__brand-line site-footer__brand-line--small", line_small),
      tags$div(class = "site-footer__brand-line site-footer__brand-line--large", line_large)
    )
  )
}

# new fun for navbar to match open gov website
gnwt_navbar_wordmark <- function(lang = "en") {
  if (lang == "fr") {
    line_small <- "Gouvernement des"
    line_large <- "Territoires du Nord-Ouest"
  } else {
    line_small <- "Government of"
    line_large <- "Northwest Territories"
  }

  tags$div(
    class = paste(
      "navbar-gnwt-brand",
      if (lang == "fr") "navbar-gnwt-brand--fr" else "navbar-gnwt-brand--en"
    ),
    tags$div(class = "navbar-gnwt-brand-line navbar-gnwt-brand-line--small", line_small),
    tags$div(class = "navbar-gnwt-brand-line navbar-gnwt-brand-line--large", line_large)
  )
}

gnwt_footer_ui <- function(lang = "en") {
  tags$footer(
    class = "site-footer tab-footer-curve-stack",
    gnwt_footer_graphic(),
    tags$div(
      class = "site-footer__content",
      tags$div(
        class = "site-footer__inner",
        gnwt_footer_links(lang),
        gnwt_footer_branding(lang)
      )
    )
  )
}

# cartoDB helper function
carto_tiles <- function(map, style = "light_all", group = "CartoDB") {
  key <- Sys.getenv("CARTO_API_KEY")          # match your .Renviron name
  if (!nzchar(key)) stop("CARTO_API_KEY not set in .Renviron")

  leaflet::addTiles(
    map,
    urlTemplate = sprintf(
      "https://{s}.basemaps.cartocdn.com/rastertiles/%s/{z}/{x}/{y}.png?key=%s",
      style, key),
    attribution = paste0(
      '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a>, ',
      '&copy; <a href="https://carto.com/attributions">CARTO</a>'),
    group = group,
    options = leaflet::tileOptions(subdomains = "abcd", maxZoom = 20)
  )
}

# Function to create about content
create_about_content <- function(lang) {
  if(lang == "fr") {
    HTML("<div style='font-size: 14px;'>

  <h2 style='font-weight: bold; font-size: 24px; margin-bottom: 20px;'>Bienvenue dans l'Explorateur des données climatiques des Territoires du Nord-Ouest</h2>

</div>")
  } else {
    HTML("<div style='font-size: 14px;'>

  <h2 style='font-weight: bold; font-size: 24px; margin-bottom: 20px;'>Welcome to the Northwest Territories Climate Data Explorer</h2>

  <p style='font-size: 16px; line-height: 1.6;'>This Explorer hosts climate data from across the Northwest Territories (NWT). Users can view station information on an interactive map and download data as CSV files.</p>

  <div style='margin-top: 25px; padding-top: 20px; border-top: 1px solid #0066cc;'>
    <h3 style='font-size: 18px; font-weight: bold; margin-top: 25px; margin-bottom: 10px;'>About</h3>

    <p style='font-size: 15px; line-height: 1.6;'>Climate records in this Explorer come from two networks:</p>

    <ul style='font-size: 15px; line-height: 1.6; padding-left: 20px; margin-top: 10px;'>
      <li><strong>ECC (territorial):</strong> Hourly climate data from the GNWT&ndash;ECC monitoring network. GNWT&ndash;ECC operates and maintains these territorial stations and makes this network available through this Explorer.</li>
      <li><strong>ECCC (federal):</strong> Daily climate data from ECCC stations, presented here as a stitched and merged dataset (one daily series per location). GNWT&ndash;ECC compiles and merges these records for use in this Explorer; data remain subject to ECCC&rsquo;s terms and may differ from ECCC&rsquo;s own releases.</li>
    </ul>

    <p style='font-size: 15px; line-height: 1.6;'>More detail on the ECCC stitched and merged dataset, data collection, and usage will be available on the <strong>Download Data</strong> tab and in the FAQ (forthcoming).</p>
  </div>

  <div style='margin-top: 25px; padding-top: 20px; border-top: 1px solid #0066cc;'>
    <h3 style='font-size: 18px; font-weight: bold; margin-top: 25px; margin-bottom: 10px;'>Explore the Data</h3>

    <p style='font-size: 15px; line-height: 1.6;'>Open the <strong>Station Map</strong> to view ECC and ECCC stations across the NWT. The map shows two station networks:</p>

    <ul style='padding-left: 20px; margin-top: 10px; font-size: 15px; line-height: 1.6;'>
<li><span style='display:inline-block; width:14px; height:14px; border-radius:50%; background:#457B9D; border:1px solid black; opacity:0.8; margin-right:6px; vertical-align:middle;'></span> <strong>ECC (territorial)</strong></li>
<li><span style='display:inline-block; width:14px; height:14px; border-radius:50%; background:#E63946; border:1px solid black; opacity:0.8; margin-right:6px; vertical-align:middle;'></span> <strong>ECCC (federal)</strong></li>
    </ul>

    <div style='font-size: 15px; font-weight: bold; margin-top: 15px; margin-bottom: 10px;'>Data interpretation:</div>

    <ul style='padding-left: 20px; margin-top: 10px; font-size: 15px; line-height: 1.6;'>
      <li><strong>Click stations</strong> on the map to view metadata, including location, years of record, and available climate variables.</li>
      <li><strong>Network colours</strong> distinguish territorial (ECC) and federal (ECCC) stations; they do not indicate whether values are above or below average.</li>
      <li>Use the layer control to switch base maps (for example, CartoDB or satellite imagery).</li>
    </ul>
  </div>

  <div style='margin-top: 25px; padding-top: 20px; border-top: 1px solid #0066cc;'>
    <h3 style='font-size: 18px; font-weight: bold; margin-top: 25px; margin-bottom: 10px;'>Download Data</h3>

    <p style='font-size: 15px; line-height: 1.6;'>On the <strong>Download Data</strong> tab, select a network (ECC or ECCC), station, year, and parameters, then download a CSV file. ECC data are sub-daily (hourly); ECCC data are daily. The download page includes a data disclaimer and additional notes on the ECCC stitched and merged product.</p>
  </div>

</div>")
  }
}

# Import rds shp files from GitHub
load_github_rdsshp <- function(filename) {
  github_url <- paste0("https://raw.githubusercontent.com/M-Auclair/nwtclimate/main/data/shapefiles/", filename)
  temp_file <- tempfile(fileext = ".rds")
  download.file(github_url, temp_file, mode = "wb", quiet = TRUE)
  data <- readRDS(temp_file)
  unlink(temp_file)
  data
}


# Station map / metadata tab
build_climate_popup_content <- function(df, network) {
  if (network == "ECC") {
    name  <- df$STATION_NAME
    lat   <- df$LATITUDE
    lon   <- df$LONGITUDE
    elev  <- df$ELEVATION
    start <- df$data_start_year
    end   <- df$data_end_year
  } else {
    name  <- df$merged_name
    lat   <- df$lat
    lon   <- df$lon
    elev  <- NA
    start <- df$start_year
    end   <- df$end_year
  }
  vars <- df$available_params

  elev_row <- if (network == "ECC") {
    ifelse(!is.na(elev),
           paste0("<tr><td>Elevation:</td><td>", elev, " m</td></tr>"),
           "")
  } else {
    ""
  }

  years_row <- ifelse(
    !is.null(start) & !is.na(start),
    paste0("<tr><td>Years:</td><td>", start, " \u2013 ", end, "</td></tr>"),
    ""
  )

  vars_row <- ifelse(
    !is.null(vars) & !is.na(vars) & vars != "",
    paste0("<tr><td>Variables:</td><td>", vars, "</td></tr>"),
    ""
  )

  paste0(
    "<div>",
    "<div class='metadata-header'>", name, "</div>",
    "<table class='metadata-table'>",
    "<tr><td>Network:</td><td>", network, "</td></tr>",
    "<tr><td>Latitude:</td><td>", round(lat, 4), "</td></tr>",
    "<tr><td>Longitude:</td><td>", round(lon, 4), "</td></tr>",
    elev_row,
    years_row,
    vars_row,
    "</table>",
    "</div>"
  )
}

# Download tab
create_climate_disclaimer_content <- function() {
  HTML("
    <h4 style='font-weight: bold; font-size: 18px; margin-bottom: 10px;'>Data Disclaimer</h4>
    <p><strong>Climate data are provisional and subject to revision.</strong></p>
    <ul>
      <li>Values may be affected by equipment malfunctions or environmental conditions.</li>
      <li>Not all parameters are available at all stations or years.</li>
      <li>Quality-control flags are included where available.</li>
      <li><strong>ECC (territorial):</strong> sub-daily (hourly) data from the GNWT&ndash;ECC monitoring network.</li>
      <li><strong>ECCC (federal):</strong> daily data from ECCC stations, presented here as a stitched and merged dataset (one daily series per location). GNWT&ndash;ECC compiles and merges these records for use in this Explorer; data remain subject to ECCC&rsquo;s terms and may differ from ECCC&rsquo;s own releases.</li>
    </ul>
  ")
}


## DATA SUMMARY MAP ##

# ---- Private Update_Climate ECC loaders ---------------------------------

## ECC
# check for token
github_climate_token <- function() {
  tok <- Sys.getenv("UPDATE_CLIMATE_PAT")
  if (!nzchar(tok)) {
    stop("UPDATE_CLIMATE_PAT is not set. Locally use ~/.Renviron; on Connect Cloud use a secret variable.")
  }
  tok
}

#search for _new.rds files
list_ecc_github_files <- function(ref = "main") {
  files <- gh::gh(
    "GET /repos/nwtgov/Update_Climate/contents/data/ECC",
    ref = ref,
    .token = github_climate_token()
  )
  nms <- vapply(files, function(x) x$name, character(1))
  nms[grepl("_FTS_new\\.rds$", nms, ignore.case = TRUE)]
}

load_ecc_github_rds <- function(filename, ref = "main") {
  meta <- gh::gh(
    "GET /repos/nwtgov/Update_Climate/contents/data/ECC/{file}",
    file = filename,
    ref = ref,
    .token = github_climate_token()
  )
  tmp <- tempfile(fileext = ".rds")
  on.exit(unlink(tmp), add = TRUE)
  httr2::request(meta$download_url) |>
    httr2::req_auth_bearer_token(github_climate_token()) |>
    httr2::req_perform(path = tmp)
  readRDS(tmp)
}

latest_ecc_air_temp <- function(filenames, ref = "main") {
  rows <- lapply(filenames, function(f) {
    df <- tryCatch(
      load_ecc_github_rds(f, ref = ref),
      error = function(e) {
        message("Skip ", f, ": ", conditionMessage(e))
        NULL
      }
    )
    if (is.null(df) || !"T_AIR_HIGH_C" %in% names(df)) return(NULL)

    df <- df %>% dplyr::filter(!is.na(T_AIR_HIGH_C))
    if (nrow(df) == 0) return(NULL)

    if ("Date" %in% names(df)) {
      df <- df %>% dplyr::arrange(dplyr::desc(Date))
    } else {
      df <- df %>%
        dplyr::arrange(
          dplyr::desc(CD_YEAR), dplyr::desc(CD_MONTH),
          dplyr::desc(CD_DAY), dplyr::desc(CD_TIME)
        )
    }

    df %>%
      dplyr::slice(1) %>%
      dplyr::transmute(
        STATION_NAME = as.character(STATION_NAME),
        obs_time = if ("Date" %in% names(df)) {
          stored <- lubridate::as_datetime(Date[1], tz = "UTC")
          utc <- stored + lubridate::hours(6)
          mt <- lubridate::with_tz(utc, "America/Edmonton")
          format(mt, "%Y-%m-%d %H:%M %Z")
        } else {
          sprintf("%04d-%02d-%02d %s", CD_YEAR, CD_MONTH, CD_DAY, CD_TIME)
        },
        T_AIR_HIGH_C = T_AIR_HIGH_C
      )
  })
  dplyr::bind_rows(rows)
}

# ECCC SWOB
load_eccc_github_rds <- function(filename, ref = "main") {
  meta <- gh::gh(
    "GET /repos/nwtgov/Update_Climate/contents/data/ECCC/{file}",
    file = filename,
    ref = ref,
    .token = github_climate_token()
  )
  tmp <- tempfile(fileext = ".rds")
  on.exit(unlink(tmp), add = TRUE)
  httr2::request(meta$download_url) |>
    httr2::req_auth_bearer_token(github_climate_token()) |>
    httr2::req_perform(path = tmp)
  readRDS(tmp)
}

add_eccc_latlon <- function(swob, metadata) {
  coords <- metadata %>%
    dplyr::mutate(merged_name = as.character(merged_name)) %>%
    dplyr::distinct(merged_name, .keep_all = TRUE) %>%
    dplyr::select(merged_name, lat, lon)
  swob %>%
    dplyr::mutate(merged_name = as.character(merged_name)) %>%
    dplyr::left_join(coords, by = "merged_name")
}

latest_swob_air_temp <- function(swob) {
  swob %>%
    dplyr::filter(!is.na(air_temp), !is.na(time)) %>%
    dplyr::arrange(dplyr::desc(time)) %>%
    dplyr::distinct(merged_name, .keep_all = TRUE) %>%
    dplyr::transmute(
      merged_name = as.character(merged_name),
      station_name = as.character(station_name),
      obs_time = format(
        lubridate::with_tz(time, "America/Edmonton"),
        "%Y-%m-%d %H:%M %Z"
      ),
      air_temp = air_temp,
      lat = lat,
      lon = lon
    )
}



