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
* **The Insult Loophole** — Moderators showed high tolerance for abusive/insult language (0.38 avg score present in 94%+ of toxic comments) but near-zero tolerance for threats and identity attacks — the moderation line sits on category, not severity.
* **The 17/93 Distribution** — Just **17% of publications account for 93% of articles subjected to toxic engagement**. Toxicity isn't evenly spread across the platform — it's concentrated in a small number of high-friction hubs.
* **The Nesting Risk** — **50% of toxic comments are replies**, not top-level posts — comment-threading structure itself is an under-audited surface for abuse.

---

## 💡 Strategic Recommendations

1. **Audit the labels before the model** — Any AI trained on this dataset inherits an engagement bias. Strip out popularity signals (likes, reactions) before using human labels as ground truth.
2. **Move from platform-wide to hub-targeted moderation** — Concentrate review resources on the 17% of publications driving 93% of toxic engagement instead of spreading effort evenly.
3. **Apply tiered sensitivity thresholds** — Lower auto-moderation thresholds specifically within high-toxicity hubs, where nuanced context is more likely to be missed by a single global threshold.
4. **Investigate the false-rejection rate** — The 1.63% of non-toxic comments wrongly rejected is a real cost to creator voice and user retention — worth its own root-cause pass.
5. **Extend the audit to identity-term bias** — Check whether comments containing identity keywords (e.g., "gay," "Muslim," "Black") are scored high by the AI but approved by humans — a direct, quantifiable measure of model bias relevant to Trust & Safety review.

---

## 🎯 The Business Case (What a Trust & Safety Team Actually Gets)

* **A measurable false-positive/false-negative baseline** — 1.63% wrongful rejection and ~20% wrongful approval give leadership real numbers to weigh censorship complaints against safety gaps, instead of anecdote.
* **A targeting strategy, not a blanket filter** — Focusing moderation on the 17% of hubs neutralizes the majority of platform risk without inflating review costs across the other 83%.
* **A bias detector for AI training data** — Surfaces exactly where engagement metrics are corrupting ground-truth labels before that bias gets baked into a production model.
* **A structural blind spot identified** — Nested reply threads carry half of all toxicity but are typically under-weighted in comment-level moderation tooling.

---

## 🛠️ Technical Stack & Approach

* **Tool:** SQL (Window Functions, Correlation Analysis, categorical aggregation)
* **Core Techniques:** Approval/rejection rate analysis by toxicity tier, engagement-reaction correlation (likes, disagree, funny), Pareto/concentration analysis (17/93 distribution), reply-thread nesting analysis, category-level tolerance scoring (obscenity, threats, identity attacks, insults)
* **Dataset:** Jigsaw/YouTube Toxic Comment Classification data, 2015–2017, ~91K unique comments

---

## 🚀 Next Layers (Interview-Ready Extensions)

1. **Identity Bias Check** — Compare AI toxicity scores against human approval for comments containing identity terms, to quantify unintended AI bias.
2. **Length & Caps Correlation** — Test whether comment length or capitalization ratio predicts moderation outcome independent of toxicity score.
3. **Sentiment vs. Toxicity Discrepancy** — Distinguish "negative but not toxic" from "toxic" to test whether moderators are approving supportive-but-harsh language.
4. **Precision/Recall Trade-off Analysis** — Quantify the cost trade-off of lowering the toxicity threshold (more caught threats vs. more false positives and creator-voice loss).

---

*Data tells you what was labeled. Auditing tells you whether the labels can be trusted.*
