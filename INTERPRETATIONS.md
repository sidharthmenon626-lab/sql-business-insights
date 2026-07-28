# Query Interpretations — Task 1

*Owner: Sidharth Menon · Data window: Mar 16 – Jun 14, 2026 (June 14 is a partial trailing day)*
*Currency in ₹. Rates in [0,1] unless labelled %. Censored cohort cells shown blank, not 0.*

---

## Q1 — Daily Business Summary with DoD and Same-Weekday WoW

**What the query does (1 sentence):** Builds a daily P&L strip — revenue, orders, AOV, paid/cancelled rates and refunds — with day-over-day and same-weekday (7-day lag) revenue deltas over Mar 16 – Jun 14, 2026.

**Pattern choice (1-2 sentences):** Used `lag(...,1)` for DoD and `lag(...,7)` for same-weekday WoW to strip day-of-week seasonality, with every denominator wrapped in `nullif(...,0)` to avoid divide-by-zero.

**Business interpretation (2-3 sentences):**

- Revenue slid **~80%** from the early-April peak (**~₹7.6M** on Apr 5) to **~₹1.4M** by mid-June.
- AOV held steady at **₹7,000–8,000** throughout — so this is a **traffic/volume** problem, not a basket-size one.
- **May 13** is a clear outlier: cancelled rate spiked to **53%** and paid rate collapsed to **47%** — an order-status/instrumentation lapse, not real demand.
- **June 14** is a partial trailing day (72 orders) and should not be read as a crash.

**What I'd ask next:** Is the sustained volume decline driven by cuts in acquisition spend or by worsening on-site conversion? Cross against the Q3 funnel and Q10 channel mix — and confirm May 13 is a data artifact before anyone reports a "53% cancellation day."

---

## Q2 — Monthly Signup Cohort Retention

**What the query does (1 sentence):** Tracks each monthly signup cohort's return rate in months 1–3 after the customer's first non-cancelled order.

**Pattern choice (1-2 sentences):** A first-order-month CTE feeds a month-offset self-join; censored future cells are shown as NULL (never 0%), and cancelled orders are excluded from "retained."

**Business interpretation (2-3 sentences):**

- March cohort retains strongly early (**50.2% M1, 41.9% M2**) but **M3 roughly halves to 19.2%** — a churn cliff around month three.
- M1 retention **declines cohort-over-cohort**: **50.2% (Mar) → 42.6% (Apr) → 18.2% (May)** — newer signups return at roughly a third the March rate, mirroring the Q1 revenue slide.
- Later cohorts' M2/M3 cells are **censored** (too recent to observe) and correctly appear blank, not zero.

**What I'd ask next:** What changed in acquisition after March — a cheaper, lower-intent channel, or degraded onboarding? The M1 collapse is the single biggest retention risk and needs a channel-level cohort cut to localize the cause.

---

## Q3 — Funnel Conversion by Acquisition Channel

**What the query does (1 sentence):** Splits sessions through the product-view → add-to-cart → checkout → purchase funnel by acquisition channel, restricted to the post-launch window (instrumentation began 2026-04-19).

**Pattern choice (1-2 sentences):** Used `count(distinct session_id) filter (where event_type = ...)` per stage — a single pass with no row explosion from five left joins; unattributed sessions bucket as `direct` rather than being dropped.

**Business interpretation (2-3 sentences):**

- The leak is **at the top of the funnel**: only **40%** of viewers add to cart.
- Downstream stages are healthy — cart→checkout **81%**, checkout→purchase **86%** — so it's an interest/merchandising problem, not checkout friction.
- Conversion is **near-identical across all five channels** (**~24%** session-to-purchase) — channel choice doesn't change on-site behaviour; only traffic volume differs.
- Organic drives the most sessions (**23,072**) at the same efficiency as everyone else.

