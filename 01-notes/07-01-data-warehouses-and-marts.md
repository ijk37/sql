# &#128216; 07-01: Data Warehouses & Data Marts

<!-- course-header -->
<div align="center" markdown>

![SQL & Databases](../assets/banner.svg)

<img src="https://img.shields.io/badge/Module_07-Data_Warehousing_BI-336791?style=for-the-badge&labelColor=24506B" alt="Module 07: Data Warehousing, BI & Big Data">

[![Home](https://img.shields.io/badge/⌂_Home-1B2A35?style=flat-square)](../index.md) [![All Notes](https://img.shields.io/badge/All_Notes-1B2A35?style=flat-square)](README.md) [![Practice](https://img.shields.io/badge/✎_Practice-C6821E?style=flat-square&labelColor=24506B)](../02-exercises/07-exercise.md) [![Quiz](https://img.shields.io/badge/▶_Quiz-C6821E?style=flat-square&labelColor=24506B)](../03-quiz/)

</div>
<!-- /course-header -->

## &#128161; Why Reporting Wrecks a Production Database

Every table you've built so far in this course — `department`, `employee`, `project`, `assignment` — is an **operational** table. It exists to answer "what is true right now": which employee is in which department, how many hours were logged today. Databases built for this job are called **OLTP** systems (On-Line Transaction Processing), and Module 07 starts by asking what happens when a manager wants a *different* kind of question answered: "how did sales trend over the last three years by region and product line?"

Run that kind of question directly against a live OLTP database and two problems show up immediately:

- **Performance** — a multi-year aggregation scans huge amounts of historical data and can lock tables or starve the very transactions (new orders, new assignments) the database exists to process.
- **Shape** — operational tables are normalized to avoid update anomalies, which means answering an analytical question requires joining a dozen tables. That's the wrong shape for fast aggregation.

The industry's answer is to **stop querying the operational database for analysis at all**, and instead build a second, separate database whose entire purpose is analytical reporting: a **data warehouse**.

---

## &#128204; Data Warehouse vs. Data Mart

A **data warehouse** is a database — along with the extraction programs, cleaning routines, and specialist staff around it — dedicated to preparing and storing data for business intelligence (BI). It typically holds data pulled from *many* operational systems (sales, HR, inventory) going back *years*, not just the current snapshot.

A **data mart** is a smaller, more focused slice of that same idea — data prepared for one department or one subject area (e.g., "Marketing's customer analytics mart") rather than the whole enterprise. Think of a data mart as a warehouse scoped down to one business function. When an organization combines a central warehouse with several department-specific marts feeding off it, that overall architecture is often called an **enterprise data warehouse (EDW)**.

| | Data Warehouse | Data Mart |
|---|---|---|
| Scope | Whole organization | One department / subject area |
| Size | Large | Smaller |
| Owner | Central IT / BI team | Often a single business unit |
| Source | Many operational systems | Often just the warehouse itself |

> [!NOTE]
> You may also hear the term **data lake** — a repository that stores *all* data relevant to a business in raw form, including unstructured files (documents, images, logs), not just tabular data destined for a warehouse. A data lake stores everything as-is; a data warehouse stores data that has already been cleaned and structured for analysis.

---

## &#128204; ETL / ELT — Getting Data Into the Warehouse

Operational data is rarely warehouse-ready as-is. Real operational data is often **dirty**: inconsistent codes (`"M"` vs. `"Male"`), missing values, duplicate customer records from two different systems, or columns with too much irrelevant detail. Before it can support reliable analysis, it has to be processed through a pipeline usually called **ETL**:

1. **Extract** — pull data out of one or more source (operational) systems.
2. **Transform** — clean it up and reshape it: standardize codes, fix formats, resolve duplicates, and often *simplify* a value into something more useful for reporting (e.g., turning a raw email address `joe@acme.com` into just the domain `acme.com` for a "customers by company" report, or a country code `"US"` into the friendlier `"United States"`).
3. **Load** — write the transformed data into the warehouse's own tables.

**ELT** (Extract, Load, Transform) is the modern cloud-era variant: raw data is loaded into the warehouse (or lake) first, and transformation happens afterward using the warehouse's own compute power — practical now that cloud warehouses (Snowflake, BigQuery, Redshift) are cheap to scale and can crunch huge raw datasets directly.

> [!TIP]
> Whichever order you use, the goal is the same: by the time an analyst queries the warehouse, the data should already be clean, consistent, and shaped for fast aggregation — none of that work should happen at query time.

---

## &#128204; The Star Schema

Once data lands in the warehouse, it isn't stored in the same normalized shape as the operational system. Warehouses use a **dimensional model**, most commonly a **star schema**: one central **fact table** surrounded by several **dimension tables**, resembling a star when diagrammed.

- **Fact table** — one row per business event (a sale, a shipment, an assignment-hour). Holds foreign keys to each dimension plus numeric **measures** you want to aggregate (quantity, amount, hours).
- **Dimension tables** — the "who, what, when, where" that describes each fact: products, customers, dates, stores. Dimension tables are often deliberately **denormalized** — flattened, with repeated text — because the goal is fast, simple joins, not update-anomaly-free storage.

### Worked example — a small sales warehouse

```sql
-- Dimension: which product was sold
CREATE TABLE dim_product (
    product_key    SERIAL PRIMARY KEY,
    product_number VARCHAR(10)  NOT NULL,
    product_name   VARCHAR(50)  NOT NULL,
    category       VARCHAR(30)
);

-- Dimension: who bought it
CREATE TABLE dim_customer (
    customer_key   SERIAL PRIMARY KEY,
    customer_id    VARCHAR(10)  NOT NULL,
    customer_name  VARCHAR(50)  NOT NULL,
    city           VARCHAR(30),
    state          CHAR(2)
);

-- Dimension: when it was sold (a classic "date dimension")
CREATE TABLE dim_date (
    date_key    SERIAL PRIMARY KEY,
    full_date   DATE NOT NULL,
    day_of_week VARCHAR(10),
    month_name  VARCHAR(10),
    quarter     SMALLINT,
    year        SMALLINT
);

-- Fact: one row per sale line
CREATE TABLE fact_sales (
    sale_id        SERIAL PRIMARY KEY,
    product_key    INTEGER NOT NULL REFERENCES dim_product(product_key),
    customer_key   INTEGER NOT NULL REFERENCES dim_customer(customer_key),
    date_key       INTEGER NOT NULL REFERENCES dim_date(date_key),
    quantity_sold  INTEGER NOT NULL,
    sale_amount    NUMERIC(10, 2) NOT NULL
);
```

Notice the fact table is the only *fully normalized* table here — it references each dimension by a surrogate key and stores nothing but keys and measures. `dim_date` in particular is a warehouse staple: rather than compute "quarter" or "day of week" at query time, that information is precomputed once and stored as a row per calendar date, so any fact query can group by `quarter` or `month_name` with a plain join, no date-math required.

> [!NOTE]
> Dimension attributes can change over time (a customer moves to a new city, a product gets recategorized). Warehouses handle this with **slowly changing dimensions (SCD)** — techniques for deciding whether to overwrite the old value, keep history in new rows, or track both. That's a deeper topic than this course covers, but it's worth knowing the term.

A simple analytic query against this star schema — total quantity sold per product per quarter — stays a single, cheap join across four small tables instead of a sprawl of operational joins:

```sql
SELECT p.product_name,
       d.year,
       d.quarter,
       SUM(f.quantity_sold) AS units_sold,
       SUM(f.sale_amount)   AS revenue
FROM   fact_sales f
JOIN   dim_product  p ON f.product_key  = p.product_key
JOIN   dim_date      d ON f.date_key     = d.date_key
GROUP  BY p.product_name, d.year, d.quarter
ORDER  BY d.year, d.quarter, p.product_name;
```

---

## &#128204; Operational vs. Dimensional, Side by Side

| | Operational (OLTP) Database | Dimensional (Warehouse) Database |
|---|---|---|
| Purpose | Structured transaction processing | Unstructured, ad-hoc analysis |
| Time frame | Current data | Current *and* historical data |
| Who changes data | End users, one row at a time | Loaded/refreshed systematically by ETL jobs, not by hand |
| Shape | Normalized (3NF+) | Star schema — normalized fact, denormalized dimensions |

We'll draw this contrast out fully in the next note, including how it plays out in actual query patterns (OLTP vs. OLAP).

---

See also: [OLAP vs. OLTP & BI](07-02-olap-vs-oltp-and-bi.md), [Transforming E-R Models into Tables](05-01-transforming-er-to-tables.md)

<!-- course-footer -->
---

<div align="center" markdown>

[All Notes](README.md) &nbsp;|&nbsp; [Module 07 Exercise](../02-exercises/07-exercise.md) &nbsp;|&nbsp; <strong>Next:</strong> [OLAP vs. OLTP & BI](07-02-olap-vs-oltp-and-bi.md)

</div>
<!-- /course-footer -->
