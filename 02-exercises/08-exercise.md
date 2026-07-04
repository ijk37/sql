# &#9997; 08: Advanced SQL — Exercises

<!-- course-header -->
<div align="center" markdown>

![SQL & Databases](../assets/banner.svg)

<img src="https://img.shields.io/badge/Module_08-Advanced_SQL-336791?style=for-the-badge&labelColor=24506B" alt="Module 08: Advanced SQL"> <img src="https://img.shields.io/badge/12_questions-C6821E?style=for-the-badge&labelColor=24506B" alt="12 questions">

[![Home](https://img.shields.io/badge/⌂_Home-1B2A35?style=flat-square)](../index.md) [![Notes](https://img.shields.io/badge/Notes-1B2A35?style=flat-square)](../01-notes/08-01-alter-merge-and-views.md) [![All Exercises](https://img.shields.io/badge/All_Exercises-1B2A35?style=flat-square)](README.md) [![Quiz](https://img.shields.io/badge/▶_Quiz-C6821E?style=flat-square&labelColor=24506B)](../03-quiz/)

</div>
<!-- /course-header -->

> [!TIP]
> **Practice —** try each question first, then expand the answer to check your reasoning. Queries use the Wedgewood Pacific (WP) tables: `department`, `employee(employee_number, first_name, last_name, department_id, position, supervisor_id, office_phone, email_address)`, `project(project_id, project_name, department_id, max_hours, start_date, end_date)`, `assignment(project_id, employee_number, hours_worked)`.

Work through each question, then click **Show answer** to check yourself. Review the [notes](../01-notes/08-01-alter-merge-and-views.md) if you get stuck.

---

### &#128313; Q1. Write an `ALTER TABLE` statement that adds a nullable column `bonus_eligible BOOLEAN` to `employee`.

<details>
<summary><strong>Show answer</strong></summary>

```sql
ALTER TABLE employee
    ADD COLUMN bonus_eligible BOOLEAN;
```
</details>

---

### &#10067; Q2. You need to add a `NOT NULL` column `region` to `department`, which already has rows. Describe the three-step process (you don't need every value to be the same).

<details>
<summary><strong>Show answer</strong></summary>

1. Add the column allowing `NULL`s: `ALTER TABLE department ADD COLUMN region VARCHAR(20);`
2. Backfill every existing row with a real value: `UPDATE department SET region = 'Unassigned' WHERE region IS NULL;`
3. Now enforce the constraint: `ALTER TABLE department ALTER COLUMN region SET NOT NULL;`

You can't add `NOT NULL` directly to a column on a table that already has rows with no value for that column yet.
</details>

---

### &#128313; Q3. Write a PostgreSQL `INSERT ... ON CONFLICT` statement that inserts a new `department` row (`department_id = 6`, `department_name = 'Analytics'`), or updates `department_name` if a row with that `department_id` already exists.

<details>
<summary><strong>Show answer</strong></summary>

```sql
INSERT INTO department (department_id, department_name)
VALUES (6, 'Analytics')
ON CONFLICT (department_id)
DO UPDATE SET department_name = EXCLUDED.department_name;
```

`EXCLUDED` refers to the row values that would have been inserted — that's how the `DO UPDATE` clause references the new incoming data.
</details>

---

### &#10067; Q4. Rewrite your Q3 statement for MySQL, using its upsert syntax.

<details>
<summary><strong>Show answer</strong></summary>

```sql
INSERT INTO department (department_id, department_name)
VALUES (6, 'Analytics')
ON DUPLICATE KEY UPDATE
    department_name = VALUES(department_name);
```

MySQL has no `MERGE` statement; `ON DUPLICATE KEY UPDATE` is its equivalent, and requires a unique or primary key on `department_id` to detect the conflict.
</details>

---

### &#128313; Q5. Write a query using `LEFT JOIN` that lists every project along with any assignments, so that projects with zero assignments still appear (with `NULL` in the assignment columns).

<details>
<summary><strong>Show answer</strong></summary>

```sql
SELECT p.project_name, a.employee_number, a.hours_worked
FROM   project AS p
LEFT JOIN assignment AS a ON p.project_id = a.project_id
ORDER  BY p.project_id;
```

An inner join would silently drop any project that has no matching `assignment` rows; `LEFT JOIN` keeps every `project` row and fills unmatched columns with `NULL`.
</details>

---

### &#10067; Q6. Write a query using `NOT EXISTS` (an anti-join) to find every project that currently has zero assignments.

<details>
<summary><strong>Show answer</strong></summary>

```sql
SELECT p.project_id, p.project_name
FROM   project AS p
WHERE  NOT EXISTS (
    SELECT 1
    FROM   assignment AS a
    WHERE  a.project_id = p.project_id
);
```

The subquery is correlated — it references the outer query's `p.project_id` — and `NOT EXISTS` is true only when the subquery returns no rows at all for that project.
</details>

---

### &#128313; Q7. Write a correlated subquery that lists employees who share the same `position` as at least one other employee (i.e., their position isn't unique in the company).

<details>
<summary><strong>Show answer</strong></summary>

```sql
SELECT e1.employee_number, e1.first_name, e1.last_name, e1.position
FROM   employee AS e1
WHERE  EXISTS (
    SELECT 1
    FROM   employee AS e2
    WHERE  e1.position = e2.position
    AND    e1.employee_number <> e2.employee_number
);
```

Both aliases refer to the same `employee` table; the inner query's `WHERE` clause reaches out to `e1`, the outer query's current row, which is what makes the subquery correlated rather than a fixed, independent result.
</details>

---

### &#10067; Q8. Write a `WITH RECURSIVE` query that returns every employee who reports — directly or indirectly — to the employee with `employee_number = 100`, including a `level` column showing how many steps down the chain each one is.

<details>
<summary><strong>Show answer</strong></summary>

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
)
SELECT * FROM org_chart ORDER BY level, last_name;
```

The anchor starts at employee 100; the recursive member repeatedly finds employees whose `supervisor_id` matches someone already in `org_chart`, so `level` grows by one with each layer down the chart, until a pass finds no new matches.
</details>

---

### &#128313; Q9. What is the difference between `UNION` and `UNION ALL`, and which should you prefer by default?

<details>
<summary><strong>Show answer</strong></summary>

`UNION` removes duplicate rows from the combined result; `UNION ALL` keeps every row from both queries, including duplicates. Prefer `UNION ALL` by default — deduplication requires comparing every row against every other row, which costs real performance, and matters only when you specifically need duplicates removed.
</details>

---

### &#10067; Q10. Write a query using `EXCEPT` (or `MINUS` on Oracle) to find department IDs that exist in `department` but have no matching employee in `employee`. Then note which widely-used database version first added this operator, if you're using MySQL.

<details>
<summary><strong>Show answer</strong></summary>

```sql
SELECT department_id FROM department
EXCEPT
SELECT department_id FROM employee;
```

On Oracle, replace `EXCEPT` with `MINUS`; the logic is identical. **MySQL did not support `INTERSECT` or `EXCEPT` until version 8.0.31** (released October 2022) — on earlier MySQL versions, this would have to be rewritten using `NOT EXISTS` or a `LEFT JOIN ... WHERE right.column IS NULL`.
</details>

---

### &#128313; Q11. Write a window-function query that ranks employees by total hours worked (summed across all their assignments) *within each department*, using `RANK()`. Show department_id, employee_number, total hours, and the rank.

<details>
<summary><strong>Show answer</strong></summary>

```sql
SELECT e.department_id, e.employee_number, e.last_name,
       SUM(a.hours_worked) AS total_hours,
       RANK() OVER (PARTITION BY e.department_id ORDER BY SUM(a.hours_worked) DESC) AS hours_rank
FROM   employee AS e
JOIN   assignment AS a ON e.employee_number = a.employee_number
GROUP  BY e.department_id, e.employee_number, e.last_name
ORDER  BY e.department_id, hours_rank;
```

`PARTITION BY e.department_id` restarts the ranking for every department; `RANK()` (rather than `ROW_NUMBER()`) means two employees tied on total hours receive the same rank, and the next rank number is skipped accordingly.
</details>

---

### &#10067; Q12. Write a `CREATE FUNCTION` statement in PostgreSQL (`plpgsql`) called `full_name` that takes a first name and last name and returns `"LastName, FirstName"`. Then show how you'd call it in a `SELECT`.

<details>
<summary><strong>Show answer</strong></summary>

```sql
CREATE FUNCTION full_name(p_first VARCHAR, p_last VARCHAR)
RETURNS VARCHAR AS $$
BEGIN
    RETURN p_last || ', ' || p_first;
END;
$$ LANGUAGE plpgsql;

SELECT full_name(first_name, last_name) AS employee_name, department_id
FROM   employee
ORDER  BY employee_name;
```

Once created, the function is callable from any query exactly like a built-in function such as `SUM()` — the formatting logic is written once and reused everywhere, instead of repeating `CONCAT(last_name, ', ', first_name)` in every query that needs it.
</details>

---

[All Exercises](README.md)

<!-- course-footer -->
---

<div align="center" markdown>

[All Exercises](README.md) &nbsp;|&nbsp; [Module 08 Notes](../01-notes/08-01-alter-merge-and-views.md)

</div>
<!-- /course-footer -->
