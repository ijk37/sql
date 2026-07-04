# &#128216; 04-03: Relationship Types

<!-- course-header -->
<div align="center" markdown>

![SQL & Databases](../assets/banner.svg)

<img src="https://img.shields.io/badge/Module_04-Data_Modeling_ER-336791?style=for-the-badge&labelColor=24506B" alt="Module 04: Data Modeling & E-R Diagrams">

[![Home](https://img.shields.io/badge/⌂_Home-1B2A35?style=flat-square)](../index.md) [![All Notes](https://img.shields.io/badge/All_Notes-1B2A35?style=flat-square)](README.md) [![Practice](https://img.shields.io/badge/✎_Practice-C6821E?style=flat-square&labelColor=24506B)](../02-exercises/04-exercise.md) [![Quiz](https://img.shields.io/badge/▶_Quiz-C6821E?style=flat-square&labelColor=24506B)](../03-quiz/)

</div>
<!-- /course-header -->

## &#128161; Maximum Cardinality: Three Shapes

Every binary relationship (between two entity types) falls into one of three maximum-cardinality shapes. **Maximum cardinality** is the largest number of instances of one entity that can relate to a single instance of the other.

---

## &#128204; One-to-One (1:1)

A single instance of Entity A relates to at most a single instance of Entity B, and vice versa.

*Example:* An `EMPLOYEE` is assigned exactly one `PARKING_SPOT`; a `PARKING_SPOT` is assigned to at most one `EMPLOYEE`.

```
EMPLOYEE ──||────────────||── PARKING_SPOT
```

1:1 relationships are the least common of the three — when you find one, it's often worth asking whether the two entities should just be merged into a single table, since a strict one-to-one pairing frequently means the "second" entity is really just a set of optional attributes on the first.

---

## &#128204; One-to-Many (1:N)

A single instance of Entity A relates to **many** instances of Entity B, but each instance of B relates to only **one** instance of A. This is by far the most common relationship shape in real schemas.

*Example (Wedgewood Pacific):* A `DEPARTMENT` employs many `EMPLOYEE`s; each `EMPLOYEE` works in exactly one `DEPARTMENT`.

```
DEPARTMENT ──||─────────────<○── EMPLOYEE
           one department      zero-or-many employees
```

*Another example:* A `PROFESSOR` teaches one or more `CLASS`es; each `CLASS` is taught by exactly one `PROFESSOR`.

Notice the crow's foot (many) is always on the "many" side, and the bar (one) is always on the "one" side — the shape of the symbols mirrors the shape of the business rule.

---

## &#128204; Many-to-Many (N:M)

Many instances of Entity A relate to many instances of Entity B, and vice versa.

*Example (fresh scenario):* Picture a small community art school. A `STUDENT` may enroll in many `COURSE`s (Pottery, Watercolor, Sculpture...), and each `COURSE` has many `STUDENT`s enrolled. Neither side caps out at one.

```
STUDENT ──<○──────────────○>── COURSE
        zero-or-many        zero-or-many
```

This is exactly the shape of the Wedgewood Pacific `EMPLOYEE`–`PROJECT` relationship too: an `EMPLOYEE` can be assigned to many `PROJECT`s, and a `PROJECT` has many `EMPLOYEE`s assigned to it.

### The Problem with Pure N:M — and the Fix

A pure N:M relationship line can't hold data of its own. Suppose the art school needs to record *when* each student enrolled in each course, or Wedgewood Pacific needs to record *how many hours* each employee logged on each project. Where does that fact live?

- It can't go on `STUDENT` — enrollment date isn't a property of the student in general, only of one specific enrollment.
- It can't go on `COURSE` — same problem, mirrored.
- It has to live on the **relationship itself** — one enrollment date *per student-course pairing*.

The fix is to convert the N:M relationship into an **associative entity** (also called an intersection entity or linking entity): a new entity that sits between the two originals, links to both, and holds any attributes that belong to the *pairing* rather than to either entity alone.

```
STUDENT ──||────< ENROLLMENT >────||── COURSE
                (EnrollmentDate)
```

`ENROLLMENT` links one `STUDENT` to one `COURSE` per row, and its own attribute `EnrollmentDate` describes that specific pairing. This is precisely what Wedgewood Pacific's `ASSIGNMENT` table does for `EMPLOYEE` and `PROJECT`:

```sql
CREATE TABLE assignment (
    project_id       INTEGER      NOT NULL REFERENCES project(project_id),
    employee_number  INTEGER      NOT NULL REFERENCES employee(employee_number),
    hours_worked     NUMERIC(6,2),
    PRIMARY KEY (project_id, employee_number)
);
```

`ASSIGNMENT` is the associative entity: it resolves the `EMPLOYEE`–`PROJECT` many-to-many relationship into two 1:N relationships (`PROJECT` to `ASSIGNMENT`, and `EMPLOYEE` to `ASSIGNMENT`), and `HoursWorked` — an attribute that only makes sense per employee-per-project — lives exactly where it belongs.

> [!TIP]
> **The tell-tale sign you need an associative entity:** you find yourself wanting to attach an attribute to a relationship line rather than to either entity box. The moment that happens, convert the relationship into an entity of its own. Every N:M relationship becomes two 1:N relationships once you introduce the associative entity — this is also exactly how N:M relationships get implemented in SQL, since a table can't natively store a many-to-many foreign key.

---

## &#128204; Weak Entities

A **weak entity** is an entity that cannot exist in the database without the entity it depends on. Any entity that is *not* weak is called a **strong entity**.

Two flavors:

- **ID-dependent weak entity** — has no identifier of its own; its identifier is a composite of the parent's identifier plus a partial key of its own. Example: a `DEPENDENT` of an employee, identified only by `(EmployeeNumber, DependentID)` together — `DependentID` alone (e.g., "dependent #1") means nothing without knowing whose dependent #1 it is. The connecting relationship is drawn with a **solid line** and is called an **identifying relationship**.
- **Non-ID-dependent weak entity** — has its own identifier, but still can't logically exist without its parent. Example: a `SECTION` of a `COURSE`, identified by its own `SectionID`, but a section can't exist if the course it belongs to is deleted. The connecting relationship is drawn with a **dashed line** and is called a **non-identifying relationship**.

`ASSIGNMENT` above is itself an example of an ID-dependent weak entity — its primary key `(ProjectID, EmployeeNumber)` only makes sense in relation to both parents; there's no standalone "assignment number" independent of the pairing.

> [!NOTE]
> In practice, many designers skip the weak/strong distinction entirely and give every entity — even dependents and sections — its own surrogate identifier (`DependentID`, `SectionID` as their own standalone auto-incrementing keys). Once every entity has its own key, the tables end up looking the same either way; the "weak entity" concept mainly matters for how you *justify* your key choices, not for how the final tables are built.

---

See also: [E-R Diagram Notation](04-02-er-diagram-notation.md), [Relationship Degree](04-04-relationship-degree.md)

<!-- course-footer -->
---

<div align="center" markdown>

[All Notes](README.md) &nbsp;|&nbsp; [Module 04 Exercise](../02-exercises/04-exercise.md) &nbsp;|&nbsp; <strong>Next:</strong> [Relationship Degree](04-04-relationship-degree.md)

</div>
<!-- /course-footer -->
