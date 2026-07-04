# &#9997; 02: The Relational Model — Exercises

<!-- course-header -->
<div align="center" markdown>

![SQL & Databases](../assets/banner.svg)

<img src="https://img.shields.io/badge/Module_02-Relational_Model-336791?style=for-the-badge&labelColor=24506B" alt="Module 02: The Relational Model"> <img src="https://img.shields.io/badge/12_questions-C6821E?style=for-the-badge&labelColor=24506B" alt="12 questions">

[![Home](https://img.shields.io/badge/⌂_Home-1B2A35?style=flat-square)](../index.md) [![Notes](https://img.shields.io/badge/Notes-1B2A35?style=flat-square)](../01-notes/02-01-relations-and-terminology.md) [![All Exercises](https://img.shields.io/badge/All_Exercises-1B2A35?style=flat-square)](README.md) [![Quiz](https://img.shields.io/badge/▶_Quiz-C6821E?style=flat-square&labelColor=24506B)](../03-quiz/)

</div>
<!-- /course-header -->

> [!TIP]
> **Practice —** try each question first, then expand the answer to check your reasoning.

Work through each question, then click **Show answer** to check yourself. Review the [notes](../01-notes/02-01-relations-and-terminology.md) if you get stuck.

---

### &#128313; Q1. Match the formal term to the everyday/SQL term: relation, tuple, attribute.

<details>
<summary><strong>Show answer</strong></summary>

- **Relation** → table
- **Tuple** → row / record
- **Attribute** → column / field
</details>

---

### &#10067; Q2. Why do textbooks say "relation" while SQL products and everyday conversation say "table"? Are they always describing the same thing?

<details>
<summary><strong>Show answer</strong></summary>

"Relation" is the formal term from relational theory, with strict rules (no duplicate rows, atomic cell values, etc.). "Table" is the everyday/SQL term, used loosely — even when a table doesn't fully satisfy every formal rule (e.g., it currently has a non-atomic column), people still call it a "table." Not every table is a perfectly valid relation, but the terms are treated as interchangeable in casual use.
</details>

---

### &#128313; Q3. List the four defining characteristics of a relation covered in this module.

<details>
<summary><strong>Show answer</strong></summary>

1. No duplicate rows.
2. Row order doesn't matter.
3. Column order doesn't matter.
4. Every cell holds a single, atomic value.
</details>

---

### &#127981; Q4. A table has a `Skills` column that stores values like `"SQL, Excel, Salesforce"` for one employee. Which rule of a relation does this break, and how would you fix it?

<details>
<summary><strong>Show answer</strong></summary>

This breaks the **atomic value** rule — the cell holds multiple values instead of one. Fix: create a separate `EMPLOYEE_SKILL` table with one row per (employee, skill) pair, linked back to `EMPLOYEE` by a foreign key.
</details>

---

Use this small schema for Q5–Q9:

```text
STUDENT    (StudentID, FirstName, LastName, Major, Email)
COURSE     (CourseID, CourseTitle, Credits)
ENROLLMENT (StudentID, CourseID, Grade)
```

### &#128313; Q5. What is the most likely primary key of `STUDENT`? Is `Email` a candidate key too?

<details>
<summary><strong>Show answer</strong></summary>

`StudentID` is the natural choice for primary key (a surrogate key with no business meaning). `Email` is very likely also a **candidate key** — if every student's email is guaranteed unique, it could have been chosen as the primary key instead, making it an **alternate key** since it wasn't chosen.
</details>

---

### &#10067; Q6. What is the primary key of `ENROLLMENT`? What kind of key is it?

<details>
<summary><strong>Show answer</strong></summary>

`(StudentID, CourseID)` — a **composite key**. Neither column is unique alone (one student takes many courses; one course has many students), but the pair is unique, since a student enrolls in a given course only once.
</details>

---

### &#128313; Q7. In `ENROLLMENT`, which columns are foreign keys, and what do they reference?

<details>
<summary><strong>Show answer</strong></summary>

`StudentID` references `STUDENT.StudentID`, and `CourseID` references `COURSE.CourseID`. Both must match an existing row in their respective parent tables — the referential integrity rule.
</details>

---

### &#128313; Q8. Is `StudentID` in `STUDENT` a natural key or a surrogate key? What about `Email`?

<details>
<summary><strong>Show answer</strong></summary>

`StudentID` is a **surrogate key** — a DBMS/registrar-assigned number with no inherent business meaning. `Email` would be a **natural key** — it's real-world data that happens to (probably) be unique, not an artificial identifier created just to serve as a key.
</details>

---

### &#127981; Q9. Suppose `ENROLLMENT` is widened to add a `StudentMajor` column (copied from `STUDENT`). Identify the dependency this creates and name it.

<details>
<summary><strong>Show answer</strong></summary>

Since the primary key of `ENROLLMENT` is `(StudentID, CourseID)`, but `StudentMajor` only depends on `StudentID` (not on `CourseID`), this is a **partial dependency** — `StudentMajor` depends on only part of the composite key.
</details>

---

### &#10067; Q10. Now suppose `COURSE` is widened to add a `DepartmentOffice` column, and `DepartmentOffice` really depends on a `Department` column also stored in `COURSE`, not on `CourseID` directly. What is this called?

<details>
<summary><strong>Show answer</strong></summary>

A **transitive dependency** — `CourseID → Department → DepartmentOffice`. `DepartmentOffice` depends on `Department`, a non-key column, rather than depending directly on the primary key `CourseID`.
</details>

---

### &#128313; Q11. In the Wedgewood Pacific `ASSIGNMENT` table `(ProjectID, EmployeeNumber, HoursWorked)`, explain why `HoursWorked` is a *full* functional dependency on the key rather than a partial one.

<details>
<summary><strong>Show answer</strong></summary>

`HoursWorked` genuinely needs **both** `ProjectID` and `EmployeeNumber` to be determined — it's the number of hours a *specific employee* worked on a *specific project*. Neither column alone determines it, so the dependency is on the whole composite key, not just part of it — making it a full functional dependency, not a partial one.
</details>

---

### &#127974; Q12. Why is `DepartmentName` a risky choice of primary key for WP's `DEPARTMENT` table, and what's the recommended fix?

<details>
<summary><strong>Show answer</strong></summary>

If the department is ever renamed, every row in `EMPLOYEE` and `PROJECT` that references the old name as a foreign key would need to be updated too, risking a moment of broken referential integrity (or missed rows). The fix is to add a **surrogate key**, e.g. `DepartmentID`, which never changes even if `DepartmentName` does.
</details>

---

<!-- course-footer -->
---

<div align="center" markdown>

[All Exercises](README.md) &nbsp;|&nbsp; [Module 02 Notes](../01-notes/02-01-relations-and-terminology.md) &nbsp;|&nbsp; <strong>Next:</strong> [03: SQL Fundamentals — Exercises](03-exercise.md)

</div>
<!-- /course-footer -->
