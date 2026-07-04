# &#128736; Project 02 — Relational Schema &amp; Keys

<!-- course-header -->
<div align="center" markdown>

![SQL & Databases](../../assets/banner.svg)

[![View the live site — ijk37.com](https://img.shields.io/badge/%F0%9F%87%A7%F0%9F%87%A9_View_the_Live_Site-IJK37.COM-F42A41?style=for-the-badge&labelColor=006A4E)](https://ijk37.com/sql/)

<img src="https://img.shields.io/badge/Project_02-Relational_Schema_%26_Keys-336791?style=for-the-badge&labelColor=24506B" alt="Project 02: Relational Schema and Keys">

[![Home](https://img.shields.io/badge/⌂_Home-1B2A35?style=flat-square)](../../index.md) [![All Projects](https://img.shields.io/badge/All_Projects-1B2A35?style=flat-square)](../README.md) [![Notes](https://img.shields.io/badge/Notes-1B2A35?style=flat-square)](../../01-notes/02-01-relations-and-terminology.md) [![Quiz](https://img.shields.io/badge/▶_Quiz-C6821E?style=flat-square&labelColor=24506B)](../../03-quiz/)

</div>
<!-- /course-header -->

**Type:** Design document + PostgreSQL DDL
**Modules:** 02 (The Relational Model)
**Difficulty:** ⭐⭐⭐

---

## &#127919; Objective

Take a small, denormalized, spreadsheet-style dataset and design a proper set of relational tables from it — correctly identifying **candidate keys, primary keys, composite keys, surrogate keys, and foreign keys** for each table, then writing the PostgreSQL `CREATE TABLE` statements that enforce them.

---

## &#129517; Scenario: James River Jewelry

**James River Jewelry** is a small retailer that has been tracking customers, purchases, and loyalty credits in a single combined spreadsheet:

| Customer Name | Phone | Email | Join Date | Loyalty Level | Purchase Date | Item Description | Category | Amount ($) |
|---|---|---|---|---|---|---|---|---|
| Sarah Lee | 555-123-4567 | sarah.lee@email.com | 2025-01-12 | Gold | 2026-06-15 | Gold Ring | Jewelry | 450 |
| Sarah Lee | 555-123-4567 | sarah.lee@email.com | 2025-01-12 | Gold | 2026-06-20 | Jade Necklace | Asian Art | 720 |
| Sarah Lee | 555-123-4567 | sarah.lee@email.com | 2025-01-12 | Gold | 2026-07-12 | Diamond Pendant | Jewelry | 950 |
| David Kim | 555-234-5678 | david.kim@email.com | 2024-11-03 | Silver | 2026-06-25 | Silver Earrings | Jewelry | 120 |
| David Kim | 555-234-5678 | david.kim@email.com | 2024-11-03 | Silver | 2026-07-18 | Jade Pendant | Asian Art | 300 |
| Emma Chen | 555-345-6789 | emma.chen@email.com | 2025-05-18 | Bronze | 2026-07-02 | Handcrafted Bracelet | Asian Art | 250 |
| Emma Chen | 555-345-6789 | emma.chen@email.com | 2025-05-18 | Bronze | 2026-07-20 | Silver Chain | Jewelry | 180 |

The shop also occasionally issues a **loyalty credit** once a customer's purchases cross a spending threshold — recorded, so far, in a *second*, separate spreadsheet that repeats the customer's name, phone, and email a third time:

| Customer Name | Phone | Email | Credit Date | Total of Last 10 Purchases ($) | Credit Amount ($) | Purchase Applied To |
|---|---|---|---|---|---|---|
| Sarah Lee | 555-123-4567 | sarah.lee@email.com | 2026-07-13 | 5,200 | 260 | Diamond Pendant |
| David Kim | 555-234-5678 | david.kim@email.com | 2026-07-19 | 2,400 | 120 | Jade Pendant |

The owner wants a real relational schema before this grows any further — new purchases keep re-typing the same customer details, and there's no clean way to add a customer who hasn't bought anything yet.

---

## &#128204; Requirements

1. Design at least three tables: one for customers, one for purchases, and one for credits — each holding exactly one theme (see [Why Databases?](../../01-notes/01-01-why-databases.md)).
2. Every table must have a properly chosen **primary key** — state whether it's natural or surrogate, and why.
3. Every relationship between tables must be represented with a correctly declared **foreign key**.
4. Identify at least one **candidate key** that was *not* chosen as the primary key, and explain why you passed over it.
5. Write real, runnable PostgreSQL `CREATE TABLE` statements enforcing every primary key and foreign key you designed.

---

## &#129513; Tasks

### &#128313; Part A — Identify Themes and Candidate Keys

1. List the distinct themes in the combined data (customer info, purchase info, credit info).
2. For the customer theme, identify at least two columns that could each serve as a candidate key on their own (hint: look at `Email` vs. a to-be-created ID column).
3. Decide which candidate key you'll promote to primary key for each table, and whether it's a **natural key** (real-world data) or a **surrogate key** (artificial, DBMS-assigned).

### &#128313; Part B — Design the Tables

1. Sketch each table's column list, marking the primary key and any foreign keys.
2. For the `PURCHASE` table, decide how it relates back to `CUSTOMER` — what foreign key does it need?
3. For the `CREDIT` table, decide how it relates to *both* `CUSTOMER` and a specific `PURCHASE` row (the "Purchase Applied To" column) — this needs two foreign keys pointing at two different tables.
4. Double check: does every non-key column in each table actually describe *that table's* theme, and not some other table's? (This is the same instinct you built in [Functional Dependencies](../../01-notes/02-04-functional-dependencies.md).)

### &#128313; Part C — Write the DDL

Write PostgreSQL `CREATE TABLE` statements for your full design. A partial starting skeleton:

```sql
CREATE TABLE customer (
    customer_id    SERIAL PRIMARY KEY,
    first_name     VARCHAR(50) NOT NULL,
    last_name      VARCHAR(50) NOT NULL,
    phone          VARCHAR(20),
    email          VARCHAR(100) UNIQUE,
    join_date      DATE,
    loyalty_level  VARCHAR(20)
);

CREATE TABLE purchase (
    purchase_id       SERIAL PRIMARY KEY,
    customer_id       INT NOT NULL REFERENCES customer(customer_id),
    purchase_date     DATE NOT NULL,
    item_description  VARCHAR(100),
    category          VARCHAR(50),
    amount            NUMERIC(10, 2)
);

-- You design CREDIT — it needs a foreign key to CUSTOMER,
-- and a foreign key to the specific PURCHASE the credit was applied to.
```

Finish the `CREDIT` table yourself, including both foreign keys, and add a `UNIQUE` or `CHECK` constraint anywhere you think the data should be restricted (e.g., `amount > 0`).

---

## &#9989; Verification Checklist

- [ ] Three or more tables, each representing exactly one theme.
- [ ] Every table has a clearly chosen primary key, labeled natural or surrogate.
- [ ] At least one alternate/candidate key identified and explained.
- [ ] Every foreign key uses `REFERENCES` and points at the correct parent table's primary key.
- [ ] `CREDIT` correctly references both `CUSTOMER` and `PURCHASE`.
- [ ] Running your DDL in a PostgreSQL instance (e.g., a free [Neon](https://neon.tech) or local `psql`) creates all tables with no errors.
- [ ] Inserting a new customer with zero purchases succeeds (proving the insertion anomaly from the original spreadsheet is gone).

---

## &#128230; Deliverables

- A `schema.sql` file containing all `CREATE TABLE` statements.
- A short write-up (5–8 sentences) explaining your primary key choices and identifying which anomaly (update/insertion/deletion) from the original spreadsheet each table split resolves.
- A one-paragraph explanation of the two foreign keys in `CREDIT` and what relationship each represents.

---

## &#128640; Stretch Goals

- Add a `CHECK` constraint ensuring `credit_amount` never exceeds some reasonable percentage of `total_of_last_10_purchases`.
- Write a single `INSERT` script that populates all your tables with the sample data above, respecting foreign key order (parents before children).
- Identify a partial or transitive dependency you would introduce if you added a `CustomerLoyaltyDiscountPercent` column directly to `PURCHASE` instead of keeping it on `CUSTOMER` — explain why it belongs where you originally put it.

See also notes: [Keys](../../01-notes/02-03-keys.md), [Functional Dependencies](../../01-notes/02-04-functional-dependencies.md)

<!-- course-footer -->
---

<div align="center" markdown>

[All Projects](../README.md) &nbsp;|&nbsp; [Module 02 Notes](../../01-notes/02-01-relations-and-terminology.md) &nbsp;|&nbsp; <strong>Next:</strong> [Project 03 — SQL Querying &amp; Joins](../03-sql-querying-and-joins/README.md)

</div>
<!-- /course-footer -->
