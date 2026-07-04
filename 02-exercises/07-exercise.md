# &#9997; 07: Data Warehousing, BI & Big Data — Exercises

<!-- course-header -->
<div align="center" markdown>

![SQL & Databases](../assets/banner.svg)

<img src="https://img.shields.io/badge/Module_07-Data_Warehousing_BI-336791?style=for-the-badge&labelColor=24506B" alt="Module 07: Data Warehousing, BI & Big Data"> <img src="https://img.shields.io/badge/11_questions-C6821E?style=for-the-badge&labelColor=24506B" alt="11 questions">

[![Home](https://img.shields.io/badge/⌂_Home-1B2A35?style=flat-square)](../index.md) [![Notes](https://img.shields.io/badge/Notes-1B2A35?style=flat-square)](../01-notes/07-01-data-warehouses-and-marts.md) [![All Exercises](https://img.shields.io/badge/All_Exercises-1B2A35?style=flat-square)](README.md) [![Quiz](https://img.shields.io/badge/▶_Quiz-C6821E?style=flat-square&labelColor=24506B)](../03-quiz/)

</div>
<!-- /course-header -->

> [!TIP]
> **Practice —** try each question first, then expand the answer to check your reasoning.

Work through each question, then click **Show answer** to check yourself. Review the [notes](../01-notes/07-01-data-warehouses-and-marts.md) if you get stuck.

---

### &#128313; Q1. What is the key difference between a data warehouse and a data mart?

<details>
<summary><strong>Show answer</strong></summary>

A **data warehouse** covers the whole organization, pulling data from many operational systems. A **data mart** is a smaller, more focused slice of that same data — scoped to one department or subject area (e.g., a marketing analytics mart). Combining a central warehouse with several department marts is sometimes called an enterprise data warehouse (EDW) architecture.
</details>

---

### &#10067; Q2. A manager wants to run a three-year sales trend report and asks to point the reporting tool directly at the live order-entry (OLTP) database. Give two reasons this is a bad idea.

<details>
<summary><strong>Show answer</strong></summary>

1. **Performance** — scanning years of historical data can lock tables or slow down the very transactions (new orders) the OLTP database exists to process quickly.
2. **Shape** — OLTP tables are normalized to prevent update anomalies, so an analytical question requires joining many tables; that's the wrong shape for fast large-scale aggregation, which is what a star-schema warehouse is built for.
</details>

---

### &#128313; Q3. Design a star schema for a small **video rental** business: design one fact table and at least two dimension tables. Name the columns.

<details>
<summary><strong>Show answer</strong></summary>

**`fact_rental`** (the event — one row per rental):
`rental_key`, `movie_key` (FK), `customer_key` (FK), `date_key` (FK), `rental_fee`, `days_rented`

**`dim_movie`**: `movie_key`, `movie_title`, `genre`, `release_year`

**`dim_customer`**: `customer_key`, `customer_name`, `city`, `membership_tier`

**`dim_date`**: `date_key`, `full_date`, `month_name`, `quarter`, `year`

The fact table stores foreign keys plus numeric measures (`rental_fee`, `days_rented`); the dimensions describe the who/what/when and can be denormalized (repeated text) since they're built for fast joins, not update-anomaly prevention.
</details>

---

### &#10067; Q4. Why is a `dim_date` table useful in a warehouse instead of just storing a plain `DATE` column on the fact table and computing quarter/month at query time?

<details>
<summary><strong>Show answer</strong></summary>

Precomputing `quarter`, `month_name`, `day_of_week`, and `year` once in `dim_date` means any fact-table query can `GROUP BY` or filter on those attributes with a plain join — no repeated date-math in every single report query. It also makes it easy to add business-specific calendar attributes later (fiscal quarter, holiday flag) without touching the fact table at all.
</details>

---

### &#128313; Q5. Classify each scenario as OLTP or OLAP: (a) a cashier ringing up a sale, (b) an analyst computing total revenue by region for the last five years, (c) an ATM withdrawal, (d) a quarterly board report summarizing store performance.

<details>
<summary><strong>Show answer</strong></summary>

- (a) Cashier ringing up a sale → **OLTP** (a single fast transaction against current data)
- (b) Five-year revenue analysis → **OLAP** (large-scale historical aggregation)
- (c) ATM withdrawal → **OLTP** (a single fast transaction updating current balances)
- (d) Quarterly board report → **OLAP** (aggregated historical reporting)
</details>

---

### &#10067; Q6. What is the difference between `GROUP BY ROLLUP` and `GROUP BY CUBE`?

<details>
<summary><strong>Show answer</strong></summary>

`ROLLUP` produces a **hierarchical** set of subtotals (detail rows, then subtotals for each level of the hierarchy, then one grand total) — it assumes an order like year → quarter → month. `CUBE` produces subtotals for **every possible combination** of the grouped columns, not just the hierarchical path. Use `ROLLUP` when your groupings have a natural nesting order; use `CUBE` when you want every possible slice.
</details>

---

### &#128313; Q7. What does the SQL function `GROUPING()` tell you in a query that uses `ROLLUP` or `CUBE`?

<details>
<summary><strong>Show answer</strong></summary>

`GROUPING(column)` returns `1` on a row that is a subtotal/grand-total row generated by `ROLLUP`/`CUBE` for that column, and `0` on a genuine detail row. It lets you tell a real `NULL` data value apart from a `NULL` that only appears because that row is a subtotal — useful for labeling subtotal rows as "All Quarters" instead of showing a bare blank.
</details>

---

### &#10067; Q8. A startup is choosing between renting a raw virtual machine and managing everything themselves (IaaS), versus using a fully managed database service like Amazon RDS (closer to PaaS). Name one tradeoff of each choice.

<details>
<summary><strong>Show answer</strong></summary>

- **IaaS (raw VM):** maximum flexibility — install any DBMS version or extension you want — but you own patching, backups, and failover yourself.
- **Managed service (RDS-style, PaaS):** automated backups, patching, and high availability are handled for you, at the cost of less control over the underlying OS/engine configuration.
</details>

---

### &#128313; Q9. Name the three "V"s commonly used to describe Big Data, and give a one-sentence example of a dataset that is high in one "V" but low in another.

<details>
<summary><strong>Show answer</strong></summary>

**Volume** (total amount of data), **Velocity** (speed of arrival), **Variety** (mix of structured/semi-structured/unstructured data).

Example: a company's archive of old training videos is high **volume** (many terabytes) but low **velocity** (new videos arrive rarely) — volume and velocity don't have to move together.
</details>

---

### &#10067; Q10. Explain the CAP theorem in your own words, and why "partition tolerance" is usually treated as non-negotiable in real distributed systems.

<details>
<summary><strong>Show answer</strong></summary>

The CAP theorem says a distributed database can only fully guarantee two of **Consistency** (all replicas agree), **Availability** (every request gets a response), and **Partition tolerance** (the system keeps working through a network split) at the same time. Network partitions will eventually happen in any real distributed system, so partition tolerance can't realistically be dropped — the practical tradeoff distributed databases actually make is between consistency and availability *when* a partition occurs.
</details>

---

### &#128313; Q11. A product catalog has a mostly-fixed set of core columns (`product_id`, `product_name`, `price`) but each product category has wildly different extra attributes (a shirt has `size`/`color`; a laptop has `ram`/`screen_size`). Would you model the variable attributes as more relational columns, a separate NoSQL document store, or a `JSONB` column? Justify your choice.

<details>
<summary><strong>Show answer</strong></summary>

A **`JSONB` column** alongside the normal typed columns is usually the pragmatic middle ground: the core, always-present fields (`product_id`, `product_name`, `price`) stay as normal relational columns with full constraint/indexing support, while the wildly varying category-specific attributes go in `attributes JSONB`, queryable with `->>`/`@>` and indexable with a GIN index. Standing up an entirely separate NoSQL document database is usually overkill unless the *entire* catalog — not just some attributes — needs that flexibility, or the scale genuinely exceeds what a relational engine can handle.
</details>

---

[All Exercises](README.md) &nbsp;·&nbsp; **Next:** [Module 08 — Advanced SQL Exercises](08-exercise.md)

<!-- course-footer -->
---

<div align="center" markdown>

[All Exercises](README.md) &nbsp;|&nbsp; [Module 07 Notes](../01-notes/07-01-data-warehouses-and-marts.md) &nbsp;|&nbsp; <strong>Next:</strong> [08: Advanced SQL — Exercises](08-exercise.md)

</div>
<!-- /course-footer -->
