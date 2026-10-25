-- =========================================================
-- GLOBAL ADS PERFORMANCE ANALYSIS
-- MySQL analysis of global advertising performance
-- =========================================================

-- 01. DATABASE AND TABLE SETUP
CREATE DATABASE IF NOT EXISTS global_ads_performance;
USE global_ads_performance;

-- Reset this project's table so the script can be run again.
-- This permanently deletes any existing data in ads_campaigns.
DROP TABLE IF EXISTS ads_campaigns;

CREATE TABLE IF NOT EXISTS ads_campaigns (
    id INT AUTO_INCREMENT PRIMARY KEY,
    campaign_date DATE NOT NULL,
    platform VARCHAR(20) NOT NULL,
    campaign_type VARCHAR(20) NOT NULL,
    industry VARCHAR(30) NOT NULL,
    country VARCHAR(30) NOT NULL,
    impressions INT NOT NULL,
    clicks INT NOT NULL,
    ctr DECIMAL(6,4) NOT NULL,
    cpc DECIMAL(6,2) NOT NULL,
    ad_spend DECIMAL(10,2) NOT NULL,
    conversions INT NOT NULL,
    cpa DECIMAL(8,2) NOT NULL,
    revenue DECIMAL(12,2) NOT NULL,
    roas DECIMAL(6,2) NOT NULL
);

-- Should be done both at MySQL and at Client(may require admin permission, you can do it in mysql command line client).
SET GLOBAL local_infile = 1;

-- To look if local_infile is on in MySQL
SHOW GLOBAL VARIABLES LIKE 'local_infile';


-- 02. DATA IMPORT
-- LOAD DATA LOCAL INFILE LOCAL INFILE require LOCAL INFILE to be enabled on both the MySQL server and the client. 
-- Load procedure to load data from the dataset csv.
-- Update the CSV path before running this section.
LOAD DATA LOCAL INFILE 'C:/path/to/global_ads_performance_dataset.csv'
INTO TABLE ads_campaigns
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(campaign_date, platform, campaign_type, industry, country, impressions, clicks, ctr, cpc, ad_spend, conversions, cpa, revenue, roas);


-- 03. DATA QUALITY CHECKS
-- Check the imported rows and expected dataset shape.
SELECT COUNT(*) FROM ads_campaigns;              -- expect 1800
SELECT COUNT(DISTINCT id) FROM ads_campaigns;     -- sanity check, should match
SELECT MIN(campaign_date), MAX(campaign_date) FROM ads_campaigns;  -- expect 2024-01-01 to 2024-12-30
SELECT platform, COUNT(*) FROM ads_campaigns GROUP BY platform;    -- expect 720/630/450
SELECT ROUND(AVG(roas),2) FROM ads_campaigns;     -- expect 6.45, matches what we saw in the raw file
SELECT * FROM ads_campaigns;


-- 04. BUSINESS QUESTIONS
-- How should marketing budget be allocated? 
-- Which platform, campaign type, industry, and region combinations tend to perform well?


-- Analysis:
-- 05. OVERALL PERFORMANCE
-- Performance of each platform
SELECT platform, 
COUNT(*)total_records, SUM(impressions)total_impressions, AVG(impressions)avg_impressions, 
SUM(clicks)total_clicks, ROUND(SUM(clicks) / SUM(impressions), 4)blended_ctr, ROUND(SUM(ad_spend) / SUM(clicks), 2)blended_cpc, SUM(ad_spend)total_spend, 
ROUND(AVG(ad_spend), 2)average_spend, SUM(conversions)total_conversions, AVG(conversions)avg_conversions, ROUND(SUM(ad_spend) / SUM(conversions), 2)blended_cpa, 
SUM(revenue)total_revenue, ROUND(SUM(revenue) / SUM(ad_spend), 2) AS blended_roas
FROM ads_campaigns GROUP BY platform;
-- With these metrics as the evaluator:
	-- 1. Tiktok ads perform the best at all of these metrics, with highest impression per record, CTR, conversion per record, and highest ROAS, with lowest CPC and CPA.
    -- 2. Meta ads perfrom second to tiktok, while having the lowest impression per record, CTR, conversion per record, 
    -- it has lower CPC and CPA, which lifted it's ROAS to become higher than google ads.
    -- 3. Google has better impression per record, CTR, conversion per record then Meta ads, but has way higher CPC and CPA compared to facebook and tiktok ads, which lower its ROAS.

-- Blended ROAS vs  AVG ROAS for each platform 
SELECT platform,
ROUND(SUM(revenue) / SUM(ad_spend), 2) AS blended_roas, 
ROUND(AVG(roas), 2) AS average_roas
FROM ads_campaigns
GROUP BY platform;

