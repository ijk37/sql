# &#128216; 01-03: The DBMS Landscape

<!-- course-header -->
<div align="center" markdown>

![SQL & Databases](../assets/banner.svg)

<img src="https://img.shields.io/badge/Module_01-Getting_Started-336791?style=for-the-badge&labelColor=24506B" alt="Module 01: Getting Started">

[![Home](https://img.shields.io/badge/⌂_Home-1B2A35?style=flat-square)](../index.md) [![All Notes](https://img.shields.io/badge/All_Notes-1B2A35?style=flat-square)](README.md) [![Practice](https://img.shields.io/badge/✎_Practice-C6821E?style=flat-square&labelColor=24506B)](../02-exercises/01-exercise.md) [![Quiz](https://img.shields.io/badge/▶_Quiz-C6821E?style=flat-square&labelColor=24506B)](../03-quiz/)

</div>
<!-- /course-header -->

## &#128204; Personal vs. Enterprise Database Systems

Not every database needs to survive a Black Friday traffic spike. It's useful to separate two very different scales of use:

| | Personal database system | Enterprise database system |
|---|---|---|
| Users | One person, one session at a time | Thousands of concurrent users |
| Size | A handful of tables, hundreds of rows | Hundreds of tables, millions/billions of rows |
| Uptime | Runs when you open the app | 24/7, expected to never go down |
| Example tools | SQLite, Microsoft Access | PostgreSQL, Oracle, SQL Server, MySQL at scale |

A hobby project tracking your personal book collection is a personal database. The system running a bank's core ledger is an enterprise database. Both are "relational databases" — they just live at opposite ends of a scale dial.

---

## &#128204; Survey of Major Engines

Every engine below implements the relational model and speaks SQL, but each has its own personality, licensing model, and sweet spot.

| Engine | License | Typical use | Notes |
|---|---|---|---|
| **PostgreSQL** | Open source (permissive) | General purpose, data-heavy apps, analytics, geospatial (PostGIS) | Extremely standards-compliant SQL; rich data types (`JSONB`, arrays, ranges); the default choice in most modern data-science and backend tooling. |
| **MySQL / MariaDB** | Open source (GPL) | Web applications (classic LAMP stack), read-heavy sites, WordPress | Fast and simple to operate; historically weaker standards compliance than Postgres, though modern versions have closed much of the gap. MariaDB is a community fork of MySQL. |
| **SQL Server** | Commercial (Microsoft) | Enterprise apps in Windows/.NET shops, business intelligence | Deep integration with the Microsoft stack (.NET, Power BI, Azure); strong tooling in SQL Server Management Studio (SSMS). |
| **Oracle Database** | Commercial (Oracle Corp.) | Large enterprise and legacy mission-critical systems, banking, ERP | Extremely mature, feature-rich, and expensive; dominant in large enterprises with decades-old systems still running on it. |
| **SQLite** | Public domain | Embedded/local storage — mobile apps, browsers, small tools, prototyping | Not a client-server DBMS at all — the entire database is a single file, with no separate server process. Ideal when you need "a database" without needing "a server." |

Every one of these engines will run the *core* SQL you learn in this course. Where they disagree is mostly around auto-incrementing keys, string quoting defaults, `LIMIT`-style row limiting, and a handful of vendor-specific functions — differences this course calls out with dialect notes as they come up.

> [!NOTE]
> **A quick preview of a real dialect difference — auto-incrementing primary keys:**
>
> | Dialect | Syntax |
> |---|---|
> | PostgreSQL | `id SERIAL PRIMARY KEY` (or `GENERATED ALWAYS AS IDENTITY` in modern Postgres) |
> | MySQL / MariaDB | `id INT AUTO_INCREMENT PRIMARY KEY` |
> | SQL Server | `id INT IDENTITY(1,1) PRIMARY KEY` |
> | SQLite | `id INTEGER PRIMARY KEY` (autoincrements by default) |
> | Oracle | `id NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY` |
>
> You'll see this exact contrast again in [Keys](02-03-keys.md) and in Module 03's DDL notes.

---

## &#128204; Why This Course Teaches PostgreSQL

> [!TIP]
> **Why PostgreSQL is the primary dialect in this course:**
>
> - **It's free and open source** — no licensing barrier to installing it on your own machine or a free-tier cloud instance.
> - **It's rigorously standards-compliant** — SQL you learn here transfers cleanly to other engines, more so than starting with a vendor-specific dialect.
> - **It has genuinely advanced features** used throughout later modules: window functions (Module 08), rich `JSONB` support for semi-structured data, powerful indexing, and full transactional DDL.
> - **It's the default choice across the modern data ecosystem** — `pandas.read_sql`, `SQLAlchemy`, `psycopg`, and `dbt` all treat PostgreSQL as a first-class citizen, and most cloud data warehouses (Redshift, Supabase, Neon) are Postgres-compatible under the hood.
> - **It's a realistic on-ramp to enterprise habits** — proper transactions, constraints, and roles — without a commercial license.
>
> You'll still see MySQL, SQL Server, and SQLite syntax called out in comparison callouts throughout the rest of this course, because real jobs will hand you all of them.

---

## &#128204; Choosing an Engine in Practice

A rough decision guide, useful outside the classroom too:

- **Prototyping or embedded/local storage?** → SQLite.
- **General-purpose web app, want an open-source standard?** → PostgreSQL.
- **Fast web reads, existing LAMP/WordPress ecosystem?** → MySQL/MariaDB.
- **Already a Microsoft shop (.NET, Power BI, Active Directory)?** → SQL Server.
- **Massive legacy enterprise system, deep pockets, need Oracle-specific features (RAC, PL/SQL)?** → Oracle.

None of these choices are permanent or exclusive — many companies run more than one engine for different workloads.

---

See also: [Relational Tables & Database Systems](01-02-relational-tables-and-db-systems.md), [Web Apps, Warehouses, Big Data & Cloud](01-04-web-warehouses-big-data-cloud.md)

<!-- course-footer -->
---

<div align="center" markdown>

[All Notes](README.md) &nbsp;|&nbsp; [Module 01 Exercise](../02-exercises/01-exercise.md) &nbsp;|&nbsp; <strong>Next:</strong> [Web Apps, Warehouses, Big Data &amp; Cloud](01-04-web-warehouses-big-data-cloud.md)

</div>
<!-- /course-footer -->
