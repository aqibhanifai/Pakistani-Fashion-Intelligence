# Quick Start Guide

This repository is already organized for GitHub and for classroom/portfolio use.

## 1. Requirements

Install Python 3 and Jupyter Notebook, then install the project libraries:

```bash
pip install -r requirements.txt
```

For the SQL stage, install PostgreSQL and use pgAdmin, VS Code, or another PostgreSQL client.

## 2. Run the Web Scraping Notebook

Open:

```text
01_Fashion_Web_Scraping_Aqib_Hanif.ipynb
```

Run the notebook from top to bottom. It saves:

```text
01_raw_fashion_products.csv
```

The repository already includes the project snapshot, so re-scraping is optional.

## 3. Run Data Cleaning and Feature Engineering

Open:

```text
02_Data_Cleaning_Feature_Engineering_Aqib_Hanif.ipynb
```

It reads the raw CSV and creates:

```text
02_processed_fashion_products.csv
```

## 4. Run PostgreSQL Analysis

Open:

```text
03_PostgreSQL_Analysis_Aqib_Hanif.sql
```

Follow the comments inside the SQL file. The script creates a PostgreSQL database named:

```text
fashion_analytics
```

and works with the main table:

```text
fashion_products
```

Import `02_processed_fashion_products.csv` when the SQL file instructs you to do so.

## 5. Run the Peshawar Weather API Notebook

Open:

```text
04_Peshawar_Weather_API_Aqib_Hanif.ipynb
```

Open-Meteo does not require an API key. The notebook saves:

```text
04_current_peshawar_weather.csv
04_peshawar_seasonal_context.csv
```

## 6. Open the Final Dashboard

Open:

```text
05_Pakistani_Fashion_Intelligence_Dashboard_Aqib_Hanif.xlsx
```

Use the dashboard filters to explore brands, categories, collections, availability, and price segments.

## 7. Report and Presentation

Use these files for documentation and presentation:

```text
06_Project_Report_Aqib_Hanif.pdf
07_Project_Presentation_Aqib_Hanif.pptx
```


Recommended GitHub topics:

```text
data-analysis
python
postgresql
sql
excel
jupyter-notebook
web-scraping
pandas
beautifulsoup
data-cleaning
data-visualization
dashboard
fashion-analytics
portfolio-project
```
