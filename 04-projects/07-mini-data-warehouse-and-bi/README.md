# &#128736; Project 07 — Mini Data Warehouse & BI

<!-- course-header -->
<div align="center" markdown>

![SQL & Databases](../../assets/banner.svg)

[![View the live site — ijk37.com](https://img.shields.io/badge/%F0%9F%87%A7%F0%9F%87%A9_View_the_Live_Site-IJK37.COM-F42A41?style=for-the-badge&labelColor=006A4E)](https://ijk37.com/sql/)

<img src="https://img.shields.io/badge/Project_07-Mini_Data_Warehouse_BI-336791?style=for-the-badge&labelColor=24506B" alt="Project 07: Mini Data Warehouse & BI">

[![Home](https://img.shields.io/badge/⌂_Home-1B2A35?style=flat-square)](../../index.md) [![All Projects](https://img.shields.io/badge/All_Projects-1B2A35?style=flat-square)](../README.md) [![Notes](https://img.shields.io/badge/Notes-1B2A35?style=flat-square)](../../01-notes/07-01-data-warehouses-and-marts.md) [![Quiz](https://img.shields.io/badge/▶_Quiz-C6821E?style=flat-square&labelColor=24506B)](../../03-quiz/)

</div>
<!-- /course-header -->

**Type:** Schema design + SQL implementation (PostgreSQL)
**Modules:** 07 (Data Warehousing, BI & Big Data)
**Difficulty:** ⭐⭐⭐

---

## &#127919; Objective

Design and build a small **star schema** for a sales-style dataset, load a handful of sample rows, and write analytic/rollup queries that demonstrate why a dimensional model makes reporting easy.

---

## &#129517; Scenario

**Riverbend Jewelry** is a small retailer (loosely inspired by the kind of jewelry-store business used elsewhere in this course) that wants its first real reporting database. Right now, all sales data lives buried in an operational order-entry system. Management wants to be able to answer questions like "which product category sells best each quarter?" and "who are our top customers by revenue?" without touching the live operational database.

You've been asked to design and populate a **mini warehouse**: one fact table capturing each sale, and two to three dimension tables describing the who/what/when of each sale.

---

## &#128204; Requirements

1. Design **one fact table** (`fact_sales`) with foreign keys to your dimensions plus at least two numeric measures (e.g., `quantity_sold`, `sale_amount`).
2. Design **at least two, ideally three, dimension tables** — for example `dim_product`, `dim_customer`, and `dim_date`.
3. Dimension tables may be denormalized (repeated text is fine) — this is a warehouse, not an OLTP schema.
4. Populate every table with sample data using inline `INSERT` statements (at least 5 products, 5 customers, a handful of dates, and 15+ fact rows).
5. Write **4–5 analytic/rollup queries** against your schema, at least one of which uses `ROLLUP` or `CUBE`.

---

## &#129513; Tasks

### &#128313; Part A — Design the Star Schema

Create your dimension and fact tables:

```sql
CREATE TABLE dim_product (
    product_key    SERIAL PRIMARY KEY,
    product_name   VARCHAR(50) NOT NULL,
    category       VARCHAR(30) NOT NULL
);

CREATE TABLE dim_customer (
    customer_key   SERIAL PRIMARY KEY,
    customer_name  VARCHAR(50) NOT NULL,
    city           VARCHAR(30),
    state          CHAR(2)
);

CREATE TABLE dim_date (
    date_key    SERIAL PRIMARY KEY,
    full_date   DATE NOT NULL,
    month_name  VARCHAR(10) NOT NULL,
    quarter     SMALLINT NOT NULL,
    year        SMALLINT NOT NULL
);

CREATE TABLE fact_sales (
    sale_id        SERIAL PRIMARY KEY,
    product_key    INTEGER NOT NULL REFERENCES dim_product(product_key),
    customer_key   INTEGER NOT NULL REFERENCES dim_customer(customer_key),
    date_key       INTEGER NOT NULL REFERENCES dim_date(date_key),
    quantity_sold  INTEGER NOT NULL,
    sale_amount    NUMERIC(10, 2) NOT NULL
);
```

### &#128313; Part B — Populate With Sample Data

Load your dimensions first, then the fact table (foreign keys require the parents to exist first):

```sql
INSERT INTO dim_product (product_name, category) VALUES
    ('Diamond Solitaire Ring', 'Rings'),
    ('Gold Hoop Earrings', 'Earrings'),
    ('Pearl Necklace', 'Necklaces'),
    ('Sapphire Bracelet', 'Bracelets'),
    ('Silver Chain Necklace', 'Necklaces');

INSERT INTO dim_customer (customer_name, city, state) VALUES
    ('Ava Thompson', 'Richmond', 'VA'),
    ('Marcus Lee', 'Norfolk', 'VA'),
    ('Priya Patel', 'Charlottesville', 'VA'),
    ('Diego Ramirez', 'Alexandria', 'VA'),
    ('Sofia Moretti', 'Roanoke', 'VA');

INSERT INTO dim_date (full_date, month_name, quarter, year) VALUES
    ('2025-01-15', 'January',  1, 2025),
    ('2025-02-20', 'February', 1, 2025),
    ('2025-04-05', 'April',    2, 2025),
    ('2025-07-11', 'July',     3, 2025),
    ('2025-10-30', 'October',  4, 2025);

-- date_key/product_key/customer_key values below assume the SERIAL sequence
-- assigned 1-5 in insertion order above; adjust if your keys differ.
INSERT INTO fact_sales (product_key, customer_key, date_key, quantity_sold, sale_amount) VALUES
    (1, 1, 1, 1, 4200.00),
    (2, 2, 1, 2,  650.00),
    (3, 3, 2, 1,  980.00),
    (1, 4, 2, 1, 3900.00),
    (4, 5, 3, 1, 1250.00),
    (2, 1, 3, 3,  975.00),
    (5, 2, 4, 1,  320.00),
    (3, 3, 4, 2, 1960.00),
    (1, 4, 4, 1, 4500.00),
    (4, 5, 5, 2, 2500.00),
    (2, 1, 5, 1,  325.00),
    (5, 2, 5, 4, 1280.00),
    (3, 4, 1, 1,  980.00),
    (1, 5, 2, 1, 4100.00),
    (4, 1, 3, 1, 1250.00);
```

### &#128313; Part C — Write Analytic Queries

Write and run at least these five queries:

1. **Revenue by category, by quarter** — a plain aggregation.
2. **Top 3 customers by total revenue** — aggregation + `ORDER BY` + `LIMIT`.
3. **A `ROLLUP` report** — revenue by product category with quarterly subtotals and a grand total.
4. **Units sold by product, filtered to a single quarter** — a filtered aggregation joining all three dimensions.
5. **Customers who bought from more than one product category** — using `GROUP BY ... HAVING COUNT(DISTINCT ...) > 1`.

---

## &#9989; Verification Checklist

- [ ] `fact_sales` references all three dimension tables via foreign keys.
- [ ] Dimension tables contain at least 5 rows each; `fact_sales` has 15+ rows.
- [ ] At least one query uses `ROLLUP` or `CUBE` and produces visible subtotal/grand-total rows.
- [ ] All 5 analytic queries run without error and return sensible results.
- [ ] Every query is a genuine join across the star schema, not a query against a single table alone.

---

## &#128230; Deliverables

- A single `.sql` file with your `CREATE TABLE` statements, `INSERT` statements, and all 5 analytic queries, in that order.
- A short paragraph (in a comment block at the top of the file) describing your fact table's grain — i.e., what one row of `fact_sales` represents.

---

## &#128640; Stretch Goals

- Add a `dim_store` dimension (if Riverbend has multiple locations) and extend `fact_sales` with a `store_key`.
- Rewrite one `ROLLUP` query as a `CUBE` query and compare the row counts.
- Add a `GROUPING()` column to your rollup query to label subtotal rows clearly (e.g., `'All Quarters'`).

See also notes: [Data Warehouses & Data Marts](../../01-notes/07-01-data-warehouses-and-marts.md), [OLAP vs. OLTP & BI](../../01-notes/07-02-olap-vs-oltp-and-bi.md)
