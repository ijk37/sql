# &#128216; 03-01: DDL — Tables & Data Types

<!-- course-header -->
<div align="center" markdown>

![SQL & Databases](../assets/banner.svg)

<img src="https://img.shields.io/badge/Module_03-SQL_Fundamentals-336791?style=for-the-badge&labelColor=24506B" alt="Module 03: SQL Fundamentals">

[![Home](https://img.shields.io/badge/⌂_Home-1B2A35?style=flat-square)](../index.md) [![All Notes](https://img.shields.io/badge/All_Notes-1B2A35?style=flat-square)](README.md) [![Practice](https://img.shields.io/badge/✎_Practice-C6821E?style=flat-square&labelColor=24506B)](../02-exercises/03-exercise.md) [![Quiz](https://img.shields.io/badge/▶_Quiz-C6821E?style=flat-square&labelColor=24506B)](../03-quiz/)

</div>
<!-- /course-header -->

## &#128161; SQL Is a Sublanguage, Not a Whole Language

SQL (Structured Query Language) isn't a general-purpose programming language — it's a **data sublanguage**: a focused set of statements for defining, populating, and querying database structures. Its statements fall into a few categories:

| Category | Purpose | Example statements |
|---|---|---|
| **DDL** — Data Definition Language | Create/modify/remove structures | `CREATE`, `ALTER`, `DROP`, `TRUNCATE` |
| **DML** — Data Manipulation Language | Query and change data | `SELECT`, `INSERT`, `UPDATE`, `DELETE` |
| **DCL** — Data Control Language | Grant/revoke permissions | `GRANT`, `REVOKE` |
| **TCL** — Transaction Control Language | Mark transaction boundaries | `COMMIT`, `ROLLBACK` |

This note covers **DDL** — the statements that build the tables everything else runs against. All examples run in **PostgreSQL**; differences in MySQL and SQL Server are called out where they matter.

---

## &#128204; The Running Example: Wedgewood Pacific

Throughout Module 03 we'll build and query the same small schema: **Wedgewood Pacific (WP)**, a drone manufacturer with four related tables — `department`, `employee`, `project`, and `assignment`. You'll stand this schema up yourself in the [Module 03 project](../04-projects/03-sql-querying-and-joins/README.md); for now, we build it piece by piece to learn the syntax.

```sql
CREATE TABLE department (
    department_name  VARCHAR(35)  PRIMARY KEY,
    budget_code       VARCHAR(30)  NOT NULL,
    office_number     VARCHAR(15)  NOT NULL,
    department_phone  VARCHAR(12)  NOT NULL
);
```

> [!NOTE]
> The textbook's WP schema uses `DepartmentName` as the primary key of `DEPARTMENT`. That works, but it's a design smell: names can change, and a natural-language string makes a clumsy join key. A surrogate `department_id` would be sturdier — we call this out again in Module 05 when we cover key selection. We keep `department_name` as the PK here only to match the source material you'll see in exercises and quizzes.

---

## &#128204; CREATE TABLE — Full Syntax

```sql
CREATE TABLE employee (
    employee_number  SERIAL       PRIMARY KEY,
    first_name       VARCHAR(25)  NOT NULL,
    last_name        VARCHAR(25)  NOT NULL,
    department_name  VARCHAR(35)  NOT NULL REFERENCES department(department_name),
    position         VARCHAR(35),
    supervisor       INTEGER      REFERENCES employee(employee_number),
    office_phone     VARCHAR(12),
    email_address    VARCHAR(100) NOT NULL UNIQUE
);
```

Notice a few things happening here:

- `SERIAL` auto-generates a surrogate primary key (`1, 2, 3, ...`) — this is what the textbook calls an "AutoNumber" column in Access.
- `supervisor REFERENCES employee(employee_number)` is a **self-referencing foreign key** — an employee's supervisor is another row in the same table. This models the reporting hierarchy and is revisited in [Joins](03-04-joins.md) as a self join.
- Column constraints (`NOT NULL`, `UNIQUE`, `REFERENCES`) can be written inline, or pulled out as **table constraints** at the bottom of the statement — useful for composite keys:

```sql
CREATE TABLE project (
    project_id       INTEGER      PRIMARY KEY,
    project_name     VARCHAR(50)  NOT NULL,
    department_name  VARCHAR(35)  NOT NULL,
    max_hours        NUMERIC(6,2) NOT NULL,
    start_date       DATE,
    end_date         DATE,
    CONSTRAINT fk_project_department
        FOREIGN KEY (department_name) REFERENCES department(department_name)
);

CREATE TABLE assignment (
    project_id       INTEGER      NOT NULL REFERENCES project(project_id),
    employee_number  INTEGER      NOT NULL REFERENCES employee(employee_number),
    hours_worked     NUMERIC(6,2) DEFAULT 0,
    CONSTRAINT pk_assignment PRIMARY KEY (project_id, employee_number)
);
```

`assignment` has a **composite primary key** — `(project_id, employee_number)` together, not either column alone — because the same employee can appear on many projects and the same project can have many employees, but each employee/project *pairing* should appear only once. This is the intersection table for a many-to-many relationship, which you'll see formalized in [Relationship Types](04-03-relationship-types.md).

---

## &#128204; Constraints Reference

| Constraint | Meaning |
|---|---|
| `NOT NULL` | Column must always have a value |
| `UNIQUE` | No two rows may share the same value in this column |
| `PRIMARY KEY` | Uniquely identifies each row; implies `NOT NULL` + `UNIQUE` |
| `FOREIGN KEY ... REFERENCES` | Value must exist as a primary key value in the referenced table |
| `CHECK (condition)` | Value must satisfy a boolean expression |
| `DEFAULT value` | Value used automatically when none is supplied on `INSERT` |

`CHECK` constraints enforce business rules directly in the schema:

```sql
CREATE TABLE assignment (
    project_id       INTEGER      NOT NULL REFERENCES project(project_id),
    employee_number  INTEGER      NOT NULL REFERENCES employee(employee_number),
    hours_worked     NUMERIC(6,2) DEFAULT 0 CHECK (hours_worked >= 0),
    PRIMARY KEY (project_id, employee_number)
);
```

That `CHECK` rejects any attempt to insert negative hours — the database refuses bad data instead of trusting every application that ever writes to it.

---

## &#128204; PostgreSQL Data Types

| Type | Stores | Typical use |
|---|---|---|
| `INTEGER` | Whole numbers (~-2B to 2B) | Counts, IDs, foreign keys |
| `NUMERIC(p,s)` | Exact fixed-point decimal, `p` total digits, `s` after the decimal | Money, hours worked — anywhere rounding errors are unacceptable |
| `VARCHAR(n)` | Variable-length text, up to `n` characters | Names, codes, short text |
| `TEXT` | Variable-length text, no length limit | Descriptions, notes, long free text |
| `DATE` | Calendar date (no time) | Start dates, birthdates |
| `TIMESTAMP` | Date + time (optionally with time zone via `TIMESTAMPTZ`) | Created-at/updated-at, event logging |
| `BOOLEAN` | `TRUE` / `FALSE` / `NULL` | Flags — `is_active`, `is_completed` |
| `JSONB` | Binary-parsed JSON document | Semi-structured data, flexible attributes |

> [!NOTE]
> **Cross-database type names differ.** The concepts are universal; the keywords are not.
>
> | Concept | PostgreSQL | MySQL | SQL Server |
> |---|---|---|---|
> | Auto-incrementing integer | `SERIAL` / `GENERATED ALWAYS AS IDENTITY` | `INT AUTO_INCREMENT` | `INT IDENTITY(1,1)` |
> | Variable text | `VARCHAR(n)` | `VARCHAR(n)` | `VARCHAR(n)` / `NVARCHAR(n)` (Unicode) |
> | Unlimited text | `TEXT` | `TEXT` | `VARCHAR(MAX)` |
> | Exact decimal | `NUMERIC(p,s)` | `DECIMAL(p,s)` | `DECIMAL(p,s)` |
> | Date + time | `TIMESTAMP` | `DATETIME` | `DATETIME2` |
> | Boolean | `BOOLEAN` | `TINYINT(1)` (no native boolean) | `BIT` |
> | JSON document | `JSONB` (binary, indexable) | `JSON` | `NVARCHAR` + `JSON` functions (no native JSON type before SQL Server 2025) |

`JSONB` is a genuinely useful PostgreSQL feature: it lets you store a flexible, semi-structured document (like a product's variable attributes) alongside your strict relational columns, and still index and query into it with operators like `->` and `->>`.

---

## &#128204; ALTER TABLE

Schemas evolve. `ALTER TABLE` changes an existing table's structure without dropping it:

```sql
-- Add a column
ALTER TABLE employee ADD COLUMN hire_date DATE;

-- Change a column's type
ALTER TABLE employee ALTER COLUMN office_phone TYPE VARCHAR(20);

-- Add a constraint after the fact
ALTER TABLE employee ADD CONSTRAINT chk_position CHECK (position <> '');

-- Drop a column
ALTER TABLE employee DROP COLUMN office_phone;

-- Rename a column
ALTER TABLE employee RENAME COLUMN position TO job_title;
```

---

## &#128204; DROP TABLE and TRUNCATE TABLE

```sql
-- Removes the table structure AND all its data — irreversible
DROP TABLE assignment;

-- Removes all rows but keeps the table structure intact
TRUNCATE TABLE assignment;
```

`DROP TABLE` fails if another table has a foreign key pointing at it, unless you cascade the drop:

```sql
DROP TABLE department CASCADE;
```

> [!TIP]
> `DROP TABLE ... CASCADE` will silently drop every dependent object (foreign keys, views) too. Always know what references a table before you cascade-drop it — in production, prefer explicitly dropping dependents one at a time so nothing unexpected disappears.

---

See also: [DML: Insert, Update, Delete](03-02-dml-insert-update-delete.md), [Keys](02-03-keys.md)

<!-- course-footer -->
---

<div align="center" markdown>

[All Notes](README.md) &nbsp;|&nbsp; [Module 03 Exercise](../02-exercises/03-exercise.md) &nbsp;|&nbsp; <strong>Next:</strong> [DML: Insert, Update, Delete](03-02-dml-insert-update-delete.md)

</div>
<!-- /course-footer -->
