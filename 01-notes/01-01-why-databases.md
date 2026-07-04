# &#128216; 01-01: Why Databases?

<!-- course-header -->
<div align="center" markdown>

![SQL & Databases](../assets/banner.svg)

<img src="https://img.shields.io/badge/Module_01-Getting_Started-336791?style=for-the-badge&labelColor=24506B" alt="Module 01: Getting Started">

[![Home](https://img.shields.io/badge/⌂_Home-1B2A35?style=flat-square)](../index.md) [![All Notes](https://img.shields.io/badge/All_Notes-1B2A35?style=flat-square)](README.md) [![Practice](https://img.shields.io/badge/✎_Practice-C6821E?style=flat-square&labelColor=24506B)](../02-exercises/01-exercise.md) [![Quiz](https://img.shields.io/badge/▶_Quiz-C6821E?style=flat-square&labelColor=24506B)](../03-quiz/)

</div>
<!-- /course-header -->

## &#128161; What a Database Is For

At its core, a database exists to **keep track of things** — customers, products, employees, orders, sailboats, whatever your organization cares about. The moment you're tracking more than one *kind* of thing, and those things relate to each other, a single flat list stops being enough.

- **Data** is a recorded fact — a name, a number, a date.
- A **database** is a structure for storing data so it can be reliably stored, retrieved, and kept consistent.

Every web app, mobile app, and IoT device you use is backed by one. The interesting question isn't *whether* to use a database — it's *why a single spreadsheet-style list breaks down* as soon as real-world data gets even a little complicated.

---

## &#128204; The Trouble With Lists

Imagine a small lending office — call it **Fast Cash Loans** — that keeps track of its customers in a single spreadsheet:

| Cust_No | Name | Phone | Spouse |
|---|---|---|---|
| A2001 | Bingo, John | (330) 528-6273 | Jenny |
| A2002 | Cusack, Philip | (330) 672-5432 | |
| A2110 | Hanks, Will | (818) 223-7809 | Lily |
| B1201 | Wit, John | (312) 765-9087 | Lisa |

This works fine — until someone asks the office to also track each customer's **children**, because collections agents need next-of-kin contacts. The obvious first move is to just add more columns:

| Cust_No | Name | Phone | Spouse | Child1 | Child2 | Child3 |
|---|---|---|---|---|---|---|
| A2001 | Bingo, John | (330) 528-6273 | Jenny | Philip | Megan | |
| B1201 | Wit, John | (312) 765-9087 | Lisa | Pierce | Johnny | |

This looks harmless in a demo with two kids. In practice it's a trap:

- **What if a customer has four children? Ten?** You either keep bolting on `Child4`, `Child5`, ... columns, or you truncate real data because the sheet ran out of room.
- **Wasted space.** Every customer with zero or one child still carries three empty `Child` columns.
- **No good way to query "list every child in the system."** The children are smeared across repeating columns instead of living in rows you can search, count, or sort.

This pattern — cramming a *repeating group* of related facts into extra columns on one row — is one of the most common design mistakes beginners make, and it's exactly what a relational database is built to avoid.

---

## &#128204; Modification Anomalies

Even without the repeating-children problem, a list that mixes more than one *theme* on a single row causes trouble the moment you try to change the data. These problems have names:

| Anomaly | What goes wrong |
|---|---|
| **Update anomaly** | The same fact is stored in more than one place. Change it in one row and forget another, and the data becomes contradictory. |
| **Insertion anomaly** | You can't add a new fact without also being forced to invent or omit unrelated data. |
| **Deletion anomaly** | Removing one row accidentally destroys a fact that had nothing to do with the reason you deleted it. |

Suppose Fast Cash Loans also wants to log each **loan payment**, and — trying to avoid a second spreadsheet — tacks payment history onto the same customer row:

| Cust_No | Name | Phone | Loan_Amount | Loan_Date | Payment_Amount |
|---|---|---|---|---|---|
| A2001 | Bingo, John | (330) 528-6273 | 5000 | 2026-01-10 | 250 |
| A2001 | Bingo, John | (330) 528-6273 | 5000 | 2026-01-10 | 250 |
| A2001 | Bingo, John | (330) 528-6273 | 5000 | 2026-01-10 | 250 |

- **Update anomaly:** John Bingo moves and gets a new phone number. It's repeated on every one of his payment rows — miss one, and the system now disagrees with itself about his own phone number.
- **Insertion anomaly:** A brand-new customer who hasn't made a payment yet can't be entered at all, because every row *requires* a `Payment_Amount`. Do you invent a fake $0 payment just to store the customer's name and phone number?
- **Deletion anomaly:** John Bingo pays off his loan and every payment row is deleted for bookkeeping cleanup. His name, phone number, and existence as a customer vanish along with the payment history — even though he's still a customer who might take out another loan next year.

All three anomalies trace back to the same root cause: **the row mixes two themes** — facts about the *customer* and facts about a *payment* — that don't share the same lifecycle. A customer can exist with zero, one, or a hundred payments; forcing them onto one row means the row's shape can never comfortably fit all three cases.

> [!NOTE]
> This scenario is a stand-in for a classic "Loan Shark" teaching example used in database courses. The names and numbers here are original, but the shape of the problem — repeating groups, then anomalies once a second theme gets bolted on — is the textbook pattern you'll see in almost every intro database course.

---

## &#128204; The Fix: One Theme per Table

The relational fix is simple to state and takes practice to apply well: **split the list into separate tables, one per theme**, and use a shared column to relate them back together.

```sql
CREATE TABLE customer (
    cust_no     VARCHAR(10) PRIMARY KEY,
    full_name   VARCHAR(100) NOT NULL,
    phone       VARCHAR(20),
    spouse_name VARCHAR(100)
);

CREATE TABLE loan_payment (
    payment_id     SERIAL PRIMARY KEY,
    cust_no        VARCHAR(10) NOT NULL REFERENCES customer(cust_no),
    payment_amount NUMERIC(10, 2) NOT NULL,
    payment_date   DATE NOT NULL
);
```

Now:

- Adding a new customer with no payments yet is trivial — just insert one row into `customer`.
- Changing John Bingo's phone number is **one** `UPDATE` statement against **one** row.
- Deleting old payment history from `loan_payment` never touches `customer` — his record stays put.
- Any number of children, payments, or loans can be added by inserting more *rows*, never more *columns*.

This is the central idea of the relational model, and the rest of this module (and Module 02) builds out the vocabulary and rules for doing it correctly.

> [!TIP]
> A good rule of thumb while you're learning: if you catch yourself naming columns `Child1`, `Child2`, `Payment1`, `Payment2` — stop. That's a repeating group, and it almost always means "this belongs in its own table, related back by a key."

---

See also: [Relational Tables & Database Systems](01-02-relational-tables-and-db-systems.md), [Keys](02-03-keys.md)

<!-- course-footer -->
---

<div align="center" markdown>

[All Notes](README.md) &nbsp;|&nbsp; [Module 01 Exercise](../02-exercises/01-exercise.md) &nbsp;|&nbsp; <strong>Next:</strong> [Relational Tables &amp; Database Systems](01-02-relational-tables-and-db-systems.md)

</div>
<!-- /course-footer -->
