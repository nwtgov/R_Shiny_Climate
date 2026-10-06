# NWT Climate Data Explorer -- Starting Structure

A Shiny web application for exploring and downloading Northwest Territories
climate data from two monitoring networks:

- **ECC** (territorial) -- ~89 sub-daily FTS stations operated by the
  Government of the Northwest Territories
- **ECCC** (federal) -- ~45 daily stations from Environment and Climate Change
  Canada

## Folder structure

```
Starting_Climate_Structure/
|-- app.R                        # Main Shiny app entry point
|-- R/
|   |-- dependencies.R           # Package install / load + param label lookups
|   |-- metadataModule.R              # Tab 1: interactive Leaflet map with popups
|   |-- downloadModule.R         # Tab 2: select & download data as CSV
|-- data/
|   |-- ECC/                     # Per-station RDS files  (e.g. 1_BDL.rds)
|   |-- ECCC/                    # ECCC_Climate_Data_Merged.rds
|   |-- metadata/
|       |-- cd_stations.csv      # ECC station coordinates & metadata
|       |-- cd_data_types.csv    # ECC parameter definitions
|       |-- data_flags.csv       # ECC QC flag lookup
|       |-- ECCC_sites.csv       # ECCC station coordinates
|-- update_scripts/
|   |-- update_ECCC.R            # Pipeline: update -> filter -> stitch -> merge
|   |-- update_ECC.R             # FTS360 API download + QC flagging
|-- www/
|   |-- logo_PB.png              # App logo
|-- README.md                    # This file
```

## Quick start

### 1. Data files (already in place)

The data files are already in the correct locations:

- `data/ECC/` -- 89 per-station RDS files (sub-daily ECC data)
- `data/ECCC/ECCC_Climate_Data_Merged.rds` -- merged ECCC daily data
- `data/metadata/cd_stations.csv` -- ECC station coordinates & metadata
- `data/metadata/cd_data_types.csv` -- ECC parameter definitions
- `data/metadata/data_flags.csv` -- ECC QC flag lookup
- `data/metadata/ECCC_sites.csv` -- ECCC station coordinates

### 2. Install R dependencies

Open `R/dependencies.R` in RStudio -- it will auto-install any missing
CRAN packages on first run.  Required packages:

shiny, leaflet, dplyr, sf, ggplot2, shinyjs, DT, waiter, lubridate,
tidyr, readr

### 3. Run the app

Open `app.R` in RStudio and click **Run App**, or from the R console:

```r
shiny::runApp("Starting_Climate_Structure")
```

## App features (v1 -- starting point)

| Tab | What it does |
|-----|-------------|
| **Station Map** | Leaflet map with red markers (ECC) and blue markers (ECCC). Click any marker to see a popup with station name, coordinates, elevation, year range, and available parameters. Toggle layers on/off. |
| **Download Data** | Pick a network (ECC / ECCC), station, year, and parameters. Downloads a tidy CSV with one row per observation per parameter, including QC flags. |

## Updating the data

Both update scripts are in `update_scripts/` and are designed to run as
standalone R scripts -- either manually or via **GitHub Actions**.

### ECCC (federal) data -- `update_ECCC.R`

Runs the nwtclimate package pipeline (`update -> filter -> stitch ->
nt_merge`) and copies the final `ECCC_Climate_Data_Merged.rds` into
`data/ECCC/`.

Requires the **nwtclimate** and **hydroclim** package source trees.
Set paths via environment variables or edit the script header:

| Variable | Default |
|----------|---------|
| `NWTCLIMATE_PATH` | `C:/Users/Emma_Gregory/Documents/R_Scripts/Packages/nwtclimate/` |
| `HYDROCLIM_PATH`  | `C:/Users/Emma_Gregory/Documents/R_Scripts/Packages/hydroclim/` |

### ECC (territorial) data -- `update_ECC.R`

Downloads new data from the **FTS360 API**, applies QC flags, and
appends to the per-station RDS files in `data/ECC/`.

Requires FTS360 credentials (set via environment variables):

| Variable | Description |
|----------|-------------|
| `FTS_EMAIL` | FTS360 account email |
| `FTS_PASSWORD` | FTS360 account password |
| `FTS_START_DATE` | (optional) ISO datetime, defaults to yesterday |
| `FTS_END_DATE` | (optional) ISO datetime, defaults to today |

### GitHub Actions (recommended for automation)

Since this app will likely be hosted on a free-tier server (e.g.
shinyapps.io), scheduled data updates can be handled by a GitHub Action
that:

1. Checks out the repo
2. Installs R + dependencies
3. Runs `Rscript update_scripts/update_ECCC.R` and/or
   `Rscript update_scripts/update_ECC.R`
4. Commits and pushes updated RDS files back to the repo
5. (Optional) triggers a re-deploy to shinyapps.io

A cron schedule like `0 8 * * *` (daily at 8 AM UTC) works well for
keeping data reasonably current.

## Future enhancements

- Add interactive time-series plots (click station -> modal with
  ggplot/plotly chart, percentile bands, water-year toggle)
- Add barometric pressure to the ECC download
  (noted in `update_ECC.R` -- needs FTS360 field IDs)
- Add a station metadata editing / admin interface
- Add map overlays (drainage basins, etc.)


