# &#128216; 06-04: Security, Backup & Recovery

<!-- course-header -->
<div align="center" markdown>

![SQL & Databases](../assets/banner.svg)

<img src="https://img.shields.io/badge/Module_06-Database_Administration-336791?style=for-the-badge&labelColor=24506B" alt="Module 06: Database Administration">

[![Home](https://img.shields.io/badge/⌂_Home-1B2A35?style=flat-square)](../index.md) [![All Notes](https://img.shields.io/badge/All_Notes-1B2A35?style=flat-square)](README.md) [![Practice](https://img.shields.io/badge/✎_Practice-C6821E?style=flat-square&labelColor=24506B)](../02-exercises/06-exercise.md) [![Quiz](https://img.shields.io/badge/▶_Quiz-C6821E?style=flat-square&labelColor=24506B)](../03-quiz/)

</div>
<!-- /course-header -->

## &#128161; Two Halves of "Keeping the Data Safe"

Database security is about **who is allowed to do what**. Backup and recovery is about **surviving the day something goes wrong anyway** — hardware failure, a bad deploy, a mistaken `DELETE`, or a malicious actor. Both are core DBA responsibilities from [06-01](06-01-dba-roles.md), and both show up constantly in real interviews and real incidents.

---

## &#128204; Authentication vs. Authorization

- **Authentication** — proving *who you are* (username + password, certificate, SSO token).
- **Authorization** — determining *what you're allowed to do* once you're recognized.

SQL's authorization model is built on `GRANT` and `REVOKE`, applied either to individual users or — much more commonly in real organizations — to **roles** that group related permissions together.

```sql
-- Create a role representing "read-only reporting access"
CREATE ROLE reporting_readonly;
GRANT CONNECT ON DATABASE charter_co TO reporting_readonly;
GRANT USAGE ON SCHEMA public TO reporting_readonly;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO reporting_readonly;

-- Create an actual login and add it to the role
CREATE ROLE alice WITH LOGIN PASSWORD 'change_me_immediately';
GRANT reporting_readonly TO alice;
```

Granting narrower privileges on specific tables/columns instead of the whole schema:

```sql
GRANT SELECT, INSERT, UPDATE ON charter TO booking_clerk;
GRANT SELECT ON customer (customer_id, customer_name, phone) TO booking_clerk;
-- booking_clerk can read only those three columns of customer, not credit_card_number
```

Taking privileges back:

```sql
REVOKE INSERT, UPDATE ON charter FROM booking_clerk;
```

---

## &#128204; The Principle of Least Privilege

Grant each role **only the access it needs to do its job, and nothing more**. In practice:

- Never grant permissions to individual user accounts directly if a role can represent the job function instead — when someone changes jobs, you swap their role membership rather than re-auditing a pile of one-off grants.
- Application accounts (the credentials your web app connects with) should almost never have `DROP TABLE`, `ALTER TABLE`, or superuser rights — a SQL-injection bug in the app then can't take down the schema.
- Read-only reporting tools get `SELECT`-only roles, never `INSERT`/`UPDATE`/`DELETE`.
- Reserve superuser/admin accounts for actual DBA work, used rarely and audited when used.

This mirrors the Kroenke textbook's own case study: administrative assistants at a fictional seminar company get `Read, Insert, Change` on customer-facing tables, management gets those plus `Delete`, and only a system administrator role gets `Grant Rights, Modify Structure` — nobody gets more power than their job requires.

> [!NOTE]
> **Role/grant syntax differs across products.** PostgreSQL uses `CREATE ROLE` (a `ROLE` and a `USER` are essentially the same object — `USER` is a role with `LOGIN` implied). MySQL uses `CREATE USER` plus a separate `GRANT ... TO user@host` (privileges are tied to a user *and the host they connect from*). SQL Server layers `CREATE LOGIN` (server-level authentication) on top of `CREATE USER` (database-level) and grants permissions to database roles. The concepts — authenticate, then authorize via roles, then apply least privilege — are identical everywhere; only the exact commands change.

---

## &#128204; Why Backups Fail If Never Tested

Common causes of data loss the DBA must plan around: hardware failure, application bugs, human error (an accidental `DELETE` with no `WHERE` clause), and malicious action. None of these are fully preventable, which is why recovery procedures — not just prevention — are essential.

**Recovery via reprocessing** means redoing every transaction from scratch since the last backup, using saved input records. It's simple in concept but has an obvious flaw: it takes roughly as long to redo the work as it took to do it the first time, and a busy system may never "catch up" to the present.

**Recovery via rollback/rollforward** is what real DBMSs actually use, built on a **transaction log**:

- Every change is recorded in the log as a **before-image** (the row's value before the change) and an **after-image** (the row's value after the change).
- **Rollback** applies before-images in reverse order — used to undo a bad or malicious transaction after the fact.
- **Rollforward** applies after-images in order — used to bring a restored backup back up to date by replaying everything that happened since.

---

## &#128204; Backup Strategies

| Strategy | What it captures | Restore speed | Storage cost |
|---|---|---|---|
| **Full backup** | The entire database, every table | Fast (one restore step) | Highest |
| **Differential backup** | Everything changed since the *last full* backup | Medium (full + one differential) | Medium |
| **Incremental backup** | Everything changed since the *last backup of any kind* | Slowest to restore (full + every incremental in sequence) | Lowest |

A typical schedule: full backup weekly, incrementals nightly. Restoring means loading the full backup, then replaying each incremental in order up to the point of failure.

**Point-in-time recovery (PITR)** goes further: instead of restoring only to the moment of the last backup, you restore the last full backup and then replay the transaction log up to *any specific timestamp* — e.g., "restore to 11:58 AM, one minute before someone ran the accidental mass delete."

### Write-Ahead Logging (WAL) in PostgreSQL

PostgreSQL's durability guarantee (the "D" in ACID, from [06-03](06-03-transactions-and-acid.md)) is implemented via **WAL**: every change is written to the WAL log *before* it's applied to the actual data files, and before `COMMIT` returns success to the client. This gives PostgreSQL two things at once:

1. **Crash recovery** — if the server crashes, Postgres replays the WAL on restart to reapply any committed change that hadn't yet been flushed to the data files.
2. **Point-in-time recovery** — a base backup plus the archived WAL segments generated since lets you replay forward to any moment, exactly the rollforward concept above, implemented with a continuously-streamed log instead of a periodic one.

```sql
-- Conceptual shape of a PITR restore (actual commands run at the OS/tool level,
-- typically via pg_basebackup + a recovery target):
-- 1. Restore the last full base backup to a new data directory
-- 2. Supply the archived WAL segments since that backup
-- 3. Set a recovery target time, e.g. recovery_target_time = '2026-07-04 11:58:00'
-- 4. Start Postgres — it replays WAL up to that instant and stops
```

> [!TIP]
> A backup you have never restored is not a backup — it's an untested assumption. Periodically practice restoring to a scratch environment so a real incident isn't the first time anyone finds out the backup file was corrupt or incomplete.

> [!NOTE]
> MySQL's equivalent of WAL-based PITR uses the **binary log (binlog)**, replayed on top of a full `mysqldump`/`mysqlbackup` snapshot. SQL Server uses **transaction log backups** on top of full/differential backups. The underlying idea — full snapshot plus a replayable log of changes since — is the same pattern across every major relational DBMS.

---

See also: [Concurrency & Locking](06-02-concurrency-and-locking.md), [Transactions & ACID](06-03-transactions-and-acid.md)

<!-- course-footer -->
---

<div align="center" markdown>

[All Notes](README.md) &nbsp;|&nbsp; [Module 06 Exercise](../02-exercises/06-exercise.md) &nbsp;|&nbsp; <strong>Next:</strong> [Data Warehouses & Marts](07-01-data-warehouses-and-marts.md)

</div>
<!-- /course-footer -->
