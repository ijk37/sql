# &#128216; 08-04: Window Functions & User-Defined Functions

<!-- course-header -->
<div align="center" markdown>

![SQL & Databases](../assets/banner.svg)

<img src="https://img.shields.io/badge/Module_08-Advanced_SQL-336791?style=for-the-badge&labelColor=24506B" alt="Module 08: Advanced SQL">

[![Home](https://img.shields.io/badge/⌂_Home-1B2A35?style=flat-square)](../index.md) [![All Notes](https://img.shields.io/badge/All_Notes-1B2A35?style=flat-square)](README.md) [![Practice](https://img.shields.io/badge/✎_Practice-C6821E?style=flat-square&labelColor=24506B)](../02-exercises/08-exercise.md) [![Quiz](https://img.shields.io/badge/▶_Quiz-C6821E?style=flat-square&labelColor=24506B)](../03-quiz/)

</div>
<!-- /course-header -->

## &#128161; The Course's Final Stop

This is the last note in the course, and it lands on arguably the single most valuable SQL feature for anyone heading toward data analysis: **window functions**. They solve a problem that correlated subqueries (08-02) technically *can* solve but express clumsily — "rank/compare each row against other rows in a group, without collapsing the rows into a single aggregate." After window functions, we close with a brief, practical look at user-defined functions.

---

## &#128204; The Problem `GROUP BY` Can't Solve

`GROUP BY` collapses many rows into one row per group — perfect for "total hours per department," useless if you also need to see *every individual row* alongside a per-group calculation. Window functions compute across a "window" of related rows **without collapsing them**: every input row still appears in the output, now carrying extra per-group context.

The syntax pattern is always:

```sql
<window_function>() OVER (
    PARTITION BY <column(s) defining the group>
    ORDER BY <column(s) defining order within the group>
)
```

`PARTITION BY` is the window equivalent of `GROUP BY` — it defines which rows belong together — but instead of collapsing the group into one row, every row keeps its identity while the function runs "within" its own partition.

---

## &#128204; Ranking Functions: `ROW_NUMBER`, `RANK`, `DENSE_RANK`

```sql
SELECT department_id,
       employee_number,
       last_name,
       (SELECT SUM(hours_worked) FROM assignment a WHERE a.employee_number = e.employee_number) AS total_hours,
       ROW_NUMBER() OVER (PARTITION BY department_id ORDER BY last_name)                AS row_num,
       RANK()       OVER (PARTITION BY department_id ORDER BY last_name)                AS rank_num,
       DENSE_RANK() OVER (PARTITION BY department_id ORDER BY last_name)                AS dense_rank_num
FROM   employee e
ORDER  BY department_id, last_name;
```

The three ranking functions only diverge when there are **ties** in the `ORDER BY` column:

| Function | On a tie | After a tie of 2 |
|---|---|---|
| `ROW_NUMBER()` | Assigns a different number anyway (arbitrary tiebreak) | Continues 1, 2, 3, 4 ... |
| `RANK()` | Assigns the *same* rank to tied rows | Skips ranks: 1, 2, 2, 4 |
| `DENSE_RANK()` | Assigns the *same* rank to tied rows | Does not skip: 1, 2, 2, 3 |

### Top-N-per-group, the window-function way

This is the same "top earner per department" report from 08-02, expressed far more cleanly:

```sql
SELECT *
FROM (
    SELECT e.department_id, e.employee_number, e.last_name,
           SUM(a.hours_worked) AS total_hours,
           RANK() OVER (PARTITION BY e.department_id ORDER BY SUM(a.hours_worked) DESC) AS hours_rank
    FROM   employee AS e
    JOIN   assignment AS a ON e.employee_number = a.employee_number
    GROUP  BY e.department_id, e.employee_number, e.last_name
) AS ranked
WHERE hours_rank = 1;
```

Window functions run *after* `GROUP BY`/aggregation in the logical query order, which is why `RANK()` here can be layered on top of a `SUM()` — the aggregate produces one row per employee, and the window function then ranks those rows within each department. Because a window function can't be filtered directly in the same `SELECT`'s `WHERE` clause (same restriction as any computed column), the ranked query has to be wrapped in a subquery so `WHERE hours_rank = 1` can filter on it.

---

## &#128204; `LAG` / `LEAD` — Comparing to Another Row

`LAG()` looks *backward* to a previous row in the same window; `LEAD()` looks *forward*. Both are the natural tool for period-over-period comparisons:

```sql
-- Month-over-month revenue change, using the fact_sales / dim_date star schema
SELECT d.year, d.month_name,
       SUM(f.sale_amount) AS monthly_revenue,
       LAG(SUM(f.sale_amount)) OVER (ORDER BY d.year, d.quarter) AS prior_period_revenue,
       SUM(f.sale_amount) - LAG(SUM(f.sale_amount)) OVER (ORDER BY d.year, d.quarter) AS revenue_change
FROM   fact_sales f
JOIN   dim_date d ON f.date_key = d.date_key
GROUP  BY d.year, d.month_name, d.quarter
ORDER  BY d.year, d.quarter;
```

### Running totals

Omitting `PARTITION BY` (or using it without narrowing the window) plus an `ORDER BY` turns a simple `SUM() OVER (...)` into a running total — each row's window is "everything up to and including this row":

```sql
SELECT d.full_date,
       SUM(f.sale_amount) AS daily_revenue,
       SUM(SUM(f.sale_amount)) OVER (ORDER BY d.full_date) AS running_total_revenue
FROM   fact_sales f
JOIN   dim_date d ON f.date_key = d.date_key
GROUP  BY d.full_date
ORDER  BY d.full_date;
```

> [!TIP]
> Window functions are a cornerstone of modern data-science SQL — running totals, top-N-per-group, and period-over-period deltas are exactly the calculations that show up constantly in analytics, dashboards, and BI reports, and doing them without window functions usually means slow, hard-to-read correlated subqueries or client-side code. If you only take one advanced-SQL skill from this entire course into a data job, make it this one.

> [!NOTE]
> `ROW_NUMBER`, `RANK`, `DENSE_RANK`, `LAG`, and `LEAD` all work with identical syntax in PostgreSQL, SQL Server (2012+), MySQL (8.0+), and Oracle. This is genuinely one of the most portable areas of modern SQL — a rare case where you can write one query and expect it to run almost unchanged everywhere.

---

## &#128204; User-Defined Functions (SQL/PSM)

**SQL/PSM** (Persistent Stored Modules) is the standard's umbrella term for code stored *inside* the database itself — user-defined functions, triggers, and stored procedures. A **user-defined function** is a named, reusable block of SQL (and procedural logic) that takes parameters and returns a value, callable from any query exactly like a built-in function such as `SUM()` or `COUNT()`.

The motivating example is a formatting task you'd otherwise repeat in every query: building a `"LastName, FirstName"` display string.

```sql
-- Without a function: correct, but repeated everywhere this format is needed
SELECT CONCAT(last_name, ', ', first_name) AS employee_name,
       department_id, office_phone, email_address
FROM   employee
ORDER  BY employee_name;
```

### PostgreSQL: `CREATE FUNCTION ... LANGUAGE plpgsql`

```sql
CREATE FUNCTION name_concatenation(p_first VARCHAR, p_last VARCHAR)
RETURNS VARCHAR AS $$
BEGIN
    RETURN p_last || ', ' || p_first;
END;
$$ LANGUAGE plpgsql;

-- Now reusable anywhere:
SELECT name_concatenation(first_name, last_name) AS employee_name,
       department_id, office_phone, email_address
FROM   employee
ORDER  BY employee_name;
```

`plpgsql` is Postgres's own procedural extension to SQL — it adds variables, `IF`/`LOOP` control flow, and `BEGIN...END` blocks, which is exactly what SQL/PSM describes generically.

> [!NOTE]
> **Dialect comparison for stored functions:**
>
> - **SQL Server (T-SQL):** `CREATE FUNCTION dbo.NameConcatenation (@first NVARCHAR(50), @last NVARCHAR(50)) RETURNS NVARCHAR(101) AS BEGIN RETURN @last + ', ' + @first END;`
> - **MySQL:** functions are wrapped with a temporary `DELIMITER` change, because MySQL's default statement terminator (`;`) would otherwise end the function body early:
>   ```sql
>   DELIMITER $$
>   CREATE FUNCTION NameConcatenation(p_first VARCHAR(50), p_last VARCHAR(50))
>   RETURNS VARCHAR(101) DETERMINISTIC
>   BEGIN
>       RETURN CONCAT(p_last, ', ', p_first);
>   END $$
>   DELIMITER ;
>   ```
> - **Oracle (PL/SQL):** `CREATE FUNCTION name_concatenation(p_first VARCHAR2, p_last VARCHAR2) RETURN VARCHAR2 IS BEGIN RETURN p_last || ', ' || p_first; END;`

Beyond user-defined functions, SQL/PSM also covers **triggers** (code that fires automatically on `INSERT`/`UPDATE`/`DELETE` against a table) and **stored procedures** (database-resident programs invoked directly rather than embedded in a query). Both are database-administration-adjacent topics — worth knowing the vocabulary, but a full treatment belongs in a DBA-focused course rather than this one.

---

## &#128161; Course Wrap-Up

That closes out Module 08, and with it, the course. Starting from "what is a relational table" through E-R modeling, normalization, transactions, warehousing, and now window functions and stored functions — every piece here builds toward being able to design a real schema and write the real queries a data role expects. [Project 08](../04-projects/08-advanced-sql-capstone/README.md) is the cumulative checkpoint: it deliberately combines a view, a recursive CTE, and window functions into one deliverable, so treat it as the final proof that these pieces fit together.

---

See also: [Recursive Queries & Set Operators](08-03-recursive-queries-and-set-operators.md), [Outer Joins & Correlated Subqueries](08-02-outer-joins-and-correlated-subqueries.md)

<!-- course-footer -->
---

<div align="center" markdown>

[All Notes](README.md) &nbsp;|&nbsp; [Module 08 Exercise](../02-exercises/08-exercise.md)

</div>
<!-- /course-footer -->
