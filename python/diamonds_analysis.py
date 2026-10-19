
import pandas as pd
import numpy as np
from sklearn.model_selection import train_test_split
from sklearn.compose import ColumnTransformer
from sklearn.preprocessing import OneHotEncoder
from sklearn.pipeline import Pipeline
from sklearn.ensemble import RandomForestRegressor
from sklearn.metrics import r2_score, mean_absolute_error, mean_squared_error

df = pd.read_csv("diamonds.csv")

# EDA
print("Shape:", df.shape)
print("\nMissing values:\n", df.isna().sum())
print("\nDuplicate rows:", df.duplicated().sum())
print("\nDescriptive statistics:\n", df.describe(include="all").T)

# Data-quality rules: zero dimensions are physically invalid for a diamond.
invalid_dimensions = (df[["x","y","z"]] <= 0).any(axis=1)
analysis_df = df.loc[~invalid_dimensions].drop_duplicates().copy()

# Feature engineering
analysis_df["volume"] = analysis_df["x"] * analysis_df["y"] * analysis_df["z"]
analysis_df["price_per_carat"] = analysis_df["price"] / analysis_df["carat"]
analysis_df["price_per_volume"] = analysis_df["price"] / analysis_df["volume"]

print("\nAnalysis dataset:", analysis_df.shape)

# Business-level summaries
print("\nCut summary:")
print(analysis_df.groupby("cut").agg(
    count=("price","size"),
    revenue=("price","sum"),
    avg_price=("price","mean"),
    median_price=("price","median"),
    avg_price_per_carat=("price_per_carat","mean")
).sort_values("revenue", ascending=False))

print("\nColor summary:")
print(analysis_df.groupby("color").agg(
    count=("price","size"),
    revenue=("price","sum"),
    avg_price=("price","mean"),
    avg_price_per_carat=("price_per_carat","mean")
).sort_values("revenue", ascending=False))

print("\nClarity summary:")
print(analysis_df.groupby("clarity").agg(
    count=("price","size"),
    revenue=("price","sum"),
    avg_price=("price","mean"),
    avg_price_per_carat=("price_per_carat","mean")
).sort_values("revenue", ascending=False))

# Correlation
print("\nNumeric correlation with price:")
print(analysis_df.select_dtypes("number").corr()["price"].sort_values(ascending=False))

# Predictive model
X = analysis_df.drop(columns=["price","price_per_carat","price_per_volume","volume"])
y = analysis_df["price"]
cat = ["cut","color","clarity"]
pre = ColumnTransformer(
    [("cat", OneHotEncoder(handle_unknown="ignore"), cat)],
    remainder="passthrough"
)
X_train, X_test, y_train, y_test = train_test_split(
    X, y, test_size=0.20, random_state=42
)
model = Pipeline([
    ("pre", pre),
    ("model", RandomForestRegressor(
        n_estimators=200, max_depth=18, min_samples_leaf=2,
        n_jobs=-1, random_state=42
    ))
])
model.fit(X_train, y_train)
pred = model.predict(X_test)

print("\nRandom Forest performance")
print("R2:", round(r2_score(y_test, pred), 4))
print("MAE:", round(mean_absolute_error(y_test, pred), 2))
print("RMSE:", round(mean_squared_error(y_test, pred) ** 0.5, 2))
