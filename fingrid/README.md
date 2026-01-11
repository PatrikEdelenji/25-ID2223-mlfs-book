# Fingrid Energy Consumption Forecasting Project

This project demonstrates a complete machine learning forecasting system for Finland's electricity consumption using data from Fingrid (the Finnish Transmission System Operator) and Open-Meteo weather data.

## Overview

The system builds and maintains predictive models for energy consumption, retrains them regularly with new data, and provides daily 7-day ahead forecasts. It uses Hopsworks Feature Store for data management and XGBoost for predictions.

## Architecture

The project consists of four main notebooks:

1. **1_backfill_feature_group.ipynb** - Initial setup that backfills historical data from Fingrid API and Open-Meteo weather API into the feature store. This runs once to populate baseline data.

2. **2_daily_feature_pipeline.ipynb** - Daily scheduled pipeline that fetches the latest day's energy consumption and next 7 days of weather forecast. Calculates lag features and inserts new data into feature groups. Should be scheduled to run every day.

3. **3_training_pipeline.ipynb** - Retrains four different XGBoost models using accumulated historical data:
   - Baseline model (no lag features)
   - 1-day lag model (24-hour consumption history)
   - 2-day lag model (48-hour consumption history)
   - 3-day lag model (72-hour consumption history)

4. **4_inference_pipeline.ipynb** - Makes daily predictions using all four trained models on the next 7 days of weather forecast. Stores predictions for monitoring, generates forecast visualization, and creates a hindcast chart comparing 1-day-ahead predictions against actual consumption.

## Data

- **Energy consumption**: Fingrid API (dataset ID 193) - hourly electricity consumption for Finland
- **Weather data**: Open-Meteo API - hourly weather forecasts and historical data including temperature, precipitation, cloud cover, wind speed, pressure, and radiation
- **Location**: Helsinki, Finland (60.1695°N, 24.9354°E)

## Features

The models use temporal features (year, month, day, hour, day-of-week, weekend flag, week-of-year) combined with weather variables and lag features derived from consumption history.

## Deployment

Predictions and monitoring data are stored in Hopsworks Feature Store for tracking model performance over time. Visualization assets (forecast and hindcast charts) are uploaded to Hopsworks for monitoring.