-- Performance of each industry
SELECT industry, 
COUNT(*)total_records, SUM(impressions)total_impressions, AVG(impressions)avg_impressions, 
SUM(clicks)total_clicks, ROUND(SUM(clicks) / SUM(impressions), 4)blended_ctr, ROUND(SUM(ad_spend) / SUM(clicks), 2)blended_cpc, SUM(ad_spend)total_spend, 
ROUND(AVG(ad_spend), 2)average_spend, SUM(conversions)total_conversions, AVG(conversions)avg_conversions, ROUND(SUM(ad_spend) / SUM(conversions), 2)blended_cpa, 
SUM(revenue)total_revenue, ROUND(SUM(revenue) / SUM(ad_spend), 2) AS blended_roas 
FROM ads_campaigns GROUP BY industry;
-- Each industry ads roughly perform at the same level, with SaaS doing the best with Blended ROAS of 5.04 , while Fintech doing the worst with Blended ROAS of 4.48.
-- SaaS have the lowest overall CPA of 33.08, while Fintech have the highest with 34.88 

-- Performance of each country
SELECT country, 
COUNT(*)total_records, SUM(impressions)total_impressions, AVG(impressions)avg_impressions, 
SUM(clicks)total_clicks, ROUND(SUM(clicks) / SUM(impressions), 4)blended_ctr, ROUND(SUM(ad_spend) / SUM(clicks), 2)blended_cpc, SUM(ad_spend)total_spend, 
ROUND(AVG(ad_spend), 2)average_spend, SUM(conversions)total_conversions, AVG(conversions)avg_conversions, ROUND(SUM(ad_spend) / SUM(conversions), 2)blended_cpa, 
SUM(revenue)total_revenue, ROUND(SUM(revenue) / SUM(ad_spend), 2) AS blended_roas 
FROM ads_campaigns GROUP BY country;
-- Same, each country ads roughly perform at the same level, with India doing the best with Blended ROAS of 5.50 , while USA doing the worst with Blended ROAS of 4.16.
-- India has the lowest overall CPA of 30.76, while USA have the highest with 36.01.

-- Performance of each campaign type
SELECT campaign_type, 
COUNT(*)total_campaigns, SUM(impressions)total_impressions, AVG(impressions)avg_impressions, 
SUM(clicks)total_clicks, ROUND(SUM(clicks) / SUM(impressions), 4)blended_ctr, ROUND(SUM(ad_spend) / SUM(clicks), 2)blended_cpc, SUM(ad_spend)total_spend, 
ROUND(AVG(ad_spend), 2)average_spend, SUM(conversions)total_conversions, AVG(conversions)avg_conversions, ROUND(SUM(ad_spend) / SUM(conversions), 2)blended_cpa, 
SUM(revenue)total_revenue, ROUND(SUM(revenue) / SUM(ad_spend), 2) AS blended_roas
FROM ads_campaigns GROUP BY campaign_type;
-- Same, each country ads roughly perform at the same level, with Search doing the best with Blended ROAS of 5.31, while shopping doing the worst with blended ROAS of 4.58.
-- Search has the lowest overall CPA of 31.64, while Video have the highest with 35.30.