**What I'd ask next:** Why do 60% of product viewers never add to cart — price, stock-outs, or PDP quality? A view→cart cut by category and product would localize it. I'd also sanity-check that the suspiciously uniform cross-channel rates aren't a tracking artifact.

---

## Q4 — Top Products by Net Revenue (After Refunds)

**What the query does (1 sentence):** Ranks all 4,000 products by net revenue after proportionally allocating order-level refunds down to individual line items.

**Pattern choice (1-2 sentences):** Three separate CTEs (revenue, returns, refunds) joined at the end to avoid double-counting; refunds allocated by each line's `line_total` share since refunds are recorded at order grain.

**Business interpretation (2-3 sentences):**

- Revenue is concentrated in **audio and wearables** — the top 8 products are all headphones and smartwatches, each clearing **₹700K–920K** net.
- Leader: **Eastlight Clarity ANC Headphones** at **₹921K** net.
- Refunds are immaterial — **₹1.2M (~0.47%)** of ₹253M gross — so net ≈ gross for the winners.
- The scary-looking **50% return-rate** products are noise: they've sold ~2 units, so one return swings the rate.

**What I'd ask next:** Are these hero SKUs margin-rich or merely high-revenue? Net revenue is not profit — I'd overlay COGS before declaring them the products that actually "make us money."

---

## Q5 — Category Health: Purchases → Returns

**What the query does (1 sentence):** Ranks product categories by paid-order revenue alongside their unit-level return rate.

**Pattern choice (1-2 sentences):** Two CTEs (category_sales, category_returns) joined at the end; returns traced through `return_items → product_variants → products → categories` because returns reference variants, not products directly.

**Business interpretation (2-3 sentences):**

- **Smartwatch is the revenue engine** at **₹59.7M** — 57% more than the next category, Headphones (**₹38.1M**) — confirming the Q4 wearables/audio concentration.
- Return rates are **tight and low everywhere** (**0.77–1.08%**); Decor is highest at 1.08%, Headphones lowest at 0.77% — both on modest volume.
- Revenue spread is enormous (**Smartwatch ₹59.7M vs Haircare ₹4.0M**) while return rates barely move — so category strategy should follow revenue and margin, not returns.

**What I'd ask next:** Is Smartwatch's dominance a handful of hero SKUs or broad catalogue depth? If it's concentrated, that's a supplier and inventory risk worth hedging.

---

## Q6 — Payment Failure Analysis (Method × Top Error Code)

**What the query does (1 sentence):** Reports attempts, failures and failure rate per payment method, plus each method's single most common error code and its share of that method's failures.

**Pattern choice (1-2 sentences):** The classic top-N-per-group pattern — one CTE aggregates rates per method, a second ranks error codes with `row_number() over (partition by method order by count desc)` and keeps `rn = 1`; a plain GROUP BY cannot pick the top error per method.

**Business interpretation (2-3 sentences):**

- **UPI** carries the most real volume (**12,835 attempts, 711 failures**) and the **worst rate at 5.5%** — a quarter of failures are `GATEWAY_TIMEOUT`, an infrastructure issue (recoverable), not customer error.
- **Card** has the highest raw attempts (**14,166**) but a lower **4.2%** rate; its top reason is **FRAUD (28%)** — a risk problem, not a technical one.
- **Netbanking** is the cleanest method at **4.2%**.

**What I'd ask next:** What's the revenue leakage from UPI GATEWAY_TIMEOUTs, and can we auto-retry or fail over to a second gateway? A timeout-driven failure is the cheapest conversion to win back.

---

## Q7 — Delivery SLA Breach by Carrier × Shipping Method

**What the query does (1 sentence):** Measures the delivery-day distribution (avg, median, p90) and the >5-day late rate for every carrier × shipping-method combination.

**Pattern choice (1-2 sentences):** Used `percentile_cont(0.9) within group (order by delivery_days)` for p90; in-transit shipments (`delivered_at IS NULL`) are excluded so they don't count as instant deliveries.

