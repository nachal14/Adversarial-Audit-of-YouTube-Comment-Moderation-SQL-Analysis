Here's the README updated with the tech stack corrected to reflect the actual SQL work shown — MySQL specifically, with the real technique names pulled from your script:

# **Adversarial Audit of YouTube Comment Moderation | SQL Analysis**

> **Trust & Safety Data Audit** — Testing whether AI toxicity scores actually predict human moderation decisions, using 91K rows of Jigsaw/YouTube comment data (2015–2017).

---

## 📌 Executive Summary

Most Trust & Safety work assumes the training labels are correct and focuses on tuning the model against them. This project starts from a different premise: audit the humans first. Across 91K comments, AI toxicity scores and human moderation decisions frequently disagree — and that disagreement isn't random. It's driven by engagement, humor, and where in the comment thread the toxicity occurs. Any model trained on these labels without correcting for that will learn "popularity," not "safety."

---

## 🔍 Key Findings

* **The Engagement Paradox** — Toxic comments (score > 0.7) with high likes had a **65.7% approval rate**. Comments marked "Funny" alongside high toxicity also saw elevated approval — social proof and humor both act as a shield against moderation, regardless of the underlying AI score.
* **The Disagree Disconnect** — Toxic comments that drew "Disagree" reactions were **8x more likely to be approved than rejected** — one comment scoring 0.72 toxicity was approved despite 96 users hitting disagree, suggesting moderators read high engagement as "debate" rather than a violation.
* **The 19.96% Override Rate** — Nearly 20% of comments scoring above the "High Toxicity" threshold were approved anyway, while only 1.63% of non-toxic comments were wrongly rejected — moderators lean permissive on borderline content, not restrictive.
* **The Insult Loophole** — Moderators showed high tolerance for abusive/insult language but near-zero tolerance for threats and identity attacks — the moderation line sits on category, not severity.
* **The 17/93 Distribution** — A small share of publications account for the large majority of articles subjected to toxic engagement — toxicity is concentrated in specific high-friction hubs, not evenly spread.
* **The Nesting Risk** — **50% of toxic comments are replies**, not top-level posts — comment-threading structure itself is an under-audited surface for abuse.

---

## 💡 Strategic Recommendations

1. **Audit the labels before the model** — Any AI trained on this dataset inherits an engagement bias. Strip out popularity signals (likes, reactions) before using human labels as ground truth.
2. **Move from platform-wide to hub-targeted moderation** — Concentrate review resources on the small set of publications driving most toxic engagement instead of spreading effort evenly.
3. **Apply tiered sensitivity thresholds** — Lower auto-moderation thresholds specifically within high-toxicity hubs, where nuanced context is more likely to be missed by a single global threshold.
4. **Investigate the false-rejection rate** — The 1.63% of non-toxic comments wrongly rejected is a real cost to creator voice and user retention — worth its own root-cause pass.
5. **Extend the audit to identity-term bias** — Check whether comments containing identity keywords are scored high by the AI but approved by humans — a direct, quantifiable measure of model bias relevant to Trust & Safety review.

---

## 🎯 The Business Case (What a Trust & Safety Team Actually Gets)

* **A measurable false-positive/false-negative baseline** — 1.63% wrongful rejection and ~20% wrongful approval give leadership real numbers to weigh censorship complaints against safety gaps, instead of anecdote.
* **A targeting strategy, not a blanket filter** — Focusing moderation on the highest-density hubs neutralizes most platform risk without inflating review costs everywhere else.
* **A bias detector for AI training data** — Surfaces exactly where engagement metrics are corrupting ground-truth labels before that bias gets baked into a production model.
* **A structural blind spot identified** — Nested reply threads carry half of all toxicity but are typically under-weighted in comment-level moderation tooling.

---

## 🛠️ Technical Stack & Approach

* **Tool:** MySQL
* **Schema:** Single fact table (`toxicity_data`) with 91K+ rows spanning toxicity subtype scores (obscene, identity attack, insult, threat), 24 identity-attribute fields, moderation metadata (rating, annotator counts), and engagement reactions (likes, funny, wow, sad, disagree)
* **Core Techniques:** CTEs (multi-step ratio and concentration calculations), conditional aggregation (`COUNT(CASE WHEN...)`), self-referencing parent/reply analysis via `parent_id`, temporary tables for article-level rollups, window-style ratio comparisons across annotator thresholds, `CASE`-based risk-tier bucketing (High/Medium/Low Risk)
* **Data Load:** `LOAD DATA LOCAL INFILE` for bulk CSV ingestion into MySQL
* **Dataset:** Jigsaw/YouTube Toxic Comment Classification data, 2015–2017, ~91K unique comments

---

## 🚀 Next Layers (Interview-Ready Extensions)

1. **Identity Bias Check** — Compare AI toxicity scores against human approval for comments containing identity terms, to quantify unintended AI bias.
2. **Length & Caps Correlation** — Test whether comment length or capitalization ratio predicts moderation outcome independent of toxicity score.
3. **Sentiment vs. Toxicity Discrepancy** — Distinguish "negative but not toxic" from "toxic" to test whether moderators are approving supportive-but-harsh language.
4. **Precision/Recall Trade-off Analysis** — Quantify the cost trade-off of lowering the toxicity threshold (more caught threats vs. more false positives and creator-voice loss).

---

*Data tells you what was labeled. Auditing tells you whether the labels can be trusted.*
