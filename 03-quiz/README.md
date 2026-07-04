# &#128451;&#65039; 03 Quiz

<div align="center">

<a href="https://ijk37.com/sql/03-quiz/"><img src="../assets/banner.svg" alt="SQL & Databases" width="100%"></a>

[![View the live site — ijk37.com](https://img.shields.io/badge/%F0%9F%87%A7%F0%9F%87%A9_View_the_Live_Site-IJK37.COM-F42A41?style=for-the-badge&labelColor=006A4E)](https://ijk37.com/sql/)

<a href="https://ijk37.com/sql/03-quiz/"><img src="https://img.shields.io/badge/▶_Launch_Quiz_Hub-C6821E?style=for-the-badge&labelColor=24506B" alt="Launch Quiz Hub"></a>

<a href="../README.md">Home</a> &nbsp;|&nbsp; <a href="../01-notes/README.md">Notes</a> &nbsp;|&nbsp; <a href="../02-exercises/README.md">Exercises</a> &nbsp;|&nbsp; <a href="../04-projects/README.md">Projects</a>

</div>

Interactive multiple-choice quizzes for all 8 **SQL & Databases** modules, plus 3 cumulative mixed reviews — Postgres blue & MySQL amber theme, built with plain HTML + JavaScript, no server required.

**Locally:** open `index.html` in your browser.

---

## &#128451;&#65039; Module Quizzes

Each module has a pool of **~30-40 questions**; every attempt shows **20 random** of them.

| # | Module | Pool |
|---|--------|------|
| 01 | Getting Started | ~30-40 |
| 02 | The Relational Model | ~30-40 |
| 03 | SQL Fundamentals | ~30-40 |
| 04 | Data Modeling & E-R Diagrams | ~30-40 |
| 05 | Database Design & Normalization | ~30-40 |
| 06 | Database Administration | ~30-40 |
| 07 | Data Warehousing, BI & Big Data | ~30-40 |
| 08 | Advanced SQL | ~30-40 |

**Total: ~300 module questions** (20 drawn per attempt).

## &#129514; Mixed Reviews

Cumulative checkpoints sampled across a growing range of modules, so weak spots from earlier material stay in rotation.

| Quiz | Coverage | Questions per attempt |
|------|----------|-----------------------|
| Mixed Review 1 | Modules 01-04 | 40 |
| Mixed Review 2 | Modules 01-06 | 50 |
| Final Mixed Review | Modules 01-08 | 60 |

## &#9989; How It Works

- **Randomized attempts** — every attempt draws a fresh random subset from the pool; answer options are reshuffled too, so memorizing position doesn't help.
- **Question navigator** — jump between questions, see which are answered, and finish whenever you're ready.
- **Instant scoring + full review** — after finishing, every question is reviewed with your answer, the correct answer, and an explanation.
- **Elapsed timer** — tracks how long an attempt takes (no penalty, just feedback).

## &#128736; Files

```
03-quiz/
├── index.html          # hub — links to quiz.html?topic=<id>
├── quiz.html            # engine — all quiz logic + inline styling
├── data.js               # TOPICS, QUIZ_CONFIG, QUESTIONS = {}
├── data-01.js … data-08.js   # one question pool per module
├── data-mixed-1.js       # shared sampling helpers + Mixed Review 1
├── data-mixed-2.js       # Mixed Review 2
└── data-mixed-3.js       # Final Mixed Review
```

[← Back to Root](../README.md)
