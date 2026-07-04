# &#128216; 08-02: Outer Joins & Correlated Subqueries

<!-- course-header -->
<div align="center" markdown>

![SQL & Databases](../assets/banner.svg)

<img src="https://img.shields.io/badge/Module_08-Advanced_SQL-336791?style=for-the-badge&labelColor=24506B" alt="Module 08: Advanced SQL">

[![Home](https://img.shields.io/badge/⌂_Home-1B2A35?style=flat-square)](../index.md) [![All Notes](https://img.shields.io/badge/All_Notes-1B2A35?style=flat-square)](README.md) [![Practice](https://img.shields.io/badge/✎_Practice-C6821E?style=flat-square&labelColor=24506B)](../02-exercises/08-exercise.md) [![Quiz](https://img.shields.io/badge/▶_Quiz-C6821E?style=flat-square&labelColor=24506B)](../03-quiz/)

</div>
<!-- /course-header -->

## &#128161; Beyond the Inner Join

Module 03 introduced joins as matching rows between two tables. That covers the common case, but two situations need more: finding rows that *don't* have a match (missing data), and writing a query where an inner query needs to reference the outer query's current row (correlated subqueries). Both come up constantly in real reporting work.

---

## &#128204; Outer Joins Revisited: Finding the Gaps

An inner join only returns rows that match on both sides. Suppose Wedgewood Pacific creates a brand-new `PROJECT` row that has no `ASSIGNMENT` rows yet — nobody has logged hours against it. An inner join between `project` and `assignment` **silently drops that project from the results**, because there's nothing to match:

```sql
-- Inner join: brand-new, unassigned projects vanish from the output
SELECT p.project_name, a.employee_number, a.hours_worked
FROM   project AS p
JOIN   assignment AS a ON p.project_id = a.project_id
ORDER  BY p.project_id;
```

A **`LEFT JOIN`** keeps every row from the left-hand table, filling in `NULL` for any right-hand columns that have no match:

```sql
SELECT p.project_name, a.employee_number, a.hours_worked
FROM   project AS p
LEFT JOIN assignment AS a ON p.project_id = a.project_id
ORDER  BY p.project_id;
```

Now the new project appears with `employee_number` and `hours_worked` shown as `NULL` — exactly the signal that "this project has zero assignments," which is the point of running the report in the first place.

A **`RIGHT JOIN`** is the mirror image — keep every row from the right-hand table. It's most useful when you'd rather not reorder your `FROM` clause:

```sql
-- Every employee, whether or not they're assigned to any project
SELECT p.project_name, e.first_name, e.last_name, a.hours_worked
FROM   (project AS p
        JOIN assignment AS a ON p.project_id = a.project_id)
RIGHT JOIN employee AS e ON a.employee_number = e.employee_number
ORDER  BY p.project_id, e.employee_number;
```

This surfaces employees with no assignments at all, alongside the normal matched rows.

> [!TIP]
> `LEFT JOIN X` and `RIGHT JOIN Y ... FROM X` describing the same logical result are interchangeable by swapping table order — most style guides prefer sticking to `LEFT JOIN` everywhere and just reordering the `FROM` clause, since `RIGHT JOIN` is easy to misread in a long query.

### Anti-joins: `NOT EXISTS`

Finding "rows on the left with **no** match on the right" — an **anti-join** — is a very common reporting need: which projects have zero assignments? A `LEFT JOIN ... WHERE right_key IS NULL` works, but `NOT EXISTS` with a correlated subquery is usually clearer and often faster:

```sql
SELECT p.project_id, p.project_name
FROM   project AS p
WHERE  NOT EXISTS (
    SELECT 1
    FROM   assignment AS a
    WHERE  a.project_id = p.project_id
);
```

---

## &#128204; Correlated Subqueries

A regular (uncorrelated) subquery is self-contained: it runs once, produces a result, and the outer query uses that fixed result. A **correlated subquery** is different — it references a column from the *outer* query, so it conceptually re-runs once per row of the outer query, each time using that row's current values.

```sql
-- Find employees who share a last name with at least one other employee
SELECT e1.employee_number, e1.first_name, e1.last_name
FROM   employee AS e1
WHERE  e1.last_name IN (
    SELECT e2.last_name
    FROM   employee AS e2
    WHERE  e1.last_name = e2.last_name
    AND    e1.employee_number <> e2.employee_number
);
```

Notice both instances of the table are aliased differently (`e1`, `e2`) purely so the query can compare a row against *other* rows of the same table — the inner query's `WHERE` clause reaches out to `e1`, the outer query's current row, which is what makes it correlated.

### `EXISTS` / `NOT EXISTS`

`EXISTS` is a correlated-subquery idiom that only cares whether the subquery returns *any* rows at all — it never actually inspects subquery values, just tests for their presence:

```sql
-- Departments that currently have at least one employee
SELECT d.department_name
FROM   department AS d
WHERE  EXISTS (
    SELECT 1
    FROM   employee AS e
    WHERE  e.department_id = d.department_id
);
```

If the subquery returns at least one row for a given outer row, `EXISTS` is true and that outer row is kept; if it returns nothing, the row is dropped. `NOT EXISTS` is the anti-join pattern already shown above.

### Worked example — top earner (most hours) per department

A classic correlated-subquery report: for each department, find the employee who has logged the most total project hours. Rather than a window function (Module 08's final note covers those), this is the "no window function" version, worth knowing because it works in any SQL dialect:

```sql
SELECT e.department_id, e.first_name, e.last_name,
       (SELECT SUM(a.hours_worked)
        FROM   assignment AS a
        WHERE  a.employee_number = e.employee_number) AS total_hours
FROM   employee AS e
WHERE  (SELECT SUM(a.hours_worked)
        FROM   assignment AS a
        WHERE  a.employee_number = e.employee_number)
     = (
        -- the maximum total-hours figure within this employee's department
        SELECT MAX(dept_totals.total_hours)
        FROM (
            SELECT e2.employee_number,
                   SUM(a2.hours_worked) AS total_hours
            FROM   employee AS e2
            JOIN   assignment AS a2 ON e2.employee_number = a2.employee_number
            WHERE  e2.department_id = e.department_id
            GROUP  BY e2.employee_number
        ) AS dept_totals
);
```

This works, but it's dense — every correlated subquery has to be re-evaluated per outer row, which is exactly why Module 08's window-functions note exists: `RANK() OVER (PARTITION BY department_id ORDER BY total_hours DESC)` expresses the same "top per group" idea in a single pass and far more readably. Correlated subqueries remain essential, though, for `EXISTS`/`NOT EXISTS` existence checks and for databases/situations where window functions aren't available.

> [!NOTE]
> All major dialects (PostgreSQL, MySQL 8+, SQL Server, Oracle) support `EXISTS`, `NOT EXISTS`, and correlated subqueries with identical syntax — this is one of the more portable corners of advanced SQL.

---

See also: [ALTER, MERGE & Views](08-01-alter-merge-and-views.md), [Recursive Queries & Set Operators](08-03-recursive-queries-and-set-operators.md)

<!-- course-footer -->
---

<div align="center" markdown>

[All Notes](README.md) &nbsp;|&nbsp; [Module 08 Exercise](../02-exercises/08-exercise.md) &nbsp;|&nbsp; <strong>Next:</strong> [Recursive Queries & Set Operators](08-03-recursive-queries-and-set-operators.md)

</div>
<!-- /course-footer -->
