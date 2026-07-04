# &#128736; Project 04 — Full ER Diagram Design

<!-- course-header -->
<div align="center" markdown>

![SQL & Databases](../../assets/banner.svg)

[![View the live site — ijk37.com](https://img.shields.io/badge/%F0%9F%87%A7%F0%9F%87%A9_View_the_Live_Site-IJK37.COM-F42A41?style=for-the-badge&labelColor=006A4E)](https://ijk37.com/sql/)

<img src="https://img.shields.io/badge/Project_04-Full_ER_Diagram_Design-336791?style=for-the-badge&labelColor=24506B" alt="Project 04: Full ER Diagram Design">

[![Home](https://img.shields.io/badge/⌂_Home-1B2A35?style=flat-square)](../../index.md) [![All Projects](https://img.shields.io/badge/All_Projects-1B2A35?style=flat-square)](../README.md) [![Notes](https://img.shields.io/badge/Notes-1B2A35?style=flat-square)](../../01-notes/04-01-systems-analysis-and-db-lifecycle.md) [![Quiz](https://img.shields.io/badge/▶_Quiz-C6821E?style=flat-square&labelColor=24506B)](../../03-quiz/)

</div>
<!-- /course-header -->

**Type:** Design document (draw.io, Crow's Foot notation)
**Modules:** 04 (Data Modeling & E-R Diagrams)
**Difficulty:** ⭐⭐⭐

---

## &#127919; Objective

Design a complete **Crow's Foot E-R diagram** — entities, attributes, identifiers, relationships, and cardinalities — for a small retail jewelry business, then extend it to cover a customer rewards program. This project pulls together every concept from Module 04: entities and attributes, cardinality notation, associative entities, and context-driven cardinality decisions.

---

## &#129517; Scenario: Cascade River Jewelers

**Cascade River Jewelers** is a small chain of jewelry stores. The owner has described the business to you as follows:

- The store only creates a **customer record** the first time someone completes a purchase — people who browse but never buy are never entered into the system. Each customer has a name, phone number, and email address.
- Each **purchase** is a single transaction: it has an invoice number, a date, and a pre-tax dollar amount. Every purchase belongs to exactly one customer, and a customer may have made many purchases over time.
- A single purchase can include **multiple items** — a ring and a necklace bought together in one transaction, for example. Each line item on a purchase records which specific piece was bought and at what price; a purchase must include at least one item to count as a purchase at all.
- Every piece of jewelry in inventory is an **item**, with its own item number, description, and current price. An item might exist in inventory for a long time before it's ever sold — or might never sell at all.
- The owner is now adding a **rewards program**: customers accumulate points for every purchase (1 point per dollar of pre-tax amount), and can redeem accumulated points for **awards** — things like a free cleaning, a discount voucher, or a small gift. Each award has a description and a point cost. A customer may redeem the same award more than once over time (each redemption is a separate event, on its own date), and a customer might never redeem anything at all. The store wants to track, for every customer enrolled in the program, a running total of points currently available.

---

## &#128204; Requirements

1. Use **Crow's Foot (IE) notation** for every relationship — see [E-R Diagram Notation](../../01-notes/04-02-er-diagram-notation.md) if you need a refresher on reading the symbols.
2. Identify **at least five entities** total (hint: the base scenario alone needs four; the rewards program adds at least two more).
3. Every entity needs a clearly marked **identifier** (primary key) and a short list of relevant attributes.
4. Every relationship needs **both** a maximum and a minimum cardinality on **both** ends, and each cardinality choice must be justified by a specific sentence from the scenario above — not by assumption.
5. At least **one relationship must require an associative entity** — identify which one, and explain why a plain N:M line wouldn't work.

---

## &#129513; Tasks

### &#128313; Part A — List Entities and Attributes

1. From the scenario, list every entity you can identify. Do not include `CASCADE RIVER JEWELERS` itself as an entity — the whole diagram models *its* data, so the company can't be inside its own model.
2. For each entity, list its identifier and 2–4 other relevant attributes.

### &#128313; Part B — Base Relationships (Customer, Purchase, Item)

1. Draw the `CUSTOMER`–`PURCHASE` relationship. Justify the minimum cardinality on the `CUSTOMER` side using the specific business rule about when customer records are created.
2. Draw the `PURCHASE`–`ITEM` relationship. Since a purchase can include several items, and the same item could theoretically appear across many purchases over time (assuming inventory is restocked), decide: does this need a plain relationship, or an associative entity? Justify your answer, including what attribute (if any) belongs on the relationship itself rather than on `PURCHASE` or `ITEM`.

### &#128313; Part C — Extend for the Rewards Program

1. Add entities to represent: the running points balance per customer, the catalog of available awards, and the record of each redemption event.
2. Connect these new entities back to `CUSTOMER` with correctly justified cardinalities — pay close attention to which relationships are optional (a customer who has never redeemed anything) versus mandatory.
3. Identify which new relationship(s) require an associative entity, and why.

### &#128313; Part D — Validate

1. Pick two use cases (e.g., "show every award a specific customer has redeemed" and "show every purchase that included a specific item") and trace them through your diagram — confirm you can actually answer both questions by following relationship lines.
2. Write 3–5 sentences describing how you'd validate this model with the store owner before building the real database (see [Systems Analysis & DB Lifecycle](../../01-notes/04-01-systems-analysis-and-db-lifecycle.md) on data model validation).

---

## &#9989; Verification Checklist

- [ ] At least five entities, each with an identifier and relevant attributes.
- [ ] Every relationship shows both minimum and maximum cardinality on both ends, in Crow's Foot notation.
- [ ] Every cardinality choice is justified with a quoted or paraphrased sentence from the scenario — not left unexplained.
- [ ] At least one associative entity appears, with a clear explanation of the N:M relationship it resolves and what attribute(s) it holds.
- [ ] No foreign keys are shown inside entity boxes (this is a conceptual diagram — see [E-R Diagram Notation](../../01-notes/04-02-er-diagram-notation.md)).
- [ ] `CASCADE RIVER JEWELERS` itself does not appear as an entity in the model.
- [ ] Both Part D use cases can be traced end-to-end through the diagram without a missing link.

---

## &#128230; Deliverables

- A complete Crow's Foot E-R diagram, built in [draw.io](https://app.diagrams.net/) (free, no login required), exported as `.png` or `.svg`, plus the `.drawio` source file.
- A short written justification (1–2 sentences per relationship) for every cardinality decision.
- The Part D validation write-up (3–5 sentences).

---

## &#128640; Stretch Goals

- Model a `STORE_LOCATION` entity (Cascade River has multiple physical stores) and decide how it connects to `PURCHASE` — does a purchase happen at exactly one location?
- Add a `PREFERRED_STYLE` or `WISH_LIST` entity capturing which categories of jewelry a customer has expressed interest in, independent of any purchase — this mirrors how customer *interest* (not just completed transactions) sometimes needs its own N:M relationship in a real CRM-style extension.
- Re-examine your `PURCHASE`–`ITEM` design: what would change if the business started tracking returns (a purchase amount could go negative)? Would any cardinality or entity need to change?

See also notes: [Relationship Types](../../01-notes/04-03-relationship-types.md), [Context-Dependent Design](../../01-notes/04-05-context-dependent-design.md)

<!-- course-footer -->
---

<div align="center" markdown>

[All Projects](../README.md) &nbsp;|&nbsp; [Module 04 Notes](../../01-notes/04-01-systems-analysis-and-db-lifecycle.md) &nbsp;|&nbsp; <strong>Next:</strong> [Project 05 — Normalization &amp; Schema Refinement](../05-normalization-and-refinement/README.md)

</div>
<!-- /course-footer -->
