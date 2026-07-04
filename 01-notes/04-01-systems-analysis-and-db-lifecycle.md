# &#128216; 04-01: Systems Analysis & Database Lifecycle

<!-- course-header -->
<div align="center" markdown>

![SQL & Databases](../assets/banner.svg)

<img src="https://img.shields.io/badge/Module_04-Data_Modeling_ER-336791?style=for-the-badge&labelColor=24506B" alt="Module 04: Data Modeling & E-R Diagrams">

[![Home](https://img.shields.io/badge/⌂_Home-1B2A35?style=flat-square)](../index.md) [![All Notes](https://img.shields.io/badge/All_Notes-1B2A35?style=flat-square)](README.md) [![Practice](https://img.shields.io/badge/✎_Practice-C6821E?style=flat-square&labelColor=24506B)](../02-exercises/04-exercise.md) [![Quiz](https://img.shields.io/badge/▶_Quiz-C6821E?style=flat-square&labelColor=24506B)](../03-quiz/)

</div>
<!-- /course-header -->

## &#128161; Why Design Comes Before SQL

Module 03 assumed a schema already existed — `department`, `employee`, `project`, `assignment` were handed to you, ready to `CREATE TABLE`. In the real world, someone has to *decide* that schema first: which entities matter, what data they carry, and how they connect. That decision-making process is **data modeling**, and it happens well before a single `CREATE TABLE` statement is typed. Get the model wrong, and every query built on top of it inherits the mistake.

---

## &#128204; Data vs. Information

Two words that sound interchangeable in casual speech mean something precise here:

- **Data** — recorded facts and numbers, on their own. `47`, `2026-07-04`, `"Jacobs"`.
- **Information** — data that has been given meaning through context or processing: summarized, sorted, averaged, compared, grouped. "Employee count grew 12% this quarter" is information; the raw row counts behind it are data.

A database's job is to store data reliably so that information can be produced from it on demand.

---

## &#128204; The Systems Development Life Cycle (SDLC)

Databases are built as part of a larger **information system** — hardware, software, data, procedures, and people working together toward a business goal. The classic methodology for building any information system is the **Systems Development Life Cycle (SDLC)**:

| Stage | Input | What happens | Output |
|---|---|---|---|
| **1. System definition** | A business need | Define project scope, assess feasibility, form the team | Project plan |
| **2. Requirements analysis** | Project plan | Interview users, study existing systems, identify needed reports/queries | Approved user requirements |
| **3. Component design** | Approved requirements | Design hardware, software, database, procedures, and job roles | Documented system design |
| **4. Implementation** | System design | Build, test, integrate, and cut over to the new system | Installed, functioning system |
| **5. Maintenance** | Live system | Patch, tune, and log change requests | Updated system (feeding the next cycle) |

Notice the SDLC is a *cycle*, not a one-way street: maintenance requests eventually trigger a new pass through definition and analysis for the next version of the system.

---

## &#128204; The Database Development Process — A Sub-Cycle Inside the SDLC

Building a database specifically follows a narrower three-stage process nested inside the SDLC's broader steps:

| Phase | Focus |
|---|---|
| **Planning** | Establish the general scope of the database — what business area does it serve? |
| **Analysis** | Determine specific data requirements as seen by the user; produce the conceptual **data model** — an Entity-Relationship (E-R) diagram — and document **business rules** |
| **Design** | Convert the conceptual data model into a database design — a relational schema (tables, columns, keys); write technical specifications |
| **Implementation** | Create the actual database, load data, and build the forms/reports/queries that use it |

A fifth activity — **maintenance** — runs continuously after implementation: tuning performance, fixing bugs, and confirming the database still meets user needs as those needs evolve. And unlike the four phases above, **documentation runs the entire time**, not just at the end — every business rule, design decision, and schema change gets written down as it happens, because a data model no one wrote down is a data model no one can maintain.

> [!NOTE]
> Notice where SQL sits in this lifecycle: everything from Module 03 (`CREATE TABLE`, `INSERT`, `SELECT`) belongs to **implementation** — the *last* phase. This module (04) and Module 05 cover **analysis** and **design** — the phases that must happen *before* implementation produces correct, well-structured tables. Skipping straight to SQL without modeling first is how databases end up with the anomalies described in [Why Databases?](01-01-why-databases.md).

---

## &#128204; Business Rules — The Real Input to a Data Model

A **business rule** is a statement that defines or constrains some aspect of how an organization operates. Business rules — not just "what data exists" — are what actually determine the shape of a data model. Examples:

- "A student may register for a class only if they've completed its prerequisites."
- "No advisor may have more than 25 advisees."
- "Every project must have at least one employee assigned to it."

Some business rules translate cleanly into E-R diagram cardinalities (covered in the next few notes); others are too complex for diagram notation and simply get written down in plain language alongside the model, then enforced later with `CHECK` constraints, triggers, or application code.

The key discipline: **before you can draw an E-R diagram, you need business rules, gathered through requirements analysis** — interviews, existing-form review, sample-report review. A data model built without talking to the people who actually run the business is just a guess with a nice diagram wrapped around it.

---

## &#128204; Where Requirements Actually Come From

Systems analysis rarely starts from a blank page — it starts by mining sources that already exist inside the organization:

- **Existing forms and paper records** — a customer intake sheet, an invoice template, a timesheet. Every field on a real-world form is a strong hint at an attribute the new system needs to capture.
- **Interviews with the people who do the work** — the person entering data by hand every day usually knows exactly where the current process breaks down, long before a diagram is drawn.
- **Sample reports** — if the business currently produces a monthly summary report by hand, whatever data that report pulls together has to exist somewhere in the new model.
- **Existing (even informal) systems** — a spreadsheet, an old database, a shared document — reveal both what data matters today and which anomalies (see [Why Databases?](01-01-why-databases.md)) the redesign needs to fix.

Treat these sources as raw material, not final answers: a paper form built around a flawed process shouldn't be copied field-for-field into a new data model. The analyst's job is to extract the underlying business rules and data needs, not to digitize whatever the old paperwork happened to look like.

---

> [!TIP]
> When you sit down to design a database for a real scenario, resist the urge to open a diagramming tool first. Start by writing down business rules in plain English — "a customer places many orders," "an order must belong to exactly one customer" — and only convert them to entities, attributes, and cardinalities once the rules are clear. [ER Diagram Notation](04-02-er-diagram-notation.md) shows exactly how those sentences become diagram symbols.

---

See also: [Why Databases?](01-01-why-databases.md), [E-R Diagram Notation](04-02-er-diagram-notation.md)

<!-- course-footer -->
---

<div align="center" markdown>

[All Notes](README.md) &nbsp;|&nbsp; [Module 04 Exercise](../02-exercises/04-exercise.md) &nbsp;|&nbsp; <strong>Next:</strong> [E-R Diagram Notation](04-02-er-diagram-notation.md)

</div>
<!-- /course-footer -->
