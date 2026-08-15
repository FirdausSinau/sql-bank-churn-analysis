# Bank Customer Churn Analysis

## Project Overview
This project uses SQL to explore customer churn — customers who stop using a bank's services — at a multistate bank. The work is framed around four business questions posed by the bank's management, the party who needs the analysis, with the goal of producing actionable recommendations to reduce churn.

## About the Dataset
The analysis is built on the **Bank Customer Churn Dataset** from Kaggle: 10,000 customers of a multistate bank, each described by 12 columns. `churn` is the target variable — 1 means the customer left, 0 means the customer stayed. The remaining columns describe the customer:

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
The analysis answers four questions:

1. Which attributes are more common among churners than non-churners?
2. What do the overall demographics (population characteristics) of the bank's customers look like?
3. Do German, French, and Spanish customers differ in account behavior?
4. What segments exist within the bank's customer base?

A fifth question — whether churn can be predicted from the available variables — falls outside the scope of this project. Prediction requires machine learning; SQL-based EDA cannot answer it. It is recorded here as a direction for future work.

## Data Cleaning
Cleaning precedes the analysis and is documented in `00_data_cleaning.sql`. The process ran in four stages. None of it is analysis itself, but the stages matter: the grouping queries later in this project only produce clean results if the input is clean first.

**1. Staging table**
The raw data was copied from the original `cust_info` table into `cust_info_staging` using `CREATE TABLE` followed by `INSERT ... SELECT`. All cleaning and analysis happens on the copy, so the raw data stays untouched.

**2. Duplicate check**
Total rows and distinct `customer_id` values were counted and compared. Both returned 10,000 — the dataset contains no duplicate customers.

**3. Standardization**
The `country` and `gender` columns were checked for inconsistent formatting and cleaned with `TRIM()` to remove leading and trailing spaces. Without this step, values such as `'Germany'` and `' Germany '` would split into separate groups in `GROUP BY` queries.

**4. Null and blank value check**
Every column was checked for missing data, split by type:
- Numeric columns (`customer_id`, `credit_score`, `age`, `tenure`, `balance`, `products_number`, `credit_card`, `active_member`, `estimated_salary`, `churn`) were tested with `IS NULL`.
- Text columns (`country`, `gender`) were tested with `IS NULL OR = ''`, since a text field can be blank without being NULL.

Categorical columns (`gender`, `credit_card`, `active_member`, `churn`) were also reviewed with `SELECT DISTINCT` to confirm only valid values exist, and `age`, `tenure`, and `products_number` were checked for out-of-range values — age below 18, negative tenure, or a product count of zero or less.

The dataset came out clean: no duplicates, no nulls, no blank values, no invalid entries. No imputation or deletion was needed.

## Exploratory Data Analysis (EDA)
Each business question has its own query file. The SQL itself is not reproduced here; each section below presents the query result and what it means, and links to the file for the full query.

### Question 1: Attributes that differ between churners and non-churners
**File**: `02_churners_vs_non_churners.sql`, which compares the average of each customer attribute between the churned and stayed groups.

![Churners vs non-churners query result](screenshots/Churners%20vs%20Non-churnes.png)

2,037 customers left (20.4%); 7,963 stayed (79.6%). The average profiles diverge in three places. Churners are older — 44.8 years on average against 37.4 for those who stayed — and hold a higher average balance (91,108.5 vs 72,745.3). The widest gap is in activity: only 36.1% of churners were active members, compared with 55.5% of those who stayed.

The remaining attributes barely differ between the two groups: average credit score 645.4 vs 651.9, credit card ownership 69.9% vs 70.7%, average product count 1.5 in both, and estimated salary 101,465.7 vs 99,738.4. None of these separates churners from non-churners.

The activity gap was followed up directly. Inactivity can matter in two distinct ways: how common it is, and how much churn it causes once a customer is inactive. The two are not the same thing, so both were measured.

![Inactive prevalence and consequence by country](screenshots/Non%20active%20by%20country.png)

Prevalence is similar across countries: 48.3% of customers are inactive in France, 50.3% in Germany, 47.0% in Spain. The consequence is not similar. Among inactive customers, churn reaches 21.1% in France and 23.3% in Spain — but 41.1% in Germany. Inactivity is about equally common everywhere; it is far more costly in Germany.

