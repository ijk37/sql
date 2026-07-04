# &#128216; 03-02: DML — Insert, Update, Delete

<!-- course-header -->
<div align="center" markdown>

![SQL & Databases](../assets/banner.svg)

<img src="https://img.shields.io/badge/Module_03-SQL_Fundamentals-336791?style=for-the-badge&labelColor=24506B" alt="Module 03: SQL Fundamentals">

[![Home](https://img.shields.io/badge/⌂_Home-1B2A35?style=flat-square)](../index.md) [![All Notes](https://img.shields.io/badge/All_Notes-1B2A35?style=flat-square)](README.md) [![Practice](https://img.shields.io/badge/✎_Practice-C6821E?style=flat-square&labelColor=24506B)](../02-exercises/03-exercise.md) [![Quiz](https://img.shields.io/badge/▶_Quiz-C6821E?style=flat-square&labelColor=24506B)](../03-quiz/)

</div>
<!-- /course-header -->

## &#128161; Three Ways to Change Data

Once tables exist (see [DDL](03-01-ddl-tables-and-datatypes.md)), DML gives you three operations to change what's in them:

| Statement | Effect |
|---|---|
| `INSERT` | Adds new row(s) |
| `UPDATE` | Modifies existing row(s) |
| `DELETE` | Removes existing row(s) |

We'll use the Wedgewood Pacific `employee` and `assignment` tables from the previous note.

---

## &#128204; INSERT

```sql
INSERT INTO employee (first_name, last_name, department_name, position, supervisor, email_address)
VALUES ('Mary', 'Jacobs', 'Administration', 'CEO', NULL, 'Mary.Jacobs@WP.com');

INSERT INTO employee (first_name, last_name, department_name, position, supervisor, email_address)
VALUES ('Rosalie', 'Jackson', 'Administration', 'Admin Assistant', 1, 'Rosalie.Jackson@WP.com');
```

The column list after the table name tells SQL which columns you're supplying values for, and in what order — the order of columns in the `INSERT` doesn't have to match the table's physical column order, as long as it matches the order of the values you provide.

```sql
-- Column order doesn't matter, as long as VALUES matches it
INSERT INTO employee (email_address, last_name, first_name, department_name)
VALUES ('Ken.Evans@WP.com', 'Evans', 'Ken', 'Finance');
```

You can omit the column list entirely, but then you must supply a value (or `DEFAULT`) for *every* column in table order — fragile if the schema changes later, so naming columns explicitly is the safer habit.

**Multi-row insert** — one statement, several rows:

```sql
INSERT INTO assignment (project_id, employee_number, hours_worked) VALUES
    (1000, 1,  30.00),
    (1000, 6,  50.00),
    (1000, 10, 50.00),
    (1000, 16, 75.00);
```

---

## &#128204; UPDATE

`UPDATE` always needs a `WHERE` clause unless you genuinely intend to change every row in the table:

```sql
-- Give everyone in Sales and Marketing a title bump
UPDATE employee
SET position = 'Senior ' || position
WHERE department_name = 'Sales and Marketing';

-- Reassign an employee to a new supervisor
UPDATE employee
SET supervisor = 12
WHERE employee_number = 13;

-- Update multiple columns at once
UPDATE assignment
SET hours_worked = 80.00
WHERE project_id = 1000 AND employee_number = 17;
```

> [!TIP]
> Before running an `UPDATE` (or `DELETE`) against real data, run the same `WHERE` clause as a `SELECT` first: `SELECT * FROM employee WHERE department_name = 'Sales and Marketing';`. If that returns the rows you expect, the `UPDATE`/`DELETE` will touch exactly those rows and no others.

---

## &#128204; DELETE

```sql
-- Remove one specific assignment
DELETE FROM assignment
WHERE project_id = 1600 AND employee_number = 7;

-- Remove every assignment for a finished project
DELETE FROM assignment
WHERE project_id = 1000;
```

> [!NOTE]
> `DELETE FROM assignment;` with **no `WHERE` clause** deletes every row in the table — a fully valid, syntactically correct statement that has ended more than one career-defining incident. Postgres will not ask you to confirm. Always check your `WHERE` clause with a `SELECT` first.

---

## &#128204; UPSERT — Insert, or Update if It Already Exists

A common need: "insert this row, but if a row with this key already exists, update it instead." Every major database has its own syntax for this — full mastery of `MERGE` is Module 08 material, but here's the shape of each so you recognize it:

**PostgreSQL — `INSERT ... ON CONFLICT`:**

```sql
INSERT INTO assignment (project_id, employee_number, hours_worked)
VALUES (1000, 1, 35.00)
ON CONFLICT (project_id, employee_number)
DO UPDATE SET hours_worked = EXCLUDED.hours_worked;
```

`EXCLUDED` refers to the row that *would* have been inserted — here, it means "overwrite `hours_worked` with the new value I tried to insert."

> [!NOTE]
> **Same idea, different syntax across databases.**
>
> | Database | Upsert syntax |
> |---|---|
> | PostgreSQL | `INSERT ... ON CONFLICT (key) DO UPDATE SET ...` |
> | MySQL | `INSERT ... ON DUPLICATE KEY UPDATE ...` |
> | SQL Server | `MERGE INTO target USING source ON ... WHEN MATCHED THEN UPDATE ... WHEN NOT MATCHED THEN INSERT ...` |
> | SQLite | `INSERT ... ON CONFLICT (key) DO UPDATE SET ...` (same as Postgres) |
>
> SQL Server's `MERGE` is the most general of these — it can also handle `WHEN NOT MATCHED BY SOURCE THEN DELETE` in one statement. Postgres and MySQL support a `MERGE` statement too as of recent versions, but the `ON CONFLICT` / `ON DUPLICATE KEY` shorthand remains the idiomatic choice for simple upserts. We'll write full `MERGE` statements in [Module 08](08-01-alter-merge-and-views.md).

---

## &#128204; RETURNING — See What You Just Changed

PostgreSQL lets any DML statement report back the rows it affected, without a separate `SELECT`:

```sql
INSERT INTO employee (first_name, last_name, department_name, email_address)
VALUES ('Grace', 'Lin', 'InfoSystems', 'Grace.Lin@WP.com')
RETURNING employee_number;

UPDATE assignment
SET hours_worked = hours_worked + 5
WHERE project_id = 1100 AND employee_number = 1
RETURNING *;
```

`RETURNING` is especially handy for grabbing a newly generated `SERIAL` primary key immediately after an `INSERT`, without a round trip to look it up.

---

See also: [DDL: Tables & Data Types](03-01-ddl-tables-and-datatypes.md), [SELECT: Filtering & Sorting](03-03-select-filtering-sorting.md)

<!-- course-footer -->
---

<div align="center" markdown>

[All Notes](README.md) &nbsp;|&nbsp; [Module 03 Exercise](../02-exercises/03-exercise.md) &nbsp;|&nbsp; <strong>Next:</strong> [SELECT: Filtering & Sorting](03-03-select-filtering-sorting.md)

</div>
<!-- /course-footer -->
