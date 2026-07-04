# &#128216; 08-01: ALTER, MERGE & Views

<!-- course-header -->
<div align="center" markdown>

![SQL & Databases](../assets/banner.svg)

<img src="https://img.shields.io/badge/Module_08-Advanced_SQL-336791?style=for-the-badge&labelColor=24506B" alt="Module 08: Advanced SQL">

[![Home](https://img.shields.io/badge/⌂_Home-1B2A35?style=flat-square)](../index.md) [![All Notes](https://img.shields.io/badge/All_Notes-1B2A35?style=flat-square)](README.md) [![Practice](https://img.shields.io/badge/✎_Practice-C6821E?style=flat-square&labelColor=24506B)](../02-exercises/08-exercise.md) [![Quiz](https://img.shields.io/badge/▶_Quiz-C6821E?style=flat-square&labelColor=24506B)](../03-quiz/)

</div>
<!-- /course-header -->

## &#128161; Databases Change After Day One

Module 03 covered `CREATE TABLE` as if a schema were designed once and never touched again. Real schemas evolve constantly: a new business rule shows up, a column needs a different type, an import process needs to insert-or-update in one step. This note covers three tools for exactly that: `ALTER TABLE` for changing structure, `MERGE`/upsert patterns for combining insert-and-update logic, and `CREATE VIEW` for packaging a query as if it were a table.

---

## &#128204; `ALTER TABLE`

`ALTER TABLE` modifies the structure of an existing table — its columns and its constraints — without recreating it or losing existing data.

### Adding a column

```sql
ALTER TABLE employee
    ADD COLUMN hire_date DATE;
```

If the new column must eventually be `NOT NULL`, you can't add that constraint directly on a table that already has rows — there's no value yet for the existing rows. The standard three-step pattern:

```sql
-- 1. Add the column allowing NULLs
ALTER TABLE employee
    ADD COLUMN approval_date DATE;

-- 2. Backfill every existing row with a real value
UPDATE employee
    SET approval_date = hire_date
    WHERE approval_date IS NULL;

-- 3. Now that every row has a value, enforce NOT NULL
ALTER TABLE employee
    ALTER COLUMN approval_date SET NOT NULL;
```

### Changing a column's type

```sql
ALTER TABLE employee
    ALTER COLUMN office_phone TYPE VARCHAR(20);
```

### Dropping a column

```sql
ALTER TABLE employee
    DROP COLUMN approval_date;
```

### Adding and dropping constraints

```sql
-- A CHECK constraint
ALTER TABLE project
    ADD CONSTRAINT check_project_dates CHECK (start_date < end_date);

-- A foreign key constraint added after the fact
ALTER TABLE employee
    ADD CONSTRAINT fk_employee_supervisor
        FOREIGN KEY (supervisor_id) REFERENCES employee(employee_number);

-- Removing a constraint by name
ALTER TABLE project
    DROP CONSTRAINT check_project_dates;
```

> [!NOTE]
> Syntax varies more than you'd expect. MySQL accepts (and historically favored) `MODIFY COLUMN office_phone VARCHAR(20)` instead of `ALTER COLUMN ... TYPE`. SQL Server uses `ALTER COLUMN office_phone VARCHAR(20)` with no separate `TYPE` keyword. The `ADD`/`DROP COLUMN` and `ADD`/`DROP CONSTRAINT` forms shown above are the most portable across PostgreSQL, MySQL, and SQL Server.

---

## &#128204; `MERGE` / Upsert — Insert-or-Update in One Statement

A common need: "if a row with this key already exists, update it; otherwise, insert it." Doing that as two separate statements (`SELECT` to check, then `INSERT` or `UPDATE`) is a race condition under concurrent access. Every major dialect has a dedicated way to do it atomically, but the syntax differs sharply.

### PostgreSQL: `INSERT ... ON CONFLICT`

```sql
INSERT INTO product_catalog (product_id, product_name, attributes)
VALUES (101, 'Wireless Mouse', '{"color": "black"}')
ON CONFLICT (product_id)
DO UPDATE SET product_name = EXCLUDED.product_name,
              attributes   = EXCLUDED.attributes;
```

`EXCLUDED` refers to the row that *would* have been inserted — that's how you reference the new incoming values inside the `DO UPDATE` clause.

### MySQL: `ON DUPLICATE KEY UPDATE`

```sql
INSERT INTO product_catalog (product_id, product_name, attributes)
VALUES (101, 'Wireless Mouse', '{"color": "black"}')
ON DUPLICATE KEY UPDATE
    product_name = VALUES(product_name),
    attributes   = VALUES(attributes);
```

### SQL Server / Oracle: `MERGE`

```sql
MERGE INTO product_catalog AS target
USING (SELECT 101 AS product_id, 'Wireless Mouse' AS product_name) AS source
ON target.product_id = source.product_id
WHEN MATCHED THEN
    UPDATE SET product_name = source.product_name
WHEN NOT MATCHED THEN
    INSERT (product_id, product_name) VALUES (source.product_id, source.product_name);
```

`MERGE` is the most general form of all three — it can drive its logic off a whole source table or query result (not just one row), and can add `WHEN MATCHED ... DELETE` clauses too.

> [!NOTE]
> MySQL has no `MERGE` statement — `ON DUPLICATE KEY UPDATE` is its closest equivalent, but it requires a unique/primary key to detect the conflict, same as Postgres's `ON CONFLICT`. Oracle and SQL Server both support standard `MERGE`.

---

## &#128204; `CREATE VIEW`

A **view** is a virtual table: it stores no data of its own, only a saved `SELECT` statement. Query the view like a table, and the database runs the underlying query behind the scenes every time.

```sql
CREATE VIEW employee_phone_view AS
    SELECT first_name, last_name, office_phone AS employee_phone
    FROM   employee;

SELECT * FROM employee_phone_view
ORDER BY last_name, first_name;
```

Views are useful for three main reasons:

1. **Hiding complexity** — a multi-table join gets written once, and everyone downstream just queries the view.
2. **Consistency** — every report using `employee_project_hours_view` sees the exact same join logic, instead of five slightly different hand-copied versions of the same query.
3. **Security** — a view can expose only certain columns/rows of a sensitive table, without granting access to the underlying table itself.

```sql
CREATE VIEW employee_project_hours_view AS
    SELECT p.project_name, e.first_name, e.last_name, a.hours_worked
    FROM   employee AS e
    JOIN   assignment AS a ON e.employee_number = a.employee_number
    JOIN   project AS p    ON a.project_id      = p.project_id;
```

### Updatable views

A view built from a **single table**, with no aggregation, `DISTINCT`, or `GROUP BY`, is usually **updatable** — you can `INSERT`/`UPDATE`/`DELETE` through it and PostgreSQL will translate the change onto the underlying table:

```sql
UPDATE employee_phone_view
    SET employee_phone = '555-0199'
    WHERE last_name = 'Nguyen';
```

A view that joins multiple tables or aggregates data (like `employee_project_hours_view` above) is generally **not** updatable directly — there's no single unambiguous underlying row to change. PostgreSQL supports `CREATE VIEW ... WITH CHECK OPTION` and `INSTEAD OF` triggers on views to define custom update behavior when you need it.

> [!TIP]
> Standard SQL doesn't allow an `ORDER BY` inside the view definition itself — sort order belongs to the query that *uses* the view, not the view. If you always want a view's results in a certain order, add the `ORDER BY` to the `SELECT` that queries the view, not to the `CREATE VIEW` statement.

---

See also: [Outer Joins & Correlated Subqueries](08-02-outer-joins-and-correlated-subqueries.md), [DDL: Tables & Data Types](03-01-ddl-tables-and-datatypes.md)

<!-- course-footer -->
---

<div align="center" markdown>

[All Notes](README.md) &nbsp;|&nbsp; [Module 08 Exercise](../02-exercises/08-exercise.md) &nbsp;|&nbsp; <strong>Next:</strong> [Outer Joins & Correlated Subqueries](08-02-outer-joins-and-correlated-subqueries.md)

</div>
<!-- /course-footer -->
