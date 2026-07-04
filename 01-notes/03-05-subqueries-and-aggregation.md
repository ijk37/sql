# &#128216; 03-05: Subqueries & Aggregation

<!-- course-header -->
<div align="center" markdown>

![SQL & Databases](../assets/banner.svg)

<img src="https://img.shields.io/badge/Module_03-SQL_Fundamentals-336791?style=for-the-badge&labelColor=24506B" alt="Module 03: SQL Fundamentals">

[![Home](https://img.shields.io/badge/⌂_Home-1B2A35?style=flat-square)](../index.md) [![All Notes](https://img.shields.io/badge/All_Notes-1B2A35?style=flat-square)](README.md) [![Practice](https://img.shields.io/badge/✎_Practice-C6821E?style=flat-square&labelColor=24506B)](../02-exercises/03-exercise.md) [![Quiz](https://img.shields.io/badge/▶_Quiz-C6821E?style=flat-square&labelColor=24506B)](../03-quiz/)

</div>
<!-- /course-header -->

## &#128161; Aggregate Functions — Summarizing Rows

An **aggregate function** collapses many rows into one summary value. These are the five you'll use constantly:

| Function | Meaning |
|---|---|
| `COUNT(*)` | Number of rows |
| `COUNT(column)` | Number of rows where `column IS NOT NULL` |
| `SUM(column)` | Total of a numeric column |
| `AVG(column)` | Average of a numeric column |
| `MIN(column)` | Smallest value |
| `MAX(column)` | Largest value |

```sql
SELECT COUNT(*) AS total_employees FROM employee;

SELECT AVG(max_hours) AS avg_planned_hours FROM project;

SELECT MIN(start_date) AS earliest_start, MAX(end_date) AS latest_end FROM project;
```

`COUNT(*)` counts rows regardless of `NULL`s; `COUNT(office_phone)` counts only employees whose `office_phone` is filled in — a quick way to measure how much of a column is actually populated.

---

## &#128204; GROUP BY — Aggregating Per Category

`GROUP BY` splits the table into buckets by a column's value, then applies the aggregate function separately to each bucket.

```sql
SELECT department_name, COUNT(*) AS employee_count
FROM employee
GROUP BY department_name
ORDER BY employee_count DESC;
```

Think of this as: WP has 9 departments, so this query produces 9 groups (one row of output per department), each showing how many employees fall into that group.

**Rule to remember:** every column in `SELECT` that is *not* wrapped in an aggregate function must appear in `GROUP BY`. This query is invalid —

```sql
-- INVALID: first_name isn't aggregated and isn't in GROUP BY
SELECT department_name, first_name, COUNT(*)
FROM employee
GROUP BY department_name;
```

— because for a department with five employees, SQL has no way to pick which single `first_name` to display for that one summary row.

### HAVING — Filtering Groups

`WHERE` filters *rows* before grouping; `HAVING` filters *groups* after aggregation. You cannot put an aggregate function in `WHERE`:

```sql
-- Departments with more than one employee
SELECT department_name, COUNT(*) AS employee_count
FROM employee
GROUP BY department_name
HAVING COUNT(*) > 1;

-- Projects whose total logged hours exceed 100
SELECT a.project_id, SUM(a.hours_worked) AS total_logged
FROM assignment a
GROUP BY a.project_id
HAVING SUM(a.hours_worked) > 100;
```

Clause order is fixed: `SELECT ... FROM ... WHERE ... GROUP BY ... HAVING ... ORDER BY`. Conceptually, execution happens roughly in this order — filter rows (`WHERE`), form groups (`GROUP BY`), filter groups (`HAVING`), then sort the final result (`ORDER BY`).

```sql
SELECT department_name, COUNT(*) AS employee_count
FROM employee
WHERE position IS NOT NULL
GROUP BY department_name
HAVING COUNT(*) > 1
ORDER BY employee_count DESC;
```

---

## &#128161; Subqueries — A Query Inside a Query

A **subquery** (or "inner query") is a `SELECT` nested inside another statement, usually inside `WHERE`. The outer query uses the subquery's result to decide which rows to keep.

### Scalar Subquery — Returns a Single Value

When a subquery is guaranteed to return exactly one value, you can compare it directly with `=`, `>`, `<`, etc.

```sql
-- Employees who earn... well, WP doesn't track salary, so: employees whose
-- assigned max_hours on a project exceeds the average across all projects
SELECT project_name, max_hours
FROM project
WHERE max_hours > (SELECT AVG(max_hours) FROM project);
```

The inner query `(SELECT AVG(max_hours) FROM project)` runs first, producing one number; the outer query then filters projects against that single value.

### IN Subquery — Returns a List of Values

```sql
-- Employees who are assigned to at least one project
SELECT first_name, last_name
FROM employee
WHERE employee_number IN (SELECT employee_number FROM assignment);
```

This is a subquery-based alternative to a join: instead of combining columns from both tables, `IN` simply asks "does this employee's number appear anywhere in `assignment`'s employee_number column?"

### EXISTS Subquery — Tests Whether Any Row Matches

`EXISTS` doesn't care what the subquery returns — only whether it returns *any* row at all. It's often faster than `IN` on large tables because the database can stop searching the moment it finds one match.

```sql
-- Departments that have at least one project
SELECT department_name
FROM department d
WHERE EXISTS (
    SELECT 1 FROM project p WHERE p.department_name = d.department_name
);
```

Notice the subquery references `d.department_name` from the *outer* query — this is a **correlated subquery**, one that re-runs once per outer row rather than once total. Correlated subqueries, along with `NOT EXISTS` for "find rows with no match" (the subquery equivalent of the outer-join pattern from [Joins](03-04-joins.md)), get full treatment in [Module 08](08-02-outer-joins-and-correlated-subqueries.md). For now, just recognize the shape: a subquery that mentions a column from the query wrapped around it.

---

## &#128204; Subqueries vs. Joins — When to Use Which

| | Subquery | Join |
|---|---|---|
| Can display columns from | Only the outer (top) table | Any table involved |
| Best for | "Does this exist / not exist" checks, single computed values | Combining and displaying data from multiple tables side by side |
| Readability | Often clearer for existence checks | Often clearer for "show me columns from both" |

```sql
-- Subquery version: just confirms which projects exist for Finance,
-- can only show PROJECT columns
SELECT project_name, max_hours
FROM project
WHERE department_name IN (SELECT department_name FROM department WHERE department_name = 'Finance');

-- Join version: can show columns from BOTH tables
SELECT p.project_name, p.max_hours, d.budget_code, d.office_number
FROM project p
JOIN department d ON p.department_name = d.department_name
WHERE d.department_name = 'Finance';
```

Both retrieve the same rows conceptually, but only the join can pull in `budget_code` and `office_number` from `department` — a subquery is fundamentally a single-table-output tool, even when it reaches into other tables to decide *which* rows to return.

---

> [!TIP]
> A good habit: reach for a **subquery** when the question is "which rows satisfy a condition based on another table," and reach for a **join** when the question is "show me combined columns from two or more tables." When in doubt, try both — for straightforward cases they're often interchangeable, and comparing them builds intuition for which reads more naturally.

---

See also: [Joins](03-04-joins.md), [Outer Joins & Correlated Subqueries](08-02-outer-joins-and-correlated-subqueries.md)

<!-- course-footer -->
---

<div align="center" markdown>

[All Notes](README.md) &nbsp;|&nbsp; [Module 03 Exercise](../02-exercises/03-exercise.md) &nbsp;|&nbsp; <strong>Next:</strong> [Systems Analysis & DB Lifecycle](04-01-systems-analysis-and-db-lifecycle.md)

</div>
<!-- /course-footer -->
