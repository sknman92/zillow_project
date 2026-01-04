# Zillow Real Estate Data Pipeline with dbt

End-to-end data pipeline for Zillow real estate listings, from web scraping to analytical modeling with dbt and MCP integration.

## Project Overview

This project demonstrates a complete modern data stack workflow:

1. **Web Scraping** - Automated Selenium-based extraction of Zillow listing data
2. **Cloud Storage** - Raw data uploaded to AWS S3 bucket
3. **Data Warehouse** - Transfer to Snowflake for analytics-ready storage
4. **Transformation Layer** - dbt models with staging, intermediate, and mart layers
5. **MCP Integration** - Connected to dbt Model Context Protocol for enhanced development
6. **Advanced Features** - Custom macros for Period-over-Period analytics and unit testing

---

## Architecture

```
Zillow Website
    ↓ (Selenium scraper)
Raw CSV Data
    ↓ (upload.py)
AWS S3 Bucket
    ↓ (Snowflake COPY)
Snowflake Raw Tables
    ↓ (dbt transformations)
Analytics-Ready Models
```

---

## 1. Data Extraction with Selenium

The `extract.py` script uses Selenium WebDriver to scrape Zillow listing data:

- Extracts property details (price, location, type, inventory metrics)
- Handles dynamic page loading and pagination
- Outputs CSV files to the `data/` directory

**Key files:**

- `extract.py` - Main scraper logic
- `data/for_sale_listings_*.csv` - Output files

---

## 2. S3 Upload Pipeline

The `upload.py` script manages data transfer to AWS:

- Uploads CSV files from `data/` to S3 bucket
- Maintains data versioning and folder structure
- Configurable via `.env` for credentials

**Environment variables required:**

```
AWS_ACCESS_KEY_ID
AWS_SECRET_ACCESS_KEY
S3_BUCKET_NAME
```

---

## 3. Snowflake Data Warehouse

Raw data is loaded into Snowflake using:

- `COPY INTO` commands from S3 stage
- Dedicated `raw_zillow` schema for source tables
- File format definitions for CSV ingestion

---

## 4. dbt MCP Integration

This project leverages the dbt Model Context Protocol (MCP) for enhanced development:

- Real-time model introspection and metadata
- Automated YAML generation for model documentation
- Command execution through MCP tools
- Semantic layer integration

**MCP Tools Used:**

- `mcp_dbt_generate_model_yaml` - Auto-generate schema files
- `mcp_dbt_compile` / `mcp_dbt_run` - Build and execute models
- `mcp_dbt_test` - Run data quality tests

---

## 5. dbt Model Layers

### Staging Layer (`models/staging_zillow/`)

- **Purpose:** Clean and standardize raw Zillow data
- **Naming:** `stg_zillow__<table>`
- **Transformations:** Type casting, column renaming, basic filters

### Intermediate Layer (`models/intermediate_zillow/`)

- **Purpose:** Business logic and data enrichment
- **Key Model:** `int_zillow__for_sale_unioned`
  - Unions SFR and all-homes listings
  - Adds property type classification
  - Deduplicates records

### Marts Layer (`models/marts_zillow/`)

- **Purpose:** Analytics-ready tables for end users
- **Key Model:** `marts_zillow__PoP_metrics`
  - Period-over-Period (PoP) analysis
  - Quarterly and yearly metrics
  - Percentage change calculations

---

## 6. Custom Macros & Testing

### PoP Template Macro (`macros/PoP_template.sql`)

Reusable Jinja macro for calculating Period-over-Period metrics:

```sql
{{ PoP_template(
    table = 'unioned_model',
    metric_col = 'forsaleinventory',
    frequency = 'quarter',
    partition = ['cityname', 'statename', 'property_type']
) }}
```

**Features:**

- Configurable time frequency (quarter, year, month)
- Dynamic partitioning by dimensions
- Automatic calculation of value and percentage change
- LAG window function for previous period comparison

### Unit Testing

**Data Quality Tests:**

