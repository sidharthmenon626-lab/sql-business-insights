# E-Commerce Analytics — 10 SQL Queries

Ten SQL queries against a real-shaped e-commerce warehouse (`ecom` schema, Postgres/Metabase), answering the questions a founder actually asks — how are we doing today, why aren't customers coming back, where does the funnel leak, and which payments are we losing.

**House style:** CTEs over subqueries · window functions for trend/ranking · `nullif(..., 0)` on every denominator · every query header-commented with its business question and a sanity-check assertion.

## 📌 Executive Summary

- **Revenue fell off a cliff, but it's a volume problem, not a pricing one.** Daily revenue slid **~80%**, from a **₹7.6M** peak (Apr 5) to **~₹1.4M** by mid-June, while AOV held flat at **₹7,000–8,000** the entire time.
- **New-customer retention is collapsing.** Month-1 cohort retention fell from **50.2%** (March) to **18.2%** (May) — newer signups return at roughly a third the rate of March's cohort.
- **This is a whale-driven business.** The **₹20,000+** lifetime-spend bucket is **40%** of customers but generates **88%** of revenue — protecting them matters more than acquiring more low-value signups.
- **The funnel leaks at the very top.** Only **40%** of product-viewers add to cart — uniformly across all five acquisition channels — while every stage after that converts at **81%+**.
- **UPI payment failures are recoverable revenue.** UPI has the worst failure rate (**5.5%**, 12,835 attempts), and a quarter of those failures are infrastructure timeouts, not declined payments.

## 📊 Key Charts

![Daily Revenue vs AOV](assets/q1_daily_revenue_vs_aov.jpg)
*Q1 — Daily revenue sliding ~80% from the April peak while AOV holds flat: a volume problem, not a pricing one.*

![Funnel Conversion by Channel](assets/q3_funnel_conversion_by_channel.jpg)
*Q3 — Stage-to-stage funnel conversion by channel. The leak is uniformly at view→cart (~40%); downstream stages are healthy (81%+).*

![Revenue Share by Customer LTV Bucket](assets/q8_revenue_share_by_ltv_bucket.jpg)
*Q8 — The ₹20,000+ lifetime-spend bucket alone generates 88% of total revenue.*

![Customer Count by LTV Bucket](assets/q8_customer_count_by_ltv_bucket.jpg)
*Q8 — That same ₹20,000+ tier is only 40% of customers — the whale concentration behind the revenue chart above.*

## 📄 Case study

The full write-up — a memo to a hypothetical founder covering the five findings that matter and what I'd do about them on Monday — lives in Notion:

**[What 10 SQL Queries Told Me About This Business](https://shy-position-1fc.notion.site/What-10-SQL-Queries-Told-Me-About-This-Business-39ea3c1d0a298064a4a5d3ab66edf684)**

## 🔗 Author

Sidharth Menon — [LinkedIn](https://www.linkedin.com/in/sidharthmenon793)

## 📂 Queries

| # | File | Business question | Key data insight |
|---|------|-------------------|-------------------|
| Q1 | `queries/q1_daily_business_summary.sql` | How are we doing today vs yesterday and the same day last week? | Revenue fell **~80%** (₹7.6M → ₹1.4M); AOV held flat at ₹7,000–8,000 |
| Q2 | `queries/q2_cohort_retention.sql` | Do each month's new signups come back in months 1–3? | Month-1 retention: **50.2% → 42.6% → 18.2%** (Mar → Apr → May) |
| Q3 | `queries/q3_funnel_conversion.sql` | Where does each channel's traffic leak in the funnel? | **40%** view→cart is the bottleneck; downstream stages convert at 81%+ |
| Q4 | `queries/q4_top_products_net_revenue.sql` | Which products make us money, net of returns? | Top 8 products (audio/wearables) each clear **₹700K–920K** net; refunds ~0.47% of gross |
| Q5 | `queries/q5_category_health.sql` | Which categories drive revenue, and which get returned? | Smartwatch leads at **₹59.7M**; return rates tight everywhere (0.77–1.08%) |
| Q6 | `queries/q6_payment_failure.sql` | Which payment methods fail most, and why? | UPI worst failure rate at **5.5%** (12,835 attempts) — a quarter are recoverable timeouts |
| Q7 | `queries/q7_delivery_sla.sql` | Who's missing the 5-day delivery SLA, and by how much? | EcomExpress breaches SLA on **20–21%** of express/same-day deliveries |
| Q8 | `queries/q8_customer_ltv.sql` | Who are our top spenders, and what share of revenue are they? | **40%** of customers = **88%** of revenue (₹20,000+ bucket) |
| Q9 | `queries/q9_repeat_interval_rowlevel_summary.sql` | How long until a customer's next order? | Median repeat interval: **6 days**; 41% of "repeats" are same-day noise |
| Q10 | `queries/q10_attribution.sql` | First-touch vs last-touch: which channels open vs close? | Organic opens (**40%** first-touch); Email closes (6.3% → 7.2% last-touch) |

## 🚀 How to run

1. Open Metabase → **New Question → Native query** → select the **`ecom`** schema as the data source.
2. Paste any `queries/*.sql` file into the editor and run it — each is self-contained (no setup scripts, no temp tables).
3. Check the header comment's **sanity-check assertion** first, before trusting the output.
4. Analysis window is **Mar 16 – Jun 14, 2026** — adjust the date literals inside the query to re-point at a different period.
5. No Metabase access? Any Postgres client (psql, DBeaver) connected to the same `ecom` schema runs these unchanged.

## 🧠 Reflection

- **What I learned.** The interpretation is the job, not the query. Pulling "revenue fell 80%" is easy; realizing AOV stayed flat — and therefore that it's a volume problem, not a pricing one — is the part that changes a decision.
- Data-quality caveats (the May 13 cancellation artifact, censored cohort cells, the post-Apr-19 instrumentation window) matter as much as the headline numbers, because one uncaught artifact in a board deck destroys trust in all the real findings.
- Letting queries cross-check each other (Q1's decline against Q2's retention collapse) produces a story, where a single query only produces a fact.
- **What I'd do differently.** I'd overlay COGS and marketing spend from the start — without them, "net revenue" and "the decline" are only half-answered, and both gaps became my top "investigate next" items.
- I'd parameterize the date window (a Metabase variable) instead of hard-coding literals, so the same query serves the daily standup and the quarterly review without edits.
