# &#128216; 01-02: Relational Tables &amp; Database Systems

<!-- course-header -->
<div align="center" markdown>

![SQL & Databases](../assets/banner.svg)

<img src="https://img.shields.io/badge/Module_01-Getting_Started-336791?style=for-the-badge&labelColor=24506B" alt="Module 01: Getting Started">

[![Home](https://img.shields.io/badge/⌂_Home-1B2A35?style=flat-square)](../index.md) [![All Notes](https://img.shields.io/badge/All_Notes-1B2A35?style=flat-square)](README.md) [![Practice](https://img.shields.io/badge/✎_Practice-C6821E?style=flat-square&labelColor=24506B)](../02-exercises/01-exercise.md) [![Quiz](https://img.shields.io/badge/▶_Quiz-C6821E?style=flat-square&labelColor=24506B)](../03-quiz/)

</div>
<!-- /course-header -->

## &#128204; What Is a Relational Database?

A **relational database** is a collection of separate tables, each holding data about one theme, related to each other by shared columns. This module introduces the everyday vocabulary; Module 02 tightens it into formal terms.

- A **table** holds rows and columns of data about a single theme (customers, employees, projects).
- If a table is trying to describe two or more themes at once, it should be split into two or more tables (see [Why Databases?](01-01-why-databases.md)).

---

## &#128204; Everyday Terminology

| Everyday term | Meaning |
|---|---|
| **Table** | A named grid of data about one theme, e.g. `EMPLOYEE`. |
| **Column** / **field** | A characteristic shared by every row — e.g. `LastName`. |
| **Row** / **record** | One occurrence of the theme — e.g. all the data about one employee. |
| **Value** | A single piece of data in one cell, e.g. `"Chen"`. |

Consider a small slice of the Wedgewood Pacific (WP) company's `EMPLOYEE` table:

| EmployeeNumber | FirstName | LastName | Department | Position | EmailAddress |
|---|---|---|---|---|---|
| 1 | Mary | Jacobs | Administration | President | MJacobs@wp.com |
| 2 | Fred | Jones | Marketing | Manager | FJones@wp.com |
| 3 | Homer | Wells | Marketing | Salesperson | HWells@wp.com |

- The **table** is `EMPLOYEE`.
- `LastName` is a **column** (field).
- The row `(3, Homer, Wells, Marketing, Salesperson, HWells@wp.com)` is a **record**.
- `"Wells"` is a single **value**.

> [!NOTE]
> Naming convention used throughout this course (matching Kroenke's textbook): table names are written in `ALL_CAPS` and are singular (`EMPLOYEE`, not `Employees`). Column names are written in `PascalCase` (`FirstName`, `EmailAddress`). In actual PostgreSQL DDL, most teams use `snake_case` and lowercase table names instead — both are shown throughout this course so you can recognize either style.

---

## &#128204; The Four Components of a Database System

A **database system** is bigger than "the database" — it's four parts working together:

| Component | Role |
|---|---|
| **Users** | People who need the data — data entry staff, managers, analysts. |
| **Database application** | The forms, reports, and query screens users interact with (built with SQL, a web framework, a BI tool, etc.). |
| **DBMS** (Database Management System) | The engine that actually creates, stores, secures, and retrieves the data — e.g. PostgreSQL, MySQL, SQL Server. |
| **Database** | The self-describing collection of related tables that actually holds the data. |

The application never touches the stored files directly — it always goes through the DBMS, which handles concurrency, security, and consistency behind the scenes.

```sql
-- A tiny "database application" query, sent through the DBMS,
-- against the database:
SELECT first_name, last_name, email_address
FROM employee
WHERE department = 'Marketing'
ORDER BY last_name;
```

---

## &#128204; Metadata: Self-Describing Databases

A relational database is **self-describing** — the description of its own structure (its **metadata**) is stored inside the database itself, right alongside the data.

- **Data**: `Homer`, `Wells`, `Marketing`
- **Metadata**: "the `EMPLOYEE` table has a column named `LastName` of type `VARCHAR(50)`, which cannot be null"

You can query the metadata directly. In PostgreSQL, the system catalog `information_schema` exposes it as ordinary tables:

```sql
SELECT column_name, data_type, is_nullable
FROM information_schema.columns
WHERE table_name = 'employee'
ORDER BY ordinal_position;
```

This is what allows tools (query builders, ORMs, BI dashboards) to inspect a database and figure out its shape automatically, without a human describing it separately somewhere else.

---

## &#128204; Referential Integrity — A First Look

Once you have more than one table, you need a rule for how they stay consistent with each other. If `EMPLOYEE.Department` stores `'Marketing'`, that value needs to correspond to a real row in the `DEPARTMENT` table — otherwise you have an employee assigned to a department that doesn't exist.

A **referential integrity constraint** is a rule, enforced by the DBMS, that guarantees a value in one table's column must match an existing value in another table's column.

```sql
CREATE TABLE department (
    department_name VARCHAR(50) PRIMARY KEY,
    budget_code      VARCHAR(20)
);

CREATE TABLE employee (
    employee_number SERIAL PRIMARY KEY,
    first_name      VARCHAR(50),
    last_name       VARCHAR(50),
    department      VARCHAR(50) REFERENCES department(department_name)
);
```

With this constraint in place, trying to insert an employee into a department that doesn't exist yet fails immediately:

```sql
INSERT INTO employee (first_name, last_name, department)
VALUES ('Homer', 'Wells', 'Skunkworks');
-- ERROR: insert or update on table "employee" violates
-- foreign key constraint — no matching row in "department"
```

That's the DBMS protecting you from an inconsistent database instead of silently accepting bad data. Module 02 covers this in full as **foreign keys**.

> [!TIP]
> Referential integrity is the DBMS *refusing to let your data lie to you*. It's one of the biggest practical advantages a real relational database has over a spreadsheet — Excel will happily let you type a department that doesn't exist anywhere.

---

See also: [Why Databases?](01-01-why-databases.md), [The DBMS Landscape](01-03-dbms-landscape.md), [Keys](02-03-keys.md)

<!-- course-footer -->
---

<div align="center" markdown>

[All Notes](README.md) &nbsp;|&nbsp; [Module 01 Exercise](../02-exercises/01-exercise.md) &nbsp;|&nbsp; <strong>Next:</strong> [The DBMS Landscape](01-03-dbms-landscape.md)

</div>
<!-- /course-footer -->
