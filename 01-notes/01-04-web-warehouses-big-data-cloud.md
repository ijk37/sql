# &#128216; 01-04: Web Apps, Warehouses, Big Data &amp; Cloud

<!-- course-header -->
<div align="center" markdown>

![SQL & Databases](../assets/banner.svg)

<img src="https://img.shields.io/badge/Module_01-Getting_Started-336791?style=for-the-badge&labelColor=24506B" alt="Module 01: Getting Started">

[![Home](https://img.shields.io/badge/⌂_Home-1B2A35?style=flat-square)](../index.md) [![All Notes](https://img.shields.io/badge/All_Notes-1B2A35?style=flat-square)](README.md) [![Practice](https://img.shields.io/badge/✎_Practice-C6821E?style=flat-square&labelColor=24506B)](../02-exercises/01-exercise.md) [![Quiz](https://img.shields.io/badge/▶_Quiz-C6821E?style=flat-square&labelColor=24506B)](../03-quiz/)

</div>
<!-- /course-header -->

This note is scene-setting. Each idea here gets a full module later in the course — the goal right now is just to recognize the terms and see how they connect to the tables you've been reading about.

---

## &#128204; Web Database Applications

A **web database application** is a web app whose front end (a browser or mobile screen) never talks to the database directly. Instead:

1. The user does something in the browser (submits a form, clicks a link).
2. The web app calls an **API** (Application Programming Interface) — often over HTTP, using JSON as the data format.
3. Server-side code (Python, JavaScript/Node, PHP, Java, ...) turns that request into SQL.
4. The SQL runs against the DBMS, and results flow back up the same chain.

```text
Browser  →  Web/API server  →  SQL  →  DBMS  →  Database
   ↑                                              │
   └──────────────── JSON response  ◄─────────────┘
```

This is why "the website is down" is so often actually "the database connection is down" — the browser is just a window onto data sitting in tables, several layers removed.

---

## &#128204; OLTP vs. OLAP — A Teaser

Databases get used for two very different jobs, and the same table design isn't always good at both:

| | OLTP (Online Transaction Processing) | OLAP (Online Analytical Processing) |
|---|---|---|
| Job | Record what's happening *right now* — an order, a payment, a login | Analyze *history* — trends, totals, patterns over time |
| Typical query | "Insert this order" / "What's the status of order #4471?" | "What were total sales by region for the last 8 quarters?" |
| Optimized for | Fast, small, frequent read/write transactions | Large, complex, read-only aggregations |
| Example system | The database behind a checkout page | A company's data warehouse / BI dashboard |

A single production database is usually an OLTP system. Running heavy analytical queries directly against it can slow down the very transactions it exists to process — which is one reason companies copy data out into a separate **data warehouse** built for OLAP instead.

> [!NOTE]
> This is only a preview. Module 07 covers data warehouses, star schemas, and business intelligence (BI) tooling in depth.

---

## &#128204; Big Data and NoSQL — A Teaser

**Big Data** refers to datasets so large, fast-moving, or unstructured that traditional relational tables start to strain — think billions of sensor readings, social media posts, or clickstream events per day.

- **NoSQL** ("Not Only SQL") databases are a family of *non*-relational engines built for this scale and shape of data: document stores (MongoDB), key-value stores (Redis), wide-column stores (Cassandra), and graph databases (Neo4j, ArangoDB) are all common examples.
- They typically trade some of the strict consistency and rigid schema of a relational database for horizontal scalability and flexible, schema-light documents.

This course is a *relational* database course — but it's worth knowing NoSQL exists so you recognize when a project's shape (huge scale, loosely structured data, need for horizontal scale-out) might call for it instead of, or alongside, a relational engine.

---

## &#128204; Cloud Computing — A Teaser

**Cloud computing** means running your database (and everything else) on someone else's hardware, rented over the internet, instead of buying and maintaining your own servers.

| Provider | Managed relational database offering |
|---|---|
| **Amazon Web Services (AWS)** | RDS (PostgreSQL, MySQL, SQL Server, ...), Aurora |
| **Microsoft Azure** | Azure SQL Database, Azure Database for PostgreSQL |
| **Google Cloud Platform (GCP)** | Cloud SQL, AlloyDB |

A **managed database service** handles backups, patching, replication, and scaling for you — you connect to it exactly like any other PostgreSQL/MySQL/SQL Server instance, using the same SQL you're learning in this course, but you never touch the physical machine it runs on.

> [!TIP]
> Everything in this course — every `CREATE TABLE`, every `SELECT` — runs identically whether the database sits on your laptop or inside AWS RDS. The SQL doesn't change; only *who manages the server underneath it* does.

---

See also: [The DBMS Landscape](01-03-dbms-landscape.md), [Data Warehouses & Marts](../01-notes/07-01-data-warehouses-and-marts.md)

<!-- course-footer -->
---

<div align="center" markdown>

[All Notes](README.md) &nbsp;|&nbsp; [Module 01 Exercise](../02-exercises/01-exercise.md) &nbsp;|&nbsp; <strong>Next:</strong> [Relations &amp; Terminology](02-01-relations-and-terminology.md)

</div>
<!-- /course-footer -->