- Unique and not-null constraints on key columns
- Relationships tests for referential integrity
- Custom tests for join validation

**Example:** `_int_zillow__unit_test.yml`

```yaml
unit_tests:
  - name: int_zillow_unit_test
    description: "testing city name in int zillow models"
    model: int_zillow__for_sale_unioned
    given:
      - input: ref('stg_zillow__for_sale_all_homes')
        rows:
          - { regionname: "San Francisco, CA" }
          - { regionname: "United States" }
      - input: ref('stg_zillow__for_sale_sfr')
        rows:
          - { regionname: "CA" }
    expect:
      rows:
        - { regionname: "San Francisco, CA", cityname: "San Francisco" }
        - { regionname: "United States", cityname: null }
        - { regionname: "CA", cityname: null }
```

This unit test validates the city name extraction logic by mocking input data and asserting expected transformations.

---

## Project Structure

```
├── data/                       # Raw CSV files from Zillow
├── macros/
│   ├── PoP_template.sql       # Period-over-Period macro
│   └── convert_money.sql      # Currency conversion utilities
├── models/
│   ├── staging_zillow/        # Staging layer models
│   ├── intermediate_zillow/   # Intermediate transformations
│   └── marts_zillow/          # Analytics marts
├── tests/                      # Custom dbt tests
├── extract.py                  # Selenium web scraper
├── upload.py                   # S3 upload script
├── utils.py                    # Shared utilities
├── dbt_project.yml            # dbt configuration
└── requirements.txt           # Python dependencies
```

---

## Setup & Installation

### Prerequisites

- Python 3.8+
- dbt Core 1.11+
- Snowflake account
- AWS S3 bucket

### Installation

1. Clone the repository:

```bash
git clone https://github.com/sknman92/zillow_dbt.git
cd zillow_dbt
```

2. Create virtual environment:

```bash
python -m venv venve
venve\Scripts\activate  # Windows
source venve/bin/activate  # Mac/Linux
```

3. Install dependencies:

```bash
pip install -r requirements.txt
```

4. Configure `.env`:

```
AWS_ACCESS_KEY_ID=your_key
AWS_SECRET_ACCESS_KEY=your_secret
S3_BUCKET_NAME=your_bucket
```

5. Install dbt packages:

```bash
dbt deps
```

---

## Usage

### 1. Extract Zillow Data

```bash
python extract.py
```

### 2. Upload to S3

```bash
python upload.py
```

### 3. Load to Snowflake

```sql
-- Run Snowflake COPY commands to ingest from S3
COPY INTO raw_zillow.for_sale_listings
FROM @s3_stage/for_sale_listings.csv
FILE_FORMAT = (TYPE = CSV SKIP_HEADER = 1);
```

### 4. Run dbt Models

```bash
# Compile models
dbt compile

# Run staging layer
dbt run -s staging_zillow

# Run full pipeline
dbt build

# Test data quality
dbt test
```

### 5. Generate Documentation

```bash
dbt docs generate
dbt docs serve
```

---

## Key Features

✅ **Automated Web Scraping** - Selenium-based extraction with error handling  
✅ **Cloud-Native Storage** - S3 integration for scalable data lake  
✅ **Enterprise DWH** - Snowflake for high-performance analytics  
✅ **Modern Transformation** - dbt with staging/intermediate/marts pattern  
✅ **MCP Integration** - Enhanced development workflow  
✅ **Reusable Macros** - DRY principle for PoP calculations  
✅ **Comprehensive Testing** - Unit tests and data quality checks

---

## Future Enhancements

- [ ] Airflow/Dagster orchestration for scheduled runs
- [ ] Incremental models for large datasets
- [ ] dbt Semantic Layer metrics definitions
- [ ] CI/CD pipeline with GitHub Actions
- [ ] Power BI/Tableau dashboard integration

---

## License

This project is licensed under the MIT License.

---

## Contact

For questions or collaboration:

- GitHub: [@sknman92](https://github.com/sknman92)
- Project: [zillow_dbt](https://github.com/sknman92/zillow_dbt)
