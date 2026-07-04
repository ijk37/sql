# &#9997; 05: Database Design & Normalization — Exercises

<!-- course-header -->
<div align="center" markdown>

![SQL & Databases](../assets/banner.svg)

<img src="https://img.shields.io/badge/Module_05-DB_Design_Normalization-336791?style=for-the-badge&labelColor=24506B" alt="Module 05: Database Design & Normalization"> <img src="https://img.shields.io/badge/11_questions-C6821E?style=for-the-badge&labelColor=24506B" alt="11 questions">

[![Home](https://img.shields.io/badge/⌂_Home-1B2A35?style=flat-square)](../index.md) [![Notes](https://img.shields.io/badge/Notes-1B2A35?style=flat-square)](../01-notes/05-01-transforming-er-to-tables.md) [![All Exercises](https://img.shields.io/badge/All_Exercises-1B2A35?style=flat-square)](README.md) [![Quiz](https://img.shields.io/badge/▶_Quiz-C6821E?style=flat-square&labelColor=24506B)](../03-quiz/)

</div>
<!-- /course-header -->

> [!TIP]
> **Practice —** try each question first, then expand the answer to check your reasoning.

Work through each question, then click **Show answer** to check yourself. Review the [notes](../01-notes/05-01-transforming-er-to-tables.md) if you get stuck.

---

### &#128313; Q1. A `PROJECT` entity has a 1:N relationship with `ASSIGNMENT` conceptually, but `PROJECT` and `EMPLOYEE` are really related N:M through hours worked. How should this be represented in the relational model?

<details>
<summary><strong>Show answer</strong></summary>

Create an **intersection table** (e.g., `ASSIGNMENT`) whose primary key is the composite of both parent keys: `(project_id, employee_number)`. Store `hours_worked` — an attribute of the relationship itself — in that intersection table, not in either `PROJECT` or `EMPLOYEE`.
</details>

---

### &#10067; Q2. A `DEPARTMENT` has many `EMPLOYEE`s. Which table gets the foreign key, and why can't it go the other way?

<details>
<summary><strong>Show answer</strong></summary>

The foreign key (`department_id`) goes in `EMPLOYEE` — the "many" side. It can't go in `DEPARTMENT` because a single column in one department row can only hold one value, but a department needs to reference *many* employees; only the "many" side can hold a single reference back to its "one" parent.
</details>

---

### &#128313; Q3. What makes an entity a "weak, ID-dependent" entity, and how does that change its primary key?

<details>
<summary><strong>Show answer</strong></summary>

A weak, ID-dependent entity cannot be uniquely identified without its parent — it has no independent existence. Its primary key must include the parent's primary key as a foreign key, combined with a discriminator that's only unique *within* that parent (e.g., `LOG(charter_id, entry_number)` — `entry_number` restarts at 1 for every charter).
</details>

---

### &#127919; Q4. Write the `CREATE TABLE` statement for a 1:1 relationship between `CUSTOMER` and `CONTACT`, where every customer has at most one contact record. What constraint (beyond the foreign key itself) is required to enforce "at most one"?

<details>
<summary><strong>Show answer</strong></summary>

```sql
CREATE TABLE customer (
    customer_id   SERIAL PRIMARY KEY,
    customer_name VARCHAR(100) NOT NULL
);

CREATE TABLE contact (
    contact_id   SERIAL PRIMARY KEY,
    customer_id  INTEGER NOT NULL UNIQUE
        REFERENCES customer(customer_id),
    contact_name VARCHAR(100) NOT NULL
);
```

The `UNIQUE` constraint on `customer_id` in `contact` is required — without it, a plain foreign key alone permits many `contact` rows per customer, which would silently make the relationship 1:N instead of 1:1.
</details>

---

### &#10067; Q5. Look at this table. What normal-form violation does it show, and how would you fix it?

| order_id | customer_name | item1 | item2 | item3 |
|---|---|---|---|---|
| 5001 | Alvarez, Rosa | Anchor | Life jacket | |
| 5002 | Bloom, Sam | Rope | | |

<details>
<summary><strong>Show answer</strong></summary>

This violates **1NF** — `item1`/`item2`/`item3` are a repeating group crammed into extra columns instead of separate rows. Fix: create an `ORDER_ITEM` table with one row per item, keyed by `(order_id, item_number)` or a surrogate key plus a foreign key back to `order_id`. This also removes the wasted empty cells and the hard cap on how many items an order can have.
</details>

---

### &#128313; Q6. A table `SHIPMENT(shipment_id, boat_reg_number, boat_name, boat_daily_rate, ship_date)` uses a composite key `(shipment_id, boat_reg_number)`. `boat_name` and `boat_daily_rate` depend only on `boat_reg_number`. What normalization problem is this, and which normal form fixes it?

<details>
<summary><strong>Show answer</strong></summary>

This is a **partial dependency** — a **2NF violation**. `boat_name` and `boat_daily_rate` depend on only part of the composite key (`boat_reg_number`), not the whole key. Fix: move `boat_name` and `boat_daily_rate` into their own `BOAT` table keyed by `boat_reg_number`, leaving only `boat_reg_number` as a foreign key in `SHIPMENT`.
</details>

---

### &#10067; Q7. A table `CHARTER(charter_id, customer_id, customer_name, customer_phone, departure_date)` has `customer_name` and `customer_phone` depending on `customer_id`, not on `charter_id` (the primary key). What's this called, and how do you fix it?

<details>
<summary><strong>Show answer</strong></summary>

This is a **transitive dependency** — a **3NF violation**: a non-key column (`customer_name`) depends on another non-key column (`customer_id`) rather than directly on the primary key. Fix: move `customer_name` and `customer_phone` into their own `CUSTOMER` table keyed by `customer_id`, leaving `customer_id` as a foreign key in `CHARTER`.
</details>

---

### &#128313; Q8. Give one legitimate business reason to denormalize a table on purpose, and explain the trade-off being made.

<details>
<summary><strong>Show answer</strong></summary>

Example: a read-heavy dashboard duplicates `customer_name` directly onto the `charter` table to avoid a `JOIN` to `customer` on every page load. Trade-off: faster reads, at the cost of `customer_name` now living in two places — an `UPDATE` must touch both, and if one is missed the data disagrees with itself (the exact anomaly normalization exists to prevent). This is only acceptable when the denormalized copy is not the sole system of record, or is rebuilt/refreshed automatically.
</details>

---

### &#127919; Q9. Write `CREATE TABLE` statements for `EMPLOYEE` with a recursive 1:N "supervises" relationship (an employee has at most one supervisor, who is also an employee).

<details>
<summary><strong>Show answer</strong></summary>

```sql
CREATE TABLE employee (
    employee_number INTEGER PRIMARY KEY,
    first_name      VARCHAR(25) NOT NULL,
    last_name       VARCHAR(25) NOT NULL,
    supervisor_id   INTEGER REFERENCES employee(employee_number)
);
```

`supervisor_id` references the table's own primary key — this is what makes it recursive/unary rather than a relationship between two different entities.
</details>

---

### &#10067; Q10. Write a self-join query that lists every employee's first/last name next to their supervisor's first/last name. Why must you use a `LEFT JOIN` instead of an inner join?

<details>
<summary><strong>Show answer</strong></summary>

```sql
SELECT e.first_name AS emp_first, e.last_name AS emp_last,
       s.first_name AS sup_first, s.last_name AS sup_last
FROM employee AS e
LEFT JOIN employee AS s
    ON e.supervisor_id = s.employee_number;
```

A `LEFT JOIN` is required because the top-level employee (e.g., the president) has `supervisor_id IS NULL`. An inner join would have nothing to match on the right side and would silently drop that employee from the results entirely.
</details>

---

### &#128313; Q11. What does `WITH RECURSIVE` let you do that a fixed chain of self-joins can't?

<details>
<summary><strong>Show answer</strong></summary>

A self-join walks exactly one level of the hierarchy per join, so you'd need to know in advance how many levels deep to go (and write that many joins). `WITH RECURSIVE` repeatedly applies the same join step until no new rows are produced (e.g., until it reaches an employee with `supervisor_id IS NULL`), so it correctly walks a chain of *any* depth without the query needing to know the depth ahead of time.
</details>

---

[All Exercises](README.md) &nbsp;|&nbsp; **Next:** [06: Database Administration — Exercises](06-exercise.md)

<!-- course-footer -->
---

<div align="center" markdown>

[All Exercises](README.md) &nbsp;|&nbsp; [Module 05 Notes](../01-notes/05-01-transforming-er-to-tables.md) &nbsp;|&nbsp; <strong>Next:</strong> [06: Database Administration — Exercises](06-exercise.md)

</div>
<!-- /course-footer -->
