// ============================================================================
//  SQL & Databases Quiz Data — Database Concepts, 9th Edition (Kroenke)
//  data.js        →  TOPICS list + shared config
//  data-01..08.js  →  module quizzes
//  data-mixed-1..3.js → cumulative mixed quizzes
// ============================================================================

const TOPICS = [
  { id: "01", title: "Getting Started" },
  { id: "02", title: "The Relational Model" },
  { id: "03", title: "SQL Fundamentals" },
  { id: "04", title: "Data Modeling & E-R Diagrams" },
  { id: "05", title: "Database Design & Normalization" },
  { id: "06", title: "Database Administration" },
  { id: "07", title: "Data Warehousing, BI & Big Data" },
  { id: "08", title: "Advanced SQL" },
  { id: "mixed-1", title: "Mixed Review 1 (Modules 1-4)" },
  { id: "mixed-2", title: "Mixed Review 2 (Modules 1-6)" },
  { id: "mixed-3", title: "Final Mixed Review (Modules 1-8)" },
];

// ── Quiz sizing ─────────────────────────────────────────────────────────────
// Each attempt draws a RANDOM subset of this many questions from the topic
// pool (re-picked on every retry). If a pool is smaller than the configured
// size, the whole pool is used. Override per attempt with a ?n= URL parameter.
const QUIZ_CONFIG = {
  defaultAttempt: 25,        // random questions per attempt for module quizzes
  attempt: {                 // per-topic overrides (mixed quizzes stay large)
    "mixed-1": 50,
    "mixed-2": 65,
    "mixed-3": 80,
  },
};

// How many questions a given topic shows per attempt (capped at pool size).
function attemptSizeFor(topicId, poolLen) {
  const cfg = (QUIZ_CONFIG.attempt && QUIZ_CONFIG.attempt[topicId]) || QUIZ_CONFIG.defaultAttempt;
  return Math.min(cfg, poolLen);
}

const QUESTIONS = {};
