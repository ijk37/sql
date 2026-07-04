# &#128736; Project 08 — Advanced SQL Capstone

<!-- course-header -->
<div align="center" markdown>

![SQL & Databases](../../assets/banner.svg)

[![View the live site — ijk37.com](https://img.shields.io/badge/%F0%9F%87%A7%F0%9F%87%A9_View_the_Live_Site-IJK37.COM-F42A41?style=for-the-badge&labelColor=006A4E)](https://ijk37.com/sql/)

<img src="https://img.shields.io/badge/Project_08-Advanced_SQL_Capstone-336791?style=for-the-badge&labelColor=24506B" alt="Project 08: Advanced SQL Capstone">

[![Home](https://img.shields.io/badge/⌂_Home-1B2A35?style=flat-square)](../../index.md) [![All Projects](https://img.shields.io/badge/All_Projects-1B2A35?style=flat-square)](../README.md) [![Notes](https://img.shields.io/badge/Notes-1B2A35?style=flat-square)](../../01-notes/08-01-alter-merge-and-views.md) [![Quiz](https://img.shields.io/badge/▶_Quiz-C6821E?style=flat-square&labelColor=24506B)](../../03-quiz/)

</div>
<!-- /course-header -->

**Type:** SQL implementation (PostgreSQL) — cumulative
**Modules:** 05 (Recursive Relationships), 07 (Data Warehousing), 08 (Advanced SQL)
**Difficulty:** ⭐⭐⭐⭐

---

## &#127919; Objective

This is the **last project in the course** — a deliberate checkpoint, not a new topic. It asks you to combine three Module 08 techniques (a view, a recursive CTE, and window functions) into one cohesive deliverable, proving that everything from E-R modeling through advanced SQL fits together into a single working solution.

You may build this against the **Wedgewood Pacific (WP)** schema (`department`, `employee`, `project`, `assignment`) used throughout the course, or against **your own star schema from Project 07** if you'd rather practice these techniques on warehouse-shaped data instead. The tasks below are written for WP; if you use your Project 07 schema, adapt the specific columns while keeping the same three required techniques.

---

## &#129517; Scenario

Wedgewood Pacific's management wants a single reporting toolkit bundled together: a reusable view for a common report, a way to trace the full management chain for any employee (not just their direct supervisor), and rankings that show who's contributing the most hours in each department and project.

---

## &#128204; Requirements

1. Create **at least one view** that encapsulates a multi-table join or aggregation used elsewhere in your capstone.
2. Write **one recursive CTE** (`WITH RECURSIVE`) that walks a hierarchy to arbitrary depth — either the WP employee/supervisor management chain, or a bill-of-materials-style parent/child structure if you design your own.
3. Write **at least two window-function queries** — one using a ranking function (`RANK()`/`DENSE_RANK()`/`ROW_NUMBER()`), one using `LAG()`/`LEAD()` or a running total.
4. Every query must run against real, populated tables — reuse the WP schema and data from earlier modules, or your Project 07 warehouse tables.

---

## &#129513; Tasks

### &#128313; Part A — Reusable View

Create a view that answers a recurring reporting question in one place. For example, employee project-hours-to-date:

```sql
CREATE VIEW employee_project_hours_view AS
    SELECT e.employee_number, e.first_name, e.last_name,
           p.project_id, p.project_name,
           a.hours_worked
    FROM   employee AS e
    JOIN   assignment AS a ON e.employee_number = a.employee_number
    JOIN   project AS p    ON a.project_id      = p.project_id;
```

Then write one `SELECT` that queries the view (with its own `ORDER BY`, since the view itself can't define one).

### &#128313; Part B — Recursive Management Chain

Write a `WITH RECURSIVE` query that, given a starting employee, returns their **entire chain of supervisors up to the top of the company** (not just their direct supervisor), with a `level` column showing distance from the starting employee:

```sql
WITH RECURSIVE management_chain AS (
    SELECT employee_number, first_name, last_name, supervisor_id, 1 AS level
    FROM   employee
    WHERE  employee_number = 205          -- pick a real employee_number from your data

    UNION ALL

    SELECT e.employee_number, e.first_name, e.last_name, e.supervisor_id,
           mc.level + 1
    FROM   employee AS e
    JOIN   management_chain AS mc ON e.employee_number = mc.supervisor_id
)
SELECT * FROM management_chain ORDER BY level;
```

Include a depth guard (e.g., `WHERE mc.level < 20` in the recursive member) so the query can never loop forever if the data has a cycle.

### &#128313; Part C — Window-Function Reports

Write **two** window-function queries:

1. A ranking query — e.g., rank employees by total hours worked *within each department*:

    ```sql
    SELECT e.department_id, e.employee_number, e.last_name,
           SUM(a.hours_worked) AS total_hours,
           RANK() OVER (PARTITION BY e.department_id ORDER BY SUM(a.hours_worked) DESC) AS hours_rank
    FROM   employee AS e
    JOIN   assignment AS a ON e.employee_number = a.employee_number
    GROUP  BY e.department_id, e.employee_number, e.last_name
    ORDER  BY e.department_id, hours_rank;
    ```

2. A `LAG()`/`LEAD()` or running-total query — e.g., cumulative hours logged per project, ordered by employee:

    ```sql
    SELECT p.project_name, e.last_name, a.hours_worked,
           SUM(a.hours_worked) OVER (
               PARTITION BY p.project_id ORDER BY e.last_name
           ) AS running_hours_within_project
    FROM   assignment AS a
    JOIN   employee AS e  ON a.employee_number = e.employee_number
    JOIN   project AS p   ON a.project_id      = p.project_id
    ORDER  BY p.project_name, e.last_name;
    ```

### &#128313; Part D — Tie It Together

Write one final query that queries your **view** from Part A and layers a **window function** from Part C on top of it — proving the view and the window function compose cleanly, exactly the way a real reporting layer would use them together.

---

## &#9989; Verification Checklist

- [ ] At least one `CREATE VIEW` statement exists and is queried successfully.
- [ ] The recursive CTE returns more than one level of hierarchy for at least one starting row, and includes a depth guard.
- [ ] At least one ranking window function (`RANK`, `DENSE_RANK`, or `ROW_NUMBER`) is used correctly with `PARTITION BY`.
- [ ] At least one `LAG`/`LEAD`/running-total window function is used correctly.
- [ ] The Part D query successfully combines the view with a window function in a single `SELECT`.
- [ ] All queries run without error against populated tables.

---

## &#128230; Deliverables

- A single `.sql` file containing, in order: the view definition, the recursive CTE, both window-function queries, and the combined Part D query.
- A short closing paragraph (as a comment at the end of the file) reflecting on which Module 08 technique you found most useful, and why.

---

## &#128640; Stretch Goals

- Add a second recursive CTE walking a bill-of-materials-style structure (if you designed your own parent/child table) instead of the employee hierarchy.
- Add a `DENSE_RANK()` variant of your Part C ranking query and compare the output when there are ties.
- Wrap one of your window-function queries in a `CREATE FUNCTION ... LANGUAGE plpgsql` that takes a department ID as a parameter and returns the top-ranked employee's name for that department.

---

This closes out the course. Nice work getting from "what is a relational table" all the way to recursive CTEs and window functions — that's the real, practical core of what a working data professional uses SQL for day to day.

See also notes: [Recursive Queries & Set Operators](../../01-notes/08-03-recursive-queries-and-set-operators.md), [Window Functions & User-Defined Functions](../../01-notes/08-04-window-functions-and-udfs.md)
