# &#128736; Project 01 — Conceptual E-R Modeling

<!-- course-header -->
<div align="center" markdown>

![SQL & Databases](../../assets/banner.svg)

[![View the live site — ijk37.com](https://img.shields.io/badge/%F0%9F%87%A7%F0%9F%87%A9_View_the_Live_Site-IJK37.COM-F42A41?style=for-the-badge&labelColor=006A4E)](https://ijk37.com/sql/)

<img src="https://img.shields.io/badge/Project_01-Conceptual_ER_Modeling-336791?style=for-the-badge&labelColor=24506B" alt="Project 01: Conceptual ER Modeling">

[![Home](https://img.shields.io/badge/⌂_Home-1B2A35?style=flat-square)](../../index.md) [![All Projects](https://img.shields.io/badge/All_Projects-1B2A35?style=flat-square)](../README.md) [![Notes](https://img.shields.io/badge/Notes-1B2A35?style=flat-square)](../../01-notes/01-01-why-databases.md) [![Quiz](https://img.shields.io/badge/▶_Quiz-C6821E?style=flat-square&labelColor=24506B)](../../03-quiz/)

</div>
<!-- /course-header -->

**Type:** Design document (draw.io or pen-and-paper)
**Modules:** 01 (Getting Started)
**Difficulty:** ⭐⭐

---

## &#127919; Objective

Read a short narrative business scenario, identify the distinct **themes** (entities) hiding inside it, and sketch a **conceptual entity-relationship (E-R) diagram** — entities and the relationships between them only, with no attributes yet. This project is deliberately scoped to *before* you know formal keys or table design; it's about training your eye to spot "how many separate things are really being described here?"

---

## &#129517; Scenario: San Juan Sailboat Charters

**San Juan Sailboat Charters (SJSBC)** arranges sailboat charters out of a small marina in the Pacific Northwest. Right now, the whole business is tracked in one spreadsheet, with one row per charter booking:

| OwnerID | Owner Name | Phone | Billing Address | BoatID | Boat Name | Make | Model | Length | CharterID | Charter Date | Charter Customer | Amount Charged |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 101 | John Miller | 555-111-2222 | 12 Bay St, Seattle WA | B01 | Sea Breeze | Beneteau | Oceanis 38 | 38 ft | C001 | 2026-06-12 | Alice Green | $1,200 |
| 102 | Sarah Johnson | 555-333-4444 | 85 Harbor Rd, Tacoma | B02 | Wind Rider | Hunter | 356 Cruiser | 35 ft | C002 | 2026-06-15 | Robert Smith | $950 |
| 103 | David Lopez | 555-555-6666 | 190 Ocean Dr, Anacortes | B03 | Island Star | Catalina | 445 | 44 ft | C003 | 2026-06-20 | Lisa Wong | $1,500 |
| 101 | John Miller | 555-111-2222 | 12 Bay St, Seattle WA | B04 | Blue Horizon | Jeanneau | Sun Odyssey | 51 ft | C004 | 2026-07-01 | Emily Davis | $2,300 |

The marina's owner has noticed some problems with keeping the business this way:

- John Miller owns two boats. His phone number and billing address are typed out twice — and there's no guarantee both copies will ever be updated the same way.
- A boat that hasn't been chartered yet has no row at all — meaning it can't be entered into the system until *after* its first booking.
- If a charter record is deleted (say, a data-entry mistake for Wind Rider's booking), the only record of the boat *and* its owner disappears along with it.

Your job in this project is **not** to fix the spreadsheet with SQL yet — that comes in later modules. Your job is to figure out, conceptually, what the *real* underlying "things" are, and how they connect.

---

## &#128204; Requirements

1. Do not look at column names and assume each one is a separate entity — think about **themes**. Several columns above belong to the *same* theme.
2. Identify at least three entities in this scenario.
3. For each relationship between two entities, decide (in plain language, no notation needed yet) whether it feels like "one owner, many boats" or "many boats, many charters," etc. — you'll formalize this as relationship degree/cardinality in Module 04.
4. Your diagram should show **entities and relationships only** — no attributes, no primary keys, no data types. That level of detail is deliberately deferred to Module 04's E-R notation and Module 05's table design.

---

## &#129513; Tasks

### &#128313; Part A — Spot the Themes

1. Re-read the spreadsheet and list every distinct "kind of thing" being described (hint: an owner is a different kind of thing than a boat, which is a different kind of thing than a charter booking).
2. For each theme, give it a short, singular, capitalized name (e.g., `OWNER`, `BOAT`, `CHARTER`).
3. Write one sentence per theme describing what it represents in the real world.

### &#128313; Part B — Identify the Relationships

1. For each pair of entities that seem connected, describe the relationship in a sentence: "An owner may own one or more boats." "A boat may be booked for zero or more charters."
2. Note which relationships feel like "one-to-many" in plain language (you don't need the formal crow's-foot notation yet — just describe it in words).

### &#128313; Part C — Draw the Conceptual E-R Diagram

1. Using [draw.io](https://app.diagrams.net/) (free, no login required) or pen-and-paper, draw a box for each entity you identified in Part A.
2. Draw a line connecting each pair of entities that has a relationship, labeled with a short verb phrase (e.g., "owns," "is booked for").
3. Do **not** add attribute lists inside the boxes yet — just the entity name and the connecting lines. That level of detail comes in Module 04.

---

## &#9989; Verification Checklist

- [ ] At least three distinct entities identified, each representing exactly one theme.
- [ ] No entity mixes two unrelated themes together (re-read [Why Databases?](../../01-notes/01-01-why-databases.md) if unsure).
- [ ] Every relationship in your diagram is labeled with a short, plain-English verb phrase.
- [ ] The diagram shows entities and relationships only — no attributes, no keys, no data types.
- [ ] You can explain, in one or two sentences each, why the original single-spreadsheet design caused an update, insertion, and deletion anomaly.

---

## &#128230; Deliverables

- A conceptual E-R diagram (draw.io export as `.png`/`.svg`/`.drawio`, or a clear photo of a hand-drawn sketch).
- A short written explanation (3–5 sentences) connecting at least one update, one insertion, and one deletion anomaly you found in the original spreadsheet back to specific rows in the sample data above.

---

## &#128640; Stretch Goals

- Add a fourth entity if you can spot one hiding in the data that wasn't obvious at first glance (hint: think about what "Charter Customer" really represents — is it the same kind of thing as an owner?).
- Sketch a rough guess at cardinality using crow's-foot-style symbols, even though formal notation isn't taught until Module 04 — see how close your intuition gets.

See also notes: [Why Databases?](../../01-notes/01-01-why-databases.md), [Relational Tables & Database Systems](../../01-notes/01-02-relational-tables-and-db-systems.md)

<!-- course-footer -->
---

<div align="center" markdown>

[All Projects](../README.md) &nbsp;|&nbsp; [Module 01 Notes](../../01-notes/01-01-why-databases.md) &nbsp;|&nbsp; <strong>Next:</strong> [Project 02 — Relational Schema &amp; Keys](../02-relational-schema-and-keys/README.md)

</div>
<!-- /course-footer -->
