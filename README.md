# zomato-analysis-sql
SQL-based market intelligence and restaurant performance analysis using 10,000+ records.
# 🍴 Zomato Restaurant Insights Analysis | SQL & Market Intelligence

## 📌 Project Overview
This project involves a deep-dive analysis of over **10,000+ restaurant records** across 8+ cities using Advanced SQL. The objective was to decode pricing strategies, restaurant performance, and regional demand to provide actionable intelligence for market optimization.

---

## 🛠️ Technical Toolkit
- **Language:** SQL (MySQL/PostgreSQL)
- **Advanced Techniques used:** 
  - **Window Functions:** `RANK()`, `LAG()`, `PARTITION BY` (For performance tiering).
  - **CTEs:** For clean, modular, and high-performance queries.
  - **Complex Aggregations:** To calculate market share and demand density.
  - **Data Cleaning:** Handling NULLs and standardizing currency/pricing.

---

## 🚀 Key Business Insights

### 1. Performance Tiering & Competitor Gaps
*   **Method:** Used `RANK()` partitioned by city to identify top 10 performers.
*   **Insight:** Top-tier restaurants maintain a **30% higher engagement rate** than their immediate competitors, even with higher pricing.

### 2. Pricing "Sweet-Spot" Optimization
*   **Method:** Segmented restaurants into Budget, Mid-Tier, Premium, and Luxury using `CASE` statements.
*   **Insight:** Found a non-linear correlation where **Mid-tier (₹300-₹700)** restaurants saw a peak in ratings, suggesting a price-point optimization strategy for new entrants.

### 3. Regional Market Share
*   **Method:** Performed city-wise aggregation to map restaurant density vs. customer votes.
*   **Insight:** Identified "High-Demand, Low-Supply" zones, providing a roadmap for strategic resource allocation and marketing spend.

---

## 📂 Repository Structure
| Folder/File | Description |
| :--- | :--- |
| `scripts/` | Contains the complete `.sql` analysis files. |
| `dataset/` | Links/References to the Kaggle Zomato Dataset. |
| `README.md` | Project documentation and executive summary. |

---

## 📈 Executive Summary
By analyzing pricing tiers and regional performance, this project demonstrates how SQL can be used to drive **data-backed business decisions**, improve **order conversions**, and identify **untapped market opportunities**.
