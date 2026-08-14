# Bank Customer Churn Analysis

## Project Overview
This project is an exploratory data analysis (EDA) using SQL to understand churn patterns (customers who stop using a bank's services) at a bank. The analysis was structured around business questions from the stakeholder's perspective (the party who needs the analysis, in this case the bank's management team), with the goal of producing actionable recommendations to reduce churn.

## About the Dataset
The dataset used is the **Bank Customer Churn Dataset** from Kaggle, containing data for 10,000 customers of a multistate bank (operating across several countries), with the following 12 columns:

| Column | Description |
|---|---|
| customer_id | Unique identifier for each customer |
| credit_score | Customer's credit score. A higher score indicates a better credit history |
| country | Country where the customer is registered (France, Spain, or Germany) |
| gender | Customer's gender |
| age | Customer's age, in years |
| tenure | How long the customer has been with the bank, in years |
| balance | The customer's account balance |
| products_number | Number of bank products the customer holds, e.g. savings, credit card, or loan |
| credit_card | Whether the customer holds a credit card (1 = yes, 0 = no) |
| active_member | Whether the customer is actively using their account (1 = active, 0 = inactive) |
| estimated_salary | Customer's estimated annual salary |
| churn | Churn status. This is the target variable of the analysis (1 = customer left, 0 = customer stayed) |

## Business Questions (Stakeholder Questions)
This analysis was built to answer 4 questions:

1. What attributes are more common among churners than non-churners?
2. What do the overall demographics (population characteristics) of the bank's customers look like?
3. Is there a difference between German, French, and Spanish customers in terms of account behavior?
4. What types of segments exist within the bank's customers?

Note: the original question set also included "can churn be predicted using the variables in the data?" This question is out of scope for SQL-based EDA, as it requires predictive modeling using machine learning. It is left as a direction for future work rather than part of this analysis.

## Data Cleaning
Before the analysis stage, the data was checked and cleaned through the following steps (see `00_data_cleaning.sql`):

1. **Staging table**: the raw data was copied into a separate table (`cust_info_staging`) so the original data stays untouched during the cleaning process.
2. **Duplicate check**: confirming no identical rows appear more than once.
3. **Text standardization**: trimming extra whitespace in the `country` and `gender` columns.
4. **Null and anomaly check**: verifying that categorical columns (`gender`, `credit_card`, `active_member`, `churn`) only contain valid values, and checking that `age`, `tenure`, and `products_number` fall within a reasonable range.

**Result**: the data was found to be clean, with no duplicates or null values. A value of 0 in columns such as `tenure` or `products_number` was only treated as a potential anomaly when it fell outside a reasonable range (e.g. a negative value, or zero in a column that should never be zero), not automatically treated as missing data.

## Exploratory Data Analysis (EDA)
Each business question was answered with a separate query file, following the structure below.

### Question 1: Attributes that differ between churners and non-churners
**File**: `02_churners_vs_non_churners.sql`
**Approach**: comparing the average of each attribute (age, credit score, balance, product count, tenure, active status, credit card ownership, estimated salary) between customers who churned and those who stayed.

**Key findings**:
- Out of 10,000 total customers, 79.6% stayed and 20.4% churned.
- Churned customers are on average 44.8 years old, older than customers who stayed (37.4 years).
- The average balance of churned customers is higher (91,108) than customers who stayed (72,745).
- The starkest difference is in active status: only 36.1% of churned customers were still active, compared to 55.5% of customers who stayed.
- Credit score and credit card ownership showed no meaningful difference between the two groups, so these two attributes were not carried into further analysis.

### Question 2: Overall customer demographics
**File**: `01_overall_demographics.sql`
**Approach**: calculating summary statistics for all customers, then breaking them down by gender and age group.

**Key findings**:
- All 10,000 customers come from 3 countries, with ages ranging from 18 to 92 years (average 39).
- 51.5% of customers are classified as active users of their account.
- The overall churn rate is 20.4%.
- By age group, churn rate rises steadily from the youngest group up to a peak at ages 50-59 (56.0%), then drops again at age 60+ (27.9%). This drop is examined further in the Conclusion section, and turns out to be related to the active status of customers in that age group.

### Question 3: Differences between German, French, and Spanish customers
**File**: `03_geographic_analysis.sql`
**Approach**: comparing customer count, churn rate, and average characteristics across countries, then drilling further into the segment with the highest churn rate.

**Key findings**:
- France has the largest customer base (50.1%), with a relatively stable churn rate (16.2%), similar to Spain (16.7%).
- Germany, despite making up only 25.1% of the total customer base, has a churn rate twice as high (32.4%).
- Drilling further into German customers aged 40 and above, the churn rate reaches 50.8%.
- The only attribute that differs significantly for Germany compared to other countries is average balance (119,730, compared to around 62,000 in France and Spain). Age, product count, and tenure are relatively similar across countries, making balance the main indicator that sets Germany apart.

### Question 4: Customer segments at the bank
**File**: `04_customer_segmentation.sql`
**Approach**: grouping customers into 5 segments based on a combination of tenure, balance, product count, and active status, then comparing the churn rate per segment.

**Segments formed**:

| Segment | Criteria | Customer Count | Churn Rate |
|---|---|---|---|
| Loyal | Long-tenured (tenure >= 6 years), balance above 100,000, 2 or more products, and active | 368 (3.7%) | 16.6% |
| Established | Moderately long-tenured (tenure >= 4 years) with balance above 50,000 | 3,687 (36.9%) | 24.7% |
| At-Risk | Newer customers (tenure <= 2 years) with low balance (<= 50,000) | 888 (8.9%) | 16.9% |
| Non-Active | Customers not actively using their account | 2,398 (24.0%) | 24.3% |
| Regular | Customers not falling into any of the categories above | 2,659 (26.6%) | 12.5% |

**Key findings**:
- The Established and Non-Active segments have the highest churn rates (24.7% and 24.3%).
- The Loyal segment has the lowest churn rate (16.6%) despite having the highest balance (132,560), offset by a higher product count (2.1 products on average).
- In contrast, the Established segment has a high balance (119,653) but a low product count (1.3 on average), and a higher churn rate.
- This pattern shows that the number of products a customer holds, not just the size of their balance, plays a role in how loyal they are.

## Conclusion
Based on the four analyses above, customers at risk of churning tend to share the following combination of traits:

1. **Older age**, particularly in the 40 to 59 range, with the peak risk at ages 50-59.
2. **High balance, but few products**. Customers with a high balance but only 1 to 2 products (the Established segment profile) are at higher risk than customers with a high balance but many products (the Loyal segment profile).
3. **Based in Germany**. Germany's churn rate is twice as high as France and Spain, despite having similar age, product count, and tenure. The one attribute that stands out is the significantly higher average balance among German customers.
4. **Not actively using their account**. This is the most consistent indicator across all age groups (55.5% active among customers who stayed, versus 36.1% among churners), and the pattern becomes sharper for customers aged 60 and above (96% active among those who stayed, versus only 35% among churners).

Credit score and credit card ownership showed no meaningful relationship with churn, so these two attributes were not used as a basis for the recommendations.

Overall, the highest churn risk is found in the combination of customers with a high balance, few products, and no longer active, especially if they are based in Germany and in their 50s.

## Recommendations

**1. Prioritize retention efforts for German customers aged 50 to 59 with a high balance**
This segment has the highest churn rate found across the entire analysis (reaching 50.8% among German customers aged 40 and above). This dataset does not include customer service, fee, or competitor data, so more specific product recommendations would require additional data. However, the pattern of high balance paired with a low product count suggests an opportunity to offer additional products before these customers churn.

**2. Cross-sell additional products to customers with a high balance and few products**
Customers with a high balance but only around 1.3 products on average (the Established segment) have a churn rate of 24.7%, much higher than the Loyal segment, which averages 2.1 products with a churn rate of only 16.6%. This shows that the number of products held, not just balance size, is an important factor in retaining customers.

**3. Build a monitoring system for customer active status, applied to the entire customer base**
Customers who become less active in using their account show a higher tendency to churn. Active status can serve as an early warning signal to trigger follow-up actions, such as direct outreach from a relationship manager, incentives to re-engage, or offers of additional products, before the customer fully churns.

## Data Limitations
This dataset does not include several pieces of information that would be relevant for further churn analysis, such as customer service data (complaints, interaction history), fee structure, competitor activity, or the customer's explicit reason for leaving. The recommendations produced here are general in nature, based on patterns found in the available data, and should be validated further with additional data before being applied directly to business strategy.

## Repository Structure
```
├── README.md
├── data/
│   └── Bank_Customer_Churn_Prediction.csv
├── 00_data_cleaning.sql
├── 01_overall_demographics.sql
├── 02_churners_vs_non_churners.sql
├── 03_geographic_analysis.sql
└── 04_customer_segmentation.sql
```

## Tools Used
- MySQL (MySQL Workbench) for data cleaning and analysis
- Dataset: [Bank Customer Churn Dataset](https://www.kaggle.com/datasets/gauravtopre/bank-customer-churn-dataset) from Kaggle
