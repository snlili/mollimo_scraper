library(httr)
library(jsonlite)
Sys.setenv(TZ = "Europe/Budapest")

get_limo_cars <- function() {
  url <- paste0("https://mollimo.hu/data/cars.js?", as.integer(Sys.time()))
  resp <- GET(url, user_agent("Mozilla/5.0"),
              timeout(30))
  stop_for_status(resp)
  txt <- content(resp, as = 'text', encoding = 'UTF-8')
  
  # Extract the cars
  json <- sub("^\\s*window\\.cars\\s*=\\s*", "", txt)
  json <- sub(";\\s*$", "", json)
  cars <- fromJSON(json, flatten = TRUE)
  
  # Compile the dataframe
  data.frame(
    scraped_at = Sys.time(),
    id = cars$description.id,
    plate = cars$description.plate,
    model = cars$description.model,
    lat = cars$location.position.lat, # Current coordinates
    lon = cars$location.position.lon,
    energy_level = cars$status.energyLevel,
    is_charging = cars$status.isCharging
  )
}

## Scrape function: create a foldeer inside my project folder, with log and the CSVs

scrape <- 
  function(folder = 'scrape_data') {
    dir.create(folder, showWarnings = FALSE, recursive = TRUE) # Make the folder for the files
    
    log_file <- file.path(folder, "scrape_log.txt")
    log_message <- function(...) {
      line <- paste0(format(Sys.time(), "%Y-%m-%d %H:%M:%S"), " ", ...)
      cat(line, "\n", file = log_file, append = TRUE)
      message(line)
    }
    
    df <- tryCatch(get_limo_cars(), error = function(e) {
      log_message("FAILED: ", conditionMessage(e))
      NULL
    })
    if (is.null(df) || nrow(df) == 0) return(invisible(NULL))
    
    fname <- file.path(folder, paste0("cars_", format(Sys.time(), 
                                                      "%Y-%m-%d_%H%M"), ".csv"))
    write.csv(df, fname, row.names = FALSE)
    log_message("Scraping OK ", nrow(df), " cars: ", basename(fname))
    invisible(df)
  }

if (sys.nframe() == 0)
  scrape("mollimo_data")
