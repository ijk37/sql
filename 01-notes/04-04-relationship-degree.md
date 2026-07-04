# &#128216; 04-04: Relationship Degree

<!-- course-header -->
<div align="center" markdown>

![SQL & Databases](../assets/banner.svg)

<img src="https://img.shields.io/badge/Module_04-Data_Modeling_ER-336791?style=for-the-badge&labelColor=24506B" alt="Module 04: Data Modeling & E-R Diagrams">

[![Home](https://img.shields.io/badge/⌂_Home-1B2A35?style=flat-square)](../index.md) [![All Notes](https://img.shields.io/badge/All_Notes-1B2A35?style=flat-square)](README.md) [![Practice](https://img.shields.io/badge/✎_Practice-C6821E?style=flat-square&labelColor=24506B)](../02-exercises/04-exercise.md) [![Quiz](https://img.shields.io/badge/▶_Quiz-C6821E?style=flat-square&labelColor=24506B)](../03-quiz/)

</div>
<!-- /course-header -->

## &#128161; Degree = How Many Entity Types Are Involved

[Relationship Types](04-03-relationship-types.md) covered *cardinality* — how many instances relate to how many others. **Degree** answers a different question: how many distinct *entity types* participate in a single relationship? This is a separate, independent property of a relationship — a relationship can be 1:N *and* binary, or N:M *and* unary, and so on.

| Degree | Name | Entity types involved |
|---|---|---|
| 1 | **Unary** (recursive) | One entity type, related to itself |
| 2 | **Binary** | Two distinct entity types |
| 3 | **Ternary** | Three distinct entity types |

---

## &#128204; Unary (Recursive) Relationships

A **unary relationship** connects instances of the *same* entity type to each other. It's also called a **recursive relationship**, because the entity effectively relates back to itself.

*Example:* An `EMPLOYEE` supervises other `EMPLOYEE`s.

```
EMPLOYEE ──○<────────────||── EMPLOYEE
        (as supervisor)   (as subordinate:
         zero-or-many      exactly one supervisor,
         subordinates       though the CEO has none —
                             see note below)
```

This is exactly the Wedgewood Pacific `Supervisor` column: a foreign key on `EMPLOYEE` that references `EmployeeNumber` — also on `EMPLOYEE`. One table, one entity type, a relationship pointing back into itself. In SQL this becomes a self join (see [Joins](03-04-joins.md)):

```sql
SELECT worker.first_name AS employee, boss.first_name AS supervisor
FROM employee worker
LEFT OUTER JOIN employee boss ON worker.supervisor = boss.employee_number;
```

> [!NOTE]
> Mary Jacobs, WP's CEO, has no supervisor — her `Supervisor` column is `NULL`. That's why the subordinate side of this relationship is optional (zero-or-one, not exactly-one) in a fully accurate model: most employees have exactly one supervisor, but the very top of the hierarchy has none. Always check the edge cases in a recursive relationship — someone is usually exempt from the rule.

**Other common unary examples:**
- "A `COURSE` is a prerequisite to other `COURSE`s" (a course can have zero or more prerequisite courses, and be a prerequisite to zero or more other courses — this one is actually N:M, unary).
- "A `PART` is composed of other `PART`s" (bill-of-materials structures — a sub-assembly made of smaller parts).

---

## &#128204; Binary Relationships

A **binary relationship** connects instances of **two different** entity types. This is the shape you've seen in every example so far in this module, and it's by far the most common degree in real-world data modeling.

*Example:* `DEPARTMENT` employs `EMPLOYEE`. Two distinct entity types, one relationship between them.

```
DEPARTMENT ──||─────────────<○── EMPLOYEE
```

Every 1:1, 1:N, and N:M example in [Relationship Types](04-03-relationship-types.md) — department/employee, student/course, employee/project — is binary. When someone says "a relationship" with no further qualifier, binary is almost always what they mean.

---

## &#128204; Ternary Relationships

A **ternary relationship** connects instances of **three** different entity types in a single relationship — not three separate pairwise relationships, but one relationship where an instance of each of the three entities must be present together to make sense.

*Example:* Consider a `SUPPLIER` shipping a `PART` to a `WAREHOUSE`. A single fact — "Supplier X shipped Part Y to Warehouse Z, quantity 500, on this date" — genuinely needs all three entities present at once. You can't fully capture it as "Supplier–Part" plus separately "Part–Warehouse," because that loses which supplier shipped to which warehouse for that specific part.

```
           SUPPLIER
              │
              │
    PART ─────┼───── WAREHOUSE
       (SHIPMENT: Quantity, ShipDate)
```

In practice, a ternary relationship is almost always modeled as an **associative entity** (see [Relationship Types](04-03-relationship-types.md)) with three foreign keys — one to each participating entity — rather than as a single three-way line on the diagram:

```sql
CREATE TABLE shipment (
    supplier_id  INTEGER NOT NULL REFERENCES supplier(supplier_id),
    part_id      INTEGER NOT NULL REFERENCES part(part_id),
    warehouse_id INTEGER NOT NULL REFERENCES warehouse(warehouse_id),
    quantity     INTEGER NOT NULL,
    ship_date    DATE NOT NULL,
    PRIMARY KEY (supplier_id, part_id, warehouse_id, ship_date)
);
```

> [!NOTE]
> Ternary relationships are genuinely rarer than binary ones, and it's worth double-checking before modeling one: many situations that look ternary at first glance can actually be decomposed into two or three independent binary relationships without losing information. Only model a true ternary relationship when the fact you're recording *requires* all three entities simultaneously to mean anything — as with the supplier/part/warehouse shipment above.

---

## &#128204; Degree and Cardinality Are Independent

Don't conflate degree with cardinality — they answer different questions and combine freely:

| | Unary | Binary | Ternary |
|---|---|---|---|
| **1:1** possible? | Rare (e.g., each item has exactly one "successor" item) | Yes (employee/parking spot) | Uncommon |
| **1:N** possible? | Yes (employee/supervisor) | Yes — most common combination overall (department/employee) | Possible but unusual |
| **N:M** possible? | Yes (course/prerequisite-course) | Yes (student/course) | Yes (supplier/part/warehouse) |

A relationship's degree tells you *how many kinds of things* are connected; its cardinality tells you *how many instances* of each can pair up. Both must be nailed down before the diagram — or the resulting tables — will be correct.

---

See also: [Relationship Types](04-03-relationship-types.md), [Context-Dependent Design](04-05-context-dependent-design.md)

<!-- course-footer -->
---

<div align="center" markdown>

[All Notes](README.md) &nbsp;|&nbsp; [Module 04 Exercise](../02-exercises/04-exercise.md) &nbsp;|&nbsp; <strong>Next:</strong> [Context-Dependent Design](04-05-context-dependent-design.md)

</div>
<!-- /course-footer -->
