# &#9997; 03: SQL Fundamentals — Exercises

<!-- course-header -->
<div align="center" markdown>

![SQL & Databases](../assets/banner.svg)

<img src="https://img.shields.io/badge/Module_03-SQL_Fundamentals-336791?style=for-the-badge&labelColor=24506B" alt="Module 03: SQL Fundamentals"> <img src="https://img.shields.io/badge/12_questions-C6821E?style=for-the-badge&labelColor=24506B" alt="12 questions">

[![Home](https://img.shields.io/badge/⌂_Home-1B2A35?style=flat-square)](../index.md) [![Notes](https://img.shields.io/badge/Notes-1B2A35?style=flat-square)](../01-notes/03-01-ddl-tables-and-datatypes.md) [![All Exercises](https://img.shields.io/badge/All_Exercises-1B2A35?style=flat-square)](README.md) [![Quiz](https://img.shields.io/badge/▶_Quiz-C6821E?style=flat-square&labelColor=24506B)](../03-quiz/)

</div>
<!-- /course-header -->

> [!TIP]
> **Practice —** try each question first, then expand the answer to check your reasoning. All questions use the Wedgewood Pacific schema: `department(department_name, budget_code, office_number, department_phone)`, `employee(employee_number, first_name, last_name, department_name, position, supervisor, office_phone, email_address)`, `project(project_id, project_name, department_name, max_hours, start_date, end_date)`, `assignment(project_id, employee_number, hours_worked)`.

Work through each question, then click **▶ Show answer** to check yourself. Review the [notes](../01-notes/03-01-ddl-tables-and-datatypes.md) if you get stuck.

---

### &#128313; Q1. Write a statement that creates an `assignment` table with a composite primary key on `(project_id, employee_number)` and a `CHECK` constraint that `hours_worked` can never be negative.

<details>
<summary><strong>Show answer</strong></summary>

```sql
CREATE TABLE assignment (
    project_id       INTEGER      NOT NULL REFERENCES project(project_id),
    employee_number  INTEGER      NOT NULL REFERENCES employee(employee_number),
    hours_worked     NUMERIC(6,2) DEFAULT 0 CHECK (hours_worked >= 0),
    PRIMARY KEY (project_id, employee_number)
);
```

The `PRIMARY KEY (project_id, employee_number)` table constraint makes the *pair* unique — the same employee can appear on many projects, and the same project can have many employees, but each employee/project combination appears only once.
</details>

---

### &#10067; Q2. Write an `INSERT` statement that adds a new employee, Grace Lin, to InfoSystems, without listing every column in table order.

<details>
<summary><strong>Show answer</strong></summary>

```sql
INSERT INTO employee (first_name, last_name, department_name, email_address)
VALUES ('Grace', 'Lin', 'InfoSystems', 'Grace.Lin@WP.com');
```

Naming the column list explicitly means `position`, `supervisor`, and `office_phone` are simply left `NULL`, and the order you list columns in doesn't have to match the table's physical column order — it only has to match the order of the values.
</details>

---

### &#128313; Q3. Write a query that lists every project in the Finance department with `MaxHours` greater than 130, sorted by start date.

<details>
<summary><strong>Show answer</strong></summary>

```sql
SELECT project_name, max_hours, start_date
FROM project
WHERE department_name = 'Finance' AND max_hours > 130
ORDER BY start_date;
```
</details>

---

### &#10067; Q4. Write a query that lists all employees whose position code matches the pattern "OPS" followed by exactly one digit (e.g., `OPS1`, `OPS2`, but not `OPS10`).

<details>
<summary><strong>Show answer</strong></summary>

```sql
SELECT first_name, last_name, position
FROM employee
WHERE position LIKE 'OPS_';
```

`_` matches exactly one character, so `OPS_` matches `OPS1` and `OPS2` but not `OPS10` (which has an extra character) or `OPS` alone (which has none after the prefix).
</details>

---

### &#128313; Q5. Write a query that lists every employee's office phone, showing `'Not on file'` instead of a blank for anyone missing one.

<details>
<summary><strong>Show answer</strong></summary>

```sql
SELECT first_name, last_name, COALESCE(office_phone, 'Not on file') AS phone_display
FROM employee;
```

`COALESCE` returns the first non-`NULL` argument — here, the real phone number if one exists, otherwise the fallback text.
</details>

---

### &#10067; Q6. Write an inner join that lists each employee's first name, last name, and their department's office number.

<details>
<summary><strong>Show answer</strong></summary>

```sql
SELECT e.first_name, e.last_name, d.office_number
FROM employee e
JOIN department d ON e.department_name = d.department_name;
```
</details>

---

### &#128313; Q7. Write a query that finds every department that currently has **no projects**.

<details>
<summary><strong>Show answer</strong></summary>

```sql
SELECT d.department_name
FROM department d
LEFT OUTER JOIN project p ON d.department_name = p.department_name
WHERE p.department_name IS NULL;
```

This is the classic "find rows with no match" pattern: a `LEFT OUTER JOIN` keeps every department (even ones with zero projects, padded with `NULL`), and the `WHERE ... IS NULL` filter keeps only the padded rows — i.e., only the departments that matched nothing.
</details>

---

### &#10067; Q8. Write a self join that lists every employee alongside their supervisor's full name. Make sure the CEO (who has no supervisor) still appears in the results.

<details>
<summary><strong>Show answer</strong></summary>

```sql
SELECT worker.first_name AS employee_first, worker.last_name AS employee_last,
       boss.first_name   AS supervisor_first, boss.last_name AS supervisor_last
FROM employee worker
LEFT OUTER JOIN employee boss ON worker.supervisor = boss.employee_number;
```

The `LEFT OUTER JOIN` is required, not optional: the CEO has `supervisor = NULL`, and an `INNER JOIN` would silently drop her from the results because `NULL` never matches anything in the `ON` clause.
</details>

---

### &#128313; Q9. Write a query that lists each project's name alongside the total hours logged against it, using `assignment`.

<details>
<summary><strong>Show answer</strong></summary>

```sql
SELECT p.project_name, SUM(a.hours_worked) AS total_logged
FROM project p
JOIN assignment a ON p.project_id = a.project_id
GROUP BY p.project_name;
```

Every column in `SELECT` that isn't wrapped in an aggregate (`p.project_name`) must appear in `GROUP BY` — otherwise SQL wouldn't know which single value to display for a project with multiple assignment rows.
</details>

---

### &#10067; Q10. Extend Q9 so it only shows projects where total logged hours exceed 100.

<details>
<summary><strong>Show answer</strong></summary>

```sql
SELECT p.project_name, SUM(a.hours_worked) AS total_logged
FROM project p
JOIN assignment a ON p.project_id = a.project_id
GROUP BY p.project_name
HAVING SUM(a.hours_worked) > 100;
```

`HAVING` filters *groups* after aggregation; `WHERE` filters individual *rows* before grouping and cannot reference an aggregate function like `SUM(...)`.
</details>

---

### &#128313; Q11. Write a query using a subquery (not a join) that lists the names of employees who have at least one project assignment.

<details>
<summary><strong>Show answer</strong></summary>

```sql
SELECT first_name, last_name
FROM employee
WHERE employee_number IN (SELECT employee_number FROM assignment);
```

The inner query returns the list of employee numbers that appear in `assignment`; the outer query keeps only employees whose number is in that list. This subquery can only ever display columns from `employee` (the outer table) — it could not also show `hours_worked` from `assignment` the way a join could.
</details>

---

### &#10067; Q12. Write a query using `EXISTS` that lists every department that has at least one project.

<details>
<summary><strong>Show answer</strong></summary>

```sql
SELECT department_name
FROM department d
WHERE EXISTS (
    SELECT 1 FROM project p WHERE p.department_name = d.department_name
);
```

This is a correlated subquery — it references `d.department_name` from the outer query, so it effectively re-checks "does at least one project exist for *this* department" once per department row. `EXISTS` only cares whether the subquery returns any row at all, not what value that row contains.
</details>

---

[📚 All Exercises](README.md)  ·  **Next:** [Module 04 — Data Modeling & E-R Diagrams](04-exercise.md)

<!-- course-footer -->
---

<div align="center" markdown>

[All Exercises](README.md) &nbsp;|&nbsp; [Module 03 Notes](../01-notes/03-01-ddl-tables-and-datatypes.md) &nbsp;|&nbsp; <strong>Next:</strong> [04: Data Modeling &amp; E-R Diagrams — Exercises](04-exercise.md)

</div>
<!-- /course-footer -->
