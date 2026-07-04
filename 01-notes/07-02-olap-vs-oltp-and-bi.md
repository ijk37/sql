# &#128216; 07-02: OLAP vs. OLTP & Business Intelligence

<!-- course-header -->
<div align="center" markdown>

![SQL & Databases](../assets/banner.svg)

<img src="https://img.shields.io/badge/Module_07-Data_Warehousing_BI-336791?style=for-the-badge&labelColor=24506B" alt="Module 07: Data Warehousing, BI & Big Data">

[![Home](https://img.shields.io/badge/⌂_Home-1B2A35?style=flat-square)](../index.md) [![All Notes](https://img.shields.io/badge/All_Notes-1B2A35?style=flat-square)](README.md) [![Practice](https://img.shields.io/badge/✎_Practice-C6821E?style=flat-square&labelColor=24506B)](../02-exercises/07-exercise.md) [![Quiz](https://img.shields.io/badge/▶_Quiz-C6821E?style=flat-square&labelColor=24506B)](../03-quiz/)

</div>
<!-- /course-header -->

## &#128161; Two Workloads, Two Databases

The previous note introduced the *structural* difference between operational and dimensional databases (normalized vs. star schema). This note focuses on the **workload** difference — what kind of queries each database is optimized to run — and introduces **business intelligence (BI)** as the layer of software sitting on top of the warehouse.

---

## &#128204; OLTP — On-Line Transaction Processing

**OLTP** describes the day-to-day operational workload: lots of small, fast transactions, each touching a handful of rows.

- "Insert this new assignment." "Update this employee's phone number." "Delete this cancelled order."
- Queries are short, predictable, and heavily indexed for point lookups (`WHERE employee_number = 105`).
- Correctness under concurrent writes matters enormously — this is exactly why Module 06 covered ACID transactions and locking. Many users are reading and writing *at the same time*.
- The schema is normalized to prevent update anomalies (Module 05): one fact lives in exactly one place.

---

## &#128204; OLAP — Online Analytical Processing

**OLAP** describes the analytical workload that runs against a data warehouse: fewer, heavier queries, each touching millions of rows, executed by analysts rather than end users.

- "Total revenue by region, by quarter, for the last five years."
- Queries are read-mostly (or read-only) — nobody is placing an order against the warehouse.
- The engine is optimized for scanning and aggregating large amounts of data quickly, often using columnar storage internally, not indexed point lookups.
- The schema is the denormalized star schema from the previous note — fewer joins, precomputed dimensions, historical data retained on purpose.

| | OLTP | OLAP |
|---|---|---|
| Typical query | `UPDATE`/`INSERT` a few rows | `SELECT ... GROUP BY` millions of rows |
| Data scope | Current state | Current + historical |
| Users | Many concurrent end users | Fewer analysts, ad-hoc |
| Schema | Normalized (3NF) | Star schema (denormalized dimensions) |
| Optimized for | Fast, safe writes | Fast, large-scale reads |

> [!TIP]
> A useful shorthand: **OLTP runs the business; OLAP explains the business.** They are almost always two different database instances — running heavy OLAP reporting against your OLTP production database is one of the most common ways to accidentally degrade the app your customers are using right now.

---

## &#128204; Business Intelligence (BI)

**Business intelligence (BI)** is the umbrella term for the information systems that sit on top of a warehouse and turn its data into decisions. BI systems don't support day-to-day operations (recording an order); they support **management assessment, analysis, planning, and control**. BI tools generally fall into two broad categories:

- **Reporting systems** — sort, filter, group, and run basic calculations over warehouse data (dashboards, scheduled reports, pivot tables). This is the OLAP territory above.
- **Data mining applications** — apply more sophisticated statistical/mathematical techniques to find patterns humans wouldn't spot by eye (clustering customers, predicting churn, market-basket analysis). Data mining is out of scope for this course, but it's the same warehouse data feeding a different kind of tool.

An **OLAP report** (sometimes called an **OLAP cube**) is the typical output of a reporting-style BI tool: you pick **dimensions** (the "by" in "revenue by region by quarter") as inputs, and the tool calculates **measures** (sums, averages) as outputs. Excel PivotTables are a familiar, everyday example of an OLAP-style reporting tool built right on top of tabular data.

---

## &#128204; Simulating an OLAP Report in SQL: `ROLLUP` and `CUBE`

You don't need a dedicated BI tool to see the OLAP pattern — plain SQL's `GROUP BY ROLLUP` and `GROUP BY CUBE` extensions produce exactly the kind of subtotal/grand-total report an OLAP cube would show, directly from a star schema.

Using the `fact_sales` / `dim_product` / `dim_date` tables from the previous note:

```sql
-- ROLLUP: subtotals by product, then a grand total, in one query
SELECT p.product_name,
       d.quarter,
       SUM(f.sale_amount) AS revenue
FROM   fact_sales f
JOIN   dim_product p ON f.product_key = p.product_key
JOIN   dim_date     d ON f.date_key    = d.date_key
GROUP  BY ROLLUP (p.product_name, d.quarter)
ORDER  BY p.product_name NULLS LAST, d.quarter NULLS LAST;
```

`ROLLUP (p.product_name, d.quarter)` produces, in order: one row per (`product_name`, `quarter`) combination, then a subtotal row per `product_name` (with `quarter` shown as `NULL`), then a single grand-total row (both columns `NULL`). That hierarchy of subtotals — detail, then rolled-up subtotal, then grand total — is precisely what an OLAP report presents.

```sql
-- CUBE: every combination of subtotals, not just the hierarchical ones
SELECT p.product_name,
       d.quarter,
       SUM(f.sale_amount) AS revenue
FROM   fact_sales f
JOIN   dim_product p ON f.product_key = p.product_key
JOIN   dim_date     d ON f.date_key    = d.date_key
GROUP  BY CUBE (p.product_name, d.quarter)
ORDER  BY p.product_name NULLS LAST, d.quarter NULLS LAST;
```

`CUBE` goes further than `ROLLUP`: it adds *every* combination of subtotals — by product, by quarter, and the grand total — rather than only the hierarchical (product → total) path. Use `ROLLUP` when your groupings have a natural hierarchy (year → quarter → month); use `CUBE` when you want subtotals sliced every possible way.

To tell a genuine data value apart from a `ROLLUP`/`CUBE`-generated subtotal marker, use `GROUPING()`:

```sql
SELECT p.product_name,
       d.quarter,
       SUM(f.sale_amount) AS revenue,
       GROUPING(d.quarter) AS is_quarter_subtotal
FROM   fact_sales f
JOIN   dim_product p ON f.product_key = p.product_key
JOIN   dim_date     d ON f.date_key    = d.date_key
GROUP  BY ROLLUP (p.product_name, d.quarter);
```

`GROUPING(d.quarter)` returns `1` on the subtotal/grand-total rows it generated and `0` on genuine detail rows — useful for labeling a report as "All Quarters" instead of showing a bare `NULL`.

> [!NOTE]
> `ROLLUP` and `CUBE` are part of the SQL standard and both work in PostgreSQL, SQL Server, and Oracle. MySQL supports `WITH ROLLUP` (appended after the `GROUP BY` clause, e.g. `GROUP BY product_name, quarter WITH ROLLUP`) but has never implemented `CUBE`.

---

See also: [Data Warehouses & Data Marts](07-01-data-warehouses-and-marts.md), [Cloud & Virtualization](07-03-cloud-and-virtualization.md)

<!-- course-footer -->
---

<div align="center" markdown>

[All Notes](README.md) &nbsp;|&nbsp; [Module 07 Exercise](../02-exercises/07-exercise.md) &nbsp;|&nbsp; <strong>Next:</strong> [Cloud & Virtualization](07-03-cloud-and-virtualization.md)

</div>
<!-- /course-footer -->
