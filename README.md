<div align="center">

<a href="https://ijk37.com/sql/"><img src="assets/banner.svg" alt="SQL & Databases" width="100%"></a>

<p>
  <a href="https://ijk37.com/sql/"><img src="https://img.shields.io/badge/%F0%9F%87%A7%F0%9F%87%A9_View_the_Live_Site-IJK37.COM-F42A41?style=for-the-badge&labelColor=006A4E" alt="View the live site — ijk37.com"></a>
</p>

<p>
  <a href="01-notes/README.md"><img src="https://img.shields.io/badge/Notes-8_modules-336791?style=for-the-badge&labelColor=24506B" alt="Course Notes"></a>
  <a href="02-exercises/README.md"><img src="https://img.shields.io/badge/Exercises-8_sets-336791?style=for-the-badge&labelColor=24506B" alt="Exercises"></a>
  <a href="https://ijk37.com/sql/03-quiz/"><img src="https://img.shields.io/badge/Quiz_Hub-Open-C6821E?style=for-the-badge&labelColor=24506B" alt="Quiz Hub"></a>
  <a href="04-projects/README.md"><img src="https://img.shields.io/badge/Projects-8_labs-336791?style=for-the-badge&labelColor=24506B" alt="Projects"></a>
</p>

<p>
  <img src="https://img.shields.io/badge/Question_Bank-600-C6821E?style=flat-square&labelColor=24506B" alt="Question Bank">
  <img src="https://img.shields.io/badge/Modules-8-336791?style=flat-square&labelColor=24506B" alt="Modules">
  <img src="https://img.shields.io/badge/Projects-8-336791?style=flat-square&labelColor=24506B" alt="Projects count">
  <img src="https://img.shields.io/badge/Primary_Dialect-PostgreSQL-C6821E?style=flat-square&labelColor=24506B" alt="Primary dialect">
</p>

<p><em>A structured, self-paced learning repository built around <strong>Kroenke's Database Concepts, 9th Edition</strong>, taught in PostgreSQL with MySQL / SQL Server / SQLite / Oracle comparison notes.</em></p>

</div>

---

## Course Dashboard

| Section | Purpose | Start Here |
| --- | --- | --- |
| **01 Notes** | Topic-based study notes organized by module | [Browse notes](01-notes/README.md) |
| **02 Exercises** | Practice questions and worked activities | [Open exercises](02-exercises/README.md) |
| **03 Quiz** | Interactive multiple-choice review quizzes | [Launch quiz hub](https://ijk37.com/sql/03-quiz/) |
| **04 Projects** | Schema design, query, and data-warehouse labs | [View projects](04-projects/README.md) |
| **05 Resources** | Reserved for supplemental resources | Hidden for now |

## Why PostgreSQL?

The notes teach one dialect deeply instead of hedging across four shallowly. **PostgreSQL** is the primary language of instruction because it is free and standards-compliant, has the richest analytic SQL (window functions, `JSONB`, CTEs/recursive queries), and is the de facto default for the Python/pandas/SQLAlchemy/dbt data science stack. Wherever a real course concept has notable syntax differences, a callout box compares it against **MySQL**, **SQL Server**, **SQLite**, and **Oracle** — so the underlying relational theory transfers regardless of which engine you meet on the job.

## Learning Path

```text
Read notes -> Practice exercises -> Take quiz -> Build project -> Review weak areas
```

1. Start with the module notes in [`01-notes`](01-notes/README.md).
2. Complete the matching exercise in [`02-exercises`](02-exercises/README.md).
3. Test recall in the [Quiz Hub](https://ijk37.com/sql/03-quiz/).
4. Apply the topic through a schema or query lab in [`04-projects`](04-projects/README.md).

## Module Map

| Module | Topic | Primary Reading |
| --- | --- | --- |
| 01 | Getting Started | [Why Databases?](01-notes/01-01-why-databases.md) |
| 02 | The Relational Model | [Relations & Terminology](01-notes/02-01-relations-and-terminology.md) |
| 03 | SQL Fundamentals | [DDL: Tables & Data Types](01-notes/03-01-ddl-tables-and-datatypes.md) |
| 04 | Data Modeling & E-R Diagrams | [E-R Diagram Notation](01-notes/04-02-er-diagram-notation.md) |
| 05 | Database Design & Normalization | [Normalization](01-notes/05-03-normalization.md) |
| 06 | Database Administration | [Transactions & ACID](01-notes/06-03-transactions-and-acid.md) |
| 07 | Data Warehousing, BI & Big Data | [Data Warehouses & Marts](01-notes/07-01-data-warehouses-and-marts.md) |
| 08 | Advanced SQL | [Window Functions & UDFs](01-notes/08-04-window-functions-and-udfs.md) |

## Quiz Hub

The quiz system includes module quizzes and cumulative mixed quizzes with instant scoring and end-of-quiz review.

| Feature | Details |
| --- | --- |
| Module coverage | 8 module quizzes, sized by chapter importance (50/75/100 per module) |
| Question pool | 600 questions total |
| Attempt style | Randomized questions and shuffled options |
| Mixed review | 3 cumulative mixed quizzes |
| Access | [Open the Quiz Hub](https://ijk37.com/sql/03-quiz/) |

## Projects

The project track turns relational theory into schema design and query practice, built around two recurring case studies (**San Juan Sailboat Charters**, **James River Jewelry**) plus the Wedgewood Pacific sample database.

| Project | Focus |
| --- | --- |
| [Conceptual ER Modeling](04-projects/01-conceptual-er-modeling/README.md) | Reading a narrative case and drafting an E-R diagram |
| [Relational Schema & Keys](04-projects/02-relational-schema-and-keys/README.md) | Transforming an E-R diagram into tables and keys |
| [SQL Querying & Joins](04-projects/03-sql-querying-and-joins/README.md) | SELECT, joins, and subqueries against a real schema |
| [Full ER Diagram Design](04-projects/04-full-er-diagram-design/README.md) | Associative entities and complete relationship modeling |
| [Normalization & Schema Refinement](04-projects/05-normalization-and-refinement/README.md) | Taking a flat table to 3NF |
| [Transactions & Concurrency Lab](04-projects/06-transactions-and-concurrency-lab/README.md) | Isolation levels and concurrent-booking conflicts |
| [Mini Data Warehouse & BI](04-projects/07-mini-data-warehouse-and-bi/README.md) | Star schema and OLAP-style analytic queries |
| [Advanced SQL Capstone](04-projects/08-advanced-sql-capstone/README.md) | Views, recursive CTEs, and window functions |

## Prerequisites

| Tool | Used For |
| --- | --- |
| PostgreSQL (or [SQLite](https://sqlite.org/) for a zero-install option) | Running every query in the notes and projects |
| [pgAdmin](https://www.pgadmin.org/) or [DBeaver](https://dbeaver.io/) | Browsing schemas and running SQL interactively |
| [draw.io](https://app.diagrams.net/) | Drawing E-R diagrams for the modeling projects |
| Markdown reader or GitHub | Reading notes and exercises |

## Repository Notes

- Numbering follows the 8-module course order (Kroenke *Database Concepts*, 9th Edition, Ch. 1–7 + Extension B).
- `05-resources` is intentionally not surfaced here right now. Specific files can be added later when they are ready to share.
- The repository is designed for repeated study: read, practice, test, build, then revisit weak topics.

---

<div align="center">

<strong>Read the notes. Write the queries. Design the schema.</strong>

</div>