-- Overall Monthly performance
SELECT YEAR(campaign_date) AS yearly, MONTH(campaign_date) AS monthly, 
COUNT(*)total_records, SUM(impressions)total_impressions, AVG(impressions)avg_impressions, 
SUM(clicks)total_clicks, ROUND(SUM(clicks) / SUM(impressions), 4)blended_ctr, ROUND(SUM(ad_spend) / SUM(clicks), 2)blended_cpc, SUM(ad_spend)total_spend, 
ROUND(AVG(ad_spend), 2)average_spend, SUM(conversions)total_conversions, AVG(conversions)avg_conversions, ROUND(SUM(ad_spend) / SUM(conversions), 2)blended_cpa, 
SUM(revenue)total_revenue, ROUND(SUM(revenue) / SUM(ad_spend), 2) AS blended_roas
FROM ads_campaigns
GROUP BY yearly, monthly 
ORDER BY yearly, monthly;
-- Blended ROAS peaks in October (5.38); it is lowest in May (4.17). The gap of min and max ROAS is 1.31 (5.38(oct) - 4.17(may).
-- Ad spend is highest in December (1,097,370) and lowest in July (797,918). The gap of min and max spend is 299,452 (1,097,370(dec) - 797,918(jul)

-- Quarterly performance per platform
SELECT YEAR(campaign_date) AS campaign_year,
QUARTER(campaign_date) AS campaign_quarter, 
platform,
COUNT(*) AS total_records,
ROUND(SUM(revenue) / SUM(ad_spend), 2) AS blended_roas,
ROUND(SUM(ad_spend) / SUM(conversions), 2) AS blended_cpa
FROM ads_campaigns
GROUP BY campaign_year, campaign_quarter, platform
ORDER BY campaign_year, campaign_quarter, platform;
-- By quarters rank from best to worst in terms of Blended ROAS and CPA, is still the same, 1. Tiktok ads, 2. Meta ads, 3. Google Ads.


-- 06. CROSS-SEGMENT PLATFORM COMPARISONS
-- platform comparison blended ROAS by industry.
SELECT industry,
ROUND(
SUM(CASE WHEN platform = 'TikTok Ads' THEN revenue END) / 
SUM(CASE WHEN platform = 'TikTok Ads' THEN ad_spend END), 2
) AS tiktok_roas,
ROUND(
SUM(CASE WHEN platform = 'Meta Ads' THEN revenue END) / 
SUM(CASE WHEN platform = 'Meta Ads' THEN ad_spend END), 2
) AS meta_roas,
ROUND(
SUM(CASE WHEN platform = 'Google Ads' THEN revenue END) / 
SUM(CASE WHEN platform = 'Google Ads' THEN ad_spend END), 2
) AS google_roas
FROM ads_campaigns
GROUP BY industry;

-- platform comparison blended ROAS by country.
SELECT country,
ROUND(
SUM(CASE WHEN platform = 'TikTok Ads' THEN revenue END) / 
SUM(CASE WHEN platform = 'TikTok Ads' THEN ad_spend END), 2
) AS tiktok_roas,
ROUND(
SUM(CASE WHEN platform = 'Meta Ads' THEN revenue END) / 
SUM(CASE WHEN platform = 'Meta Ads' THEN ad_spend END), 2
) AS meta_roas,
ROUND(
SUM(CASE WHEN platform = 'Google Ads' THEN revenue END) / 
SUM(CASE WHEN platform = 'Google Ads' THEN ad_spend END), 2
) AS google_roas
FROM ads_campaigns
GROUP BY country;

-- platform comparison blended ROAS by campaign type.
SELECT campaign_type,
ROUND(
SUM(CASE WHEN platform = 'TikTok Ads' THEN revenue END) / 
SUM(CASE WHEN platform = 'TikTok Ads' THEN ad_spend END), 2
) AS tiktok_roas,
ROUND(
SUM(CASE WHEN platform = 'Meta Ads' THEN revenue END) / 
SUM(CASE WHEN platform = 'Meta Ads' THEN ad_spend END), 2
) AS meta_roas,
ROUND(
SUM(CASE WHEN platform = 'Google Ads' THEN revenue END) / 
SUM(CASE WHEN platform = 'Google Ads' THEN ad_spend END), 2
) AS google_roas
FROM ads_campaigns
GROUP BY campaign_type;
-- Tiktok win across 16 different cuts.
-- TikTok Ads has the highest blended ROAS across all 16 industry, country, and campaign-type cuts in this dataset.


-- 07. ATTRIBUTED REVENUE BELOW AD SPEND
-- Check for campaigns with negative ROAS.
SELECT * FROM ads_campaigns WHERE roas < 0;

-- List records where attributed revenue is below ad spend.
SELECT platform, campaign_type, industry, country, campaign_date, ad_spend, revenue, roas
FROM ads_campaigns
WHERE revenue < ad_spend
ORDER BY roas ASC;

-- How much attributed money lost, and does it cluster on one platform?
SELECT platform,
COUNT(*) AS attributed_revenue_below_ad_spend,
ROUND(SUM(revenue) / SUM(ad_spend), 2) AS blended_roas_of_losers,
ROUND(SUM(ad_spend), 2) AS total_ad_spend_lost,
ROUND(SUM(ad_spend) - SUM(revenue), 2) AS net_attributed_dollars_lost
FROM ads_campaigns
WHERE revenue < ad_spend
GROUP BY platform;
-- Platform with most ad_spend loss and net attributed dollar loss is Google Ads: 992,269 in ad spend and 351,791 attributed revenue gap loss.

-- Rate, what share of each platform's records have attributed revenue below ad spend ?
SELECT platform,
COUNT(*) AS total_campaigns,
SUM(CASE WHEN revenue < ad_spend THEN 1 ELSE 0 END) AS attributed_revenue_below_ad_spend,
ROUND(100 * SUM(CASE WHEN revenue < ad_spend THEN 1 ELSE 0 END) / COUNT(*), 2) AS pct_revenue_below_ad_spend
FROM ads_campaigns
GROUP BY platform;
-- tiktok has the lowest share of losing attributed records, with 2.22%, 5.24% for Meta, and 12.92% for Google ads.


-- 08. SPEND-LEVEL ANALYSIS
-- comparison to spend group or amount of ad spend

-- comparison of group 1 and 4
SELECT platform, spend_group, 
COUNT(*) AS num_records, 
ROUND(AVG(ad_spend), 2) AS avg_spend, 
ROUND(SUM(revenue) / SUM(ad_spend), 2) AS blended_roas
FROM 
(SELECT *,
NTILE(4) OVER (PARTITION BY platform ORDER BY ad_spend) AS spend_group
FROM ads_campaigns
) spend_group
WHERE spend_group IN (1, 4)
GROUP BY platform, spend_group
ORDER BY platform, spend_group;

-- Comparison of blended ROAS across all four spend quartiles.
WITH quartiles AS (
SELECT *,
NTILE(4) OVER (PARTITION BY platform ORDER BY ad_spend) AS spend_group
FROM ads_campaigns
)
SELECT platform, spend_group,
COUNT(*) AS num_records,
ROUND(AVG(ad_spend), 0) AS avg_spend,
ROUND(SUM(revenue) / SUM(ad_spend), 2) AS blended_roas
FROM quartiles
GROUP BY platform, spend_group
ORDER BY platform, spend_group;
-- Compared in quartiles, tiktok still perform the best, while meta ads still in second, and google ads at last
-- The bigger / the more the avg ad spend is, the lower the blended ROAS, this happen to all the platform.
-- For google ads and meta ads, the blended roas rise from group 1 to 2, and then falls to group 3 and lower at group 4.
-- While for tiktok ads, it falls immidiately right after getting out of group 1.

-- Exact median ad spend for each platform.
WITH ranked AS (
SELECT platform, ad_spend,
ROW_NUMBER() OVER (PARTITION BY platform ORDER BY ad_spend, id) AS row_num,
COUNT(*) OVER (PARTITION BY platform) AS total_count
FROM ads_campaigns
)
SELECT platform,
ROUND(AVG(ad_spend), 2) AS median_ad_spend
FROM ranked
WHERE row_num IN (
FLOOR((total_count + 1) / 2),
FLOOR((total_count + 2) / 2)
)
GROUP BY platform
ORDER BY platform;


-- 09. FINDINGS AND RECOMMENDATIONS
-- 1. Tiktok ads have the best performance overall, lowest CPA(cost per aquisation), lowest rate of record with revenue below ad spend, with highest blended and average ROAS.

-- TikTok wins in every single industry, country, and campaign type no exceptions across 16 different cuts. That's unusually clean for real market data. 
-- It likely means this dataset doesn't model real trade-offs between platforms and context, worth stating as a data limitation, not hiding it.

-- Considering this there might be some attribution bias happening. Also in theory TikTok acts as a massive top-of-funnel discovery engine 
-- that artificially inflates Google Ads performance, while simultaneously making its own native ad performance look terribly inefficient.
-- Which if that effect were present here, TikTok's true edge could be even bigger than shown, but we have no way to confirm this dataset models that.

-- 2. The lead holds at big spend, but shrinks a lot. Even TikTok's biggest campaigns still beat Google's and Meta's biggest campaigns.
-- But the size of the win drops fast. Small campaigns(group 1) Blended ROAS: TikTok 12.65, Meta 7.47, Google 4.92 Blended ROAS. 
-- Big campaigns(group 4) Blended ROAS: TikTok 5.88, Meta 4.23, Google 2.89 ROAS.
-- Based on quartiles spend group measurement.

-- 3. Platforms behave differently as spend grows.
-- Google and Meta both get slightly better at first as spend rises, then get worse. TikTok gets worse right away, no warm-up.
-- This might mean Google/Meta need a small minimum budget to work well, while TikTok's best return is already at low spend.

-- 4. Share  that have revenue below ad spend: TikTok 2.22%, Meta 5.24%, Google 12.92%.
-- Caveat: TikTok only has 450 records total, so 2.22% is about 10 records. Real, but a small number to be fully sure about.

-- 5. Possible seasonal pattern.
-- ROAS looks higher in october, march, august, and january. Gap between best and worst month: 1.31.
-- Given how much ROAS varies naturally, this swing might just be noise. It is worth to watch out about this.

-- Overall recommendation
-- Test a gradual shift toward TikTok Ads while monitoring blended ROAS and CPA.
-- Validate results at higher spend and for the specific business before scaling. 
-- This data might has attribution bias, and it's worth to test with caution.
-- Treat this as general guidance across many types of business, not one company's tailored plan, since the data spans many industries and countries. 


-- 10. DATA LIMITATIONS
-- No company ID, means can't test if TikTok spend affects Google results for the same business.
-- No margin column, revenue < ad_spend as a stand-in for "losing attributed records," not a true break-even line.
-- No campaign ID or duration, not fully sure if ad_spend means one day's spend or a whole campaign.
-- Very uniform results across all cuts, may mean the data doesn't reflect real market trade-offs.
-- This dataset is build more for general guidance, means it doesn't have customer id and LTV can't be measured for each platform.
