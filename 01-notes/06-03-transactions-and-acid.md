# &#128216; 06-03: Transactions & ACID

<!-- course-header -->
<div align="center" markdown>

![SQL & Databases](../assets/banner.svg)

<img src="https://img.shields.io/badge/Module_06-Database_Administration-336791?style=for-the-badge&labelColor=24506B" alt="Module 06: Database Administration">

[![Home](https://img.shields.io/badge/⌂_Home-1B2A35?style=flat-square)](../index.md) [![All Notes](https://img.shields.io/badge/All_Notes-1B2A35?style=flat-square)](README.md) [![Practice](https://img.shields.io/badge/✎_Practice-C6821E?style=flat-square&labelColor=24506B)](../02-exercises/06-exercise.md) [![Quiz](https://img.shields.io/badge/▶_Quiz-C6821E?style=flat-square&labelColor=24506B)](../03-quiz/)

</div>
<!-- /course-header -->

## &#128161; A Transaction Is a Logical Unit of Work

A **transaction** (also called a logical unit of work, or LUW) groups multiple statements so they succeed or fail *together* — never half-applied. SQL gives you three statements to control transaction boundaries:

```sql
BEGIN;                 -- start a transaction
-- ... one or more statements ...
COMMIT;                -- make all changes permanent
-- or, instead of COMMIT:
ROLLBACK;               -- undo everything since BEGIN
```

> [!NOTE]
> PostgreSQL uses `BEGIN` to start a transaction block; the SQL standard spells it `START TRANSACTION` (also accepted by PostgreSQL, and the form used by MySQL and SQL Server). `COMMIT`/`ROLLBACK` are consistent across all major products.

---

## &#128204; Worked Example: A Charter Booking Transfer

Imagine San Juan Sailboat Charters needs to move a deposit from a customer's store-credit balance to pay for a new charter booking. That's two separate row changes that must happen together — decrease the credit balance, insert the charter row — or not at all.

```sql
BEGIN;

UPDATE customer
SET store_credit = store_credit - 500.00
WHERE customer_id = 'C-01';

INSERT INTO charter (customer_id, boat_reg_number, departure_date, return_date, boat_cost)
VALUES ('C-01', 'WA-4471', '2026-08-01', '2026-08-04', 500.00);

COMMIT;
```

If the second statement failed (say, the boat was already booked and a `CHECK` constraint rejected the insert), you don't want the customer's credit silently gone with nothing to show for it. `ROLLBACK` undoes the `UPDATE` too:

```sql
BEGIN;

UPDATE customer
SET store_credit = store_credit - 500.00
WHERE customer_id = 'C-01';

-- suppose this fails or the app decides to cancel:
ROLLBACK;
-- store_credit is back to its original value, as if nothing happened
```

---

## &#128204; The Four ACID Properties

**ACID** is the acronym for the four guarantees a transaction is supposed to provide.

### Atomic

All of a transaction's steps happen, or none do. In the example above, the credit deduction and the new charter row are inseparable — the database will never show one without the other, even if the server crashes mid-transaction.

### Consistent

A transaction takes the database from one valid state to another valid state, respecting every constraint (`PRIMARY KEY`, `FOREIGN KEY`, `CHECK`, `NOT NULL`, etc.) along the way. If a step would violate a constraint — say, `store_credit` going negative because of a `CHECK (store_credit >= 0)` — the whole transaction is rejected rather than leaving the database in a state that breaks its own rules.

### Isolated

Transactions running at the same time shouldn't see each other's uncommitted, in-progress changes — each transaction should behave as if it has the database to itself, even though other transactions are actually interleaved with it. How strictly this is enforced is tunable — that's the isolation-level discussion below.

### Durable

Once a transaction commits, its changes survive — even a power failure or crash immediately afterward. PostgreSQL guarantees this using **write-ahead logging (WAL)**: changes are written to a durable log *before* the `COMMIT` is acknowledged to the client, so the database can replay the log to recover any committed transaction after a crash. (More on WAL in [06-04](06-04-security-backup-recovery.md).)

---

## &#128204; Isolation Levels and the Anomalies They Prevent

Full isolation (as if every transaction ran completely alone, one at a time) is the safest option but also the slowest, because it means transactions block each other constantly. The 1992 ANSI SQL standard defines four isolation levels, each allowing progressively fewer read anomalies at the cost of more locking/blocking.

| Anomaly | Description |
|---|---|
| **Dirty read** | Reading another transaction's *uncommitted* change (which might later roll back) |
| **Non-repeatable read** | Re-reading the same row twice in one transaction and getting a different value, because another transaction committed a change in between |
| **Phantom read** | Re-running the same filtered query twice in one transaction and getting a *different set of rows*, because another transaction inserted/deleted matching rows in between |

| Isolation level | Dirty read | Non-repeatable read | Phantom read |
|---|:---:|:---:|:---:|
| `READ UNCOMMITTED` | Possible | Possible | Possible |
| `READ COMMITTED` | Prevented | Possible | Possible |
| `REPEATABLE READ` | Prevented | Prevented | Possible |
| `SERIALIZABLE` | Prevented | Prevented | Prevented |

Setting the isolation level in PostgreSQL:

```sql
BEGIN;
SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;

SELECT berths_available FROM boat WHERE boat_reg_number = 'WA-4471';
-- ... application logic ...
UPDATE boat SET berths_available = berths_available - 1
WHERE boat_reg_number = 'WA-4471';

COMMIT;
```

> [!NOTE]
> **Defaults differ by product.** PostgreSQL and Oracle default new transactions to `READ COMMITTED`. **MySQL/InnoDB defaults to `REPEATABLE READ`** — a common surprise for developers moving between the two, since it means MySQL blocks a whole extra category of anomaly (non-repeatable reads) out of the box that Postgres would allow unless you explicitly raise the level.
>
> Also, PostgreSQL doesn't literally implement `READ UNCOMMITTED` — it accepts the syntax but silently treats it as `READ COMMITTED`, because Postgres's storage engine (MVCC — multiversion concurrency control) never lets one transaction see another's uncommitted rows in the first place.

---

## &#128204; Choosing a Level

- **`READ COMMITTED`** — the right default for most OLTP workloads. Cheap, and dirty reads (the worst anomaly) are already prevented.
- **`REPEATABLE READ`** — reach for this when a transaction reads the same row multiple times and needs it to stay stable throughout (e.g., a report that reads a balance, does math, then reads it again to double-check).
- **`SERIALIZABLE`** — reserve for the small number of transactions where correctness absolutely cannot tolerate *any* concurrency anomaly (e.g., financial transfers, inventory counts near zero) — accept that PostgreSQL may abort and ask you to retry a serializable transaction if it detects a conflict, rather than silently letting an anomaly through.

> [!TIP]
> Higher isolation is not automatically "more correct" for free — it's a deliberate trade of throughput for safety. Use `SELECT ... FOR UPDATE` (pessimistic row locking, from [06-02](06-02-concurrency-and-locking.md)) when you specifically need to protect one hot row, rather than raising the isolation level for an entire transaction.

---

See also: [Concurrency & Locking](06-02-concurrency-and-locking.md), [Security, Backup & Recovery](06-04-security-backup-recovery.md)

<!-- course-footer -->
---

<div align="center" markdown>

[All Notes](README.md) &nbsp;|&nbsp; [Module 06 Exercise](../02-exercises/06-exercise.md) &nbsp;|&nbsp; <strong>Next:</strong> [Security, Backup & Recovery](06-04-security-backup-recovery.md)

</div>
<!-- /course-footer -->
