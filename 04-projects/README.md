# &#128736; 04 Projects

<div align="center" markdown>

![SQL & Databases](../assets/banner.svg)

[![View the live site — ijk37.com](https://img.shields.io/badge/%F0%9F%87%A7%F0%9F%87%A9_View_the_Live_Site-IJK37.COM-F42A41?style=for-the-badge&labelColor=006A4E)](https://ijk37.com/sql/)

<img src="https://img.shields.io/badge/04_·_Projects-8_labs-336791?style=for-the-badge&labelColor=24506B" alt="Projects">

[Home](../index.md) &nbsp;|&nbsp; [Notes](../01-notes/README.md) &nbsp;|&nbsp; [Exercises](../02-exercises/README.md) &nbsp;|&nbsp; [Quiz Hub](../03-quiz/)

</div>

Hands-on projects that apply the notes to realistic schema-design and query work — built around two recurring case studies (**San Juan Sailboat Charters**, **James River Jewelry**) and the **Wedgewood Pacific** sample database. Each project has its own folder with a full README (objective, scenario, step-by-step tasks, verification, deliverables, and stretch goals). All SQL runs in **PostgreSQL**.

| # | Project | Type | Primary module(s) | Difficulty |
|---|---------|------|-------------------|------------|
| 01 | [Conceptual ER Modeling](01-conceptual-er-modeling/README.md) | Modeling | 01, 04 | ⭐⭐ |
| 02 | [Relational Schema & Keys](02-relational-schema-and-keys/README.md) | Schema design | 02, 05 | ⭐⭐ |
| 03 | [SQL Querying & Joins](03-sql-querying-and-joins/README.md) | Query lab | 03 | ⭐⭐⭐ |
| 04 | [Full ER Diagram Design](04-full-er-diagram-design/README.md) | Modeling | 04 | ⭐⭐⭐ |
| 05 | [Normalization & Schema Refinement](05-normalization-and-refinement/README.md) | Schema design | 05 | ⭐⭐⭐ |
| 06 | [Transactions & Concurrency Lab](06-transactions-and-concurrency-lab/README.md) | Hands-on lab | 06 | ⭐⭐⭐⭐ |
| 07 | [Mini Data Warehouse & BI](07-mini-data-warehouse-and-bi/README.md) | Schema + analytics | 07 | ⭐⭐⭐⭐ |
| 08 | [Advanced SQL Capstone](08-advanced-sql-capstone/README.md) | Query lab | 08 | ⭐⭐⭐⭐ |

## &#129517; Module Coverage

Every module (01–08) is exercised by at least one project:

| Module | Projects |
|--------|----------|
| 01 Getting Started | 01 |
| 02 The Relational Model | 02 |
| 03 SQL Fundamentals | 03 |
| 04 Data Modeling & E-R Diagrams | 01, 04 |
| 05 Database Design & Normalization | 02, 05 |
| 06 Database Administration | 06 |
| 07 Data Warehousing, BI & Big Data | 07 |
| 08 Advanced SQL | 08 |

---

## &#129520; Tools

- **PostgreSQL** (free, [postgresql.org](https://www.postgresql.org/)) — every project's SQL runs here; **SQLite** works as a zero-install fallback for the query-only projects.
- **pgAdmin** or **DBeaver** — browsing schemas and running queries interactively.
- **draw.io / diagrams.net** (free) — E-R diagramming for projects 01 and 04.

> Database dump/export files and any local `.sql` scratch files stay local — the repo tracks the README, design notes, and final schema/query scripts you choose to commit.

## &#128506; Suggested Order

1. **01 → 02** — read a case, draft entities, then turn them into real tables and keys.
2. **03** — stand up Wedgewood Pacific and get comfortable querying it.
3. **04 → 05** — a full E-R diagram, then normalize a messy table to 3NF.
4. **06** — transactions and concurrency, once schemas feel natural.
5. **07 → 08** — analytics (star schema) and advanced SQL as the capstone.

[← Back to Root](../index.md)
