"""Explore Titanic data, fit logistic regression, and save predictions."""
from pathlib import Path
import pandas as pd
from sklearn.impute import SimpleImputer
from sklearn.linear_model import LogisticRegression
from sklearn.metrics import accuracy_score
from sklearn.model_selection import train_test_split
from sklearn.pipeline import make_pipeline
from sklearn.preprocessing import StandardScaler

ROOT = Path(__file__).resolve().parents[2]
FEATURES = ["Pclass", "Sex", "Age", "SibSp", "Parch", "Fare"]


def prepare(data):
    """Select predictors and turn sex into a numeric column."""
    result = data[FEATURES].copy()
    result["Sex"] = result["Sex"].map({"male": 0, "female": 1})
    return result


def new_model():
    """Learn missing-value replacements and scaling from training rows only."""
    return make_pipeline(
        SimpleImputer(strategy="median"),
        StandardScaler(),
        LogisticRegression(max_iter=1000, random_state=42),
    )


def main():
    """Run the complete analysis and print each important step."""
    folder = ROOT / "src" / "data"
    for name in ["train.csv", "test.csv"]:
        if not (folder / name).exists():
            raise FileNotFoundError(f"Download {name} from Kaggle into {folder}.")
    train = pd.read_csv(folder / "train.csv")
    test = pd.read_csv(folder / "test.csv")
    print("Training shape:", train.shape, "Test shape:", test.shape)
    print("\nMissing values in the selected training columns:")
    print(train[FEATURES].isna().sum().to_string())
    print("\nSurvival rate by sex:")
    print(train.groupby("Sex")["Survived"].mean().to_string())
    print("\nSurvival rate by passenger class:")
    print(train.groupby("Pclass")["Survived"].mean().to_string())
    print("\nKeep:", FEATURES)
    print("Encode male=0, female=1. Fill missing predictors with training medians.")
    print("Standardize predictors before logistic regression; do not drop rows.")

    X, y = prepare(train), train["Survived"]
    X_train, X_valid, y_train, y_valid = train_test_split(
        X, y, test_size=0.2, random_state=42, stratify=y
    )
    model = new_model()
    model.fit(X_train, y_train)
    print(f"\nSplit: {len(X_train)} training rows, {len(X_valid)} validation rows.")
    print(f"Training-split accuracy: {accuracy_score(y_train, model.predict(X_train)):.4f}")
    print(f"Held-out validation accuracy: {accuracy_score(y_valid, model.predict(X_valid)):.4f}")

    # Refit on all labeled rows before predicting the Kaggle test passengers.
    final_model = new_model()
    final_model.fit(X, y)
    print("\nRefit the model and preprocessing on all labeled training rows.")
    print(f"Full training accuracy: {accuracy_score(y, final_model.predict(X)):.4f}")
    predictions = final_model.predict(prepare(test))
    result = pd.DataFrame({"PassengerId": test["PassengerId"], "Survived": predictions})
    output = ROOT / "outputs"
    output.mkdir(exist_ok=True)
    result.to_csv(output / "python_predictions.csv", index=False)
    print("\nFirst five test predictions:")
    print(result.head().to_string(index=False))
    print("Saved", len(result), "predictions to outputs/python_predictions.csv")
    print("Test accuracy: unavailable because Kaggle test.csv has no Survived labels.")
    print("Validation accuracy above is NOT the Kaggle test accuracy.")
    print("Upload the prediction CSV to Kaggle for a hidden-label competition score.")


if __name__ == "__main__":
    main()
