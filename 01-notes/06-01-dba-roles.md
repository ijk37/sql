# &#128216; 06-01: DBA Roles & Responsibilities

<!-- course-header -->
<div align="center" markdown>

![SQL & Databases](../assets/banner.svg)

<img src="https://img.shields.io/badge/Module_06-Database_Administration-336791?style=for-the-badge&labelColor=24506B" alt="Module 06: Database Administration">

[![Home](https://img.shields.io/badge/⌂_Home-1B2A35?style=flat-square)](../index.md) [![All Notes](https://img.shields.io/badge/All_Notes-1B2A35?style=flat-square)](README.md) [![Practice](https://img.shields.io/badge/✎_Practice-C6821E?style=flat-square&labelColor=24506B)](../02-exercises/06-exercise.md) [![Quiz](https://img.shields.io/badge/▶_Quiz-C6821E?style=flat-square&labelColor=24506B)](../03-quiz/)

</div>
<!-- /course-header -->

## &#128161; Data Administration vs. Database Administration

Two related terms get conflated constantly:

- **Data administration** is an *organization-wide* function — corporate policy on data privacy, data quality standards, and who is allowed to touch what, independent of any one system.
- **Database administration** is *technical and system-specific* — the day-to-day work of keeping one particular database (and the applications built on it) running correctly, securely, and fast.

The person doing the second job is the **DBA** (database administrator). Everything below is about that role.

---

## &#128204; What a DBA Actually Does

| Responsibility | In practice |
|---|---|
| **Schema design & evolution** | Reviewing/approving new tables, indexes, and migrations before they hit production |
| **Performance tuning** | Reading query plans (`EXPLAIN ANALYZE`), adding indexes, rewriting slow queries, adjusting server configuration |
| **Concurrency control** | Choosing sane isolation levels, watching for lock contention and deadlocks (see [06-02](06-02-concurrency-and-locking.md)) |
| **Security** | Managing accounts, roles, and privileges; enforcing least privilege (see [06-04](06-04-security-backup-recovery.md)) |
| **Backup & recovery** | Scheduling backups, testing restores, defining recovery point/time objectives |
| **Capacity planning** | Forecasting storage and throughput growth before it becomes an outage |
| **Change management** | Tracking schema-change requests, running them through review, documenting what changed and why |

A DBA is judged less by features shipped and more by things that *don't happen*: no data loss, no multi-hour outage, no silent corruption, no breach.

---

## &#128204; DBA vs. Data Architect vs. Data Engineer

These three roles overlap in most small companies (often the same one or two people wear all three hats), but they diverge sharply at scale — worth understanding if you're heading toward data-adjacent work.

| Role | Time horizon | Primary concern | Typical tools |
|---|---|---|---|
| **Data architect** | Long-term (months–years) | *What* the data model should look like across the whole organization — canonical entities, master data, how systems should relate | ER modeling tools, data catalogs, governance frameworks |
| **Database administrator (DBA)** | Ongoing / operational (daily–weekly) | Keeping *specific running databases* healthy — uptime, performance, security, backups | `psql`/DBMS consoles, monitoring dashboards, backup tooling |
| **Data engineer** | Project-based (days–weeks) | Building and maintaining *pipelines* that move and transform data between systems (source databases → warehouse → BI tools) | ETL/ELT frameworks, orchestration tools (Airflow-style schedulers), warehouse SQL |

A useful mental shortcut: the **architect** draws the blueprint, the **DBA** keeps the building standing and secure, and the **data engineer** builds the plumbing that moves water between buildings. All three need to understand normalization, keys, and SQL — this course covers the shared foundation every one of those roles is built on.

> [!NOTE]
> Cloud-managed databases (Amazon RDS, Google Cloud SQL, Azure SQL Database, and similar) automate some classic DBA tasks — patching, automated backups, failover — but they don't eliminate the role. Someone still has to design the schema well, choose the right indexes, review slow queries, and decide who gets access to what.

---

## &#128204; Documentation the DBA Owns

Kroenke's textbook treatment of DBA responsibilities emphasizes that documentation isn't optional busywork — it's what makes a database maintainable by someone other than the person who built it. A DBA is expected to maintain records of:

- The current database structure (schema, keys, constraints)
- Concurrency-control policy (which isolation levels are used where, and why)
- Security policy (who has which roles, and the reasoning)
- Backup and recovery procedures — and evidence that restores have actually been *tested*, not just scheduled

> [!TIP]
> If your database has no written backup/recovery runbook, assume the backups don't work until you've proven otherwise by actually restoring one. An untested backup is a hope, not a plan.

---

## &#128204; Handling Problems and Change Requests

Two ongoing processes round out the job beyond the technical checklist above:

- **Error and issue tracking** — the DBA needs a system for users to report problems, a way to prioritize them (a table locking up for every user outranks a cosmetic report formatting complaint), and a record that issues actually got resolved rather than quietly forgotten.
- **Configuration/change control** — before any schema change reaches production, there should be a repeatable process: someone records the requested change, developers and stakeholders review it for impact (does this `ALTER TABLE` break an existing report? does dropping a column break an application query?), and only then is it scheduled as an actual migration task.

Neither process needs to be heavyweight in a small shop — even a shared spreadsheet or lightweight ticket tracker beats an informal "just ask in chat" approach once more than one or two people touch the database.

### Service Level Agreements (SLAs)

For any database hosted with a cloud provider (managed PostgreSQL on AWS/GCP/Azure, for instance), the organization should have a **Service Level Agreement** on file that spells out concrete commitments: backup frequency and retention, guaranteed application response times, and error-reporting/escalation timelines. Without a written SLA, "the cloud will take care of it" is an assumption, not a guarantee — and the DBA is the one who has to know exactly what is and isn't covered before an incident happens, not during one.

---

See also: [Concurrency & Locking](06-02-concurrency-and-locking.md), [Security, Backup & Recovery](06-04-security-backup-recovery.md)

<!-- course-footer -->
---

<div align="center" markdown>

[All Notes](README.md) &nbsp;|&nbsp; [Module 06 Exercise](../02-exercises/06-exercise.md) &nbsp;|&nbsp; <strong>Next:</strong> [Concurrency & Locking](06-02-concurrency-and-locking.md)

</div>
<!-- /course-footer -->
