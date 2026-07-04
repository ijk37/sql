# &#128216; 03-03: SELECT — Filtering & Sorting

<!-- course-header -->
<div align="center" markdown>

![SQL & Databases](../assets/banner.svg)

<img src="https://img.shields.io/badge/Module_03-SQL_Fundamentals-336791?style=for-the-badge&labelColor=24506B" alt="Module 03: SQL Fundamentals">

[![Home](https://img.shields.io/badge/⌂_Home-1B2A35?style=flat-square)](../index.md) [![All Notes](https://img.shields.io/badge/All_Notes-1B2A35?style=flat-square)](README.md) [![Practice](https://img.shields.io/badge/✎_Practice-C6821E?style=flat-square&labelColor=24506B)](../02-exercises/03-exercise.md) [![Quiz](https://img.shields.io/badge/▶_Quiz-C6821E?style=flat-square&labelColor=24506B)](../03-quiz/)

</div>
<!-- /course-header -->

## &#128161; The Query Framework

Every single-table query is built from three clauses, always in this order:

```sql
SELECT   <columns to display>
FROM     <table to read from>
WHERE    <rows to include>
```

- **SELECT** — which *columns* to list in the output
- **FROM** — which *table* to read
- **WHERE** — which *rows* qualify

We'll query the Wedgewood Pacific `employee` and `project` tables throughout.

---

## &#128204; Choosing Columns

```sql
-- All columns
SELECT * FROM employee;

-- Specific columns, in the order you want them displayed
SELECT last_name, first_name, department_name FROM employee;
```

The column order in `SELECT` controls the output order — it has nothing to do with the table's physical column order.

### DISTINCT — Remove Duplicate Rows

```sql
SELECT DISTINCT department_name FROM employee;
```

Without `DISTINCT`, this would list `department_name` once per employee (repeats included). With it, each department name appears exactly once.

---

## &#128204; WHERE — Filtering Rows

### Comparison Operators

| Operator | Meaning |
|---|---|
| `=` | Equal to |
| `<>` or `!=` | Not equal to |
| `<`, `>`, `<=`, `>=` | Less than, greater than, and inclusive variants |
| `IN (...)` | Equal to one of a list of values |
| `NOT IN (...)` | Not equal to any value in a list |
| `BETWEEN a AND b` | Within a range, inclusive of both endpoints |
| `LIKE` / `NOT LIKE` | Pattern match on text |
| `IS NULL` / `IS NOT NULL` | Test for missing values |

```sql
SELECT * FROM project WHERE department_name = 'Finance';

SELECT * FROM project WHERE max_hours > 130;

SELECT * FROM project WHERE department_name IN ('Finance', 'Accounting');

SELECT * FROM project WHERE start_date BETWEEN '2019-05-01' AND '2019-08-01';
```

> [!NOTE]
> Text and date literals must be wrapped in **single quotes**, typed exactly as stored. `WHERE department_name = 'finance'` (lowercase) will match nothing if the stored value is `'Finance'` — PostgreSQL string comparisons are case-sensitive by default. Dates should use the unambiguous ISO format `'YYYY-MM-DD'` to avoid the classic `mm/dd/yyyy` vs `dd/mm/yyyy` confusion.

### Logical Operators — Combining Conditions

| Operator | Meaning |
|---|---|
| `AND` | Both conditions must be true |
| `OR` | At least one condition must be true |
| `NOT` | Negates the condition that follows |

```sql
SELECT * FROM employee
WHERE department_name = 'Production' AND position LIKE 'OPS%';

SELECT * FROM project
WHERE department_name = 'Finance' OR department_name = 'Accounting';

SELECT * FROM employee
WHERE NOT department_name = 'Production';
```

### Pattern Matching — LIKE

`LIKE` supports two wildcards:

- `%` — any sequence of zero or more characters
- `_` — exactly one character

```sql
-- Names starting with "J"
SELECT * FROM employee WHERE first_name LIKE 'J%';

-- Emails ending in @WP.com
SELECT * FROM employee WHERE email_address LIKE '%@WP.com';

-- Exactly 4-character position codes (e.g. "OPS1", "OPS2")
SELECT * FROM employee WHERE position LIKE 'OPS_';
```

> [!NOTE]
> **`LIKE` is case-sensitive in PostgreSQL; MySQL and SQL Server default to case-insensitive collations.** Postgres adds a case-insensitive variant, `ILIKE`, that MySQL and SQL Server don't have:
>
> ```sql
> SELECT * FROM employee WHERE first_name ILIKE 'j%';  -- matches 'James', 'Jason', 'james', etc.
> ```
>
> On MySQL/SQL Server with default (case-insensitive) collations, plain `LIKE` already behaves like `ILIKE`. Don't assume portability here — test the target database's collation before relying on case behavior.

### NULL Handling

`NULL` means "no value recorded" — it is not zero, not an empty string, and it never equals anything, including another `NULL`. You cannot test for it with `=`:

```sql
-- WRONG — this never matches, even for NULL rows
SELECT * FROM employee WHERE office_phone = NULL;

-- RIGHT
SELECT * FROM employee WHERE office_phone IS NULL;
SELECT * FROM employee WHERE office_phone IS NOT NULL;
```

`COALESCE` returns the first non-`NULL` argument — handy for supplying a fallback display value:

```sql
SELECT first_name, last_name, COALESCE(office_phone, 'No phone on file') AS phone_display
FROM employee;
```

---

## &#128204; ORDER BY — Sorting Results

```sql
-- Ascending by default
SELECT last_name, first_name FROM employee ORDER BY last_name;

-- Explicit descending
SELECT project_name, max_hours FROM project ORDER BY max_hours DESC;

-- Sort by multiple columns — department first, then last name within department
SELECT department_name, last_name, first_name
FROM employee
ORDER BY department_name, last_name;
```

Sorting by multiple columns works like sorting a phone book by last name, then first name for ties: the second column only breaks ties left by the first.

---

## &#128204; LIMIT and OFFSET — Paging Results

```sql
-- Only the first 5 rows
SELECT * FROM employee ORDER BY last_name LIMIT 5;

-- Skip the first 5, then take the next 5 (page 2 of a 5-per-page list)
SELECT * FROM employee ORDER BY last_name LIMIT 5 OFFSET 5;
```

> [!NOTE]
> **`LIMIT`/`OFFSET` is PostgreSQL and MySQL syntax; SQL Server historically used `TOP`.**
>
> | Database | "First 5 rows" | "Rows 6–10 (page 2)" |
> |---|---|---|
> | PostgreSQL | `SELECT * FROM t ORDER BY x LIMIT 5;` | `... LIMIT 5 OFFSET 5;` |
> | MySQL | `SELECT * FROM t ORDER BY x LIMIT 5;` | `... LIMIT 5 OFFSET 5;` (identical to Postgres) |
> | SQL Server | `SELECT TOP 5 * FROM t ORDER BY x;` | `... ORDER BY x OFFSET 5 ROWS FETCH NEXT 5 ROWS ONLY;` |
>
> SQL Server added standard `OFFSET ... FETCH NEXT ... ROWS ONLY` starting in SQL Server 2012, which is closer to the `LIMIT/OFFSET` idiom — but `TOP N` (with no offset support on its own) remains common in older code and simple "top N rows" queries.

---

## &#128204; Putting It Together

```sql
SELECT first_name, last_name, position
FROM employee
WHERE department_name = 'Production' AND position <> 'OPS1'
ORDER BY last_name
LIMIT 10;
```

Read it in framework order: pick the columns, name the table, filter the rows, then sort and page the result — `WHERE` always runs before `ORDER BY`, and `ORDER BY`/`LIMIT` are applied last, after filtering has already narrowed the row set.

---

See also: [DML: Insert, Update, Delete](03-02-dml-insert-update-delete.md), [Joins](03-04-joins.md)

<!-- course-footer -->
---

<div align="center" markdown>

[All Notes](README.md) &nbsp;|&nbsp; [Module 03 Exercise](../02-exercises/03-exercise.md) &nbsp;|&nbsp; <strong>Next:</strong> [Joins](03-04-joins.md)

</div>
<!-- /course-footer -->
