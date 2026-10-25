# Global Ads Performance Analysis

A MySQL and Tableau analysis of advertising performance across Google Ads, Meta Ads, and TikTok Ads. The project compares blended efficiency across platform, country, industry, campaign type, quarter, and ad-spend groups.

## Business questions

- Which platform perform the best?
- Which platform has the highest blended ROAS and lowest blended CPA?
- How does platform performance vary by country, industry, and campaign type?
- How does blended ROAS vary by quarter?
- How does blended ROAS vary across ad-spend groups within each platform?
- What share of records have attributed revenue below ad spend?

## Dataset

The analysis uses [Global Ads Performance (Google, Meta, TikTok)](https://www.kaggle.com/datasets/nudratabbas/global-ads-performance-google-meta-tiktok) csv files, Kaggle (synthetic, 1,800 campaigns, Jan–Dec 2024), which contains 1,800 dated advertising records from January 1 through December 30, 2024. Fields include platform, campaign type, industry, country, impressions, clicks, CTR, CPC, ad spend, conversions, CPA, revenue, and ROAS.

**
The rows do not include company or campaign IDs, campaign duration, profit margin, or customer lifetime value. Treat each row as a dated record; the data cannot track an individual campaign over time. ROAS below 1 means attributed revenue is below ad spend. It does not measure full business profit or loss. Check the dataset source and license before redistributing the CSV.
**

## Tools

- **MySQL 8.0 or later** — data import, validation, and analysis using common table expressions and window functions.
- **Tableau** — interactive dashboard for platform performance, quarterly trends, spend groups, and records below ad spend.

## Repository contents

```text
global-ads-performance/
├── README.md
├── images/
│   └── global_ads_performance_dashboard_preview.png
├── global_ads_performance_dataset_query.sql
└── global_ads_performance.twbx
```

## How to run

1. Use MySQL with support for the SQL features in the script, including window functions (MySQL 8.0 or later).
2. Open the **sql script files**, and then replace the example path in `LOAD DATA LOCAL INFILE` with the CSV's location. Example:

   ```sql
   LOAD DATA LOCAL INFILE 'C:/path/to/global_ads_performance.csv'
   ```

3. Allow `LOAD DATA LOCAL INFILE` in both the MySQL server and client. The server-side setting in the script may require administrator privileges; client configuration is separate.
4. Run the SQL script from the beginning through the end.
5. Open `tableau/DASHBOARD.twbx` in Tableau to view the dashboard. If Tableau asks you to locate the CSV, reconnect it to `data/global_ads_performance_dataset.csv`.

**Reset behavior:** each full run drops and recreates the `ads_campaigns` table before importing the CSV. This replaces that table's contents; it does not drop the database. Back up any data in that table that you need to keep.

## Analysis, findings, and conclusions

The Analysis is done by segmenting the platforms by various categories and conditions to find the performance of each platform.

### 1. TikTok delivers the strongest return, across every group checked

| Platform | Blended ROAS |
|---|---|
| Google Ads | 3.47 |
| Meta Ads | 5.66 |
| TikTok Ads | 7.62 |

TikTok Perform the best overall, it has the lowest cost per acquisition and the lowest rate of unprofitable records (see Finding 3). This ranking held in every one of 16 cross-cuts checked (5 industries × 7 countries × 4 campaign types). It also perform the best quarterly no exceptions. 

**Caveat:** that level of uniformity is unusual for real market data, where trade-offs between platform and context are normal. It likely means this dataset didn't model real interaction effects between platform and segment

**Business implication:** consider a gradual TikTok budget test and monitor blended ROAS and CPA as spend changes.

**Note on the metric (Blended ROAS):** ROAS is reported here as *blended* (total revenue ÷ total ad spend), not a simple row-by-row average. A simple average overstates the return, because it treats every records as equally important regardless of size


### 2. The lead holds at scale, but shrinks substantially

| Spend level | Google | Meta | TikTok |
|---|---|---|---|
| Small (q1) | 4.95 | 7.35 | 12.70 |
| Medium (q2) | 5.09 | 7.84 | 9.99 |
| Large (q3) | 3.40 | 7.24 | 9.07 |
| Very Large (q4) | 2.90 | 4.24 | 5.92 |

**TikTok Ads has the highest blended ROAS in each SQL spend quartile, although its lead narrows in the highest-spend quartile.** Google Ads and Meta Ads improve from quartile 1 to quartile 2 before declining, a possible "minimum viable budget" effect. TikTok Ads declines immediately after quartile 1.

The SQL assigns quartiles separately within each platform using `NTILE(4)`. The Tableau spend chart currently uses the labeled spend levels **Small**, **Medium**, **Large**, and **Very Large**, with fixed platform-specific dollar thresholds.

**Business implication:** validate the ranking with controlled tests in the specific business, markets, and attribution setup before scaling budget.

### 3. Lowest Attributed revenue below ad spend

The share of records with attributed revenue below ad spend is **lowest for TikTok Ads**. The rates are 12.92% for Google Ads, 5.24% for Meta Ads, and 2.22% for TikTok Ads. This comparison is `revenue < ad_spend`; it is not a full profit calculation.

**Caveat:** TikTok has the smallest sample (450 records vs. Google's 720), so 2.22% represents roughly 10 records, but a small base to be fully certain about.

**Business implication:** review Google Ads records below ad spend to identify where performance may need investigation.

### 4. Possible seasonal pattern (unconfirmed)

Blended ROAS is highest in October, March, August, and January; gap between best and worst month is 1.31. Given how much ROAS varies at the spend level, this could be genuine seasonality or could be noise from a changing platform mix across months, this was not independently re-verified, so it's flagged as a soft signal, not a solid finding.

**Business implication:** review if there's truely a seasonal pattern on platform campaign performance.

## Recommendations

1. Test a gradual increase in TikTok Ads budget while monitoring blended ROAS and CPA.
2. Review Google Ads records where attributed revenue is below ad spend.
3. Validate platform differences with campaign-level data and controlled tests before applying them to a specific business.
4. Compare spend quartiles to understand how blended ROAS changes as record-level ad spend increases.
5. Validate and review if there's a seasonal pattern on platform campaign performance.

## Limitations

- **No company ID** — cross-platform effects for the same business cannot be tested.
- **No campaign ID or duration** — records cannot be linked into campaigns over time, and the time period represented by ad spend is unclear.
- **No margin field** — attributed revenue below ad spend is not total business profit or loss.
- **No customer ID or lifetime value** — long-term customer value cannot be compared by platform.
- **Attribution limits** — cross-platform attribution effects cannot be evaluated with the available fields.
- **Unusually consistent ranking** — TikTok leads across many segment cuts; this may not reflect real-world platform trade-offs.
- **Spend group definitions differ** — Tableau's fixed dollar levels and SQL's within-platform quartiles should not be presented as the same grouping.

## SQL script sections

The SQL file is organized into database and table setup, data import, data-quality checks, overall performance, platform comparisons by segment, attributed revenue below ad spend, spend-level analysis, findings and recommendations, and data limitations.

## Why blended ROAS, not average ROAS

Overall (not broken out by platform): the simple average of each campaign's ROAS is 6.45. The blended figure (total revenue ÷ total ad spend) is 4.88. The gap exists because ROAS and campaign size(spend level) are negatively correlated, many small campaigns have very high ROAS, and a smaller number of large campaigns (which carry most of the actual money) have lower ROAS. Averaging the ratio column directly overweights the many small campaigns; summing the real totals first weights each campaign by the dollars actually behind it. Since this project is about real budget allocation, blended is the correct choice throughout, the simple average is kept only as a transparency note, not used anywhere in the main analysis.

## Dashboard
To look or explore the dashboard directly from Tableu Public you can click [here](https://public.tableau.com/shared/94WZSZPKW?:display_count=n&:origin=viz_share_link), or if you can also open the **.twbx** files to look at the dashboard.

Preview of the dashboard:
![global_ads_performance dashboard preview](global_ads_performance_dashboard_preview.png)