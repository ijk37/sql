# &#128216; 06-02: Concurrency & Locking

<!-- course-header -->
<div align="center" markdown>

![SQL & Databases](../assets/banner.svg)

<img src="https://img.shields.io/badge/Module_06-Database_Administration-336791?style=for-the-badge&labelColor=24506B" alt="Module 06: Database Administration">

[![Home](https://img.shields.io/badge/⌂_Home-1B2A35?style=flat-square)](../index.md) [![All Notes](https://img.shields.io/badge/All_Notes-1B2A35?style=flat-square)](README.md) [![Practice](https://img.shields.io/badge/✎_Practice-C6821E?style=flat-square&labelColor=24506B)](../02-exercises/06-exercise.md) [![Quiz](https://img.shields.io/badge/▶_Quiz-C6821E?style=flat-square&labelColor=24506B)](../03-quiz/)

</div>
<!-- /course-header -->

## &#128161; Why Concurrency Control Matters

A single-user database is trivial to reason about — every change happens in order, one after another. Real databases have dozens, hundreds, or thousands of users hitting the same tables at the same instant. **Concurrency control** is the set of techniques that make sure one user's work doesn't corrupt or contradict another's, so the outcome looks the same whether ten people are using the system or one.

---

## &#128204; The Lost Update Problem

The classic failure mode: two transactions read the same row, both compute a new value based on what they read, and the second `WRITE` silently overwrites the first — one update is **lost** with no error, no warning.

Picture two clerks both booking the last available berth on charter boat `WA-4471`:

| Time | Transaction A | Transaction B |
|---|---|---|
| t1 | `SELECT berths_available FROM boat WHERE boat_reg_number='WA-4471';` → reads `1` | |
| t2 | | `SELECT berths_available FROM boat WHERE boat_reg_number='WA-4471';` → reads `1` |
| t3 | computes `1 - 1 = 0`, `UPDATE ... SET berths_available = 0` | |
| t4 | | computes `1 - 1 = 0` (still using its stale read of `1`), `UPDATE ... SET berths_available = 0` |

Both transactions think they successfully booked the last berth. The boat is now double-booked, and the database shows `0` — a value that's *technically* correct as a final number but hides the fact that two different bookings both believe they succeeded.

A related failure is the **dirty read** (also called an inconsistent read): one transaction reads data that another transaction has changed but not yet committed. If the writer then rolls back, the reader made a decision based on data that never actually existed in the database.

---

## &#128204; Locking Granularity

A **lock** tells the DBMS "something is using this data — don't let anyone else conflict with it." Locks can be taken at different **granularities**:

| Granularity | Scope | Trade-off |
|---|---|---|
| **Row-level** | One row | High concurrency (other rows stay free), more overhead tracking many small locks |
| **Page-level** | A disk page (may hold several rows) | Middle ground — fewer locks to track, but can block unrelated rows sharing a page |
| **Table-level** | An entire table | Cheap to manage, but blocks everyone else working anywhere in that table |

PostgreSQL, like most modern DBMSs, defaults to fine-grained **row-level locking** for ordinary `UPDATE`/`DELETE` statements — only the rows actually being changed are locked, which is why concurrent traffic on unrelated rows generally isn't blocked.

Locks also come in two flavors of *strength*:

- **Shared lock** — other transactions may still read the locked data, but none may change it.
- **Exclusive lock** — no other transaction may read *or* write the locked data.

---

## &#128204; Pessimistic vs. Optimistic Concurrency Control

Two fundamentally different philosophies for handling the lost-update problem:

**Pessimistic concurrency control** assumes conflicts *will* happen, so it locks data up front before letting anyone touch it, holds the lock through the whole transaction, and releases it at the end.

```sql
BEGIN;
SELECT berths_available FROM boat
WHERE boat_reg_number = 'WA-4471'
FOR UPDATE;              -- takes an exclusive row lock right now

UPDATE boat SET berths_available = berths_available - 1
WHERE boat_reg_number = 'WA-4471';
COMMIT;                  -- lock released here
```

Any second transaction trying to `SELECT ... FOR UPDATE` the same row simply **waits** until the first commits or rolls back — it cannot read a stale value and act on it.

**Optimistic concurrency control** assumes conflicts are *rare*, so it skips locking entirely: read the data, do the work, and only check for conflicts right before writing — typically by comparing a version number or timestamp.

```sql
-- Read phase: note the version the client saw
SELECT berths_available, row_version FROM boat
WHERE boat_reg_number = 'WA-4471';
-- (application computes new value in memory)

-- Write phase: only succeeds if nobody else changed the row since the read
UPDATE boat
SET berths_available = berths_available - 1,
    row_version = row_version + 1
WHERE boat_reg_number = 'WA-4471'
  AND row_version = 7;      -- the version we originally read

-- application checks rows affected; if 0, someone else won the race —
-- reload and retry
```

| | Pessimistic | Optimistic |
|---|---|---|
| Best when | Conflicts are frequent, contention is high | Conflicts are rare, most reads never collide |
| Cost | Transactions wait on locks | Failed attempts must detect conflict and retry |
| Throughput | Lower under high contention | Higher when contention is actually low |

---

## &#128204; Two-Phase Locking and Serializability

A schedule of concurrent transactions is **serializable** if its result matches *some* possible one-at-a-time (serial) ordering of those same transactions — i.e., concurrency didn't sneak in a result that could never happen if everyone just took turns.

**Two-phase locking (2PL)** is a standard technique for guaranteeing serializability. Every transaction goes through two phases:

1. **Growing phase** — the transaction may only acquire new locks, never release any.
2. **Shrinking phase** — once the first lock is released, the transaction may only release locks, never acquire new ones.

This growing-then-shrinking shape (never released-then-acquired-again) is what prevents a whole class of anomalies where a transaction reads two different snapshots of the same data mid-flight.

---

## &#128204; Deadlock

A **deadlock** (or "deadly embrace") happens when two transactions each hold a lock the other needs, and each waits forever for the other to release it.

```text
Transaction A: locks boat WA-4471, then wants to lock boat WA-2200
Transaction B: locks boat WA-2200, then wants to lock boat WA-4471
```

Neither can proceed. PostgreSQL detects this automatically (it runs a periodic deadlock-detection check) and resolves it by picking one transaction as the "victim," aborting it with an error so the other can continue:

```sql
ERROR:  deadlock detected
DETAIL:  Process 1234 waits for ShareLock on transaction 5678; blocked by process 5678.
HINT:  See server log for query details.
```

The application is expected to catch that error and retry the aborted transaction.

> [!TIP]
> The simplest defense against deadlocks in application code: always acquire locks on multiple rows **in the same order** across every transaction (e.g., always lock the lowest primary key first). If every transaction agrees on lock order, circular waits become impossible.

> [!NOTE]
> MySQL/InnoDB and SQL Server also detect deadlocks automatically and roll back a victim transaction, using the same underlying idea — the specific victim-selection heuristic differs by product, but the SQL-level symptom (an aborted transaction you must retry) is the same everywhere.

---

See also: [Transactions & ACID](06-03-transactions-and-acid.md), [DBA Roles & Responsibilities](06-01-dba-roles.md)

<!-- course-footer -->
---

<div align="center" markdown>

[All Notes](README.md) &nbsp;|&nbsp; [Module 06 Exercise](../02-exercises/06-exercise.md) &nbsp;|&nbsp; <strong>Next:</strong> [Transactions & ACID](06-03-transactions-and-acid.md)

</div>
<!-- /course-footer -->
