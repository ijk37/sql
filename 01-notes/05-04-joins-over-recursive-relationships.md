# &#128216; 05-04: Joins over Recursive Relationships

<!-- course-header -->
<div align="center" markdown>

![SQL & Databases](../assets/banner.svg)

<img src="https://img.shields.io/badge/Module_05-DB_Design_Normalization-336791?style=for-the-badge&labelColor=24506B" alt="Module 05: Database Design & Normalization">

[![Home](https://img.shields.io/badge/⌂_Home-1B2A35?style=flat-square)](../index.md) [![All Notes](https://img.shields.io/badge/All_Notes-1B2A35?style=flat-square)](README.md) [![Practice](https://img.shields.io/badge/✎_Practice-C6821E?style=flat-square&labelColor=24506B)](../02-exercises/05-exercise.md) [![Quiz](https://img.shields.io/badge/▶_Quiz-C6821E?style=flat-square&labelColor=24506B)](../03-quiz/)

</div>
<!-- /course-header -->

## &#128161; A Relationship With Itself

A **recursive relationship** (also called a *unary* relationship) connects instances of the *same* entity to each other, rather than to a different entity. "Employee supervises employee" is the classic example — a supervisor is just another row in the same `EMPLOYEE` table, not a separate `SUPERVISOR` table.

Like any other relationship, recursive ones can be 1:1, 1:N, or N:M, and they're represented using the same rules from [05-01](05-01-transforming-er-to-tables.md) — the only twist is that the foreign key references the *same* table it lives in.

---

## &#128204; 1:N Recursive — The Supervisor Chain

Each employee has **at most one** supervisor, but a supervisor can oversee **many** employees. That's a 1:N recursive relationship, solved exactly like any 1:N: a foreign key on the "many" side, pointing back at the table's own primary key.

```sql
CREATE TABLE employee (
    employee_number INTEGER PRIMARY KEY,
    first_name      VARCHAR(25) NOT NULL,
    last_name       VARCHAR(25) NOT NULL,
    supervisor_id   INTEGER REFERENCES employee(employee_number)
);
```

To list every employee alongside their supervisor's name, you need a **self-join**: the table joined to itself, distinguished with two aliases.

```sql
SELECT
    e.employee_number,
    e.first_name  AS employee_first,
    e.last_name   AS employee_last,
    s.first_name  AS supervisor_first,
    s.last_name   AS supervisor_last
FROM employee AS e
LEFT JOIN employee AS s
    ON e.supervisor_id = s.employee_number
ORDER BY e.last_name;
```

The `LEFT JOIN` matters here: without it, the company president (whose `supervisor_id` is `NULL`) would be silently dropped from the results, because an inner join has nothing to match against on the right side.

---

## &#128204; 1:1 Recursive

A 1:1 recursive relationship works the same way, just with a `UNIQUE` constraint added so no employee can be the "partner" of more than one other row. A "mentor pairs one-to-one with mentee" relationship is a reasonable example:

```sql
CREATE TABLE employee (
    employee_number INTEGER PRIMARY KEY,
    first_name      VARCHAR(25) NOT NULL,
    last_name       VARCHAR(25) NOT NULL,
    mentee_of       INTEGER UNIQUE REFERENCES employee(employee_number)
);
```

---

## &#128204; N:M Recursive — Peer Relationships

When the relationship is many-to-many with itself — for example, "employee collaborates with employee" on shared projects, where collaboration is mutual and unrestricted — you need an intersection table, just as with any N:M relationship, except both foreign keys point at the same parent table.

```sql
CREATE TABLE employee_collaboration (
    employee_number     INTEGER NOT NULL REFERENCES employee(employee_number),
    collaborator_number INTEGER NOT NULL REFERENCES employee(employee_number),
    PRIMARY KEY (employee_number, collaborator_number),
    CHECK (employee_number <> collaborator_number)
);
```

The `CHECK` constraint prevents the nonsensical case of an employee "collaborating" with themselves.

---

## &#128204; A Recursive-CTE Teaser: Walking the Whole Chain

A single self-join gets you one level up the supervisor chain — Alice's supervisor. But what if you need Alice's supervisor's supervisor, and *their* supervisor, all the way to the top? Stacking self-joins works for a fixed, known depth, but breaks down when the org chart could be 3 levels deep or 8.

PostgreSQL (and the SQL standard) solves this with a **recursive common table expression**, `WITH RECURSIVE`:

```sql
WITH RECURSIVE management_chain AS (
    -- anchor: start at one employee
    SELECT employee_number, first_name, last_name, supervisor_id, 1 AS depth
    FROM employee
    WHERE employee_number = 205

    UNION ALL

    -- recursive step: walk up to each row's supervisor
    SELECT e.employee_number, e.first_name, e.last_name, e.supervisor_id, mc.depth + 1
    FROM employee e
    JOIN management_chain mc
        ON e.employee_number = mc.supervisor_id
)
SELECT * FROM management_chain ORDER BY depth;
```

The query starts at one employee (the *anchor*), then repeatedly joins back to `employee` to find each row's supervisor, stacking new rows onto `management_chain` until it reaches someone with no supervisor (`supervisor_id IS NULL`), at which point the recursive step stops producing matches and the query ends.

> [!NOTE]
> This is only a preview. Recursive CTEs — including how to detect and guard against infinite loops with a depth limit, and how to walk *downward* through a hierarchy instead of upward — get full treatment in [Module 08](08-03-recursive-queries-and-set-operators.md).

> [!TIP]
> Rule of thumb: use a plain **self-join** when you know exactly how many levels you need (e.g., "just show me each employee's direct supervisor"). Reach for a **recursive CTE** the moment "how many levels" becomes "as many as it takes."

---

See also: [Normalization](05-03-normalization.md), [Recursive Queries & Set Operators](08-03-recursive-queries-and-set-operators.md)

<!-- course-footer -->
---

<div align="center" markdown>

[All Notes](README.md) &nbsp;|&nbsp; [Module 05 Exercise](../02-exercises/05-exercise.md) &nbsp;|&nbsp; <strong>Next:</strong> [DBA Roles & Responsibilities](06-01-dba-roles.md)

</div>
<!-- /course-footer -->
