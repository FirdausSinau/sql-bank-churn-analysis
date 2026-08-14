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
Before moving into analysis, the raw data went through a cleaning process (see `00_data_cleaning.sql`), carried out in the following stages.

**1. Staging table**
The raw data was copied from the original `cust_info` table into a new table, `cust_info_staging`, using a `CREATE TABLE` followed by an `INSERT ... SELECT`. This keeps the raw data untouched, so all cleaning and analysis work happens on a separate copy.

**2. Duplicate check**
The total row count was compared against the count of distinct `customer_id` values. Both returned 10,000, confirming there are no duplicate customers in the dataset.

**3. Standardization**
The `country` and `gender` columns were checked for inconsistent formatting (e.g. extra whitespace) using `TRIM()`, then updated to remove any leading or trailing spaces. This ensures values used later for grouping (e.g. `GROUP BY country`) aren't accidentally split into separate groups due to formatting differences.

**4. Null and blank value check**
Every column was checked for missing data, split by data type:
- Numeric columns (`customer_id`, `credit_score`, `age`, `tenure`, `balance`, `products_number`, `credit_card`, `active_member`, `estimated_salary`, `churn`) were checked using `IS NULL`.
- Text columns (`country`, `gender`) were checked using `IS NULL OR = ''`, since a text field can be blank without technically being NULL.

Categorical columns (`gender`, `credit_card`, `active_member`, `churn`) were also checked with `SELECT DISTINCT` to confirm they only contain valid values, and `age`, `tenure`, and `products_number` were checked for out-of-range or invalid values (e.g. age below 18, negative tenure, zero or negative product count).

**Result**: the dataset was found to be clean, with no duplicates and no null or blank values in any column.

## Exploratory Data Analysis (EDA)
Each business question was answered using a separate query file. The SQL code itself isn't reproduced here, refer to the linked file for the full query; this section focuses on the query result and what it means.

### Question 1: Attributes that differ between churners and non-churners
**File**: `02_churners_vs_non_churners.sql`, which compares the average of each customer attribute between the churned and stayed groups.

![Churners vs non-churners query result](screenshots/Churners%20vs%20Non-churnes.png)

**Key findings**:
- Out of 10,000 customers, 2,037 churned (20.4%) and 7,963 stayed (79.6%).
- Churned customers are older on average (44.8 years) than customers who stayed (37.4 years).
- Churned customers hold a higher average balance (91,108.5) than those who stayed (72,745.3).
- The clearest gap is in active status: only 36.1% of churned customers were active, compared to 55.5% of customers who stayed.
- Credit score (645.4 vs 651.9), credit card ownership (69.9% vs 70.7%), product count (1.5 vs 1.5), and estimated salary (101,465.7 vs 99,738.4) show little to no meaningful difference between the two groups.

### Question 2: Overall customer demographics
**File**: `01_overall_demographics.sql`, which calculates summary statistics for the full customer base, then breaks them down by gender and age group.

![Overall summary query result](screenshots/Demographics%20Overall.png)

- The bank has 10,000 customers across 3 countries, aged 18 to 92 (average 38.9 years).
- Average credit score is 650.5, average balance is 76,485.9, and customers hold 1.5 products on average.
- 51.5% of customers are active, and the overall churn rate is 20.4%.

![Gender distribution query result](screenshots/Demographics%20by%20gender.png)

- Male customers make up 54.6% of the base with a churn rate of 16.5%, while female customers make up 45.4% with a notably higher churn rate of 25.1%.

![Age bracket distribution query result](screenshots/Demographics%20Age%20Bracket.png)

- Churn rate rises steadily from the youngest group up to a peak at ages 50-59 (56.0%), then drops at age 60+ (27.9%).
- Active member rate by age bracket doesn't decrease steadily with age. It's actually lowest at ages 40-49 (46.7%) and highest at 60+ (78.9%), which lines up with why the 60+ group's churn rate drops instead of continuing to climb.

### Question 3: Differences between German, French, and Spanish customers
**File**: `03_geographic_analysis.sql`, which compares customer count, churn rate, and average characteristics across the three countries, then drills further into the highest-risk segment.

![Country comparison query result](screenshots/Geographic.png)

- France has the largest customer base (5,014, or 50.1%), with a churn rate of 16.2%, close to Spain's 16.7% (2,477 customers, 24.8%).
- Germany, despite making up a similar share of customers as Spain (2,509, or 25.1%), has a churn rate twice as high at 32.4%.
- The one attribute that stands out for Germany is average balance (119,730.1), well above France (62,092.6) and Spain (61,818.1). Age, tenure, product count, and active member rate are all similar across the three countries.

![Germany 40+ drill-down query result](screenshots/Geographic%20Germany.png)

- Among German customers aged 40 and above, 579 churned, a churn rate of 50.8%, with an average balance of 120,052.5 and an active member rate of only 47.7%.

### Question 4: Customer segments at the bank
**File**: `04_customer_segmentation.sql`, which groups customers into 5 segments based on tenure, balance, product count, and active status, checking active status first so every inactive customer is captured consistently, then compares the churn rate per segment.

**Segmentation criteria**: each customer is checked against the following conditions in order, and placed into the first one they match:

1. **Loyal**: tenure of 6+ years, balance above 100,000, 2 or more products, and currently active.
2. **Non-Active**: not currently active (checked before tenure/balance conditions below, so every inactive customer lands here rather than being caught by Established or At-Risk first).
3. **Established**: tenure of 4+ years and balance above 50,000 (only reached by active customers, since inactive ones were already placed above).
4. **At-Risk**: tenure of 2 years or less and balance of 50,000 or below (also only active customers at this point).
5. **Regular**: any active customer who doesn't fit the criteria above.

![Customer segmentation query result](screenshots/Customer%20Segmentation.png)

**Key findings**:

| Segment | Customers | % of Total | Churn Rate |
|---|---|---|---|
| Non-Active | 4,849 | 48.5% | 26.9% |
| Established | 1,661 | 16.6% | 17.0% |
| Loyal | 368 | 3.7% | 16.6% |
| At-Risk | 463 | 4.6% | 12.7% |
| Regular | 2,659 | 26.6% | 12.5% |

- With active status checked first, Non-Active now captures every inactive customer in the dataset (4,849, or 48.5% of the base), and this segment has the highest churn rate of all (26.9%).
- Established, now made up only of active customers who meet the tenure and balance criteria, has a churn rate of 17.0%, much lower than the 24.7% seen before active status was checked first (which had mixed active and inactive customers together).
- Loyal has the highest average balance (132,560.2) and product count (2.1) of any segment, but is no longer the lowest-churn segment. Regular (12.5%) and At-Risk (12.7%) are both lower. This suggests that once inactive customers are separated out properly, active status is a stronger churn driver than balance or product count on their own.