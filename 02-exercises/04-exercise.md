# &#9997; 04: Data Modeling & E-R Diagrams — Exercises

<!-- course-header -->
<div align="center" markdown>

![SQL & Databases](../assets/banner.svg)

<img src="https://img.shields.io/badge/Module_04-Data_Modeling_ER-336791?style=for-the-badge&labelColor=24506B" alt="Module 04: Data Modeling & E-R Diagrams"> <img src="https://img.shields.io/badge/12_questions-C6821E?style=for-the-badge&labelColor=24506B" alt="12 questions">

[![Home](https://img.shields.io/badge/⌂_Home-1B2A35?style=flat-square)](../index.md) [![Notes](https://img.shields.io/badge/Notes-1B2A35?style=flat-square)](../01-notes/04-01-systems-analysis-and-db-lifecycle.md) [![All Exercises](https://img.shields.io/badge/All_Exercises-1B2A35?style=flat-square)](README.md) [![Quiz](https://img.shields.io/badge/▶_Quiz-C6821E?style=flat-square&labelColor=24506B)](../03-quiz/)

</div>
<!-- /course-header -->

> [!TIP]
> **Practice —** for each scenario, identify the relationship type, its cardinality, and (where relevant) whether an associative entity is needed — then expand the answer to check your reasoning.

Work through each question, then click **▶ Show answer** to check yourself. Review the [notes](../01-notes/04-01-systems-analysis-and-db-lifecycle.md) if you get stuck.

---

### &#128313; Q1. "A `WAREHOUSE` stores many `PRODUCT`s, but each product is stored in exactly one warehouse." What is the maximum cardinality of this relationship?

<details>
<summary><strong>Show answer</strong></summary>

**One-to-Many (1:N).** One warehouse relates to many products; each product relates to exactly one warehouse. The crow's foot (many) sits on the `PRODUCT` end, and a single bar (one) sits on the `WAREHOUSE` end.
</details>

---

### &#10067; Q2. "A `PATIENT` may be assigned one `PRIMARY_CARE_DOCTOR`, and a doctor may be the primary-care doctor for many patients — but a doctor might not have any assigned patients yet, and a patient might not have picked a doctor yet." Identify the cardinality and minimum cardinalities on both ends.

<details>
<summary><strong>Show answer</strong></summary>

**One-to-Many (1:N)**, `DOCTOR` to `PATIENT`. Maximum cardinalities: one doctor → many patients; one patient → one doctor. Minimum cardinalities are both **zero (optional)** on the "one" side and the "many" side's matching entity: a doctor can exist with zero assigned patients, and a patient can exist with no doctor picked yet. In Crow's Foot terms, both ends get the "zero" circle in addition to their bar/crow's-foot.
</details>

---

### &#128313; Q3. "A `STUDENT` can join many `CLUB`s, and each `CLUB` has many `STUDENT` members." What relationship type is this, and what extra construct would you need if the school wants to record each student's `JoinDate` per club?

<details>
<summary><strong>Show answer</strong></summary>

**Many-to-Many (N:M).** Since `JoinDate` is a fact about the *pairing* (this student, in this club, joined on this date) rather than about either entity alone, it can't be placed on `STUDENT` or `CLUB` directly. You need an **associative entity** — e.g., `MEMBERSHIP(StudentID, ClubID, JoinDate)` — that links both entities and holds the pairing-specific attribute.
</details>

---

### &#10067; Q4. A vehicle manufacturer tracks `EMPLOYEE`s and wants to record each employee's `EMERGENCY_CONTACT`. An emergency contact record cannot exist without the employee it belongs to, and has no meaningful identifier of its own outside that context. What kind of entity is `EMERGENCY_CONTACT`, and what would its identifier look like?

<details>
<summary><strong>Show answer</strong></summary>

This is a **weak entity** — specifically an **ID-dependent weak entity**, since it has no standalone identifier. Its identifier would be a composite: `(EmployeeNumber, ContactID)`, where `EmployeeNumber` comes from the parent `EMPLOYEE` and `ContactID` is just a partial key distinguishing multiple contacts for the same employee (contact #1, contact #2, ...). The relationship connecting them is drawn with a solid line (an identifying relationship).
</details>

---

### &#128313; Q5. "An `ITEM` can be sold in many `SHIPMENT`s, and a `SHIPMENT` can contain many `ITEM`s, with a `QuantityShipped` recorded for each item on each shipment." Name the resolving entity and its likely primary key.

<details>
<summary><strong>Show answer</strong></summary>

This N:M relationship resolves into an **associative entity** — call it `SHIPMENT_ITEM` — with a composite primary key of `(ShipmentID, ItemID)` and an attribute `QuantityShipped` that belongs to that specific pairing. `SHIPMENT_ITEM` also functions as an ID-dependent weak entity relative to both parents.
</details>

---

### &#10067; Q6. "An `EMPLOYEE` may supervise several other `EMPLOYEE`s, but each employee has at most one supervisor." What is the degree of this relationship, and what is it also called?

<details>
<summary><strong>Show answer</strong></summary>

**Degree 1 — a unary (recursive) relationship.** Only one entity type (`EMPLOYEE`) is involved; the relationship connects instances of that entity type back to other instances of the same type (a supervisor is just another employee).
</details>

---

### &#128313; Q7. "A `PROFESSOR` teaches a `CLASS`." Is this a binary or a ternary relationship? What would make it ternary instead?

<details>
<summary><strong>Show answer</strong></summary>

As stated, this is **binary** — two entity types, `PROFESSOR` and `CLASS`. It would become **ternary** if a third entity type had to be present simultaneously for the fact to make sense — for example, if the business also needed to record *which classroom* a specific professor-class pairing meets in for a specific term: `PROFESSOR`–`CLASS`–`ROOM` (or `–TERM`) all at once, where "who teaches what, where, and when" can't be decomposed without losing information.
</details>

---

### &#10067; Q8. A retailer models `SUPPLIER`, `PART`, and `WAREHOUSE`, needing to record "Supplier X shipped Part Y to Warehouse Z on this date, this quantity." Why can't this be modeled as three separate binary relationships without losing information?

<details>
<summary><strong>Show answer</strong></summary>

Because the fact being recorded is inherently a **ternary relationship** — a single shipment event ties all three entities together at once (this supplier, this part, this warehouse, this date/quantity). Splitting it into "Supplier–Part," "Part–Warehouse," and "Supplier–Warehouse" as three independent binary relationships loses the connection between *which* supplier shipped *which* part to *which* warehouse — you could no longer tell, from the data alone, that it was specifically Supplier X (not some other supplier of Part Y) who shipped to Warehouse Z. The fix is a `SHIPMENT` associative entity with three foreign keys, one to each participant.
</details>

---

### &#128313; Q9. A university is deciding whether to connect `PROFESSOR` directly to `CLASS`, or `PROFESSOR` directly to `DEPARTMENT` — not both. The team building an **enrollment/registration system** wants to know "who teaches Section 2 of Biology 101 this term?" Which relationship should this system prioritize, and why?

<details>
<summary><strong>Show answer</strong></summary>

**PROFESSOR–CLASS.** The business question ("who teaches this specific section?") is answered directly by that relationship. `DEPARTMENT` can often be inferred indirectly (through `CLASS.DepartmentName`) without needing a direct `PROFESSOR`–`DEPARTMENT` link in this particular system. This is a context-dependent design decision, not a universal rule — a different system (HR/payroll) might prioritize the opposite relationship for the same real-world professors and departments.
</details>

---

### &#10067; Q10. The HR/payroll team building a separate system wants to know "how many faculty report to the Biology department for review purposes?" Which relationship should *their* system prioritize?

<details>
<summary><strong>Show answer</strong></summary>

**PROFESSOR–DEPARTMENT.** Their business question is about organizational reporting structure, not classroom scheduling, so the direct relationship they need is `PROFESSOR` to `DEPARTMENT`. Note this is the same two professors and the same real-world facts as Q9 — the *system's purpose*, not the data itself, determined which relationship to model directly.
</details>

---

### &#128313; Q11. A jewelry retailer currently only creates a `CUSTOMER` record after someone completes their first purchase — browsers are never recorded. What should the minimum cardinality be on the `CUSTOMER` side of the `CUSTOMER`–`PURCHASE` relationship, and why?

<details>
<summary><strong>Show answer</strong></summary>

**Minimum cardinality = 1 (mandatory).** Because of this specific business rule (customers are only entered into the database once they've made a purchase), every `CUSTOMER` row is guaranteed to have at least one related `PURCHASE` row — being in the `CUSTOMER` table *implies* a purchase exists. If the business changed its policy to record prospective customers before any purchase (e.g., a marketing sign-up list), this minimum would need to change to 0, or a separate `LEAD` entity might be needed upstream of `CUSTOMER`.
</details>

---

### &#10067; Q12. A training center's policy states: "each class is taught by exactly one instructor, and an instructor may teach up to two classes." A different training center allows co-taught classes with no cap on how many classes an instructor teaches. How does the second policy change the `INSTRUCTOR`–`CLASS` relationship's cardinality, and what extra construct might it require?

<details>
<summary><strong>Show answer</strong></summary>

The first center's policy makes `INSTRUCTOR`–`CLASS` a **1:N relationship** (one instructor per class, an instructor teaches many classes, capped at two by a business rule rather than the model itself). The second center's co-teaching policy makes the *same two entity types* an **N:M relationship** instead — since a class can now have multiple instructors — which would need an associative entity such as `CLASS_ASSIGNMENT(ClassID, InstructorID)` to resolve. Nothing about `INSTRUCTOR` or `CLASS` themselves changed; only the business policy did, and that alone flips the correct cardinality.
</details>

---

[📚 All Exercises](README.md)  ·  **Next:** [Module 05 — Database Design & Normalization](05-exercise.md)

<!-- course-footer -->
---

<div align="center" markdown>

[All Exercises](README.md) &nbsp;|&nbsp; [Module 04 Notes](../01-notes/04-01-systems-analysis-and-db-lifecycle.md) &nbsp;|&nbsp; <strong>Next:</strong> [05: Database Design &amp; Normalization — Exercises](05-exercise.md)

</div>
<!-- /course-footer -->
