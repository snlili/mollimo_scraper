# MOL Limo car-sharing scraper

Collects the locations of available [MOL Limo](https://mollimo.hu/hu/carsharing) car-sharing cars in Budapest every 30 minutes, to study when and where the cars are used.

Written in R as a project for an *Introduction to R* course.

## How it works

The map on the MOL Limo website is drawn from one file:

```
https://mollimo.hu/data/cars.js
```

It contains every **available** car as JSON.

1. `scrape_cars.R` downloads `cars.js`, removes the `window.cars =` wrapper with a regex and parses the JSON with `jsonlite`.
2. The cars are saved as one timestamped CSV per run in `mollimo_data/`.
3. **GitHub Actions** runs the script and commits the new CSV to this repository.
4. **cron-job.org** starts the GitHub workflow every 30 minutes through the GitHub API
   (GitHub's own `schedule` trigger turned out to be too irregular).

```
cron-job.org ──(every 30 min)──▶ GitHub Actions ──▶ scrape_cars.R ──▶ mollimo_data/cars_*.csv
```

## Data

Each CSV has one row per available car:

| Column | Description |
|---|---|
| `scraped_at` | time of the snapshot (Europe/Budapest) |
| `id` | unique car ID |
| `plate` | licence plate |
| `model` | car model, e.g. *Toyota Yaris*, *Kia Picanto* |
| `lat`, `lon` | position of the car (WGS84) |
| `energy_level` | fuel/charge level as given by the website (unit unknown, use only relatively) |
| `is_charging` | whether an electric car is charging |


Requires the R packages `httr` and `jsonlite`.

## Disclaimer

This is a student project. The data comes from the publicly available MOL Limo website
and is collected at a low frequency (one request every 30 minutes) for educational purposes only.
This project is not affiliated with MOL Limo.
