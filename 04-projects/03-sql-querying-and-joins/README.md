# &#128736; Project 03 — SQL Querying & Joins

<!-- course-header -->
<div align="center" markdown>

![SQL & Databases](../../assets/banner.svg)

[![View the live site — ijk37.com](https://img.shields.io/badge/%F0%9F%87%A7%F0%9F%87%A9_View_the_Live_Site-IJK37.COM-F42A41?style=for-the-badge&labelColor=006A4E)](https://ijk37.com/sql/)

<img src="https://img.shields.io/badge/Project_03-SQL_Querying_and_Joins-336791?style=for-the-badge&labelColor=24506B" alt="Project 03: SQL Querying and Joins">

[![Home](https://img.shields.io/badge/⌂_Home-1B2A35?style=flat-square)](../../index.md) [![All Projects](https://img.shields.io/badge/All_Projects-1B2A35?style=flat-square)](../README.md) [![Notes](https://img.shields.io/badge/Notes-1B2A35?style=flat-square)](../../01-notes/03-01-ddl-tables-and-datatypes.md) [![Quiz](https://img.shields.io/badge/▶_Quiz-C6821E?style=flat-square&labelColor=24506B)](../../03-quiz/)

</div>
<!-- /course-header -->

**Type:** Query lab (PostgreSQL)
**Modules:** 03 (SQL Fundamentals)
**Difficulty:** ⭐⭐⭐

---

## &#127919; Objective

Stand up the **Wedgewood Pacific (WP)** sample database in PostgreSQL, then write a set of `SELECT` queries — filters, joins, subqueries, and aggregates — that answer specific business questions a manager might actually ask.

---

## &#129517; Scenario

Wedgewood Pacific designs and manufactures consumer drone aircraft, organized into nine departments. Management wants a handful of everyday questions answered directly from the database instead of by hand-counting spreadsheets: who's assigned to what, which projects are behind on staffing, and how hours are distributed across the company.

---

## &#128204; Set Up the Schema

Run this script first to create the four tables and load a working sample of data.

```sql
CREATE TABLE department (
    department_name  VARCHAR(35)  PRIMARY KEY,
    budget_code       VARCHAR(30)  NOT NULL,
    office_number     VARCHAR(15)  NOT NULL,
    department_phone  VARCHAR(12)  NOT NULL
);

CREATE TABLE employee (
    employee_number  SERIAL       PRIMARY KEY,
    first_name       VARCHAR(25)  NOT NULL,
    last_name         VARCHAR(25)  NOT NULL,
    department_name   VARCHAR(35)  NOT NULL REFERENCES department(department_name),
    position          VARCHAR(35),
    supervisor        INTEGER      REFERENCES employee(employee_number),
    office_phone      VARCHAR(12),
    email_address     VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE project (
    project_id       INTEGER      PRIMARY KEY,
    project_name     VARCHAR(50)  NOT NULL,
    department_name  VARCHAR(35)  NOT NULL REFERENCES department(department_name),
    max_hours        NUMERIC(6,2) NOT NULL,
    start_date       DATE,
    end_date         DATE
);

CREATE TABLE assignment (
    project_id       INTEGER      NOT NULL REFERENCES project(project_id),
    employee_number  INTEGER      NOT NULL REFERENCES employee(employee_number),
    hours_worked     NUMERIC(6,2) DEFAULT 0 CHECK (hours_worked >= 0),
    PRIMARY KEY (project_id, employee_number)
);
```

```sql
INSERT INTO department (department_name, budget_code, office_number, department_phone) VALUES
    ('Administration', 'BC-100-10', 'BLDG01-210', '360-285-8100'),
    ('Finance',        'BC-400-10', 'BLDG01-110', '360-285-8400'),
    ('Accounting',     'BC-500-10', 'BLDG01-120', '360-285-8405'),
    ('Sales and Marketing', 'BC-600-10', 'BLDG01-250', '360-285-8500'),
    ('InfoSystems',    'BC-700-10', 'BLDG02-210', '360-285-8600'),
    ('Production',     'BC-900-10', 'BLDG02-110', '360-285-8800');

-- Order matters: employees reference department, and supervisor references employee itself,
-- so insert managers first with a NULL supervisor, then their reports.
INSERT INTO employee (first_name, last_name, department_name, position, supervisor, office_phone, email_address) VALUES
    ('Mary',  'Jacobs',  'Administration', 'CEO', NULL, '360-285-8110', 'Mary.Jacobs@WP.com'),
    ('Ken',   'Evans',   'Finance', 'CFO', 1, '360-285-8410', 'Ken.Evans@WP.com'),
    ('Mary',  'Abernathy','Finance', 'FA3', 2, '360-285-8420', 'Mary.Abernathy@WP.com'),
    ('Tom',   'Caruthers','Accounting', 'FA2', 2, '360-285-8430', 'Tom.Caruthers@WP.com'),
    ('Ken',   'Numoto',  'Sales and Marketing', 'SM3', 1, '360-285-8510', 'Ken.Numoto@WP.com'),
    ('Linda', 'Granger', 'Sales and Marketing', 'SM2', 5, '360-285-8520', 'Linda.Granger@WP.com'),
    ('James', 'Nestor',  'InfoSystems', 'CIO', 1, '360-285-8610', 'James.Nestor@WP.com'),
    ('Mary',  'Smith',   'Production', 'OPS3', 1, '360-285-8810', 'Mary.Smith@WP.com'),
    ('Tom',   'Jackson', 'Production', 'OPS2', 8, '360-285-8820', 'Tom.Jackson@WP.com'),
    ('Julia', 'Hayakawa','Production', 'OPS1', 9, NULL, 'Julia.Hayakawa@WP.com');

INSERT INTO project (project_id, project_name, department_name, max_hours, start_date, end_date) VALUES
    (1000, '2019 Q3 Production Plan', 'Production', 100.00, '2019-05-10', '2019-06-15'),
    (1100, '2019 Q3 Marketing Plan',  'Sales and Marketing', 135.00, '2019-05-10', '2019-06-15'),
    (1200, '2019 Q3 Portfolio Analysis', 'Finance', 120.00, '2019-07-05', '2019-07-25'),
    (1300, '2019 Q3 Tax Preparation', 'Accounting', 145.00, '2019-08-10', '2019-10-15'),
    (1600, '2019 Q4 Portfolio Analysis', 'Finance', 140.00, '2019-10-05', NULL);

INSERT INTO assignment (project_id, employee_number, hours_worked) VALUES
    (1000, 1, 30.00), (1000, 8, 75.00), (1000, 9, 75.00),
    (1100, 1, 30.00), (1100, 5, 75.00), (1100, 6, 40.00),
    (1200, 2, 50.00), (1200, 3, 50.00),
    (1300, 4, 60.00);
```

Notice: `project_id = 1400` and `1500` from the textbook's full dataset are intentionally left out of this seed script, and employee #7 (James Nestor) and #10 (Julia Hayakawa) are intentionally left without any `assignment` rows — you'll need both gaps for the queries below.

---

## &#128204; Tasks — Write Queries to Answer These Questions

Write and run each query against the schema above. Check your work against the [Verification Checklist](#verification-checklist).

1. List every employee's first name, last name, and department, sorted by department then last name.
2. List all projects belonging to the Finance department with `max_hours` greater than 130.
3. List every employee whose email address ends in `@WP.com` and whose position starts with `'FA'` (use `LIKE`).
4. Using an inner join, list each project's name alongside the department's office number.
5. Find every employee who has **not** been assigned to any project (an outer-join "no match" query).
6. Find every project that currently has **no one assigned to it**.
7. Using a self join, list each employee alongside their supervisor's name — make sure Mary Jacobs (the CEO, who has no supervisor) still appears in the results.
8. For each project, compute total hours logged (`SUM`) and the number of distinct employees assigned (`COUNT`), sorted by total hours descending.
9. Using a subquery with `IN`, list the names of employees who have at least one assignment.
10. Using `EXISTS`, list every department that has at least one project on record.

---

## &#9989; Verification Checklist

- [ ] Q1's sort groups all employees from the same department together, ordered by last name within each department.
- [ ] Q5 correctly returns James Nestor and Julia Hayakawa (both unassigned in the seed data) and no one else.
- [ ] Q6 correctly returns exactly the projects with `project_id` not present in `assignment` in your seed data.
- [ ] Q7 includes Mary Jacobs with `NULL` supervisor columns — not silently dropped.
- [ ] Q8's `SUM`/`COUNT` numbers match what you'd get by manually adding up the `assignment` rows for each project.
- [ ] Q9 and Q10 each run without referencing any column from the "other" table in the outer `SELECT` — a reminder that a subquery can only display columns from its outer table.

---

## &#128230; Deliverables

- A single `.sql` script containing the schema + seed data (from above) and all 10 queries, each preceded by a comment naming which task it answers.
- The result set (as text, screenshot, or exported CSV) for queries 5, 6, and 8 specifically — these three are the ones most worth double-checking by hand.

---

## &#128640; Stretch Goals

- Rewrite queries 5 and 6 using `NOT EXISTS` instead of `LEFT OUTER JOIN ... IS NULL`, and confirm you get the same rows.
- Add a `department` with zero employees and zero projects, then confirm a `FULL OUTER JOIN` between `department` and `project` surfaces it correctly.
- Extend Q8 with a `HAVING` clause that only shows projects logging more than 50 total hours.

See also notes: [Joins](../../01-notes/03-04-joins.md), [Subqueries & Aggregation](../../01-notes/03-05-subqueries-and-aggregation.md)

<!-- course-footer -->
---

<div align="center" markdown>

[All Projects](../README.md) &nbsp;|&nbsp; [Module 03 Notes](../../01-notes/03-01-ddl-tables-and-datatypes.md) &nbsp;|&nbsp; <strong>Next:</strong> [Project 04 — Full ER Diagram Design](../04-full-er-diagram-design/README.md)

</div>
<!-- /course-footer -->
