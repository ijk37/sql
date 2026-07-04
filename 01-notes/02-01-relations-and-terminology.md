# &#128216; 02-01: Relations &amp; Terminology

<!-- course-header -->
<div align="center" markdown>

![SQL & Databases](../assets/banner.svg)

<img src="https://img.shields.io/badge/Module_02-Relational_Model-336791?style=for-the-badge&labelColor=24506B" alt="Module 02: The Relational Model">

[![Home](https://img.shields.io/badge/⌂_Home-1B2A35?style=flat-square)](../index.md) [![All Notes](https://img.shields.io/badge/All_Notes-1B2A35?style=flat-square)](README.md) [![Practice](https://img.shields.io/badge/✎_Practice-C6821E?style=flat-square&labelColor=24506B)](../02-exercises/02-exercise.md) [![Quiz](https://img.shields.io/badge/▶_Quiz-C6821E?style=flat-square&labelColor=24506B)](../03-quiz/)

</div>
<!-- /course-header -->

## &#128204; From Everyday Words to Formal Terms

Module 01 used the everyday words *table*, *row*, and *column*. Those words are fine for conversation, but the relational model — the mathematical theory underneath every relational DBMS — has its own precise vocabulary. Knowing both sets, and how they map to each other, matters because textbooks, academic papers, and SQL vendors don't always use the same words.

| Formal (relational theory) term | Everyday / SQL term | Meaning |
|---|---|---|
| **Relation** | Table | A structured set of data about one theme |
| **Tuple** | Row / record | One occurrence of the theme |
| **Attribute** | Column / field | A named characteristic shared by all tuples |
| **Domain** | Data type | The set of legal values an attribute can hold |

An **entity** is the real-world thing of interest that a relation represents — a customer, an employee, a project. In relational database design, an entity is (ideally) captured by exactly one table.

---

## &#128204; Relation vs. Table — What's the Difference?

Formally, a **relation** is a very specific mathematical structure with strict rules (covered in the next note). In casual usage — and inside every SQL product you'll ever open — the word **table** is used loosely to mean the same thing, even when the strict rules aren't fully satisfied.

- SQL vendors, GUI tools, and everyday conversation say **"table."**
- Academic textbooks and formal design discussions say **"relation."**

You'll see both used interchangeably from here on — that's normal and expected. When precision matters (for example, "is this actually a valid relation?"), reach for the formal term.

> [!NOTE]
> This course, like Kroenke's textbook, writes formal relation names in `ALL_CAPS` and singular — `EMPLOYEE`, not `Employees` or `employees`. Real SQL schemas (including every example in this course) typically use lowercase `snake_case` table names instead, like `employee`. Both refer to the same idea.

---

## &#128204; A Worked Example

Here's a small relation, written in the formal shorthand you'll see throughout the rest of this course:

```text
EMPLOYEE (EmployeeNumber, FirstName, LastName, Department, EmailAddress)
```

- The relation name, `EMPLOYEE`, comes first, in caps.
- The **attributes** are listed in parentheses.
- (Once we cover keys in [02-03](02-03-keys.md), the primary key attribute will be underlined in this notation.)

As an actual table with sample data:

| EmployeeNumber | FirstName | LastName | Department | EmailAddress |
|---|---|---|---|---|
| 1 | Mary | Jacobs | Administration | MJacobs@wp.com |
| 2 | Fred | Jones | Marketing | FJones@wp.com |
| 3 | Homer | Wells | Marketing | HWells@wp.com |

Mapping the vocabulary onto this table:

- The whole thing is the **relation** `EMPLOYEE` (or, casually, "the `EMPLOYEE` table").
- `(2, Fred, Jones, Marketing, FJones@wp.com)` is one **tuple** (row).
- `Department` is an **attribute** (column).
- The **domain** of `Department` might be "any text value up to 50 characters representing a valid department name."

Here it is as a real PostgreSQL table:

```sql
CREATE TABLE employee (
    employee_number SERIAL PRIMARY KEY,
    first_name      VARCHAR(50) NOT NULL,
    last_name       VARCHAR(50) NOT NULL,
    department      VARCHAR(50),
    email_address   VARCHAR(100)
);
```

---

## &#128204; Database Schema

A **database schema** is the overall design — the full set of relation/table definitions, their attributes, and how they relate to each other — that a database and its applications are built on. When someone says "let's look at the schema," they mean the blueprint of tables and relationships, not the data currently sitting inside them.

```sql
-- Viewing part of the schema in PostgreSQL:
\d employee
-- or, portably:
SELECT table_name, column_name, data_type
FROM information_schema.columns
WHERE table_schema = 'public';
```

> [!TIP]
> A handy mental model: **the schema is the noun, the data is the verb.** The schema says "there is a thing called `EMPLOYEE` with these attributes." The data is the actual rows that exist right now. You can change the data all day without touching the schema — but changing the schema (adding a column, for instance) is a separate, more careful operation, covered in Module 03's DDL notes.

---

See also: [Characteristics of Relations](02-02-characteristics-of-relations.md), [Relational Tables & Database Systems](01-02-relational-tables-and-db-systems.md)

<!-- course-footer -->
---

<div align="center" markdown>

[All Notes](README.md) &nbsp;|&nbsp; [Module 02 Exercise](../02-exercises/02-exercise.md) &nbsp;|&nbsp; <strong>Next:</strong> [Characteristics of Relations](02-02-characteristics-of-relations.md)

</div>
<!-- /course-footer -->
