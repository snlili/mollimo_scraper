### Get the map
library(dplyr)
library(stringr)
library(jsonlite)
library(sf)
library(httr)

get_map <- function() {
  url <- paste0("https://mollimo.hu/data/homezones.js")
  resp <- GET(url, user_agent("Mozilla/5.0"),
              timeout(30))
  txt <- content(resp, as = 'text', encoding = 'UTF-8')
  
  json <- txt %>% 
    str_remove("window\\.homezones\\s*=\\s*") %>% 
    str_remove(";\\s*$")
  
  services <- fromJSON(json, simplifyVector = FALSE)
  
  # The zones are given as Geo JSON collections
  zones <- lapply(services, function(s) {
    geojson <- toJSON(s$zone, auto_unbox = TRUE, digits = NA)
    z <- st_read(geojson, quiet = TRUE)
    z$service_type <- s$serviceType
    z[, c("name", "type", "service_type")]
  })
  
}
