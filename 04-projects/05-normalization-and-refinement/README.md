# &#128736; Project 05 — Normalization & Schema Refinement

<!-- course-header -->
<div align="center" markdown>

![SQL & Databases](../../assets/banner.svg)

[![View the live site — ijk37.com](https://img.shields.io/badge/%F0%9F%87%A7%F0%9F%87%A9_View_the_Live_Site-IJK37.COM-F42A41?style=for-the-badge&labelColor=006A4E)](https://ijk37.com/sql/)

<img src="https://img.shields.io/badge/Project_05-Normalization_and_Refinement-336791?style=for-the-badge&labelColor=24506B" alt="Project 05: Normalization & Schema Refinement">

[![Home](https://img.shields.io/badge/⌂_Home-1B2A35?style=flat-square)](../../index.md) [![All Projects](https://img.shields.io/badge/All_Projects-1B2A35?style=flat-square)](../README.md) [![Notes](https://img.shields.io/badge/Notes-1B2A35?style=flat-square)](../../01-notes/05-01-transforming-er-to-tables.md) [![Quiz](https://img.shields.io/badge/▶_Quiz-C6821E?style=flat-square&labelColor=24506B)](../../03-quiz/)

</div>
<!-- /course-header -->

**Type:** Written normalization exercise + `CREATE TABLE` deliverable
**Modules:** 05 (Database Design & Normalization)
**Difficulty:** ⭐⭐

---

## &#127919; Objective

Take a single, badly designed flat table full of update/insertion/deletion anomalies and normalize it step by step to 3NF, documenting each transformation and producing the final `CREATE TABLE` statements.

---

## &#129517; Scenario

**San Juan Sailboat Charters** tracks every charter booking in one spreadsheet-style table, `CHARTER_LOG`, exported from an old system:

| charter_id | customer_id | customer_name | customer_phone | boat_reg | boat_name | boat_daily_rate | equip1 | equip2 | departure_date | return_date |
|---|---|---|---|---|---|---|---|---|---|---|
| 3001 | C-11 | Alvarez, Rosa | 555-0110 | WA-4471 | Windrunner | 320.00 | Life jacket | Anchor | 2026-07-01 | 2026-07-04 |
| 3002 | C-12 | Bloom, Sam | 555-0122 | WA-2200 | Sea Fox | 275.00 | Life jacket | | 2026-07-02 | 2026-07-05 |
| 3003 | C-11 | Alvarez, Rosa | 555-0110 | WA-2200 | Sea Fox | 275.00 | Anchor | GPS unit | 2026-08-10 | 2026-08-12 |
| 3004 | C-13 | Chen, Priya | 555-0134 | WA-4471 | Windrunner | 320.00 | | | 2026-08-15 | 2026-08-17 |

The office manager has noticed real problems with this table:

- Rosa Alvarez's phone number is stored twice (rows 3001 and 3003) — if it ever needs correcting, someone has to remember to update both.
- The Sea Fox's daily rate is duplicated across every booking of that boat.
- A new customer who calls to ask about pricing, but hasn't booked yet, can't be entered at all — every row requires a full charter booking.
- The `equip1`/`equip2` columns already ran out of room on a charter that rented three items, and had to just drop the third.

---

## &#128204; Requirements

1. Identify every normalization violation in `CHARTER_LOG` (1NF, 2NF, and 3NF issues are all present).
2. Normalize step by step — don't jump straight to the final schema; show your work at each normal form.
3. Preserve every fact in the original table — normalizing must not lose information, only reorganize it.
4. Every derived/redundant value (anything computable from other columns) should be dropped, not carried forward.
5. Final schema must be in 3NF, with appropriate primary and foreign keys.

---

## &#129513; Tasks

### &#128313; Part A — Diagnose

1. List each anomaly you can find in `CHARTER_LOG` (at least one 1NF, one 2NF-style, and one 3NF-style issue).
2. For each, name which normal form it violates and why.

### &#128313; Part B — Normalize to 1NF

1. Fix the repeating `equip1`/`equip2` group. Sketch the resulting table shape (columns only, no need for full DDL yet).

### &#128313; Part C — Normalize to 2NF, then 3NF

1. Identify any partial dependency once you consider what a natural composite key would be.
2. Identify the transitive dependency involving customer details.
3. Split the design into properly normalized tables: `customer`, `boat`, `charter`, and `charter_equipment`.

### &#128313; Part D — Write the Final DDL

1. Write complete `CREATE TABLE` statements for all four resulting tables.
2. Add `PRIMARY KEY`, `FOREIGN KEY`, and at least one sensible `ON DELETE` action per foreign key, using the reasoning from [05-02](../../01-notes/05-02-representing-relationships-in-sql.md).

```sql
-- Starter shape — fill in the rest yourself
CREATE TABLE customer (
    customer_id    VARCHAR(10) PRIMARY KEY,
    customer_name  VARCHAR(100) NOT NULL,
    customer_phone CHAR(12)
);

CREATE TABLE boat (
    boat_reg        VARCHAR(10) PRIMARY KEY,
    boat_name       VARCHAR(40) NOT NULL,
    boat_daily_rate NUMERIC(9, 2) NOT NULL
);

-- charter and charter_equipment are up to you
```

---

## &#9989; Verification Checklist

- [ ] `CHARTER_LOG`'s repeating equipment columns are gone, replaced by a table with one row per equipment item.
- [ ] `customer_name` and `customer_phone` appear in exactly one table (`customer`), not duplicated per charter.
- [ ] `boat_name` and `boat_daily_rate` appear in exactly one table (`boat`), not duplicated per charter.
- [ ] No column can be computed from other columns already in the same row (no stored `num_days`, etc.).
- [ ] Every foreign key has an explicit `ON DELETE` action with a one-sentence justification.
- [ ] A new customer with no bookings yet can be inserted without any charter-related data.

---

## &#128230; Deliverables

- A short written diagnosis (a few sentences per anomaly) naming the violated normal form.
- The step-by-step normalization (1NF → 2NF → 3NF) shown as evolving table shapes.
- Final `CREATE TABLE` statements for `customer`, `boat`, `charter`, and `charter_equipment`, runnable in PostgreSQL.

---

## &#128640; Stretch Goals

- Add a `scheduled_maintenance` table (boat -> maintenance history) and reason about whether it introduces any new weak-entity considerations.
- Rewrite the original `CHARTER_LOG` as a `VIEW` built from your normalized tables with a `JOIN`, proving no information was lost in the split.

See also notes: [Normalization](../../01-notes/05-03-normalization.md), [Representing Relationships in SQL](../../01-notes/05-02-representing-relationships-in-sql.md)

<!-- course-footer -->
---

<div align="center" markdown>

[All Projects](../README.md) &nbsp;|&nbsp; [Module 05 Notes](../../01-notes/05-01-transforming-er-to-tables.md) &nbsp;|&nbsp; <strong>Next:</strong> [Transactions &amp; Concurrency Lab](../06-transactions-and-concurrency-lab/README.md)

</div>
<!-- /course-footer -->
