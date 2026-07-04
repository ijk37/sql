# &#128216; 02-02: Characteristics of Relations

<!-- course-header -->
<div align="center" markdown>

![SQL & Databases](../assets/banner.svg)

<img src="https://img.shields.io/badge/Module_02-Relational_Model-336791?style=for-the-badge&labelColor=24506B" alt="Module 02: The Relational Model">

[![Home](https://img.shields.io/badge/⌂_Home-1B2A35?style=flat-square)](../index.md) [![All Notes](https://img.shields.io/badge/All_Notes-1B2A35?style=flat-square)](README.md) [![Practice](https://img.shields.io/badge/✎_Practice-C6821E?style=flat-square&labelColor=24506B)](../02-exercises/02-exercise.md) [![Quiz](https://img.shields.io/badge/▶_Quiz-C6821E?style=flat-square&labelColor=24506B)](../03-quiz/)

</div>
<!-- /course-header -->

## &#128204; What Makes a Table a *Relation*?

Not every grid of data qualifies as a relation in the formal sense. A true relation must satisfy a short list of defining properties. We'll use a small slice of Wedgewood Pacific's `EMPLOYEE` table as the running example:

| EmployeeNumber | FirstName | LastName | Department | Position |
|---|---|---|---|---|
| 1 | Mary | Jacobs | Administration | President |
| 2 | Fred | Jones | Marketing | Manager |
| 3 | Homer | Wells | Marketing | Salesperson |
| 4 | Rick | Brown | Marketing | Salesperson |

---

## &#128204; Rule 1 — No Duplicate Rows

Every row (tuple) in a relation must be unique. If two rows were completely identical in every column, there would be no way to tell them apart, and no way to reliably refer to "that one row" versus "the other one."

```text
Not allowed as a relation:
| 3 | Homer | Wells | Marketing | Salesperson |
| 3 | Homer | Wells | Marketing | Salesperson |   ← exact duplicate
```

This is exactly why relations need a **key** — a column (or set of columns) guaranteed to be unique per row — which we cover in the next note, [Keys](02-03-keys.md).

---

## &#128204; Rule 2 — Row Order Doesn't Matter

A relation is a *set* of rows, not a *sequence*. Listing the `EMPLOYEE` rows in employee-number order, last-name order, or any other order is still the same relation — order is not part of the data.

```sql
-- These two queries return the SAME relation conceptually,
-- just displayed in a different order:
SELECT * FROM employee ORDER BY employee_number;
SELECT * FROM employee ORDER BY last_name;
```

If you need rows in a specific order for a report or a UI, you request that ordering explicitly with `ORDER BY` — the table itself has no inherent order.

---

## &#128204; Rule 3 — Column Order Doesn't Matter

Likewise, the *set* of attributes doesn't depend on which column is written first. `EMPLOYEE(EmployeeNumber, FirstName, LastName)` describes the same relation as `EMPLOYEE(LastName, FirstName, EmployeeNumber)` — same attributes, same meaning, different display order.

In SQL, `SELECT *` happens to return columns in the order they were defined in the table, but that's a display convenience, not a defining property of the relation.

```sql
-- Same data, different column order in the output:
SELECT last_name, first_name, employee_number FROM employee;
SELECT employee_number, first_name, last_name FROM employee;
```

---

## &#128204; Rule 4 — Every Cell Holds a Single, Atomic Value

Each intersection of a row and column must hold exactly **one** value — not a list, not a set, not a comma-separated pile of values. This is often called the requirement for **atomic** values.

Compare a well-formed relation to a broken one:

```text
Not a valid relation (multiple values crammed into one cell):
| EmployeeNumber | FirstName | LastName | Skills                  |
| 3              | Homer     | Wells    | SQL, Excel, Salesforce  |   ← violates atomicity
```

```text
A valid relation (one skill per row, in its own table):
EMPLOYEE_SKILL
| EmployeeNumber | Skill        |
| 3              | SQL          |
| 3              | Excel        |
| 3              | Salesforce   |
```

> [!TIP]
> This "one value per cell" rule is the seed of an idea you'll formalize in Module 05: **First Normal Form (1NF)**. You don't need the name yet — just the instinct that a comma-separated list stuffed into one column is a warning sign, the same way repeating `Child1`, `Child2` columns were a warning sign back in [Why Databases?](01-01-why-databases.md).

---

## &#128204; A Non-Relation, for Contrast

Here's a table that violates several rules at once — the kind of thing you might inherit from a messy spreadsheet import:

| EmpNo | Name | Projects |
|---|---|---|
| 3 | Homer Wells | P1, P3 |
| 3 | Homer Wells | P1, P3 |
| 4 | Rick Brown | P2 |

- **Duplicate rows** — the two `EmpNo 3` rows are identical.
- **Non-atomic values** — `Projects` holds a comma-separated list instead of one project per row.

The relational fix, following the same "one theme per table" principle from Module 01:

```sql
CREATE TABLE employee (
    employee_number SERIAL PRIMARY KEY,
    full_name       VARCHAR(100) NOT NULL
);

CREATE TABLE employee_project (
    employee_number INT REFERENCES employee(employee_number),
    project_id      VARCHAR(10),
    PRIMARY KEY (employee_number, project_id)
);
```

Now every cell holds one value, rows can't accidentally duplicate (the `PRIMARY KEY` forbids it), and order — of rows or columns — never carries meaning.

---

See also: [Relations & Terminology](02-01-relations-and-terminology.md), [Keys](02-03-keys.md)

<!-- course-footer -->
---

<div align="center" markdown>

[All Notes](README.md) &nbsp;|&nbsp; [Module 02 Exercise](../02-exercises/02-exercise.md) &nbsp;|&nbsp; <strong>Next:</strong> [Keys](02-03-keys.md)

</div>
<!-- /course-footer -->
