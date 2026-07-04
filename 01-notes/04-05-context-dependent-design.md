# &#128216; 04-05: Context-Dependent Design

<!-- course-header -->
<div align="center" markdown>

![SQL & Databases](../assets/banner.svg)

<img src="https://img.shields.io/badge/Module_04-Data_Modeling_ER-336791?style=for-the-badge&labelColor=24506B" alt="Module 04: Data Modeling & E-R Diagrams">

[![Home](https://img.shields.io/badge/⌂_Home-1B2A35?style=flat-square)](../index.md) [![All Notes](https://img.shields.io/badge/All_Notes-1B2A35?style=flat-square)](README.md) [![Practice](https://img.shields.io/badge/✎_Practice-C6821E?style=flat-square&labelColor=24506B)](../02-exercises/04-exercise.md) [![Quiz](https://img.shields.io/badge/▶_Quiz-C6821E?style=flat-square&labelColor=24506B)](../03-quiz/)

</div>
<!-- /course-header -->

## &#128161; There Is No Single "Correct" Diagram

Every note so far in this module has treated cardinality as something you read off a business rule. But the harder truth is: **the same real-world entities can be modeled correctly in more than one way**, and which way is "correct" depends entirely on *what question the database needs to answer* — its context — not on some universal, objective shape the data must take.

---

## &#128204; A Worked Contrast: Professor and Class, Professor and Department

Picture a university that has both `PROFESSOR`, `CLASS`, and `DEPARTMENT` as entities. Two relationships are both true simultaneously:

1. **"A professor teaches a class."**
2. **"A professor belongs to a department."**

Which one should the data model emphasize — connect `PROFESSOR` directly to `CLASS`, or connect `PROFESSOR` directly to `DEPARTMENT`? The honest answer is: **it depends on which system you're building.**

### If You're Building an Academic / Enrollment System

The questions this system must answer are things like "who teaches Section 3 of Calculus I this fall?" and "how many classes is Dr. Alvarez teaching this semester?" Here, the relationship that matters is **PROFESSOR–CLASS**:

```
PROFESSOR ──||──────────────<○── CLASS
          exactly one          zero-or-many classes
          professor per         (a professor might be
          class                  on research leave, teaching none)
```

`DEPARTMENT` might not even appear directly connected to `PROFESSOR` in this model — it could simply be inferred through `CLASS.DepartmentName`, since every class already belongs to a department.

### If You're Building an Administrative / HR System

The questions here are different: "which department does Dr. Alvarez report to for payroll and performance review?" "How many faculty members are in the Biology department?" Now the relationship that matters is **PROFESSOR–DEPARTMENT**:

```
DEPARTMENT ──||─────────────<○── PROFESSOR
```

In this model, `CLASS` might not connect directly to `PROFESSOR` at all — scheduling could be a separate concern handled by a different system entirely.

### Both Are Correct

Neither model is "more true" than the other — **both are valid, and both would let you determine who teaches what and where**, just by traversing a different path through the data. The deciding factor isn't the entities themselves; it's the **business rules and the questions the database exists to answer.** This is exactly why [Systems Analysis & DB Lifecycle](04-01-systems-analysis-and-db-lifecycle.md) insists on gathering requirements *before* modeling — without knowing the system's purpose, you can't know which relationships to prioritize.

---

## &#128204; How Business Rules Change Cardinality, Not Just Structure

Context doesn't only decide *which* relationships to draw — it also decides whether a given relationship is 1:N or N:M, purely based on policy, not on anything inherent about the entities.

Consider `INSTRUCTOR` and `CLASS` at a corporate training center:

- **Business rule A:** "Each class is taught by exactly one instructor. An instructor may teach up to two classes." → This is **1:N** (one instructor, many classes; each class has one instructor).
- **Business rule B (a different training center, different policy):** "Classes may be co-taught, and instructors may teach as many classes as scheduling allows." → Now the same two entities need an **N:M** relationship, resolved with an associative entity (e.g., `CLASS_ASSIGNMENT`) — because a single `CLASS` can now have multiple `INSTRUCTOR`s.

Nothing about `INSTRUCTOR` or `CLASS` as *concepts* changed. Only the **policy** changed — and that alone flipped the correct cardinality from 1:N to N:M. This is why you always justify cardinality decisions by pointing at a specific business rule, not by intuition about "how these things usually work."

---

## &#128204; When Should Two Entities Merge, or One Split Into Two?

The same context-sensitivity applies to a more basic question: is something one entity, or two?

- If a business always creates a `CUSTOMER` record only *after* a purchase (never for browsers or leads), then "every customer has at least one purchase" becomes a valid, enforceable business rule — and `CUSTOMER` and `PURCHASE` clearly stay as two separate, related entities, exactly as in the James River Jewelry case: a customer must have made at least one purchase to exist in the system at all, so the minimum cardinality on the `CUSTOMER` side of that relationship is 1, not 0.
- If instead a business wants to track prospective customers *before* they buy anything (a marketing/CRM context), then that same assumption breaks — `CUSTOMER` needs a zero-minimum relationship to `PURCHASE`, or an entirely separate `LEAD` entity needs to exist upstream of `CUSTOMER`.

Neither answer is universally right. The context — specifically, "does this business ever record someone who hasn't purchased yet?" — determines the correct minimum cardinality, and possibly whether a whole extra entity is needed.

---

## &#128204; The Practical Takeaway

When you draw an E-R diagram for an assignment, a project, or a real system, don't ask "what's the textbook-correct cardinality for a professor and a class?" There isn't one. Instead ask:

1. **What questions must this specific database answer?**
2. **What are the actual, stated business rules for this organization** — not a generic assumption about how the entities "usually" relate?
3. **What happens at the edges** — can an instance of this entity exist with zero related instances of the other? Is there ever more than one? Those answers set your minimum and maximum cardinalities.

> [!TIP]
> Whenever you justify a cardinality choice — in an assignment, a project, or a real design review — write the business rule in a full sentence first ("a customer must have made at least one purchase to exist in this database"), and only then translate it into bars, circles, and crow's feet. If you can't state the rule in plain English, you don't actually know the cardinality yet — you're guessing.

---

See also: [Relationship Degree](04-04-relationship-degree.md), [E-R Diagram Notation](04-02-er-diagram-notation.md)

<!-- course-footer -->
---

<div align="center" markdown>

[All Notes](README.md) &nbsp;|&nbsp; [Module 04 Exercise](../02-exercises/04-exercise.md) &nbsp;|&nbsp; <strong>Next:</strong> [Transforming E-R Models into Tables](05-01-transforming-er-to-tables.md)

</div>
<!-- /course-footer -->
