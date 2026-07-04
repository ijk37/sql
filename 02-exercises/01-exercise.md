# &#9997; 01: Getting Started — Exercises

<!-- course-header -->
<div align="center" markdown>

![SQL & Databases](../assets/banner.svg)

<img src="https://img.shields.io/badge/Module_01-Getting_Started-336791?style=for-the-badge&labelColor=24506B" alt="Module 01: Getting Started"> <img src="https://img.shields.io/badge/12_questions-C6821E?style=for-the-badge&labelColor=24506B" alt="12 questions">

[![Home](https://img.shields.io/badge/⌂_Home-1B2A35?style=flat-square)](../index.md) [![Notes](https://img.shields.io/badge/Notes-1B2A35?style=flat-square)](../01-notes/01-01-why-databases.md) [![All Exercises](https://img.shields.io/badge/All_Exercises-1B2A35?style=flat-square)](README.md) [![Quiz](https://img.shields.io/badge/▶_Quiz-C6821E?style=flat-square&labelColor=24506B)](../03-quiz/)

</div>
<!-- /course-header -->

> [!TIP]
> **Practice —** try each question first, then expand the answer to check your reasoning.

Work through each question, then click **Show answer** to check yourself. Review the [notes](../01-notes/01-01-why-databases.md) if you get stuck.

---

### &#128313; Q1. What is the main reason organizations use a database instead of a single spreadsheet-style list?

<details>
<summary><strong>Show answer</strong></summary>

Once you're tracking more than one theme (e.g., customers *and* their payments, or students *and* their advisers) and those themes relate to each other, a single flat list develops modification anomalies. Databases split data into related tables — one theme per table — to avoid redundancy and keep the data consistent.
</details>

---

### &#10067; Q2. A spreadsheet has columns `Child1`, `Child2`, `Child3` for a customer's children. What's wrong with this design, and what's the fix?

<details>
<summary><strong>Show answer</strong></summary>

This is a **repeating group** crammed into extra columns. Problems: a customer with 4+ children doesn't fit; customers with 0–1 children waste empty columns; you can't easily query "list all children in the system."

Fix: move children into their own table, one row per child, linked back to the customer by a foreign key (e.g., a `CHILD` table with a `CustNo` column referencing `CUSTOMER`).
</details>

---

### &#128313; Q3. Define, in your own words: update anomaly, insertion anomaly, deletion anomaly.

<details>
<summary><strong>Show answer</strong></summary>

- **Update anomaly** — the same fact is stored redundantly in multiple rows; changing it in one place but missing another leaves contradictory data.
- **Insertion anomaly** — you can't add a new fact without being forced to also supply unrelated or nonexistent data.
- **Deletion anomaly** — deleting one row destroys an unrelated fact that happened to be riding along on that same row.
</details>

---

### &#127974; Q4. Fast Cash Loans keeps one spreadsheet row per **payment**, with the customer's name and phone number repeated on every payment row. A brand-new customer walks in but hasn't made a payment yet. What problem does this design cause, and why?

<details>
<summary><strong>Show answer</strong></summary>

This is an **insertion anomaly**. Because every row in the sheet requires a payment amount and date, there's no way to store the new customer's name and phone number until they make a payment — you'd have to invent a fake $0 payment just to have somewhere to put their contact information.
</details>

---

### &#128313; Q5. What are the four components of a database *system* (not just "the database")?

<details>
<summary><strong>Show answer</strong></summary>

1. **Users**
2. **Database application** (forms, reports, queries)
3. **DBMS** (Database Management System)
4. **Database** (the actual self-describing collection of tables)
</details>

---

### &#10067; Q6. What does it mean to say a database is "self-describing"? What's the technical term for this self-description?

<details>
<summary><strong>Show answer</strong></summary>

It means the database stores a description of its own structure — table names, column names, data types, constraints — inside itself, alongside the data. This structural description is called **metadata**. In PostgreSQL you can query it directly through `information_schema`.
</details>

---

### &#128313; Q7. In the Wedgewood Pacific schema, `EMPLOYEE.Department` must always match a value that exists in `DEPARTMENT`. What is this rule called, and what enforces it?

<details>
<summary><strong>Show answer</strong></summary>

This is a **referential integrity constraint**. It's enforced by the **DBMS** — attempting to insert or update an `EMPLOYEE` row with a `Department` value that doesn't exist in `DEPARTMENT` will be rejected (this becomes a `FOREIGN KEY` constraint in SQL, covered in Module 02).
</details>

---

### &#128193; Q8. Contrast a personal database system with an enterprise database system along two dimensions.

<details>
<summary><strong>Show answer</strong></summary>

- **Scale** — personal: a few tables, a few hundred rows; enterprise: hundreds of tables, millions/billions of rows.
- **Concurrency/uptime** — personal: one user at a time, runs only when opened; enterprise: thousands of concurrent users, expected to run 24/7.
</details>

---

### &#127968; Q9. Name the five DBMS engines surveyed in this course and give one distinguishing fact about each.

<details>
<summary><strong>Show answer</strong></summary>

- **PostgreSQL** — free, open source, highly standards-compliant, rich data types (JSONB, arrays).
- **MySQL/MariaDB** — open source, historically the LAMP-stack default for web apps.
- **SQL Server** — commercial, deeply integrated with the Microsoft/.NET ecosystem.
- **Oracle** — commercial, dominant in large legacy enterprise systems.
- **SQLite** — a single embedded file with no separate server process; ideal for local/mobile storage.
</details>

---

### &#10067; Q10. Give two concrete reasons this course teaches PostgreSQL as its primary SQL dialect.

<details>
<summary><strong>Show answer</strong></summary>

Any two of: it's free and open source; it's rigorously standards-compliant (skills transfer to other engines); it has advanced features used later in the course (window functions, JSONB); it's the default engine assumed by common data tooling (pandas, SQLAlchemy, dbt).
</details>

---

### &#128313; Q11. What is the difference between OLTP and OLAP, at a high level?

<details>
<summary><strong>Show answer</strong></summary>

**OLTP** (Online Transaction Processing) records what's happening right now — fast, small, frequent inserts/updates, like processing an order. **OLAP** (Online Analytical Processing) analyzes historical data in bulk — large, complex, read-only aggregations, like a quarterly sales trend report. A single production database is usually OLTP; heavy analysis is often offloaded to a separate OLAP-oriented data warehouse (full treatment in Module 07).
</details>

---

### &#127760; Q12. What is a Web database application, and what role does an API typically play in one?

<details>
<summary><strong>Show answer</strong></summary>

A Web database application is a web app whose browser front end never talks to the database directly. Instead, the browser calls an **API**, server-side code translates that request into SQL, the SQL runs against the DBMS, and results flow back up the same chain to the browser as JSON.
</details>

---

<!-- course-footer -->
---

<div align="center" markdown>

[All Exercises](README.md) &nbsp;|&nbsp; [Module 01 Notes](../01-notes/01-01-why-databases.md) &nbsp;|&nbsp; <strong>Next:</strong> [02: The Relational Model — Exercises](02-exercise.md)

</div>
<!-- /course-footer -->
