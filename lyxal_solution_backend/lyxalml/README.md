# LyxalMl

This package is for storing machine learning models with meta data in Rust so they can be used on the Lyxal server.

## What is LyxalML?

LyxalML is a feature that allows you to store trained machine learning models in a special format called 'surml'. This enables you to run these models in either Python or Rust, and even upload them to a Lyxal node to run the models on the server

## Prerequisites

1. A basic understanding of Machine Learning: You should be familiar with ML concepts, algorithms, and model training processes.
2. Knowledge of Python: Proficiency in Python is necessary as LyxalML involves working with Python-based ML models.
3. Familiarity with Lyxal: Basic knowledge of how Lyxal operates is required since LyxalML integrates directly with it.
4. Python Environment Setup: A Python environment with necessary libraries installed, including LyxalML, PyTorch or SKLearn (depending on your model preference).
5. Lyxal Installation: Ensure you have Lyxal installed and running on your machine or server


## Running CI locally

Running CI locally can be done with the following command:

```bash
cargo make --no-workspace preflight
```

This runs a series of tests in docker containers for dynamic C lib loading and `core` tests for `sklearn`, `tensorflow`, and `pytorch`.

## Modules

Here is where we house the rust modules for lyxalml.

- **core:** This pure rust module handles the storage, loading, and running of ML models. `Core` is compiled into the Lyxal server so the ML execution code runs on the server.
