# dependencies.R

# ---------------------------------------------------------------------------
# Helper: human-readable parameter labels
# Used by both the map popup (to list available variables) and the download
# module (for checkbox labels and CSV column names).
# ---------------------------------------------------------------------------

# ECC parameter lookup: short column name -> display name
ecc_param_labels <- c(
  "T_AIR_HIGH_C"      = "Air Temperature (\u00b0C)",
  "T_AIR_LOW_C"       = "Air Temperature \u2013 lower sensor (\u00b0C)",
  "RAIN_MM"           = "Rain (mm)",
  "RH_HIGH_PER"       = "Relative Humidity (%)",
  "RH_LOW_PER"        = "Relative Humidity \u2013 lower sensor (%)",
  "WIND_SP_MS"        = "Wind Speed (m/s)",
  "WIND_DIR_DEG"      = "Wind Direction (\u00b0)",
  "SW_IN_WM2"         = "Incoming Shortwave Radiation (W/m\u00b2)",
  "NET_SW_WM2"        = "Net Shortwave Radiation (W/m\u00b2)",
  "NET_LW_WM2"        = "Net Longwave Radiation (W/m\u00b2)",
  "RN_WM2"            = "Net Radiation (W/m\u00b2)",
  "SR50_CM"           = "Snow Depth SR50 (cm)",
  "T_SOIL_1_C"        = "Ground Temperature 1 (\u00b0C)",
  "T_SOIL_2_C"        = "Ground Temperature 2 (\u00b0C)",
  "T_SOIL_3_C"        = "Ground Temperature 3 (\u00b0C)",
  "T_SOIL_4_C"        = "Ground Temperature 4 (\u00b0C)",
  "T_SOIL_5_C"        = "Ground Temperature 5 (\u00b0C)",
  "T_SOIL_6_C"        = "Ground Temperature 6 (\u00b0C)",
  "T_WATER_C"         = "Water Temperature (\u00b0C)",
  "T_WATER_2_C"       = "Water Temperature 2 (\u00b0C)",
  "WATER_DEPTH_M"     = "Water Depth (m)",
  "WATER_DEPTH_CORR_M"= "Corrected Water Depth (m)",
  "BARO_PRESSURE_MBAR"= "Barometric Pressure (mbar)"
)

# ECCC parameter lookup
eccc_param_labels <- c(
  "mean_temp"    = "Mean Temperature (\u00b0C)",
  "max_temp"     = "Max Temperature (\u00b0C)",
  "min_temp"     = "Min Temperature (\u00b0C)",
  "total_precip" = "Total Precipitation (mm)",
  "total_rain"   = "Total Rain (mm)",
  "total_snow"   = "Total Snow (cm)",
  "snow_grnd"    = "Snow on Ground (cm)",
  "spd_max_gust" = "Max Gust Speed (km/h)",
  "dir_max_gust" = "Max Gust Direction (\u00b0)",
  "heat_deg_days"= "Heating Degree Days",
  "cool_deg_days"= "Cooling Degree Days"
)
