# &#128216; 02-04: Functional Dependencies

<!-- course-header -->
<div align="center" markdown>

![SQL & Databases](../assets/banner.svg)

<img src="https://img.shields.io/badge/Module_02-Relational_Model-336791?style=for-the-badge&labelColor=24506B" alt="Module 02: The Relational Model">

[![Home](https://img.shields.io/badge/⌂_Home-1B2A35?style=flat-square)](../index.md) [![All Notes](https://img.shields.io/badge/All_Notes-1B2A35?style=flat-square)](README.md) [![Practice](https://img.shields.io/badge/✎_Practice-C6821E?style=flat-square&labelColor=24506B)](../02-exercises/02-exercise.md) [![Quiz](https://img.shields.io/badge/▶_Quiz-C6821E?style=flat-square&labelColor=24506B)](../03-quiz/)

</div>
<!-- /course-header -->

## &#128204; What Is a Functional Dependency?

A **functional dependency** describes a relationship between columns: knowing the value of one column tells you, with certainty, the value of another.

We write this as **X → Y**, read "X determines Y" or "Y is functionally dependent on X." `X` is called the **determinant**.

> [!NOTE]
> This note builds vocabulary only — it does **not** teach normal forms yet. That comes in Module 05, once you have functional dependencies as a tool. Right now, the goal is simply to be able to look at a table and say, correctly, "this column determines that one."

---

## &#128204; A Simple Example

Take a slice of the WP `EMPLOYEE` table:

| EmployeeNumber | FirstName | LastName | Department | OfficePhone |
|---|---|---|---|---|
| 1 | Mary | Jacobs | Administration | x1001 |
| 2 | Fred | Jones | Marketing | x2002 |
| 3 | Homer | Wells | Marketing | x2003 |

Because `EmployeeNumber` is the primary key, it uniquely identifies a row — so it determines *every* other column:

```text
EmployeeNumber → FirstName
EmployeeNumber → LastName
EmployeeNumber → Department
EmployeeNumber → OfficePhone
```

Or all at once: `EmployeeNumber → (FirstName, LastName, Department, OfficePhone)`.

This is expected and unremarkable — **the primary key of a relation always functionally determines every other attribute in that relation.** That's essentially what "primary key" means. The interesting cases are dependencies that show up *among the non-key columns*.

---

## &#128204; Partial Dependency

A **partial dependency** happens when a non-key column depends on only *part* of a composite key, rather than the whole thing.

This requires a composite key to even be possible. Consider WP's `ASSIGNMENT` table, whose primary key is the composite `(ProjectID, EmployeeNumber)`. Suppose someone (incorrectly) widens it to also carry the employee's department:

| ProjectID | EmployeeNumber | HoursWorked | EmployeeDepartment |
|---|---|---|---|
| P100 | 3 | 12.5 | Marketing |
| P100 | 4 | 8.0 | Marketing |
| P200 | 3 | 6.0 | Marketing |

Here:

- `(ProjectID, EmployeeNumber) → HoursWorked` — needs **both** columns; this is a full dependency (a specific employee's hours on a specific project).
- `EmployeeNumber → EmployeeDepartment` — needs **only** `EmployeeNumber`. `ProjectID` is irrelevant to which department an employee belongs to.

That second line is a **partial dependency**: `EmployeeDepartment` depends on only part of the composite key `(ProjectID, EmployeeNumber)`, namely `EmployeeNumber` alone. It's a warning sign — Homer's department (`Marketing`) is now repeated on every project he's assigned to, and if he transfers departments, every one of his `ASSIGNMENT` rows needs updating to stay consistent. (This is the same shape of problem as the update anomaly from [Why Databases?](01-01-why-databases.md).)

A **full functional dependency**, by contrast, is one where the dependent column genuinely needs the *entire* composite key — like `HoursWorked` above, which really is specific to one employee working on one project.

---

## &#128204; Transitive Dependency

A **transitive dependency** happens when a non-key column depends on *another non-key column*, rather than depending directly on the key.

Consider a version of `EMPLOYEE` that (again, incorrectly) stores department details directly:

| EmployeeNumber | LastName | Department | DepartmentPhone |
|---|---|---|---|
| 2 | Jones | Marketing | (555) 200-1000 |
| 3 | Wells | Marketing | (555) 200-1000 |
| 5 | Diaz | Finance | (555) 200-2000 |

Walking the dependencies:

```text
EmployeeNumber → Department          (the key determines the department, directly)
Department     → DepartmentPhone     (the department's phone depends on the department, not the employee)
EmployeeNumber → DepartmentPhone     (therefore true, but only "through" Department)
```

`EmployeeNumber → DepartmentPhone` is a **transitive dependency**, because it only holds *transitively*, by way of `Department`. `DepartmentPhone` isn't really a fact about the employee at all — it's a fact about the department, riding along on the employee's row. That's why Fred Jones and Homer Wells both show `(555) 200-1000` — the same phone number, copied redundantly onto every employee in Marketing. Change Marketing's phone number, and you must find and update it on every one of those rows or the data disagrees with itself.

---

## &#128204; Why This Vocabulary Matters

| Dependency type | Pattern | Problem it signals |
|---|---|---|
| **(Full) functional dependency on the key** | Key → non-key column | None — this is normal and expected |
| **Partial dependency** | Part of a composite key → non-key column | Redundant data tied to only part of the row's identity |
| **Transitive dependency** | Non-key column → another non-key column | Redundant data that really belongs to a *different* theme entirely |

Notice that both problem cases point to the same root cause from [Why Databases?](01-01-why-databases.md): a column that doesn't truly depend on "the whole key, and nothing but the key" is a sign that two themes have been mixed into one table. Module 05 turns this exact vocabulary — full, partial, and transitive dependencies — into a formal, step-by-step process (normalization) for splitting tables like these apart correctly.

> [!TIP]
> A quick self-check for any non-key column: ask **"what does this value actually describe?"** If your honest answer names something other than the table's primary key — a department, a city, a product category — you've likely found a partial or transitive dependency, and a hint that the column belongs in a table of its own.

---

See also: [Keys](02-03-keys.md), [Characteristics of Relations](02-02-characteristics-of-relations.md)

<!-- course-footer -->
---

<div align="center" markdown>

[All Notes](README.md) &nbsp;|&nbsp; [Module 02 Exercise](../02-exercises/02-exercise.md) &nbsp;|&nbsp; <strong>Next:</strong> [DDL: Tables &amp; Data Types](03-01-ddl-tables-and-datatypes.md)

</div>
<!-- /course-footer -->
