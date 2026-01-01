from invoke import task, Collection, Program, exceptions
import os
import sys
from pathlib import Path

# Monkey-patch ParseError to provide better error messages
_original_parse_error_str = exceptions.ParseError.__str__

def _custom_parse_error_str(self):
    """Custom error message for ParseError."""
    original_msg = _original_parse_error_str(self)

    # Check if it's an unknown command error
    if "No idea what" in original_msg:
        import re
        import subprocess
        match = re.search(r"No idea what ['\"]([^'\"]+)['\"]", original_msg)
        cmd_name = match.group(1) if match else "unknown"

        # Get list of available tasks
        try:
            result = subprocess.run(
                ['inv', '--list'],
                capture_output=True,
                text=True,
                timeout=2
            )
            task_list = result.stdout
        except:
            task_list = "(run 'inv --list' to see available commands)"

        return f"""❌ Command not found: '{cmd_name}'

{task_list}"""

    return original_msg

# Apply the monkey patch
exceptions.ParseError.__str__ = _custom_parse_error_str

VENV_DIR = Path(".venv")

def check_venv():
    """Check if a virtual environment exists and is active."""

    # 1. Create venv if it doesn't exist
    if not VENV_DIR.exists():
        print("🔧 There is no virtual environment. Did you run the setup step yet?")
        print("👉 ./setup-env.sh")
        sys.exit(2) 

    virtual_env = os.environ.get("VIRTUAL_ENV")
    venv_path = str(VENV_DIR.resolve())

    if virtual_env != venv_path:
        print("🐍 Virtual environment is NOT active.")
        print()
        print("👉 Activate it with:")
        print(f"   source {VENV_DIR}/bin/activate")
        sys.exit(1) 

    
##########################################
# Fingrid Energy Forecasting System
##########################################

@task
def clean(c):
    """Deletes feature groups, feature views, models for Fingrid energy forecasting."""
    check_venv()
    with c.cd(".."):
        print("#################################################")
        print("################## Cleanup   ####################")
        print("#################################################")
        c.run("uv run python mlfs/clean_hopsworks_resources.py fingrid")

@task
def backfill(c):
    """Creates feature groups, backfills energy consumption and weather data."""
    check_venv()
    print("#################################################")
    print("########## Backfill Feature Pipeline   ##########")
    print("#################################################")
    c.run("uv run ipython notebooks/1_backfill_feature_group.ipynb")

@task
def features(c):
    """Incremental ingestion of daily energy consumption, weather data, and weather forecast data."""
    check_venv()
    print("#################################################")
    print("######### Daily Feature Pipeline  ###############")
    print("#################################################")
    c.run("uv run ipython notebooks/2_daily_feature_pipeline.ipynb")

@task
def train(c):
    """Creates feature view, reads training data, trains and saves XGBoost model to predict energy consumption."""
    check_venv()
    print("#################################################")
    print("############# Training Pipeline #################")
    print("#################################################")
    c.run("uv run ipython notebooks/3_training_pipeline.ipynb")

@task
def inference(c):
    """Batch inference program that reads weather forecast from feature store, predicts energy consumption, outputs forecasts."""
    check_venv()
    print("#################################################")
    print("#############  Inference Pipeline ###############")
    print("#################################################")
    c.run("uv run ipython notebooks/2_daily_feature_pipeline.ipynb")
    c.run("uv run ipython notebooks/4_inference_pipeline.ipynb")

@task(pre=[backfill, features, train, inference])
def all(c):
    """Runs all FTI pipelines in order, outputs energy consumption predictions."""
    pass
