# &#128216; 05-03: Normalization

<!-- course-header -->
<div align="center" markdown>

![SQL & Databases](../assets/banner.svg)

<img src="https://img.shields.io/badge/Module_05-DB_Design_Normalization-336791?style=for-the-badge&labelColor=24506B" alt="Module 05: Database Design & Normalization">

[![Home](https://img.shields.io/badge/⌂_Home-1B2A35?style=flat-square)](../index.md) [![All Notes](https://img.shields.io/badge/All_Notes-1B2A35?style=flat-square)](README.md) [![Practice](https://img.shields.io/badge/✎_Practice-C6821E?style=flat-square&labelColor=24506B)](../02-exercises/05-exercise.md) [![Quiz](https://img.shields.io/badge/▶_Quiz-C6821E?style=flat-square&labelColor=24506B)](../03-quiz/)

</div>
<!-- /course-header -->

## &#128161; Why Normalize?

Normalization is a step-by-step process for reorganizing tables so that each one describes exactly one "theme," eliminating the update/insertion/deletion anomalies introduced back in [Module 01](01-01-why-databases.md). Each stage — 1NF, 2NF, 3NF, BCNF — removes a specific kind of dependency problem. You don't need to memorize the formal definitions to *use* normalization; you need to recognize the smell of each anomaly and know which normal form fixes it.

We'll normalize one running example: a badly designed table tracking sailboat charter bookings.

```text
CHARTER_BOOKING (charter_id, customer_id, customer_name, customer_phone,
                 boat_reg_number, boat_name, boat_daily_rate,
                 departure_date, return_date, num_days)
```

Sample data:

| charter_id | customer_id | customer_name | customer_phone | boat_reg_number | boat_name | boat_daily_rate | departure_date | return_date | num_days |
|---|---|---|---|---|---|---|---|---|---|
| 101 | C-01 | Alvarez, Rosa | 555-0110 | WA-4471 | Windrunner | 320.00 | 2026-07-01 | 2026-07-04 | 3 |
| 102 | C-02 | Bloom, Sam | 555-0122 | WA-2200 | Sea Fox | 275.00 | 2026-07-02 | 2026-07-05 | 3 |
| 103 | C-01 | Alvarez, Rosa | 555-0110 | WA-2200 | Sea Fox | 275.00 | 2026-08-10 | 2026-08-12 | 2 |

Spot the anomalies already: Rosa Alvarez's phone number is repeated on every charter she books (**update anomaly** — change it in row 101 but not 103 and the data contradicts itself); we can't record a new customer who hasn't booked yet (**insertion anomaly**); and deleting charter 102 would wipe out every fact we know about the Sea Fox's daily rate along with it if that were the boat's only booking (**deletion anomaly**).

---

## &#128204; First Normal Form (1NF) — No Repeating Groups

A table is in 1NF if every column holds a single, atomic value — no repeating groups, no comma-separated lists stuffed into one cell, no `Boat1`, `Boat2` columns.

Our `CHARTER_BOOKING` table above is *already* in 1NF: every cell holds one value, and there's one row per charter. If it instead had columns like `equipment_item_1`, `equipment_item_2`, `equipment_item_3` to list rented gear, it would violate 1NF — the fix is to move equipment into its own table with one row per item.

---

## &#128204; Second Normal Form (2NF) — No Partial Dependencies

2NF applies only to tables with a **composite primary key**. It requires that every non-key column depend on the *entire* key, not just part of it.

Suppose the real key of `CHARTER_BOOKING` is composite: `(charter_id, boat_reg_number)` — because in this (deliberately flawed) design a "booking" could theoretically list a boat separately per row. `boat_name` and `boat_daily_rate` depend only on `boat_reg_number` (part of the key), not on `charter_id` — that's a **partial dependency**, and it's exactly why the Sea Fox's rate is duplicated on rows 102 and 103.

The fix: split out everything that depends on just `boat_reg_number` into its own `BOAT` table.

```sql
CREATE TABLE boat (
    boat_reg_number CHAR(10) PRIMARY KEY,
    boat_name       VARCHAR(40) NOT NULL,
    boat_daily_rate NUMERIC(9, 2) NOT NULL
);
```

`CHARTER_BOOKING` keeps only `boat_reg_number` as a foreign key, dropping the two columns that depend on it alone.

---

## &#128204; Third Normal Form (3NF) — No Transitive Dependencies

3NF removes **transitive dependencies** — a non-key column that depends on *another non-key column*, rather than on the primary key directly.

In our table, `num_days` is derivable from `departure_date` and `return_date` (a computed/transitive fact, not an independent one), and `customer_name` / `customer_phone` depend on `customer_id`, not on `charter_id`. That second case is the more serious one: it's why Rosa's phone number keeps repeating.

The fix: split `CUSTOMER` into its own table, keyed by `customer_id`.

```sql
CREATE TABLE customer (
    customer_id    CHAR(6) PRIMARY KEY,
    customer_name  VARCHAR(100) NOT NULL,
    customer_phone CHAR(12)
);

CREATE TABLE charter (
    charter_id      SERIAL PRIMARY KEY,
    customer_id     CHAR(6) NOT NULL REFERENCES customer(customer_id),
    boat_reg_number CHAR(10) NOT NULL REFERENCES boat(boat_reg_number),
    departure_date  DATE NOT NULL,
    return_date     DATE NOT NULL
);
```

`num_days` is dropped entirely — it's derived (`return_date - departure_date`), and storing a derivable value is itself a normalization smell: nothing stops it from disagreeing with the dates it's supposedly summarizing.

At this point the schema is in 3NF: `customer` describes only customers, `boat` describes only boats, and `charter` describes only the fact that one customer booked one boat for a date range. Every non-key column depends on the whole key, and nothing but the key.

---

## &#128204; Boyce-Codd Normal Form (BCNF) — Every Determinant Is a Candidate Key

BCNF is a slightly stricter version of 3NF. It's needed when a table has **multiple candidate keys that overlap**, and a non-key attribute determines part of the key.

Classic example: suppose each boat can only be captained by one qualified skipper *per boat type* (a business rule), tracked in a table:

```text
BOAT_SKIPPER (boat_reg_number, boat_type, skipper_name)
```

Here `boat_type` determines `skipper_name` (every boat of the same type uses the same assigned skipper), but `boat_type` alone isn't a candidate key — `(boat_reg_number)` is. This is a determinant (`boat_type`) that isn't a candidate key, violating BCNF even though the table is already in 3NF. The fix is the same technique as before: split the `boat_type -> skipper_name` fact into its own table.

```sql
CREATE TABLE boat_type_skipper (
    boat_type    VARCHAR(20) PRIMARY KEY,
    skipper_name VARCHAR(100) NOT NULL
);
```

> [!NOTE]
> In practice, most schemas that reach 3NF are already in BCNF — violations of BCNF-but-not-3NF are rare and usually involve overlapping composite candidate keys. Don't lose sleep memorizing the distinction; focus on 1NF → 2NF → 3NF, which handles the overwhelming majority of real design work.

---

## &#128204; Denormalization — Breaking the Rules on Purpose

Normalization isn't free. Every split adds a `JOIN` that a query must perform, and more tables mean more moving parts to keep straight. **Denormalization** is the deliberate choice to merge tables back together (or duplicate a column) to trade some anomaly risk for read performance.

Common, defensible reasons to denormalize:

- A **reporting/analytics table** that's rebuilt nightly from the normalized source — anomalies don't matter because it's never manually edited, only regenerated.
- A **read-heavy dashboard** where a `JOIN` across five tables runs on every page load; storing a redundant `customer_name` directly on `charter` avoids that join at the cost of an update needing to touch two tables instead of one.
- **Data warehouses** (see [Module 07](07-01-data-warehouses-and-marts.md)), which favor wide, denormalized star schemas specifically because analytical queries read far more than they write.

The rule of thumb: normalize your transactional (write-heavy, "system of record") tables fully, and denormalize only in a copy built for reads — never let the anomaly-prone copy become the only copy of the truth.

> [!TIP]
> Normalize until it hurts (queries get too joined-up and slow), then denormalize until it works — but only in a table you're not treating as the authoritative source of truth.

---

See also: [Transforming E-R Models into Tables](05-01-transforming-er-to-tables.md), [Joins over Recursive Relationships](05-04-joins-over-recursive-relationships.md)

<!-- course-footer -->
---

<div align="center" markdown>

[All Notes](README.md) &nbsp;|&nbsp; [Module 05 Exercise](../02-exercises/05-exercise.md) &nbsp;|&nbsp; <strong>Next:</strong> [Joins over Recursive Relationships](05-04-joins-over-recursive-relationships.md)

</div>
<!-- /course-footer -->