![Inactive prevalence and consequence by age bracket](screenshots/Non%20active%20by%20age%20bracket.png)

By age, prevalence stays fairly flat: 49.0% at 18-29, rising only slightly to 53.3% at 40-49, then dropping to 21.1% at 60+. Churn among inactive customers tells a different story. It climbs with age — 9.8% at 18-29, 13.6% at 30-39, 38.0% at 40-49, 81.2% at 50-59 — and reaches 85.6% at 60+.

### Question 2: Overall customer demographics
**File**: `01_overall_demographics.sql`, which calculates summary statistics for the full customer base, then breaks them down by gender and age group.

![Overall summary query result](screenshots/Demographics%20Overall.png)

The bank serves 10,000 customers across three countries, aged 18 to 92 (average 38.9). The average credit score is 650.5, the average balance is 76,485.9, and customers hold 1.5 products on average. 51.5% of the base is active; the overall churn rate is 20.4%.

![Age bracket distribution query result](screenshots/Demographics%20Age%20Bracket.png)

| Age Bracket | Customers | % of Total | Churn Rate | Active Member % |
|---|---|---|---|---|
| 18-29 | 1,641 | 16.4% | 7.6% | 51.0% |
| 30-39 | 4,346 | 43.5% | 10.9% | 50.2% |
| 40-49 | 2,618 | 26.2% | 30.8% | 46.7% |
| 50-59 | 869 | 8.7% | 56.0% | 57.1% |
| 60+ | 526 | 5.3% | 27.9% | 78.9% |

The base skews young: 43.5% of customers are aged 30-39, and close to two thirds are under 40. Churn behaves very differently from the age distribution. It rises from 7.6% at 18-29 to 10.9% at 30-39, more than doubles to 30.8% at 40-49, peaks at 56.0% for ages 50-59, then drops to 27.9% at 60+. Activity helps explain the drop: only 46.7% of customers at 40-49 are active, against 78.9% at 60+. The customers who remain with the bank into old age are, by and large, still actively banking.

![Gender distribution query result](screenshots/Demographics%20by%20gender.png)

Men form the majority — 5,457 customers (54.6%) — with a churn rate of 16.5%. Women, 4,543 (45.4%), churn at 25.1%. To locate the gap more precisely, churn by gender was broken down by country and by age.

![Gender by country query result](screenshots/Gender%20by%20country.png)

| Country | Female Churn Rate | Male Churn Rate |
|---|---|---|
| France | 20.3% | 12.7% |
| Spain | 21.2% | 13.1% |
| Germany | 37.6% | 27.8% |

Women churn more than men in all three countries. The gap is 7-8 points in France and Spain (20.3% vs 12.7%, and 21.2% vs 13.1%) and about 10 points in Germany (37.6% vs 27.8%).

![Gender by age bracket query result](screenshots/Gender%20by%20age%20bracket.png)

| Age Bracket | Female Churn Rate | Male Churn Rate | Gap |
|---|---|---|---|
| 18-29 | 9.9% | 5.6% | 4.3 pts |
| 30-39 | 14.2% | 8.3% | 5.9 pts |
| 40-49 | 36.1% | 26.0% | 10.1 pts |
| 50-59 | 62.9% | 49.6% | 13.3 pts |
| 60+ | 34.0% | 22.8% | 11.2 pts |

The gender gap appears in every age bracket, with no exception, and it widens with age: 4.3 points at 18-29, 5.9 at 30-39, 10.1 at 40-49, 13.3 at 50-59, then 11.2 at 60+. A flat, additive gender effect would keep the gap roughly constant; it does not. Women aged 50-59 churn at 62.9% — the highest rate of any age-gender combination in the dataset.

### Question 3: Differences between German, French, and Spanish customers
**File**: `03_geographic_analysis.sql`, which compares customer count, churn rate, and average characteristics across the three countries, then drills further into the highest-risk segment.

![Country comparison query result](screenshots/Geographic.png)

France holds half the base: 5,014 customers (50.1%), churning at 16.2%. Spain has 2,477 customers (24.8%) at 16.7%. Germany's 2,509 customers (25.1%) churn at 32.4% — twice the rate of the other two countries, despite holding a similar share of the base.

The attributes that usually matter — age, tenure, product count, activity — are similar across all three countries. One attribute is not: average balance. German customers carry 119,730.1 on average, against 62,092.6 in France and 61,818.1 in Spain.

