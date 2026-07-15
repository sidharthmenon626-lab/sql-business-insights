# E-Commerce Analytics — 10 SQL Queries

Ten analytical SQL queries run against a real-shaped e-commerce warehouse (the `ecom` schema on our internal Postgres/Metabase server), answering the questions a founder actually asks: how are we doing today, why are customers not coming back, where does the funnel leak, and which payments are we leaving on the floor. Each query is written to a house style — CTEs over subqueries, window functions for trend and ranking, `nullif(..., 0)` on every denominator, and a header comment carrying the business question plus a sanity-check assertion.

The queries deliberately span the business: daily P&L (Q1), cohort retention (Q2), funnel conversion (Q3), product and category revenue net of returns (Q4–Q5), payment failures (Q6), delivery SLA (Q7), customer LTV (Q8), repeat-purchase timing (Q9), and marketing attribution (Q10).

## 📄 Case study

The full write-up — a memo to a hypothetical founder covering the five findings that matter and what I'd do about them on Monday — lives in Notion:

**[What 10 SQL Queries Told Me About This Business](https://shy-position-1fc.notion.site/What-10-SQL-Queries-Told-Me-About-This-Business-39ea3c1d0a298064a4a5d3ab66edf684)**

## 🔗 Author

Sidharth Menon — [LinkedIn](https://www.linkedin.com/in/sidharthmenon793)

## 📂 Queries

| # | File | Business question |
|---|------|-------------------|
| Q1 | `queries/q1_daily_business_summary.sql` | How are we doing today vs yesterday and the same day last week? |
| Q2 | `queries/q2_cohort_retention.sql` | Do each month's new signups come back in months 1–3? |
| Q3 | `queries/q3_funnel_conversion.sql` | Where does each channel's traffic leak in the funnel? |
| Q4 | `queries/q4_top_products_net_revenue.sql` | Which products make us money, net of returns? |
| Q5 | `queries/q5_category_health.sql` | Which categories drive revenue, and which get returned? |
| Q6 | `queries/q6_payment_failure.sql` | Which payment methods fail most, and why? |
| Q7 | `queries/q7_delivery_sla.sql` | Who's missing the 5-day delivery SLA, and by how much? |
| Q8 | `queries/q8_customer_ltv.sql` | Who are our top spenders, and what share of revenue are they? |
| Q9a / Q9b | `queries/q9a_repeat_interval_rowlevel.sql`, `queries/q9b_repeat_interval_summary.sql` | How long until a customer's next order? |
| Q10 | `queries/q10_attribution.sql` | First-touch vs last-touch: which channels open vs close? |

## 🚀 How to run

These queries target the internal Metabase instance sitting on top of our Postgres warehouse — open Metabase, create a **native (SQL) question**, and select the **`ecom`** schema/database as the source. Paste any `queries/*.sql` file into the editor and run it; each is self-contained (no setup scripts, no temp tables) and fully qualifies its tables as `ecom.orders`, `ecom.session_events`, `ecom.payment_intents`, and so on. Every query carries a header comment with its business question and a sanity-check assertion — run that check first before trusting the output. The analysis window is **Mar 16 – Jun 14, 2026**; adjust the date literals inside each query if you re-point it at a different period. If you don't have Metabase access, any Postgres client (psql, DBeaver) connected to the same `ecom` schema will run these unchanged.

## 🧠 Reflection

- **What I learned.** The interpretation is the job, not the query. Pulling "revenue fell 80%" is easy; realizing AOV stayed flat — and therefore that it's a volume problem, not a pricing one — is the part that changes a decision.
- Data-quality caveats (the May 13 cancellation artifact, censored cohort cells, the post-Apr-19 instrumentation window) matter as much as the headline numbers, because one uncaught artifact in a board deck destroys trust in all the real findings.
- Letting queries cross-check each other (Q1's decline against Q2's retention collapse) produces a story, where a single query only produces a fact.
- **What I'd do differently.** I'd overlay COGS and marketing spend from the start — without them, "net revenue" and "the decline" are only half-answered, and both gaps became my top "investigate next" items.
- I'd parameterize the date window (a Metabase variable) instead of hard-coding literals, so the same query serves the daily standup and the quarterly review without edits.
