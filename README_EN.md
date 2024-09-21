# Basics of Working With Greenplum

## Table of Contents
1. [Distribution: Table Creation](#distribution-table-creation)
   - [Overview](#overview)
   - [Goals](#goals)
   - [Database Structure](#database-structure)
   - [Key Features](#key-features)
   - [Skills and Competencies Gained](#skills-and-competencies-gained)
2. [Integration with External Systems](#integration-with-external-systems)
   - [Description of Work](#description-of-work)
   - [Skills and Competencies Gained](#skills-and-competencies-gained-1)

## Distribution: Table Creation

### Overview

"Distribution: Table Creation" is a project focused on designing an optimized database for tracking sales, distribution channels, and product data. The project simulates a real-world scenario where efficient storage, distribution, and analysis of large datasets are critical. The database employs techniques like partitioning, data compression, and distribution for enhanced performance and scalability.

This project is ideal for learning database design, data warehousing, and analytics in the context of sales data.

### Goals

1. **Database Design**: Learn to design and implement fact and dimension tables using partitioning and distribution strategies.
2. **Performance Optimization**: Explore how partitioning, data compression, and replication can improve query speed and storage efficiency for large datasets.

### Database Structure

The database follows a star schema structure with fact and dimension tables, organized as follows:

#### Fact Tables:
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

#### Dimension Tables:
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

### Key Features

1. **Partitioning and Distribution**:
   - The `sales` and `plan` fact tables are partitioned by `date` to optimize time-based queries.
   - Distribution strategies are used to balance query loads.

2. **Data Compression**:
   - Applied `zstd` compression to save storage space and optimize performance.

### Skills and Competencies Gained

Through this project, I developed the following skills and competencies:

- **Database Design**: Gained experience in designing and implementing fact and dimension tables tailored for sales data analysis.
- **Query Optimization**: Improved skills in writing efficient SQL queries and understanding how partitioning and distribution can enhance performance.
- **Analytical Thinking**: Enhanced ability to analyze business requirements and translate them into a well-structured database design.

## Integration with External Systems

### Description of Work

In this section, I describe the integration with external systems through the creation of external tables in Greenplum. The objectives and results are as follows:

1. **Creating External Tables Using the PXF Protocol**:
   - **Objective**: Enable access to data from existing Postgres tables (`gp.plan` and `gp.sales`) within the Greenplum environment.
   - **Outcome**: Successfully created external tables that facilitate data retrieval, allowing for seamless integration with the sales and planning data.
   - **Description**: The PXF (Pivotal Extension Framework) protocol is used to connect Greenplum to external data sources, allowing JDBC connections for querying relational databases.

2. **Creating External Tables Using the gpfdist Protocol**:
   - **Objective**: Access and manage data stored in CSV files (`price`, `chanel`, `product`, and `region`) using the gpfdist protocol.
   - **Outcome**: Created external tables that allow for efficient loading of data from these CSV files into Greenplum, improving the flexibility and accessibility of data sources for analysis.
   - **Description**: The gpfdist protocol allows Greenplum to read data from files served over HTTP, enabling efficient data loading from distributed file systems or cloud storage.

### Skills and Competencies Gained

Through this integration work, I developed the following skills and competencies:

- **Understanding of Data Integration**: Gained knowledge in integrating different data sources using various protocols, enhancing my understanding of data workflows.
- **Proficiency in Greenplum**: Improved my skills in creating external tables and utilizing Greenplum features for effective data management.
- **Familiarity with Data Access Protocols**: Learned how to implement and utilize PXF and gpfdist protocols, broadening my expertise in data access methods.
- **Analytical Skills**: Enhanced my ability to analyze data structures and integration points, leading to more effective data retrieval and analysis strategies.
