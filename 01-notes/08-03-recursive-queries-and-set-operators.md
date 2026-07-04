# &#128216; 08-03: Recursive Queries & Set Operators

<!-- course-header -->
<div align="center" markdown>

![SQL & Databases](../assets/banner.svg)

<img src="https://img.shields.io/badge/Module_08-Advanced_SQL-336791?style=for-the-badge&labelColor=24506B" alt="Module 08: Advanced SQL">

[![Home](https://img.shields.io/badge/⌂_Home-1B2A35?style=flat-square)](../index.md) [![All Notes](https://img.shields.io/badge/All_Notes-1B2A35?style=flat-square)](README.md) [![Practice](https://img.shields.io/badge/✎_Practice-C6821E?style=flat-square&labelColor=24506B)](../02-exercises/08-exercise.md) [![Quiz](https://img.shields.io/badge/▶_Quiz-C6821E?style=flat-square&labelColor=24506B)](../03-quiz/)

</div>
<!-- /course-header -->

## &#128161; Finishing What Module 05 Started

[05-04](05-04-joins-over-recursive-relationships.md) ended with a teaser: a `WITH RECURSIVE` query that walked one employee up their management chain. This note gives recursive CTEs full treatment — walking both up and down a hierarchy, with a guard against infinite loops — and then covers SQL's **set operators**, which combine the *results* of separate queries the way `JOIN` combines columns from separate tables.

---

## &#128204; `WITH RECURSIVE`, Fully Worked

Every recursive CTE has the same two-part shape:

```sql
WITH RECURSIVE cte_name AS (
    -- 1. Anchor member: the non-recursive starting point
    SELECT ...

    UNION ALL

    -- 2. Recursive member: references cte_name itself
    SELECT ...
    FROM   some_table
    JOIN   cte_name ON <link the recursive step back to the anchor's growing result>
)
SELECT * FROM cte_name;
```

The engine runs the anchor once, then repeatedly re-runs the recursive member — feeding it the rows produced in the *previous* iteration — until an iteration produces zero new rows, at which point it stops.

### Walking down: everyone who reports to a given manager

The 05-04 teaser walked *up* the chain (an employee's chain of supervisors). Walking *down* — every employee who reports to a given manager, directly or indirectly — uses the same shape with the join direction reversed:

```sql
WITH RECURSIVE org_chart AS (
    -- anchor: start at the top manager
    SELECT employee_number, first_name, last_name, supervisor_id, 1 AS level
    FROM   employee
    WHERE  employee_number = 100   -- e.g., the VP of Engineering

    UNION ALL

    -- recursive step: find everyone whose supervisor is already in org_chart
    SELECT e.employee_number, e.first_name, e.last_name, e.supervisor_id,
           oc.level + 1
    FROM   employee AS e
    JOIN   org_chart AS oc ON e.supervisor_id = oc.employee_number
)
SELECT * FROM org_chart ORDER BY level, last_name;
```

Each pass finds employees whose supervisor was added in the *previous* pass, so `level` grows by one with each layer of the org chart, and the recursion naturally terminates once a pass finds nobody new.

### Guarding against infinite loops

A recursive CTE with a genuine cycle in the data (a data-entry error where employee A supervises B, and B ends up listed as A's supervisor) will loop forever unless you cap it. Add an explicit depth guard in the recursive member:

```sql
WITH RECURSIVE org_chart AS (
    SELECT employee_number, first_name, last_name, supervisor_id, 1 AS level
    FROM   employee
    WHERE  employee_number = 100

    UNION ALL

    SELECT e.employee_number, e.first_name, e.last_name, e.supervisor_id,
           oc.level + 1
    FROM   employee AS e
    JOIN   org_chart AS oc ON e.supervisor_id = oc.employee_number
    WHERE  oc.level < 20   -- hard stop: no org chart is 20 levels deep
)
SELECT * FROM org_chart ORDER BY level, last_name;
```

> [!TIP]
> PostgreSQL also lets you cap total *iterations* with `SET recursion_limit` behavior indirectly via a `WHERE` guard like above — there is no separate "max recursion" session setting in Postgres (unlike SQL Server's `OPTION (MAXRECURSION n)`). Always design the depth/cycle guard into the query itself, don't rely on the engine to catch it for you.

A bill-of-materials hierarchy (a `PART` that contains sub-`PART`s, which contain further sub-parts) is the other classic recursive-CTE use case — structurally identical to the org chart, just walking a parent/child `part_id` / `parent_part_id` relationship instead of `employee_number` / `supervisor_id`. Project 08 asks you to build exactly this kind of structure.

---

## &#128204; Set Operators

**Set operators** combine the *result rows* of two or more separate `SELECT` statements — unlike a `JOIN`, which combines *columns* from different tables on a matching condition. Every set operator requires both queries to return the **same number of columns**, in the **same order**, with **compatible data types**.

| Operator | Meaning | Venn-diagram equivalent |
|---|---|---|
| `UNION` | All distinct rows from either query | A ∪ B (duplicates removed) |
| `UNION ALL` | All rows from either query, duplicates kept | A ∪ B (no dedup — faster) |
| `INTERSECT` | Only rows appearing in *both* queries | A ∩ B |
| `EXCEPT` | Rows in the first query *not* in the second | A − B |

### `UNION` vs. `UNION ALL`

```sql
-- Every distinct city that is either a customer's city or an employee's city
SELECT city FROM customer
UNION
SELECT city FROM employee;
```

```sql
-- Same query, but keep duplicate cities (much cheaper — no dedup pass)
SELECT city FROM customer
UNION ALL
SELECT city FROM employee;
```

Always reach for `UNION ALL` unless you specifically need duplicates removed — `UNION`'s deduplication step means comparing every row against every other row, which costs real performance on large result sets.

### `INTERSECT` — rows in both

```sql
-- Employees who are also customers (matched by email address, say)
SELECT email_address FROM employee
INTERSECT
SELECT email_address FROM customer;
```

### `EXCEPT` — rows in the first, not the second

```sql
-- Departments that exist but currently have zero employees
SELECT department_id FROM department
EXCEPT
SELECT department_id FROM employee;
```

This is a set-operator alternative to the `NOT EXISTS` anti-join pattern from [08-02](08-02-outer-joins-and-correlated-subqueries.md) — both answer "what's in A but not B," just phrased differently.

> [!NOTE]
> **Dialect differences matter here.** SQL Server has supported `UNION`, `INTERSECT`, and `EXCEPT` since SQL Server 2005. Oracle uses `MINUS` instead of `EXCEPT` for set difference (`INTERSECT` is spelled the same). **MySQL did not support `INTERSECT` or `EXCEPT` until version 8.0.31** (released October 2022) — before that, MySQL developers had to fake `INTERSECT` with an `INNER JOIN` or `EXISTS`, and fake `EXCEPT`/`MINUS` with `NOT EXISTS` or a `LEFT JOIN ... WHERE right.key IS NULL`. Always check the MySQL version in front of you before assuming these operators are available.

---

See also: [Joins over Recursive Relationships](05-04-joins-over-recursive-relationships.md), [Window Functions & User-Defined Functions](08-04-window-functions-and-udfs.md)

<!-- course-footer -->
---

<div align="center" markdown>

[All Notes](README.md) &nbsp;|&nbsp; [Module 08 Exercise](../02-exercises/08-exercise.md) &nbsp;|&nbsp; <strong>Next:</strong> [Window Functions & User-Defined Functions](08-04-window-functions-and-udfs.md)

</div>
<!-- /course-footer -->
