# &#128216; 07-04: Big Data & NoSQL

<!-- course-header -->
<div align="center" markdown>

![SQL & Databases](../assets/banner.svg)

<img src="https://img.shields.io/badge/Module_07-Data_Warehousing_BI-336791?style=for-the-badge&labelColor=24506B" alt="Module 07: Data Warehousing, BI & Big Data">

[![Home](https://img.shields.io/badge/⌂_Home-1B2A35?style=flat-square)](../index.md) [![All Notes](https://img.shields.io/badge/All_Notes-1B2A35?style=flat-square)](README.md) [![Practice](https://img.shields.io/badge/✎_Practice-C6821E?style=flat-square&labelColor=24506B)](../02-exercises/07-exercise.md) [![Quiz](https://img.shields.io/badge/▶_Quiz-C6821E?style=flat-square&labelColor=24506B)](../03-quiz/)

</div>
<!-- /course-header -->

## &#128161; When One Server Isn't Enough

Everything in this course so far has fit comfortably on one PostgreSQL instance. **Big Data** is the label for datasets and workloads that don't — search engines, social networks, and IoT sensor feeds generate far more data, far faster, than any single relational server can practically store or process. This note covers the concepts that emerged to handle that scale, and where a relational database like PostgreSQL still fits into the picture.

---

## &#128204; The Three V's

Big Data is usually characterized by three properties, all pushing past what a traditional single-server relational database was designed for:

- **Volume** — the sheer amount of data (terabytes to petabytes and beyond).
- **Velocity** — the speed at which new data arrives (thousands of events per second from sensors, clicks, or transactions).
- **Variety** — the mix of structured (tables), semi-structured (JSON, logs), and unstructured (images, video, free text) data, often all needing to be stored together.

> [!TIP]
> A dataset can be "big" in one of these dimensions without being big in the others — a video archive is high-volume but low-velocity; a stock ticker feed is high-velocity but modest in total volume. It's the *combination* that breaks traditional single-server designs.

---

## &#128204; Scaling Out Instead of Up

A traditional database scales **vertically** — buy a bigger server. Big Data systems scale **horizontally** — add more (cheaper, commodity) machines to a cluster and spread the work across them. That shift in strategy is why an entirely different processing model was needed.

### MapReduce

**MapReduce** is a technique for processing enormous datasets by splitting a job across a cluster of machines and then combining the partial results:

1. **Map** — the job is split into many independent pieces; each machine in the cluster processes its piece and emits intermediate key/value results.
2. **Shuffle** — intermediate results with the same key are grouped together across the cluster.
3. **Reduce** — each group is combined (summed, counted, merged) into the final output.

Conceptually, it's the same idea as `GROUP BY` + an aggregate function, just distributed across hundreds of machines instead of running in one process. **Hadoop Distributed File System (HDFS)** is the storage layer that usually sits underneath a MapReduce cluster — it replicates file blocks across many machines so the cluster has a single logical (but physically distributed and fault-tolerant) file system to read from.

---

## &#128204; The CAP Theorem

Once a database is spread across multiple machines (a **distributed database** — partitioned, replicated, or both), a fundamental tradeoff appears, formalized as the **CAP theorem**. A distributed system can only fully guarantee **two of three** properties at the same time:

- **Consistency (C)** — every replica returns the same (most recent) data for the same request.
- **Availability (A)** — every request gets a response, as long as the system is reachable.
- **Partition tolerance (P)** — the system keeps working even if a network failure splits the cluster into disconnected groups.

Since network partitions *will* eventually happen in any real distributed system, **P is effectively non-negotiable** — so the practical choice most distributed databases face is really **C vs. A** when a partition occurs: return possibly-stale data so every node stays available (**AP**), or refuse to answer until consistency can be guaranteed (**CP**). This is a genuine engineering tradeoff, not a solved problem — different NoSQL products deliberately choose different sides of it.

---

## &#128204; Where NoSQL Fits

**NoSQL** ("Not only SQL") is the umbrella term for non-relational databases built to run as distributed, replicated stores for exactly this kind of workload. They generally trade some of the relational model's strict structure and consistency guarantees for horizontal scalability and flexible schemas. Four common categories:

| Category | Stores | Examples |
|---|---|---|
| **Key-value** | An opaque value looked up by a single key | Redis, DynamoDB, Memcached |
| **Document** | Semi-structured documents (usually JSON) | MongoDB, Couchbase, ArangoDB |
| **Column-family** | Sparse tables optimized for huge numbers of columns/rows | Apache Cassandra, HBase |
| **Graph** | Nodes and the relationships (edges) between them | Neo4j, ArangoDB |

None of these replace a relational database for the workloads this course covers (enforcing referential integrity, running ad-hoc joins across normalized tables). They're a different tool for a different shape of problem — massive scale, flexible/evolving schema, or relationship-heavy traversal (graph databases) — not a strictly "better" database.

---

## &#128204; PostgreSQL's Middle Ground: `JSONB`

You don't have to leave the relational world to get some of NoSQL's flexibility. PostgreSQL's `JSONB` type stores semi-structured JSON data in a binary, indexable format right inside a normal relational table — a pragmatic hybrid for data that doesn't fit neatly into columns (a product's variable attributes, an event's variable payload) without giving up SQL, transactions, or joins to the rest of your schema.

```sql
CREATE TABLE product_catalog (
    product_id   SERIAL PRIMARY KEY,
    product_name VARCHAR(50) NOT NULL,
    attributes   JSONB
);

INSERT INTO product_catalog (product_name, attributes) VALUES
    ('Wireless Mouse', '{"color": "black", "wireless": true, "battery_type": "AA"}'),
    ('Mechanical Keyboard', '{"color": "white", "switch_type": "blue", "backlit": true}');

-- Query inside the JSON with the ->> operator (extract as text)
SELECT product_name, attributes ->> 'color' AS color
FROM   product_catalog
WHERE  attributes ->> 'wireless' = 'true';

-- Index JSONB for fast containment lookups
CREATE INDEX idx_product_attributes ON product_catalog USING GIN (attributes);

-- @> is the "contains" operator — find products with backlit = true
SELECT product_name
FROM   product_catalog
WHERE  attributes @> '{"backlit": true}';
```

This is the practical takeaway of the whole NoSQL discussion for a SQL-first data person: when only *part* of your data is variable/semi-structured, you often don't need to adopt an entirely separate NoSQL database — a `JSONB` column alongside your normal typed columns can be the simplest solution.

> [!NOTE]
> MySQL has a comparable `JSON` column type (functionally similar, but historically without `JSONB`'s binary storage and indexing advantages). SQL Server stores JSON as plain `NVARCHAR` text with JSON *functions* (`JSON_VALUE`, `JSON_QUERY`) rather than a dedicated JSON type. Oracle supports a native `JSON` type from Oracle Database 21c onward. Always check your target engine's current JSON support before assuming feature parity.

---

See also: [Cloud & Virtualization](07-03-cloud-and-virtualization.md), [OLAP vs. OLTP & BI](07-02-olap-vs-oltp-and-bi.md)

<!-- course-footer -->
---

<div align="center" markdown>

[All Notes](README.md) &nbsp;|&nbsp; [Module 07 Exercise](../02-exercises/07-exercise.md) &nbsp;|&nbsp; <strong>Next:</strong> [ALTER, MERGE & Views](08-01-alter-merge-and-views.md)

</div>
<!-- /course-footer -->