**Business interpretation (2-3 sentences):**

- **EcomExpress is the SLA problem**: its express (**21% late**) and same_day (**20% late**) tiers miss the 5-day SLA with a **p90 of 8 days** — worse than its own standard tier (**10%**).
- **Delhivery is the strongest carrier**, breaching on only **3–7%** of deliveries.
- The **inversion** — premium tiers slower than standard at EcomExpress — is a data-quality/ops red flag: mis-tagged methods or genuinely failing premium lanes.

**What I'd ask next:** Are we paying an express premium to EcomExpress for standard-or-worse performance? I'd pull the carrier rate card and model shifting express volume to Delhivery.

---

## Q8 — Customer LTV + Bucket Share of Revenue

**What the query does (1 sentence):** Computes per-customer lifetime revenue, order count and AOV, buckets each customer by lifetime spend, and each bucket's share of total revenue.

**Pattern choice (1-2 sentences):** CASE-WHEN bucketing combined with a window — `sum(total_revenue) over (partition by bucket) / sum(total_revenue) over ()` — to mix row-level and aggregate-level reasoning in a single pass.

**Business interpretation (2-3 sentences):**

- Revenue is **extremely top-heavy**: the **₹20,000+** bucket is **40% of customers** (3,351 of 8,438) but **88% of revenue**.
- The single top spender has placed **155 orders** worth **₹1.34M**.
- The bottom two buckets (₹0–4,999) are **~30% of customers** but only **~2% of revenue** combined.
- This is a **whale-driven business** — retention economics should be measured on the top bucket first.

**What I'd ask next:** What's the churn rate specifically within the ₹20,000+ bucket? Given Q2's collapsing new-cohort retention, protecting the existing whale base may matter more than topping up the funnel.

---

## Q9 — Repeat Purchase Interval

**What the query does (1 sentence):** Computes each customer's gap to their next order (row-level, 40,000 rows) and summarizes repeat intervals both including and excluding same-day repeats.

**Pattern choice (1-2 sentences):** `lead(created_at) over (partition by customer_id order by created_at)` for the next-order date; the final order per customer (NULL next) is dropped from the summary to avoid biasing the average toward infinity.

**Business interpretation (2-3 sentences):**

- **41%** of all "repeat" intervals are **same-day** — customers splitting one session into multiple orders minutes apart, not genuine re-engagement.
- That single choice moves the **median from 1 day (including) to 6 days (excluding)**.
- The **excluding-same-day view** (median **6**, p90 **27**, **3,418** repeat customers) is the correct basis for win-back timing — and correctly drops **341** customers whose only "repeat" was same-day.

**What I'd ask next:** The win-back email should fire before the excluding-same-day p90 of 27 days lapses — I'd target roughly **day 14–20** and A/B test the trigger window.

---

## Q10 — Attribution Comparison: First-Touch vs Last-Touch Revenue by Channel

**What the query does (1 sentence):** Compares each acquisition channel's revenue share under first-touch versus last-touch attribution.

**Pattern choice (1-2 sentences):** Two `row_number()` partitions over `attribution_touches` per customer (ascending for first touch, descending for last), joined back to orders; unattributed orders bucket as `direct` and cancelled orders are excluded.

**Business interpretation (2-3 sentences):**

- Total revenue is **identical under both models** (**₹282.9M**) — attribution only reallocates credit, it doesn't create or destroy it.
- **Organic opens the funnel**: loses share first-touch (**40%**) → last-touch (**39%**) — it introduces customers.
- **Email closes**: gains the most, **6.3% → 7.2%** — it seals conversions.
- **Paid (36%)** and **referral (12%)** are stable across models — they play opener and closer roles roughly evenly.

**What I'd ask next:** If email disproportionately closes, are we under-investing in it relative to its last-touch contribution? And should paid's budget be judged on its first-touch assist value rather than last-touch credit alone?