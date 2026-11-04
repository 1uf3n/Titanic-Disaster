# Titanic Disaster Prediction — Python and R Analysis with Docker

## Project Overview

This project analyzes the Titanic passenger dataset using **Python and R** to predict passenger survival. Both implementations use logistic regression and run in Docker containers for reproducibility.

The project includes exploratory data analysis, missing-value handling, feature preprocessing, model training, validation, and prediction generation.

## Dataset

**Source:** [Kaggle — Titanic: Machine Learning from Disaster](https://www.kaggle.com/competitions/titanic/data)

Download the following files from Kaggle:

- `train.csv` — labeled passenger data used for training and validation (891 passengers).
- `test.csv` — unlabeled passenger data used to generate predictions (418 passengers).

Create a `src/data/` folder in the project and place both files inside it:

```text
src/
└── data/
    ├── train.csv
    └── test.csv
```

The dataset files are not included in this GitHub repository. Download them from Kaggle before running the project.

## Project Structure

```text
Titanic-Disaster/
├── .gitignore
├── .dockerignore
├── README.md
├── src/
│   ├── data/                    # Download locally from Kaggle
│   ├── python/
│   │   ├── Dockerfile
│   │   ├── main.py
│   │   └── requirements.txt
│   └── r/
│       ├── Dockerfile
│       ├── main.R
│       └── install_packages.R
└── outputs/                     # Generated locally
```

## Tools and Technologies

- Python, pandas, NumPy, scikit-learn
- R
- Docker and Docker Desktop
- Git and GitHub

## Methodology

Both implementations use the following predictors:

- Passenger class (`Pclass`)
- Sex (`Sex`)
- Age (`Age`)
- Number of siblings/spouses (`SibSp`)
- Number of parents/children (`Parch`)
- Fare (`Fare`)

The programs encode sex numerically, fill missing predictor values using training medians, and fit logistic regression models.

The Python implementation also standardizes predictors before logistic regression.

The labeled data is split into training and validation subsets to evaluate predictive performance. The final models are refitted using all labeled training observations before generating test predictions.

## Results

| Metric | Python | R |
|---|---:|---:|
| Training observations | 891 | 891 |
| Test observations | 418 | 418 |
| Training-split size | 712 | 712 |
| Validation size | 179 | 179 |
| Training-split accuracy | 79.78% | 79.49% |
| Validation accuracy | 81.01% | 82.68% |
| Full training accuracy | 79.46% | 79.46% |

The Python and R validation accuracies should not be interpreted as a controlled model comparison unless the validation splits are confirmed to be identical.

**Note:** The Kaggle `test.csv` does not contain survival labels, so test accuracy cannot be calculated locally. The reported validation accuracy is not the Kaggle competition score.

## Running the Python Solution

First, install and start Docker Desktop. Open a terminal in the repository's root directory.

Build the Python Docker image:

```bash
docker build -t titanic-python -f src/python/Dockerfile .
```

Create the output folder:

```bash
mkdir -p outputs
```

Run the Python container:

```bash
docker run --rm \
  --mount "type=bind,source=$(pwd)/src/data,target=/app/src/data,readonly" \
  --mount "type=bind,source=$(pwd)/outputs,target=/app/outputs" \
  titanic-python
```

The script generates:

`outputs/python_predictions.csv`

## Running the R Solution

Build the R Docker image:

```bash
docker build -t titanic-r -f src/r/Dockerfile .
```

Run the R container:

```bash
docker run --rm \
  --mount "type=bind,source=$(pwd)/src/data,target=/app/src/data,readonly" \
  --mount "type=bind,source=$(pwd)/outputs,target=/app/outputs" \
  titanic-r
```

The script generates:

`outputs/r_predictions.csv`

## Reproducibility

To reproduce the project:

1. Clone this GitHub repository.
2. Install and start Docker Desktop.
3. Download `train.csv` and `test.csv` from the [Kaggle Titanic dataset page](https://www.kaggle.com/competitions/titanic/data).
4. Place the CSV files inside `src/data/`.
5. Run the Docker build and execution commands above.
6. Review the terminal output and generated prediction files in `outputs/`.

The original datasets and generated predictions are kept out of Git version control. The source code, Dockerfiles, and dependency specifications are stored in GitHub.

## GitHub Workflow

The project follows a feature-branch workflow:

- `main` — final project branch
- `develop` — integration branch
- `feature/setup` — initial project configuration
- `feature/python` — Python implementation
- `feature/r` — R implementation

Feature branches were integrated through GitHub Pull Requests.

## Repository

[GitHub — Titanic-Disaster](https://github.com/1uf3n/Titanic-Disaster)
