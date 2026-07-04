# &#128736; Project 06 — Transactions & Concurrency Lab

<!-- course-header -->
<div align="center" markdown>

![SQL & Databases](../../assets/banner.svg)

[![View the live site — ijk37.com](https://img.shields.io/badge/%F0%9F%87%A7%F0%9F%87%A9_View_the_Live_Site-IJK37.COM-F42A41?style=for-the-badge&labelColor=006A4E)](https://ijk37.com/sql/)

<img src="https://img.shields.io/badge/Project_06-Transactions_and_Concurrency_Lab-336791?style=for-the-badge&labelColor=24506B" alt="Project 06: Transactions & Concurrency Lab">

[![Home](https://img.shields.io/badge/⌂_Home-1B2A35?style=flat-square)](../../index.md) [![All Projects](https://img.shields.io/badge/All_Projects-1B2A35?style=flat-square)](../README.md) [![Notes](https://img.shields.io/badge/Notes-1B2A35?style=flat-square)](../../01-notes/06-01-dba-roles.md) [![Quiz](https://img.shields.io/badge/▶_Quiz-C6821E?style=flat-square&labelColor=24506B)](../../03-quiz/)

</div>
<!-- /course-header -->

**Type:** Hands-on lab with two concurrent `psql` sessions
**Modules:** 06 (Database Administration)
**Difficulty:** ⭐⭐⭐

---

## &#127919; Objective

Deliberately reproduce a lost-update race condition using two concurrent PostgreSQL sessions, observe it happen, and then fix it two different ways: with row-level locking (`SELECT ... FOR UPDATE`) and with a stricter isolation level.

---

## &#129517; Scenario

San Juan Sailboat Charters has exactly **one** remaining berth on boat `WA-4471` for the July 1–4 weekend. Two booking clerks, working from different terminals, both try to book that last berth for different customers at almost the same moment. Without proper concurrency control, both bookings can succeed — overselling a boat that only has room for one more group.

Set up the schema:

```sql
CREATE TABLE boat (
    boat_reg_number   VARCHAR(10) PRIMARY KEY,
    boat_name         VARCHAR(40) NOT NULL,
    berths_available  INTEGER NOT NULL CHECK (berths_available >= 0)
);

INSERT INTO boat (boat_reg_number, boat_name, berths_available)
VALUES ('WA-4471', 'Windrunner', 1);

CREATE TABLE charter_booking (
    booking_id      SERIAL PRIMARY KEY,
    boat_reg_number VARCHAR(10) NOT NULL REFERENCES boat(boat_reg_number),
    customer_name   VARCHAR(100) NOT NULL,
    booked_at       TIMESTAMP NOT NULL DEFAULT now()
);
```

---

## &#128204; Requirements

1. Open **two separate `psql` sessions** connected to the same database (two terminal windows/tabs).
2. Reproduce the lost update / overbooking race condition using ordinary, unprotected statements.
3. Fix the race two ways: pessimistic locking (`SELECT ... FOR UPDATE`) and an appropriate isolation level.
4. Explain, in your own words, why each fix works.

---

## &#129513; Tasks

### &#128313; Part A — Reproduce the Race (Unprotected)

In **Session 1**:

```sql
BEGIN;
SELECT berths_available FROM boat WHERE boat_reg_number = 'WA-4471';
-- observe: 1
```

Before committing Session 1, switch to **Session 2** and run the same:

```sql
BEGIN;
SELECT berths_available FROM boat WHERE boat_reg_number = 'WA-4471';
-- observe: 1  (Session 2 also sees 1 berth available — neither session has written yet)
```

Now, back in **Session 1**, finish the booking:

```sql
UPDATE boat SET berths_available = berths_available - 1
WHERE boat_reg_number = 'WA-4471';
INSERT INTO charter_booking (boat_reg_number, customer_name)
VALUES ('WA-4471', 'Rosa Alvarez');
COMMIT;
```

Then, in **Session 2**, finish its booking too — using the value it originally read (1), not rechecking:

```sql
UPDATE boat SET berths_available = berths_available - 1
WHERE boat_reg_number = 'WA-4471';
INSERT INTO charter_booking (boat_reg_number, customer_name)
VALUES ('WA-4471', 'Sam Bloom');
COMMIT;
```

Check the result:

```sql
SELECT * FROM boat WHERE boat_reg_number = 'WA-4471';
SELECT * FROM charter_booking WHERE boat_reg_number = 'WA-4471';
```

You should find **two** `charter_booking` rows for a boat that only had one berth, and `berths_available` may show `0` or even go negative depending on timing (the `CHECK` constraint will eventually stop a UPDATE — 1 - 1 - 1 = -1 is blocked by `CHECK (berths_available >= 0)`, but by then the second `charter_booking` INSERT has already gone through, having already overbooked the boat). This is the **lost update problem** from [06-02](../../01-notes/06-02-concurrency-and-locking.md) in action.

### &#128313; Part B — Fix with Pessimistic Locking

Reset `berths_available` back to `1` and delete the test bookings. Repeat the experiment, but this time use `FOR UPDATE` in both sessions:

```sql
BEGIN;
SELECT berths_available FROM boat
WHERE boat_reg_number = 'WA-4471'
FOR UPDATE;
-- Session 2, if run now, will BLOCK here until Session 1 commits or rolls back
```

Finish Session 1's transaction, then let Session 2's blocked `SELECT ... FOR UPDATE` proceed — it will now correctly see `0` berths and your application logic can reject the second booking instead of overselling.

### &#128313; Part C — Fix with an Isolation Level

Reset the data again. This time, leave out `FOR UPDATE` but set a stricter isolation level in both sessions:

```sql
BEGIN;
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;

SELECT berths_available FROM boat WHERE boat_reg_number = 'WA-4471';
UPDATE boat SET berths_available = berths_available - 1
WHERE boat_reg_number = 'WA-4471';

COMMIT;
```

Run the same in both sessions with the same interleaving as Part A. One of the two `COMMIT`s should now fail with a **serialization failure** error, because PostgreSQL detects that the two transactions cannot be reordered into any valid serial schedule. Your application must catch this error and retry the failed transaction.

---

## &#9989; Verification Checklist

- [ ] Part A actually reproduces two successful bookings against a single available berth (screenshot or paste the terminal output).
- [ ] Part B shows Session 2's `SELECT ... FOR UPDATE` blocking until Session 1 commits, and correctly reports 0 berths afterward.
- [ ] Part C shows one transaction succeeding and the other failing with a serialization error on `COMMIT`.
- [ ] A short written explanation of *why* each fix prevents the race (pessimistic locking vs. serializable isolation are different mechanisms — explain both).

---

## &#128230; Deliverables

- Terminal transcripts (or screenshots) from all three parts, showing the interleaved commands from both sessions.
- A short written explanation (3–5 sentences per fix) of why Part B and Part C each solve the race condition differently.
- The final, corrected booking logic you'd recommend for production (pick one of the two fixes and justify the choice).

---

## &#128640; Stretch Goals

- Deliberately construct a **deadlock** between two sessions locking two different boats in opposite order, and observe PostgreSQL's `deadlock detected` error.
- Reproduce a **dirty read** by lowering the isolation level and reading another (uncommitted) session's in-progress `UPDATE` — then explain why PostgreSQL's MVCC design actually prevents this even at `READ UNCOMMITTED`.

See also notes: [Concurrency & Locking](../../01-notes/06-02-concurrency-and-locking.md), [Transactions & ACID](../../01-notes/06-03-transactions-and-acid.md)

<!-- course-footer -->
---

<div align="center" markdown>

[All Projects](../README.md) &nbsp;|&nbsp; [Module 06 Notes](../../01-notes/06-01-dba-roles.md) &nbsp;|&nbsp; <strong>Next:</strong> [Mini Data Warehouse &amp; BI](../07-mini-data-warehouse-and-bi/README.md)

</div>
<!-- /course-footer -->
