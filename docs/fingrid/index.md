# Finland Energy Consumption Dashboard

![Hopsworks Logo](../titanic/assets/img/logo.png)

{% include fingrid.html %}

## 7-Day Forecast

![Forecast](./assets/img/energy_forecast.png)

## Hindcast - Predictions vs Actual

![Hindcast](./assets/img/energy_hindcast.png)

This dashboard displays the 7-day forecast for Finland's electricity consumption using:
- **Fingrid API**: Real-time energy consumption data (3-minute intervals)
- **Open-Meteo API**: Weather forecast data (temperature, wind, precipitation, etc.)
- **XGBoost Model**: Machine learning model trained on historical consumption patterns

The forecast is updated daily at 6:15 AM UTC through automated GitHub Actions workflows.

## Data Sources

- **Energy Data**: Fingrid Open Data Hub - Dataset 193 (Electricity consumption in Finland)
- **Weather Data**: Open-Meteo Forecast API (Helsinki coordinates)
- **Feature Store**: Hopsworks Feature Store for data versioning and orchestration

## Model Features

The model uses temporal and weather features:
- Temporal: hour, day, month, day of week, weekend indicator, week of year (with cyclic encoding)
- Weather: temperature, wind speed/direction, precipitation, cloud cover, pressure, solar radiation
