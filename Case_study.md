# Case Study Link

**[What 10 SQL Queries Told Me About This Business](https://shy-position-1fc.notion.site/What-10-SQL-Queries-Told-Me-About-This-Business-39ea3c1d0a298064a4a5d3ab66edf684)**

A memo to a hypothetical founder of this ecommerce business, built from the 10 SQL queries in `queries/`. It covers the three headline findings (TL;DR), five insights each grounded in a specific query — observation, the number, why it matters, and a concrete Monday action — the questions the queries opened but couldn't close, and a methodology note on what was excluded and why.

Hosted publicly on Notion (Share to web enabled).
# What 10 SQL Queries Told Me About This Business

> **To:** Founder · **From:** Sidharth Menon (Data) · **Re:** What ten queries say about the state of the business
> 

> **Data window:** Mar 16 – Jun 14, 2026 · **Source:** internal Postgres, `ecom` schema (Metabase) · Currency in ₹
> 

This memo summarizes what ten SQL queries reveal about the current state of the business — not another dashboard, but the findings that should shape decisions.

It covers:

- **Where the numbers converge** across the ten queries
- **The actions I'd prioritize first**, framed as concrete Monday moves
- **The questions that remain open**, and what would close them

Each insight is grounded in a specific query (in the repo) and cross-checked against the others.

## TL;DR

- **We are shrinking on volume, not price.** Daily revenue fell ~80% from the early-April peak while AOV held flat at ₹7,000–8,000. Fewer customers are buying; the ones who do still spend the same.
- **The growth engine is broken while the base is fragile.** New-signup retention fell from 50% to 18% month-over-month, yet 40% of customers (the ₹20,000+ spenders) generate 88% of revenue.
- **The biggest leaks are operational, not existential.** 60% of product-viewers never add to cart, and a quarter of UPI payment failures are recoverable gateway timeouts — both fixable this quarter without a strategy pivot.

## Five things the data told me

### 1. The decline is a traffic problem, not a pricing problem

📄 Query: q1_daily_business_summary.sql

- **What I saw:** Daily revenue slid from **~₹7.6M on Apr 5 to ~₹1.4M by mid-June — an ~80% drop** — but AOV never moved, holding at **₹7,000–8,000 every single day**.
- **Why it matters:** When revenue falls and basket size holds, you're losing *buyers*, not margin. This is a top-of-funnel/acquisition story, not a merchandising or pricing one.
- **Monday action:** Put the last 90 days of acquisition spend by channel next to this daily curve. If spend fell in lockstep, the "crash" is a budget decision, not a market signal — reversible by turning spend back on.
- **Caveat:** **May 13's 53% cancellation spike** reads as an instrumentation artifact, not real demand — don't let it into a board deck uncorrected.

### 2. New customers have stopped coming back

📄 Query: q2_cohort_retention.sql

- **What I saw:** Month-1 retention **declined cohort-over-cohort: 50.2% (March) → 42.6% (April) → 18.2% (May)**, and the March cohort itself **roughly halves to 19.2% by month three**.
- **Why it matters:** This is the single most alarming number in the set — whatever we changed in acquisition after March is bringing in customers who don't repeat, and it mirrors the Q1 volume decline exactly.
- **Monday action:** Cut this same cohort retention by acquisition channel for the April and May signups. If one cheaper, lower-intent channel is behind it, pausing or re-targeting it is a fast, cheap fix.
- **If not:** A collapse *across all channels* points to onboarding or product — a bigger conversation, and where I'd point the next two weeks.

### 3. This is a whale business — protect the whales first

📄 Query: q8_customer_ltv.sql

- **What I saw:** The **₹20,000+ lifetime-spend bucket is 40% of customers (3,351 of 8,438) but 88% of revenue**. The top customer alone has placed **155 orders worth ₹1.34M**; the bottom ~30% of customers contribute ~2% of revenue combined.
- **Why it matters:** Given Q2's collapsing new-cohort retention, the highest-leverage defensive move isn't topping up the funnel with low-value signups — it's keeping the existing high-value base from churning.
- **Monday action:** Stand up a simple "whale watch" — flag any ₹20,000+ customer who hasn't ordered in 30 days and route them to a human or a concierge offer.
- **Bottom line:** Losing ten of these customers costs more than losing a thousand from the bottom, so measure retention on this bucket first, not the blended average that hides them.

### 4. The funnel leaks at the top, and it leaks equally everywhere

📄 Query: q3_funnel_conversion.sql

- **What I saw:** Only **40% of product-viewers add to cart**, while everything downstream is healthy — **cart→checkout 81%, checkout→purchase 86%**. Session-to-purchase is **~24% across all five channels**, nearly identical.
- **Why it matters:** This is an interest/merchandising problem, not checkout friction. Channel choice doesn't change on-site behavior — only traffic volume does — so we can't fix conversion by shifting the channel mix; we have to fix the product page.
- **Monday action:** Take the ten highest-traffic products and audit their view→cart rate. Where certain PDPs or categories leak worse, the culprit is usually price, an out-of-stock variant, or thin content — all cheap to test.
- **The prize:** Closing the view→cart gap from 40% to even 50% lifts purchases across every channel at once, because the leak is uniform.

### 5. UPI gateway timeouts are free money

📄 Query: q6_payment_failure.sql

- **What I saw:** **UPI carries the most volume (12,835 attempts) and the worst failure rate at 5.5%**, and about **a quarter of those failures are gateway timeouts** (`GATEWAY_TIMEOUT`) — an infrastructure fault, not a customer declining.
- **Why it matters:** That's a recoverable conversion — the customer *wanted* to pay. Card fails at 4.2% but its top reason is FRAUD (28%), a risk we mostly want to hold. Timeouts are the opposite: pure leakage.
- **Monday action:** Turn on an automatic retry (or failover to a second PSP) for UPI timeouts, and instrument the recovery rate. It's the cheapest conversion in the building — no new traffic or product, just catching payments we already earned.
- **Size it first:** timeout-failures × AOV is the revenue currently on the floor — that number justifies the engineering ticket.

## What I'd investigate next

- **Is the decline driven by acquisition spend cuts or worsening conversion?** My queries see orders and sessions but not marketing spend. Overlaying spend-by-channel on the Q1 curve would settle whether this is a self-inflicted budget cut or a real market shift.
- **Why do 60% of product-viewers never add to cart?** Price, stock-outs, or weak PDP content? A view→cart cut by category and product would localize the leak — and I'd confirm the suspiciously uniform cross-channel conversion is real behavior, not a tracking artifact.
- **What is churn *within* the ₹20,000+ whale bucket, and are these revenue leaders actually our profit leaders?** Net revenue isn't margin. I'd overlay COGS before building retention programs around the hero SKUs (audio and wearables).

## Methodology note

- **Source:** internal Postgres warehouse, `ecom` schema, via Metabase.
- **Window:** Mar 16 – Jun 14, 2026.
- **Tables used:** orders, order_items, refunds, customers, sessions, session_events, payment_intents, shipments, attribution_touches.

Deliberate choices behind every number:

- **Cancelled orders excluded** from revenue, AOV, and retention throughout, applied consistently.
- **Refunds count only where status = 'succeeded'**, allocated to line items proportionally by `line_total` share (refunds are recorded at order grain).
- **The funnel (Q3) is restricted to sessions on/after 2026-04-19**, when instrumentation launched — earlier sessions are uninstrumented, not inactive.
- **Censored cohort cells (Q2) show NULL, never 0** — later cohorts are simply too recent to observe M2/M3.
- **June 14 (partial day, 72 orders) and May 13 (likely artifact)** are excluded from trend reads.

Every denominator is wrapped in `nullif(..., 0)`, and each query carries a header comment with its business question and a sanity-check assertion. The `.sql` files are in the repo alongside this memo.

