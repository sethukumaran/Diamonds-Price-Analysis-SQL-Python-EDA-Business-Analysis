# Diamonds Price Analysis — SQL + Python EDA & Business Analysis

## 1. Project overview
This project performs a senior-analyst-style exploratory data analysis (EDA), data-quality assessment, SQL business analysis, visualization, and predictive price modeling on the classic diamonds dataset.

**Business objective:** understand the drivers of diamond price, identify high-value product segments, evaluate inventory/value concentration, and build a baseline model that can support pricing and commercial decisions.

## 2. Dataset
- Raw records: **53,940**
- Columns: **10**
- Missing values: **0**
- Exact duplicate rows: **146**
- Records with zero dimensions (x/y/z): **20**
- Analysis records after removing invalid dimensions and exact duplicates: **53,775**

### Key fields
`carat`, `cut`, `color`, `clarity`, `depth`, `table`, `x`, `y`, `z`, `price`

## 3. EDA process
The Python workflow starts with:
1. Dataset shape and schema inspection.
2. Missing-value profiling.
3. Duplicate detection.
4. Descriptive statistics and distribution checks.
5. Invalid-dimension checks (`x`, `y`, `z` equal to zero).
6. Numeric correlation analysis.
7. Categorical-level profiling.
8. Business metric creation: volume, price per carat, and price per volume.

## 4. Data preparation
For business analysis, the workflow:
- removes exact duplicate rows;
- removes records where any physical dimension (`x`, `y`, `z`) is zero;
- preserves all other observations;
- creates `volume = x × y × z`;
- creates `price_per_carat = price / carat`.

This is a transparent analytical cleaning rule rather than an attempt to overwrite the source dataset.

## 5. Business findings

### Overall
- Analysis inventory: **53,775 diamonds**
- Total observed value (sum of price): **$211,401,371**
- Average price: **$3,931**
- Median price: **$2,401**
- Average price per carat: **$4,009**
- Price range: **$326 to $18,823**
- Carat range: **0.20 to 5.01 ct**

### Cut
The largest total value pool is **Ideal**, contributing **$74,384,253** across **21,485** units.

Premium has a higher average selling price than Ideal, but Ideal has the largest unit base and therefore the largest aggregate value. This is an important distinction between **unit economics** and **portfolio value contribution**.

### Color
By total observed value, **G** is the largest color segment at **$45,005,742**. The highest average price is associated with **J**.

Because carat mix differs materially across color grades, raw average price should not be interpreted as a pure color premium. Pricing decisions should control for carat and other quality attributes.

### Clarity
The highest average price occurs in **SI2**, while the largest total value pool is **SI1**. Again, mix effects matter: clarity groups have materially different average carat sizes.

### Price driver
Pearson correlation with price:
- Carat: **0.922**
- x dimension: **0.887**
- y dimension: **0.868**
- z dimension: **0.868**
- Table: **0.127**
- Depth: **-0.011**

The dominant commercial signal is **carat/physical size**, while depth has almost no linear correlation with price in this dataset.

## 6. Predictive modeling
A Random Forest regressor was used as a nonlinear benchmark after the EDA.

Test-set performance:
- **R²: 0.9825**
- **MAE: $270**
- **RMSE: $526**

The model substantially outperforms a simple linear baseline and indicates that price is driven by nonlinear interactions among carat, dimensions, and categorical quality attributes.

**Important:** this is an analytical benchmark, not a production pricing engine. Production use would require time-aware validation, market/brand effects, currency normalization, transaction-level prices, and monitoring for data drift.

## 7. SQL analysis
`diamonds_analysis.sql` contains SQLite-compatible queries for:
- data-quality checks;
- overall KPIs;
- cut/color/clarity performance;
- price-band segmentation;
- carat-band segmentation;
- cut × color commercial opportunities;
- high-value inventory extraction.

## 8. Visualizations
The `visualizations/` folder contains:
1. Price distribution
2. Carat vs price
3. Revenue/value by cut
4. Average price by color
5. Average price by clarity
6. Numeric correlation matrix

## 9. Recommended business actions
1. **Use carat as a primary pricing anchor**, but avoid a purely linear carat-price rule.
2. **Separate portfolio strategy from unit-price strategy:** Ideal has the largest aggregate value pool, while Premium commands a higher average price.
3. **Use controlled comparisons** when evaluating color and clarity premiums because their observed carat mix differs.
4. **Segment inventory by price and carat bands** for merchandising, promotion, and assortment planning.
5. **Prioritize nonlinear pricing models** for decision support; the Random Forest benchmark demonstrates strong predictive power.
6. **Investigate outliers and high-value stones separately**, because they can materially affect averages and commercial conclusions.

## 10. Conclusion
The analysis shows that diamond pricing is primarily associated with **carat and physical dimensions**, with cut, color, and clarity adding important segmentation effects. The largest business opportunity is not simply to maximize average selling price: it is to optimize the balance between **volume, total inventory value, and price realization** across quality segments.

The strongest practical takeaway is to move from one-dimensional pricing toward a **segmented, data-driven pricing framework** that combines carat/size with quality attributes. The strong Random Forest test performance supports using nonlinear predictive methods as a decision-support layer, while SQL summaries provide an auditable foundation for recurring commercial reporting.