![Germany 40+ drill-down query result](screenshots/Geographic%20Germany.png)

German customers aged 40 and above were isolated next. 579 of them churned — a rate of 50.8% — with an average balance of 120,052.5 and an active rate of 47.7%. The figure blends every age from 40 upward into one number, so it was split into individual brackets:

![Germany age bracket query result](screenshots/Geographic%20germany%20age%20bracket.png)

| Age Bracket (Germany only) | Customers | Churn Rate |
|---|---|---|
| 18-29 | 372 | 12.6% |
| 30-39 | 997 | 18.9% |
| 40-49 | 740 | 45.1% |
| 50-59 | 277 | **70.0%** |
| 60+ | 123 | 41.5% |

The risk is not spread evenly across that range. It stays moderate through 30-39 (18.9%), jumps to 45.1% at 40-49, peaks at 70.0% for ages 50-59 — well above the blended 50.8% figure — and drops to 41.5% at 60+. The age pattern seen bank-wide in Question 2 repeats here, only sharper.

One check remains. Inactivity was the clearest differentiator in Question 1; the question here is whether it compounds with being German and aged 50-59, or acts as a separate factor.

![Compounding query result](screenshots/Compounding.png)

| Active Status (Germany, age 50-59) | Customers | Churn Rate |
|---|---|---|
| Active | 131 | 51.9% |
| Inactive | 146 | 86.3% |

Even German customers aged 50-59 who are still active churn at 51.9% — high on its own. Adding inactivity pushes the rate to 86.3%. The two factors compound; they do not simply add.

### Question 4: Customer segments at the bank
**File**: `04_customer_segmentation.sql`, which groups customers into 5 segments based on tenure, balance, product count, and active status, then compares the churn rate per segment. The criteria are checked in order, and each customer lands in the first segment they match:

1. **Loyal**: tenure of 6+ years, balance above 100,000, 2 or more products, and currently active.
2. **Non-Active**: not currently active — checked before the tenure and balance conditions below, so every inactive customer lands here rather than in Established or At-Risk.
3. **Established**: tenure of 4+ years and balance above 50,000 (only reached by active customers).
4. **At-Risk**: tenure of 2 years or less and balance of 50,000 or below (also active-only at this point).
5. **Regular**: any active customer who fits none of the criteria above.

![Customer segmentation query result](screenshots/Customer%20Segmentation.png)

| Segment | Customers | % of Total | Churn Rate |
|---|---|---|---|
| Non-Active | 4,849 | 48.5% | 26.9% |
| Established | 1,661 | 16.6% | 17.0% |
| Loyal | 368 | 3.7% | 16.6% |
| At-Risk | 463 | 4.6% | 12.7% |
| Regular | 2,659 | 26.6% | 12.5% |

Non-Active is the largest segment by far — 4,849 customers, 48.5% of the base — and its churn rate is the highest at 26.9%. Established (1,661 customers) churns at 17.0%; the 24.7% figure seen before activity was checked first mixed active and inactive customers together. Loyal holds the highest average balance (132,560.2) and product count (2.1) of any segment, but not the lowest churn: Regular (12.5%) and At-Risk (12.7%) sit below it. Once inactive customers are separated out, activity appears to drive churn more than balance or product count on their own.

One result deserves a closer look. Loyal averages 2.1 products and Established 1.3, and Loyal's churn rate is the lower of the two. Averages hide distributions, so churn was broken down by exact product count across the whole base:

| Products Held | Customers | Churn Rate |
|---|---|---|
| 1 | 5,084 | 27.7% |
| 2 | 4,590 | **7.6%** |
| 3 | 266 | 82.7% |
| 4 | 60 | 100.0% |

The relationship is not a straight line. Two products is the safest point (7.6%), clearly better than one (27.7%); three or four products carry churn rates of 82.7% and 100.0%. The group at 3-4 products is small — 326 customers combined — and the dataset does not explain the underlying cause. This pattern is left as an open question, not as grounds for encouraging unlimited product cross-selling.

## Tools Used
- MySQL (MySQL Workbench) for data cleaning and analysis
- Dataset: [Bank Customer Churn Dataset](https://www.kaggle.com/datasets/gauravtopre/bank-customer-churn-dataset) from Kaggle
