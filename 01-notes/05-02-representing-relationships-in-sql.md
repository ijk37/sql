# &#128216; 05-02: Representing Relationships in SQL

<!-- course-header -->
<div align="center" markdown>

![SQL & Databases](../assets/banner.svg)

<img src="https://img.shields.io/badge/Module_05-DB_Design_Normalization-336791?style=for-the-badge&labelColor=24506B" alt="Module 05: Database Design & Normalization">

[![Home](https://img.shields.io/badge/⌂_Home-1B2A35?style=flat-square)](../index.md) [![All Notes](https://img.shields.io/badge/All_Notes-1B2A35?style=flat-square)](README.md) [![Practice](https://img.shields.io/badge/✎_Practice-C6821E?style=flat-square&labelColor=24506B)](../02-exercises/05-exercise.md) [![Quiz](https://img.shields.io/badge/▶_Quiz-C6821E?style=flat-square&labelColor=24506B)](../03-quiz/)

</div>
<!-- /course-header -->

## &#128161; From Rule to `CREATE TABLE`

The [previous note](05-01-transforming-er-to-tables.md) covered *which side* gets the foreign key. This note covers the actual SQL: the `FOREIGN KEY` / `REFERENCES` syntax, and — just as important — what should happen when a referenced row is updated or deleted.

Every foreign key needs an answer to two questions:

- **`ON UPDATE`** — what happens to the child row if the parent's key value changes?
- **`ON DELETE`** — what happens to the child row if the parent row is deleted?

PostgreSQL supports four actions for each: `CASCADE`, `RESTRICT`, `SET NULL`, and `SET DEFAULT` (plus the implicit default, `NO ACTION`).

| Action | Effect |
|---|---|
| `CASCADE` | Propagate the change/delete to the child row automatically |
| `RESTRICT` | Refuse the change/delete outright while children exist |
| `SET NULL` | Null out the child's foreign key column |
| `SET DEFAULT` | Reset the child's foreign key column to its default value |

---

## &#128204; 1:N Relationships

The department–employee relationship is a textbook 1:N. What should happen if a department is deleted while employees still reference it? Deleting the employees along with it (`CASCADE`) is rarely what a business wants — you'd erase employee history. `RESTRICT` is usually the safer choice: it forces you to reassign or remove employees *first*.

```sql
CREATE TABLE department (
    department_id   SERIAL PRIMARY KEY,
    department_name VARCHAR(35) NOT NULL UNIQUE,
    budget_code     CHAR(5) NOT NULL
);

CREATE TABLE employee (
    employee_number INTEGER PRIMARY KEY,
    first_name      VARCHAR(25) NOT NULL,
    last_name       VARCHAR(25) NOT NULL,
    department_id   INTEGER,
    CONSTRAINT fk_employee_department
        FOREIGN KEY (department_id)
        REFERENCES department(department_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
);
```

`ON UPDATE CASCADE` is safe here — if a department's surrogate key ever changed (unusual for a `SERIAL`, but common if the key were a natural code), every employee row would follow automatically. `ON DELETE RESTRICT` protects historical employee data from silently disappearing.

A case where `SET NULL` fits better: a `PROJECT` optionally has a `department_id` describing which department sponsors it, but a project can outlive a department reorg.

```sql
CREATE TABLE project (
    project_id    SERIAL PRIMARY KEY,
    project_name  VARCHAR(100) NOT NULL,
    department_id INTEGER REFERENCES department(department_id)
        ON DELETE SET NULL,
    max_hours     NUMERIC(6, 2),
    start_date    DATE,
    end_date      DATE
);
```

---

## &#128204; N:M Relationships

The intersection table's two foreign keys almost always want `CASCADE` on delete: if an employee record or a project record is removed, the *assignment rows that only exist to connect them* should go too — there's no meaningful assignment left to keep.

```sql
CREATE TABLE assignment (
    project_id      INTEGER NOT NULL,
    employee_number INTEGER NOT NULL,
    hours_worked    NUMERIC(6, 2) DEFAULT 0,
    PRIMARY KEY (project_id, employee_number),
    FOREIGN KEY (project_id)
        REFERENCES project(project_id)
        ON DELETE CASCADE,
    FOREIGN KEY (employee_number)
        REFERENCES employee(employee_number)
        ON DELETE CASCADE
);
```

Deleting a project now automatically clears out its `assignment` rows — but leaves `employee` and every other project untouched.

---

## &#128204; 1:1 Relationships

For a strict 1:1, add a `UNIQUE` constraint on the foreign key column so the database itself enforces "at most one child per parent."

```sql
CREATE TABLE customer (
    customer_id   SERIAL PRIMARY KEY,
    customer_name VARCHAR(100) NOT NULL
);

CREATE TABLE contact (
    contact_id   SERIAL PRIMARY KEY,
    customer_id  INTEGER NOT NULL UNIQUE,
    contact_name VARCHAR(100) NOT NULL,
    phone        CHAR(12),
    FOREIGN KEY (customer_id)
        REFERENCES customer(customer_id)
        ON DELETE CASCADE
);
```

Here `CASCADE` makes sense: a `contact` row has no purpose once its `customer` is gone.

---

## &#128204; Weak Entities

Weak, ID-dependent entities should almost always cascade on delete — the child literally cannot exist without the parent, so there's nothing to preserve.

```sql
CREATE TABLE charter (
    charter_id SERIAL PRIMARY KEY,
    departure_date DATE NOT NULL,
    return_date    DATE NOT NULL
);

CREATE TABLE log (
    charter_id   INTEGER NOT NULL,
    entry_number INTEGER NOT NULL,
    entry_date   DATE NOT NULL,
    entry_location VARCHAR(50),
    PRIMARY KEY (charter_id, entry_number),
    FOREIGN KEY (charter_id)
        REFERENCES charter(charter_id)
        ON DELETE CASCADE
);
```

Cancel a charter, and its log entries — which only ever meant "log entry #3 of *that* charter" — disappear with it.

> [!NOTE]
> **Portability:** all of `CASCADE`, `RESTRICT`, and `SET NULL` are part of the SQL standard and work the same way in PostgreSQL, MySQL (InnoDB), and SQL Server. SQLite supports them too, but only if you explicitly run `PRAGMA foreign_keys = ON;` for each connection — foreign key *enforcement* is off by default in SQLite even though the syntax is accepted.

> [!TIP]
> A quick heuristic: if the child row's data is *meaningless without* the parent (a log entry, an assignment, a weak entity), lean toward `CASCADE`. If the child has an independent business life that should survive the parent's deletion being blocked or nulled out (an employee whose department was eliminated), lean toward `RESTRICT` or `SET NULL`.

---

See also: [Transforming E-R Models into Tables](05-01-transforming-er-to-tables.md), [Normalization](05-03-normalization.md)

<!-- course-footer -->
---

<div align="center" markdown>

[All Notes](README.md) &nbsp;|&nbsp; [Module 05 Exercise](../02-exercises/05-exercise.md) &nbsp;|&nbsp; <strong>Next:</strong> [Normalization](05-03-normalization.md)

</div>
<!-- /course-footer -->
