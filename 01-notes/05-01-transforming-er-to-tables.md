# &#128216; 05-01: Transforming E-R Models into Tables

<!-- course-header -->
<div align="center" markdown>

![SQL & Databases](../assets/banner.svg)

<img src="https://img.shields.io/badge/Module_05-DB_Design_Normalization-336791?style=for-the-badge&labelColor=24506B" alt="Module 05: Database Design & Normalization">

[![Home](https://img.shields.io/badge/⌂_Home-1B2A35?style=flat-square)](../index.md) [![All Notes](https://img.shields.io/badge/All_Notes-1B2A35?style=flat-square)](README.md) [![Practice](https://img.shields.io/badge/✎_Practice-C6821E?style=flat-square&labelColor=24506B)](../02-exercises/05-exercise.md) [![Quiz](https://img.shields.io/badge/▶_Quiz-C6821E?style=flat-square&labelColor=24506B)](../03-quiz/)

</div>
<!-- /course-header -->

## &#128161; From Diagram to Design

An E-R diagram is a *conceptual* model — it says what the business cares about and how those things relate. Before any of that can live inside PostgreSQL, it has to be turned into a *logical design*: an actual set of tables, columns, primary keys, and foreign keys. That translation step has a small number of mechanical rules, and once you know them, transforming even a large diagram is mostly bookkeeping.

We'll use a running example modeled on the **Wedgewood Pacific (WP)** company: departments employ people, employees work on projects, and time is logged against project assignments.

---

## &#128204; Rule 1 — Every Entity Becomes a Table

Each entity type in the E-R diagram becomes one table. Each instance of the entity (one specific department, one specific employee) becomes one row. The entity's identifier becomes the table's primary key.

```sql
CREATE TABLE department (
    department_id   SERIAL PRIMARY KEY,
    department_name VARCHAR(35) NOT NULL UNIQUE,
    budget_code     CHAR(5)     NOT NULL,
    office_number   CHAR(10),
    department_phone CHAR(12)
);
```

> [!NOTE]
> The original WP textbook schema uses `DepartmentName` itself as the primary key. That works, but it means every table that references a department stores a full text string as a foreign key, and renaming a department becomes an update-everywhere problem. Adding a surrogate `department_id` (as done above) is the more robust modern choice — this is a deliberate, common improvement over the textbook's design, not a deviation from the theory.

---

## &#128204; Rule 2 — Weak Entities Get the Parent's Key Too

A **weak entity** cannot be identified by its own attributes alone — it borrows (part of) its identity from a parent. If the weak entity is *ID-dependent*, its primary key must include the parent's primary key as a foreign key.

A `LOG` entry on a boat charter is a good example: an entry only makes sense in the context of one charter, and entry numbers restart at 1 for every charter.

```sql
CREATE TABLE log (
    charter_id     INTEGER NOT NULL REFERENCES charter(charter_id),
    entry_number   INTEGER NOT NULL,
    entry_date     DATE NOT NULL,
    entry_location VARCHAR(50),
    PRIMARY KEY (charter_id, entry_number)
);
```

If a weak entity is *not* ID-dependent (it just happens to require a parent to exist, without borrowing key attributes), treat it like a strong entity: give it its own surrogate key and a plain foreign key back to the parent.

---

## &#128204; Rule 3 — 1:N Relationships → Foreign Key on the "Many" Side

This is the single most common transformation you'll perform. In a 1:N relationship, the "1" side is the **parent**, the "N" side is the **child**, and the parent's primary key is copied into the child table as a foreign key.

One department employs many employees:

```sql
CREATE TABLE employee (
    employee_number INTEGER PRIMARY KEY,
    first_name      VARCHAR(25) NOT NULL,
    last_name       VARCHAR(25) NOT NULL,
    department_id   INTEGER REFERENCES department(department_id),
    position        VARCHAR(25),
    supervisor_id   INTEGER,
    office_phone    CHAR(12),
    email_address   VARCHAR(100)
);
```

`department_id` lives in `employee` (the many side), never the other way around. Putting the foreign key on the "1" side would force a single department row to somehow hold a *list* of employee numbers — something a single column can't do.

> [!TIP]
> When you're unsure which side is "many," ask: "can this thing have more than one of the other thing?" An employee belongs to exactly one department, but a department has many employees — so `employee` is the many side, and that's where `department_id` goes.

---

## &#128204; Rule 4 — N:M Relationships → a New Intersection Table

A many-to-many relationship can't be represented with a single foreign key in either table — an employee can work on many projects, and a project has many employees. The fix is to create a brand-new **intersection table** (also called an associative or junction table) whose primary key is the *combination* of both parents' keys.

```sql
CREATE TABLE assignment (
    project_id      INTEGER NOT NULL REFERENCES project(project_id),
    employee_number INTEGER NOT NULL REFERENCES employee(employee_number),
    hours_worked    NUMERIC(6, 2) DEFAULT 0,
    PRIMARY KEY (project_id, employee_number)
);
```

This is exactly the WP `ASSIGNMENT` table: it connects `PROJECT` and `EMPLOYEE`, and its composite primary key `(project_id, employee_number)` guarantees you can't record the same employee against the same project twice. Any attribute that describes the *relationship itself* (like hours worked) lives here, not in either parent table.

---

## &#128204; Rule 5 — 1:1 Relationships → Foreign Key on Either Side

For a strict one-to-one relationship, the foreign key can go in either table — it's a design choice, not a rule. Pick whichever side makes queries more natural, or merge the two tables entirely if every row on both sides always exists together.

A `CUSTOMER` and its single primary `CONTACT` record is a typical 1:1:

```sql
CREATE TABLE customer (
    customer_id   SERIAL PRIMARY KEY,
    customer_name VARCHAR(100) NOT NULL
);

CREATE TABLE contact (
    contact_id   SERIAL PRIMARY KEY,
    customer_id  INTEGER UNIQUE REFERENCES customer(customer_id),
    contact_name VARCHAR(100),
    phone        CHAR(12)
);
```

Note the `UNIQUE` constraint on `customer_id` in `contact` — without it, this would silently become a 1:N relationship, letting one customer have many contact rows.

---

## &#128204; Putting It Together

| E-R construct | Relational transformation |
|---|---|
| Entity | Table, identifier → primary key |
| Weak, ID-dependent entity | Table whose PK includes the parent's PK |
| 1:1 relationship | FK on either side (`UNIQUE` constraint), or merge tables |
| 1:N relationship | FK placed on the "many" (child) side |
| N:M relationship | New intersection table with a composite PK |

Once every entity and relationship has been run through these rules, the result is your **logical design** — a complete set of `CREATE TABLE` statements ready for a real DBMS, before you've spent a moment worrying about performance tuning or physical storage.

---

See also: [Representing Relationships in SQL](05-02-representing-relationships-in-sql.md), [Normalization](05-03-normalization.md)

<!-- course-footer -->
---

<div align="center" markdown>

[All Notes](README.md) &nbsp;|&nbsp; [Module 05 Exercise](../02-exercises/05-exercise.md) &nbsp;|&nbsp; <strong>Next:</strong> [Representing Relationships in SQL](05-02-representing-relationships-in-sql.md)

</div>
<!-- /course-footer -->
