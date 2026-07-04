# &#128216; 03-04: Joins

<!-- course-header -->
<div align="center" markdown>

![SQL & Databases](../assets/banner.svg)

<img src="https://img.shields.io/badge/Module_03-SQL_Fundamentals-336791?style=for-the-badge&labelColor=24506B" alt="Module 03: SQL Fundamentals">

[![Home](https://img.shields.io/badge/⌂_Home-1B2A35?style=flat-square)](../index.md) [![All Notes](https://img.shields.io/badge/All_Notes-1B2A35?style=flat-square)](README.md) [![Practice](https://img.shields.io/badge/✎_Practice-C6821E?style=flat-square&labelColor=24506B)](../02-exercises/03-exercise.md) [![Quiz](https://img.shields.io/badge/▶_Quiz-C6821E?style=flat-square&labelColor=24506B)](../03-quiz/)

</div>
<!-- /course-header -->

## &#128161; Why Joins Exist

The Wedgewood Pacific schema splits data across four tables — `department`, `employee`, `project`, `assignment` — precisely so each table holds one theme (see [Why Databases?](01-01-why-databases.md)). But real questions cross tables: *"Which department is each employee in?"* needs `employee` **and** `department` at once. A **join** combines rows from two (or more) tables based on a matching column, almost always a primary key / foreign key pair.

---

## &#128204; Thinking in Venn Diagrams

The clearest way to reason about joins is to picture two overlapping circles — one circle is "rows in the left table," the other is "rows in the right table," and where they overlap is "rows that match on the join condition."

```
   EMPLOYEE                    DEPARTMENT
  ┌───────────────┐          ┌───────────────┐
  │  employees    │          │  departments  │
  │  with no      │  ┌────┐  │  with no       │
  │  department   │  │ M  │  │  employees     │
  │  on file      │  │ A  │  │  yet           │
  │               │  │ T  │  │                │
  │               │  │ C  │  │                │
  │               │  │ H  │  │                │
  └───────────────┘  └────┘  └───────────────┘
```

- The **match region** (middle) is what an **INNER JOIN** returns — only rows that exist on both sides.
- **Left-only** + **match** is what a **LEFT OUTER JOIN** returns.
- **Right-only** + **match** is what a **RIGHT OUTER JOIN** returns.
- **Left-only** + **match** + **right-only** — everything — is what a **FULL OUTER JOIN** returns.

Every join type is just a different answer to: *which parts of these two circles do I want?*

---

## &#128204; INNER JOIN

An inner join (also called an **equijoin** when the condition is equality) returns only rows where the join condition matches on both sides. If an employee's department doesn't exist in `department`, or a department has no employees, neither shows up.

```sql
SELECT d.department_name, e.first_name, e.last_name, e.position
FROM department d
INNER JOIN employee e ON d.department_name = e.department_name
ORDER BY d.department_name, e.last_name;
```

`d` and `e` are **table aliases** — shorthand so you don't repeat `department`/`employee` on every column reference. The `ON` clause names the columns being matched: the primary key side (`department.department_name`) and the foreign key side (`employee.department_name`).

### The Older "Implicit Join" Style

You'll also see joins written with the join condition moved into `WHERE`, listing every table in `FROM` separated by commas:

```sql
SELECT department.department_name, first_name, last_name, position, email_address
FROM department, employee
WHERE department.department_name = employee.department_name
ORDER BY department_name, last_name;
```

This produces identical results to the `INNER JOIN ... ON` version above. It's called an **implicit join** because nothing in the syntax says "join" — the relationship is implied by the `WHERE` condition. Modern style strongly prefers explicit `JOIN ... ON`, because it separates *"how tables relate"* (the `ON` clause) from *"which rows to keep"* (the `WHERE` clause) — mixing both into one `WHERE` gets error-prone once outer joins or extra filters enter the picture.

### Joining Three Tables

Chain `JOIN` clauses to pull in a third table. To list every employee's hours on every project, you need `project` → `assignment` → `employee`:

```sql
SELECT p.project_name, e.first_name, e.last_name, a.hours_worked
FROM project p
JOIN assignment a ON p.project_id = a.project_id
JOIN employee e ON a.employee_number = e.employee_number
ORDER BY p.project_id, e.employee_number;
```

Read this as two pairwise joins: first match `project` to `assignment` on `project_id`, then match the result to `employee` on `employee_number`. `assignment` is the **intersection table** that makes the three-way link possible — without it, `project` and `employee` share no direct column to join on.

---

## &#128204; LEFT OUTER JOIN — Keep Everything on the Left

A `LEFT OUTER JOIN` (often just written `LEFT JOIN`) keeps **every row from the left table**, whether or not it has a match on the right. Unmatched right-side columns come back as `NULL`.

```sql
SELECT d.department_name, e.first_name, e.last_name
FROM department d
LEFT OUTER JOIN employee e ON d.department_name = e.department_name
ORDER BY d.department_name;
```

Every department appears at least once — even one with zero employees would show up with `NULL` for `first_name`/`last_name`.

### The "Find Rows With No Match" Pattern

This is the single most useful trick outer joins give you: start from a left outer join, then filter to just the rows where the right side came back `NULL`. That isolates left-side rows with **no** match at all.

*Question: which projects have no one assigned to them yet?*

```sql
SELECT p.project_id, p.project_name
FROM project p
LEFT OUTER JOIN assignment a ON p.project_id = a.project_id
WHERE a.project_id IS NULL;
```

Walk through why this works: the `LEFT OUTER JOIN` first produces one row per project per matching assignment, plus one `NULL`-padded row for any project with zero assignments. The `WHERE a.project_id IS NULL` then throws away every row *except* those `NULL`-padded ones — leaving exactly the projects that had nothing to join to.

*Question: which employees have never been assigned to a project?*

```sql
SELECT e.employee_number, e.first_name, e.last_name
FROM employee e
LEFT OUTER JOIN assignment a ON e.employee_number = a.employee_number
WHERE a.employee_number IS NULL;
```

> [!TIP]
> Whenever a question has the shape "which X have no Y," reach for: `LEFT OUTER JOIN` from X to Y, then `WHERE <Y's join column> IS NULL`. It's one of the most common query patterns you'll write in practice.

---

## &#128204; RIGHT OUTER JOIN — Keep Everything on the Right

`RIGHT OUTER JOIN` is the mirror image — every row from the right table is kept, with `NULL`s padded in for unmatched left-side columns.

```sql
SELECT e.first_name, e.last_name, a.project_id, a.hours_worked
FROM assignment a
RIGHT OUTER JOIN employee e ON a.employee_number = e.employee_number
ORDER BY e.last_name;
```

This lists every employee, whether or not they have an assignment row. In practice, most people avoid `RIGHT JOIN` and just swap the table order to use `LEFT JOIN` instead — the two are equivalent, and sticking to one direction keeps queries easier to read at a glance:

```sql
-- Equivalent to the RIGHT OUTER JOIN above
SELECT e.first_name, e.last_name, a.project_id, a.hours_worked
FROM employee e
LEFT OUTER JOIN assignment a ON e.employee_number = a.employee_number
ORDER BY e.last_name;
```

---

## &#128204; FULL OUTER JOIN — Keep Everything, Both Sides

`FULL OUTER JOIN` keeps every row from both tables — matched rows combine normally, and unmatched rows from *either* side appear padded with `NULL`s on the other side.

```sql
SELECT d.department_name, p.project_name
FROM department d
FULL OUTER JOIN project p ON d.department_name = p.department_name;
```

This surfaces departments with no active projects **and** (hypothetically, if the FK weren't enforced) projects with no matching department — the union of "left only," "match," and "right only" from the Venn diagram.

> [!NOTE]
> **MySQL has no `FULL OUTER JOIN` keyword.** Emulate it with a `UNION` of a `LEFT JOIN` and a `RIGHT JOIN`:
> ```sql
> SELECT d.department_name, p.project_name
> FROM department d LEFT JOIN project p ON d.department_name = p.department_name
> UNION
> SELECT d.department_name, p.project_name
> FROM department d RIGHT JOIN project p ON d.department_name = p.department_name;
> ```
> PostgreSQL and SQL Server both support `FULL OUTER JOIN` natively.

---

## &#128204; Self Join — Joining a Table to Itself

The `employee.supervisor` column is a foreign key back into `employee` itself (see [DDL](03-01-ddl-tables-and-datatypes.md)). To show each employee alongside their supervisor's name, join the table to itself using two different aliases:

```sql
SELECT worker.first_name AS employee_first,
       worker.last_name  AS employee_last,
       boss.first_name   AS supervisor_first,
       boss.last_name    AS supervisor_last
FROM employee worker
LEFT OUTER JOIN employee boss ON worker.supervisor = boss.employee_number
ORDER BY boss.last_name, worker.last_name;
```

The `LEFT OUTER JOIN` matters here: Mary Jacobs (the CEO) has `supervisor = NULL` — she reports to no one. An `INNER JOIN` would silently drop her from the results; the `LEFT OUTER JOIN` keeps her, with `NULL` supervisor columns.

---

## &#128204; CROSS JOIN — Every Combination

A `CROSS JOIN` pairs every row of one table with every row of the other — no `ON` clause, no matching condition. The result has `(rows in A) × (rows in B)` rows.

```sql
-- Every department paired with every possible position title — useful for
-- generating a "what positions could exist in what department" planning grid
SELECT d.department_name, positions.title
FROM department d
CROSS JOIN (VALUES ('Manager'), ('Analyst'), ('Assistant')) AS positions(title);
```

Genuine `CROSS JOIN` use cases are rare — generating combinations, building calendars, or seeding test data. An accidental cross join (forgetting the `ON` clause, or writing `FROM a, b` without a matching `WHERE`) is one of the most common SQL bugs: it silently multiplies your row count instead of erroring.

---

## &#128204; Subqueries vs. Joins — A Quick Preview

You'll also see multi-table questions answered with a **subquery** instead of a join — a `SELECT` nested inside another `SELECT`'s `WHERE` clause. The key difference: a subquery can only pull *display* columns from the outermost table, while a join can display columns from every table involved. [Subqueries & Aggregation](03-05-subqueries-and-aggregation.md) picks this up next.

---

See also: [SELECT: Filtering & Sorting](03-03-select-filtering-sorting.md), [Subqueries & Aggregation](03-05-subqueries-and-aggregation.md)

<!-- course-footer -->
---

<div align="center" markdown>

[All Notes](README.md) &nbsp;|&nbsp; [Module 03 Exercise](../02-exercises/03-exercise.md) &nbsp;|&nbsp; <strong>Next:</strong> [Subqueries & Aggregation](03-05-subqueries-and-aggregation.md)

</div>
<!-- /course-footer -->
