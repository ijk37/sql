# &#128216; 04-02: E-R Diagram Notation

<!-- course-header -->
<div align="center" markdown>

![SQL & Databases](../assets/banner.svg)

<img src="https://img.shields.io/badge/Module_04-Data_Modeling_ER-336791?style=for-the-badge&labelColor=24506B" alt="Module 04: Data Modeling & E-R Diagrams">

[![Home](https://img.shields.io/badge/⌂_Home-1B2A35?style=flat-square)](../index.md) [![All Notes](https://img.shields.io/badge/All_Notes-1B2A35?style=flat-square)](README.md) [![Practice](https://img.shields.io/badge/✎_Practice-C6821E?style=flat-square&labelColor=24506B)](../02-exercises/04-exercise.md) [![Quiz](https://img.shields.io/badge/▶_Quiz-C6821E?style=flat-square&labelColor=24506B)](../03-quiz/)

</div>
<!-- /course-header -->

## &#128161; The Four Building Blocks

The **Entity-Relationship (E-R) model**, created by Peter Chen in 1976, is the standard tool for documenting data requirements before building tables. It has four core constructs:

| Construct | Definition | Example |
|---|---|---|
| **Entity** | Something the business wants to track — a person, place, object, event, or concept | `EMPLOYEE`, `DEPARTMENT`, `PROJECT` |
| **Attribute** | A property or characteristic of an entity | `FirstName`, `HireDate`, `Position` |
| **Identifier** | An attribute (or set of attributes) that uniquely names one entity instance | `EmployeeNumber` |
| **Relationship** | An association between entity instances | "an employee **works in** a department" |

### Entities vs. Entity Instances

Write entity *classes* in uppercase, singular — `EMPLOYEE`, not `Employees`. `EMPLOYEE` is the class (the collection of all employee records); one specific row — say, employee #14, Mike Nguyen — is an **entity instance**. The diagram documents the class; the database, once built, holds the instances.

---

## &#128204; Why Crow's Foot Notation

Several E-R notations exist — Chen's original, Crow's Foot (Information Engineering, James Martin), IDEF1X, UML — but **Crow's Foot** is the one you'll see most often in industry diagramming tools (including draw.io, which you'll use in the [Module 04 project](../04-projects/04-full-er-diagram-design/README.md)). It represents relationships and their cardinalities directly as symbols drawn on the connecting line, right where it touches each entity box.

---

## &#128204; Reading Cardinality Symbols

Every relationship line in Crow's Foot notation has **two ends**, and each end carries its own pair of symbols — one for **maximum cardinality** (how many, at most) and one for **minimum cardinality** (is it required, or optional). Since we can't embed the diagram images here, read the symbols like this:

```
ENTITY_A ──────○<───────── ENTITY_B
         one-and-only-one   zero-or-many
         (mandatory,        (optional,
          maximum = 1)       maximum = many)
```

The symbols, read moving *outward* from the entity box toward the other entity:

| Symbol (near the box) | Meaning | Cardinality |
|---|---|---|
| Single straight bar `\|` | Exactly one | Minimum = 1 **and** Maximum = 1 |
| Circle `○` | Zero | Minimum = 0 (optional) |
| Crow's foot `<` (three-pronged fork) | Many | Maximum = many |
| Circle + crow's foot `○<` | Zero or many | Minimum = 0, Maximum = many |
| Bar + crow's foot `\|<` | One or many | Minimum = 1, Maximum = many |
| Bar + bar `\|\|` | Exactly one (mandatory one) | Minimum = 1, Maximum = 1 |

**The rule to memorize:** the two marks closest to an entity describe *that entity's own participation* in the relationship — not the other side. Read each end independently.

- **One bar = exactly one.** No ambiguity, no optionality.
- **Circle = zero is allowed** (this entity's participation is optional).
- **Crow's foot (the splayed three-line fork) = many are allowed** on this end.
- **Circle + crow's foot together = "zero or many"** — the most permissive combination.
- **Bar + crow's foot together = "one or many"** — at least one is required, but more are allowed.

### Worked Example

Business rules: *"A department employs one or more employees. Each employee works in exactly one department."*

```
DEPARTMENT ──||──────────────<○── EMPLOYEE
             one and         zero or many
             only one        (an employee always has
             (every           exactly one department,
             employee          but a brand-new department
             belongs to        might not have any
             exactly one        employees yet)
             department)
```

Read from the `EMPLOYEE` end back toward `DEPARTMENT`: "each employee relates to exactly one department" → bar + bar (`||`) on that end. Read from the `DEPARTMENT` end toward `EMPLOYEE`: "each department has zero or many employees" → circle + crow's foot (`○<`) on that end.

> [!TIP]
> A trick that helps beginners: cover up everything except the entity box and the symbol touching it, then finish the sentence *"one instance of [this entity] relates to ___ instance(s) of the other entity."* Do this for both ends separately — never try to read both ends of the line in one pass.

---

## &#128204; Entities, Attributes, and Identifiers on the Diagram

A full entity box typically shows the entity name in a header bar, with attributes listed below it and the identifier underlined (or marked with a key icon):

```
┌─────────────────────┐
│      EMPLOYEE        │
├─────────────────────┤
│ EmployeeNumber (PK)   │
│ FirstName             │
│ LastName              │
│ Position              │
│ EmailAddress          │
└─────────────────────┘
```

> [!NOTE]
> **Conceptual E-R diagrams do not show foreign keys.** At this stage you're modeling the *business meaning* of the data, not the physical implementation. Foreign keys are a relational-database implementation detail that gets added later, when the E-R model is converted into a table design (covered in [Module 05](05-01-transforming-er-to-tables.md)). If you find yourself drawing `DepartmentName (FK)` inside the `EMPLOYEE` box on a conceptual diagram, that's a sign you've jumped ahead to physical design too early — the relationship line itself is what represents that connection at this stage.

---

## &#128204; Relationship Names Read in Both Directions

A well-labeled relationship line reads naturally in *both* directions, and good practice is to label the diagram (or at least your notes) with both readings:

- "A `DEPARTMENT` **employs** `EMPLOYEE`s."
- "An `EMPLOYEE` **works in** a `DEPARTMENT`."

Both sentences describe the same line — they're just read starting from opposite ends. When you write your own business rules before drawing a diagram, write both directions explicitly; it forces you to pin down cardinality on both ends instead of assuming one side.

---

See also: [Systems Analysis & DB Lifecycle](04-01-systems-analysis-and-db-lifecycle.md), [Relationship Types](04-03-relationship-types.md)

<!-- course-footer -->
---

<div align="center" markdown>

[All Notes](README.md) &nbsp;|&nbsp; [Module 04 Exercise](../02-exercises/04-exercise.md) &nbsp;|&nbsp; <strong>Next:</strong> [Relationship Types](04-03-relationship-types.md)

</div>
<!-- /course-footer -->
