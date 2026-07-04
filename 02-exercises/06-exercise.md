# &#9997; 06: Database Administration — Exercises

<!-- course-header -->
<div align="center" markdown>

![SQL & Databases](../assets/banner.svg)

<img src="https://img.shields.io/badge/Module_06-Database_Administration-336791?style=for-the-badge&labelColor=24506B" alt="Module 06: Database Administration"> <img src="https://img.shields.io/badge/12_questions-C6821E?style=for-the-badge&labelColor=24506B" alt="12 questions">

[![Home](https://img.shields.io/badge/⌂_Home-1B2A35?style=flat-square)](../index.md) [![Notes](https://img.shields.io/badge/Notes-1B2A35?style=flat-square)](../01-notes/06-01-dba-roles.md) [![All Exercises](https://img.shields.io/badge/All_Exercises-1B2A35?style=flat-square)](README.md) [![Quiz](https://img.shields.io/badge/▶_Quiz-C6821E?style=flat-square&labelColor=24506B)](../03-quiz/)

</div>
<!-- /course-header -->

> [!TIP]
> **Practice —** try each question first, then expand the answer to check your reasoning.

Work through each question, then click **Show answer** to check yourself. Review the [notes](../01-notes/06-01-dba-roles.md) if you get stuck.

---

### &#128313; Q1. Two clerks both read `berths_available = 1` for the same boat, both compute `0`, and both `UPDATE` the row. What is this failure called, and what's the underlying cause?

<details>
<summary><strong>Show answer</strong></summary>

This is the **lost update problem**. The underlying cause: both transactions read the same stale value before either committed its write, so the second `UPDATE` overwrites the first with no awareness a conflict occurred — one booking's decrement is silently lost.
</details>

---

### &#10067; Q2. Write a `BEGIN ... COMMIT` transaction that uses `SELECT ... FOR UPDATE` to safely decrement `berths_available` on `boat`, avoiding the lost update problem from Q1.

<details>
<summary><strong>Show answer</strong></summary>

```sql
BEGIN;

SELECT berths_available FROM boat
WHERE boat_reg_number = 'WA-4471'
FOR UPDATE;              -- takes an exclusive row lock

UPDATE boat SET berths_available = berths_available - 1
WHERE boat_reg_number = 'WA-4471';

COMMIT;
```

`FOR UPDATE` forces any second transaction trying to lock the same row to wait until this one commits or rolls back, so it can never act on the stale pre-decrement value.
</details>

---

### &#128313; Q3. Explain the difference between optimistic and pessimistic concurrency control. Which one is `SELECT ... FOR UPDATE` an example of?

<details>
<summary><strong>Show answer</strong></summary>

**Pessimistic** control assumes conflicts will happen and locks data up front before any work begins, holding the lock until commit. **Optimistic** control assumes conflicts are rare, does the work without locking, and only checks for a conflict (usually via a version/timestamp column) right before writing — retrying if a conflict is found. `SELECT ... FOR UPDATE` is **pessimistic** — it takes the lock immediately.
</details>

---

### &#10067; Q4. Transaction A locks row X then wants row Y; Transaction B locks row Y then wants row X. What is this condition called, and how does PostgreSQL resolve it?

<details>
<summary><strong>Show answer</strong></summary>

This is a **deadlock** (deadly embrace). PostgreSQL's deadlock detector identifies the circular wait automatically, picks one transaction as the "victim," and aborts it with a `deadlock detected` error — the application is expected to catch that error and retry the aborted transaction.
</details>

---

### &#127919; Q5. List the four ACID properties and, in one sentence each, what each one guarantees.

<details>
<summary><strong>Show answer</strong></summary>

- **Atomic** — all of a transaction's steps happen, or none do.
- **Consistent** — every commit leaves the database obeying all its constraints.
- **Isolated** — concurrent transactions don't see each other's uncommitted changes.
- **Durable** — once committed, changes survive a crash.
</details>

---

### &#10067; Q6. A bank-style transfer moves $500 from account A to account B: debit A, then credit B. Write this as a single SQL transaction, and explain what `ROLLBACK` would need to undo if the credit step failed.

<details>
<summary><strong>Show answer</strong></summary>

```sql
BEGIN;

UPDATE account SET balance = balance - 500.00 WHERE account_id = 'A';
UPDATE account SET balance = balance + 500.00 WHERE account_id = 'B';

COMMIT;
```

If the credit to B failed (e.g., account B didn't exist, violating a foreign key), `ROLLBACK` must undo the debit already applied to A — otherwise $500 would simply vanish from the bank's books, violating atomicity.
</details>

---

### &#128313; Q7. Name the three read anomalies (dirty read, non-repeatable read, phantom read) and briefly distinguish them.

<details>
<summary><strong>Show answer</strong></summary>

- **Dirty read** — reading another transaction's uncommitted change, which might later be rolled back.
- **Non-repeatable read** — re-reading the *same row* twice in one transaction and getting two different values because another transaction committed a change in between.
- **Phantom read** — re-running the *same filtered query* twice and getting a different set of rows, because another transaction inserted or deleted matching rows in between.
</details>

---

### &#10067; Q8. Which SQL standard isolation level prevents all three anomalies from Q7? Which is the weakest, allowing all three?

<details>
<summary><strong>Show answer</strong></summary>

`SERIALIZABLE` prevents all three. `READ UNCOMMITTED` is the weakest and allows all three (though note: PostgreSQL doesn't actually implement `READ UNCOMMITTED` distinctly — it silently upgrades it to `READ COMMITTED` due to its MVCC storage engine).
</details>

---

### &#128313; Q9. MySQL/InnoDB defaults to which isolation level? PostgreSQL and Oracle default to which one? Why does this surprise developers switching between the two?

<details>
<summary><strong>Show answer</strong></summary>

**MySQL/InnoDB** defaults to `REPEATABLE READ`. **PostgreSQL and Oracle** default to `READ COMMITTED`. This surprises developers because code that behaves consistently under MySQL's default (immune to non-repeatable reads) may exhibit non-repeatable reads if the exact same transaction logic runs unmodified against Postgres's weaker default — the isolation level has to be raised explicitly if that guarantee is needed.
</details>

---

### &#127919; Q10. Write SQL to create a role `booking_clerk` that can `SELECT` and `INSERT` on the `charter` table, but only `SELECT` on `customer_id`, `customer_name`, and `phone` columns of `customer` (not the full row).

<details>
<summary><strong>Show answer</strong></summary>

```sql
CREATE ROLE booking_clerk WITH LOGIN PASSWORD 'change_me_immediately';

GRANT SELECT, INSERT ON charter TO booking_clerk;
GRANT SELECT (customer_id, customer_name, phone) ON customer TO booking_clerk;
```

Column-level `GRANT` restricts `booking_clerk` from reading sensitive columns (e.g., `credit_card_number`) that might exist on the same `customer` table.
</details>

---

### &#10067; Q11. What is the "principle of least privilege," and why should an application's database login almost never have `DROP TABLE` rights?

<details>
<summary><strong>Show answer</strong></summary>

The principle: grant each account or role only the access strictly required for its job, nothing more. An application login should never have `DROP TABLE`/`ALTER TABLE`/superuser rights because if the application has a vulnerability (e.g., SQL injection), an attacker who takes over that connection is limited to whatever that account can do — without destructive schema privileges, they can't drop or alter tables even if they compromise the app.
</details>

---

### &#128313; Q12. Distinguish full, differential, and incremental backups, and explain how point-in-time recovery (PITR) goes beyond all three using PostgreSQL's write-ahead log (WAL).

<details>
<summary><strong>Show answer</strong></summary>

- **Full backup** — captures the entire database.
- **Differential backup** — captures everything changed since the *last full* backup.
- **Incremental backup** — captures everything changed since the *last backup of any kind* (fastest to take, slowest to restore since every incremental must be replayed in order).

**PITR** goes further: instead of restoring only to the moment of the last backup, you restore the last full backup and then replay the archived WAL segments up to *any specific timestamp* — e.g., one minute before an accidental mass delete — because every committed change is durably recorded in the WAL before it's applied to the data files.
</details>

---

[All Exercises](README.md) &nbsp;|&nbsp; **Next:** [07: Data Warehousing, BI & Big Data — Exercises](07-exercise.md)

<!-- course-footer -->
---

<div align="center" markdown>

[All Exercises](README.md) &nbsp;|&nbsp; [Module 06 Notes](../01-notes/06-01-dba-roles.md) &nbsp;|&nbsp; <strong>Next:</strong> [07: Data Warehousing, BI &amp; Big Data — Exercises](07-exercise.md)

</div>
<!-- /course-footer -->
