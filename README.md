# Distribution: Table Creation

## Overview

"Distribution: Table Creation" is a project focused on designing an optimized database for tracking sales, distribution channels, and product data. The project simulates a real-world scenario where efficient storage, distribution, and analysis of large datasets are critical. The database employs techniques like partitioning, data compression, and distribution for enhanced performance and scalability.

This project is ideal for learning database design, data warehousing, and analytics in the context of sales data.

## Goals

1. **Database Design**: Learn to design and implement fact and dimension tables using partitioning and distribution strategies.
2. **Performance Optimization**: Explore how partitioning, data compression, and replication can improve query speed and storage efficiency for large datasets.
3. **Sales Data Analysis**: Create SQL queries to analyze sales performance across regions, distribution channels, and product categories.

## Database Structure

The database follows a star schema structure with fact and dimension tables, organized as follows:

### Fact Tables:
- **sales** (`std7_170.sales`):
  - This table tracks sales transactions.
  - **Columns**: `date`, `region`, `material`, `distr_chan`, `quantity`, `check_nm`, `check_pos`
  - **Partitioning**: By `date` (range-based).
  - **Distribution**: By `check_nm`.
  - **Compression**: `zstd`.

- **plan** (`std7_170.plan`):
  - This table tracks sales planning data.
  - **Columns**: `date`, `region`, `matdirec`, `quantity`, `distr_chan`
  - **Partitioning**: By `date` (range-based).
  - **Distribution**: Random.
  - **Compression**: `zstd`.

### Dimension Tables:
- **channel** (`std7_170.chanel`):
  - This table describes distribution channels.
  - **Columns**: `distr_chan`, `txtsh`
  - **Distribution**: Replicated.

- **price** (`std7_170.price`):
  - This table tracks product pricing information.
  - **Columns**: `material`, `region`, `distr_chan`, `price`
  - **Distribution**: Replicated.

- **product** (`std7_170.product`):
  - This table provides product details.
  - **Columns**: `material`, `asgrp`, `brand`, `matcateg`, `matdirec`, `txt`
  - **Distribution**: Replicated.

- **region** (`std7_170.region`):
  - This table describes regions.
  - **Columns**: `region`, `txt`
  - **Distribution**: Replicated.

## Key Features

1. **Partitioning and Distribution**:
   - The `sales` and `plan` fact tables are partitioned by `date` to optimize time-based queries.
   - Distribution strategies are used to balance query loads.

2. **Data Compression**:
   - Applied `zstd` compression to save storage space and optimize performance.
