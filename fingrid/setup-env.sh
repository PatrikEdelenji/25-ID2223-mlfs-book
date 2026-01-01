#!/usr/bin/env bash

# Detect if script is being sourced or executed
# When sourced, use 'return' instead of 'exit' to avoid closing the shell
(return 0 2>/dev/null) && SOURCED=1 || SOURCED=0

# Only use strict mode when executed (not sourced)
# set -e would exit the terminal when sourced
if [ "$SOURCED" -eq 0 ]; then
  set -euo pipefail
else
  set -uo pipefail
fi

# Helper function to exit or return based on how script was invoked
exit_script() {
  if [ "$SOURCED" -eq 1 ]; then
    return "$1"
  else
    exit "$1"
  fi
}

VENV_DIR=".venv"
REQUIRED_MIN="3.11"
REQUIRED_MAX="3.13"

echo "🔍 Locating Python..."

# Prefer python3, fall back to python
if command -v python3 >/dev/null 2>&1; then
  PYTHON_BIN="$(command -v python3)"
elif command -v python >/dev/null 2>&1; then
  PYTHON_BIN="$(command -v python)"
else
  echo "❌ Python not found. Please install Python >= 3.11."
  exit_script 1
fi

PY_VERSION="$($PYTHON_BIN -c 'import sys; print(f"{sys.version_info.major}.{sys.version_info.minor}")')"

echo "🐍 Found Python $PY_VERSION at $PYTHON_BIN"

# Version check: >= 3.11 and < 3.13
if ! $PYTHON_BIN - <<EOF
import sys
min_v = (3, 11)
max_v = (3, 13)
cur_v = sys.version_info[:2]
if not (min_v <= cur_v < max_v):
    print(f"❌ Python {cur_v[0]}.{cur_v[1]} is not supported.")
    print(f"   Required: {min_v[0]}.{min_v[1]} <= version < {max_v[0]}.{max_v[1]}")
    sys.exit(1)
EOF
then
  exit_script 1
fi

echo "✅ Python version is compatible."

# Create virtual environment if it doesn't exist
if [ ! -d "$VENV_DIR" ]; then
  echo "📦 Creating virtual environment in $VENV_DIR..."
  "$PYTHON_BIN" -m venv "$VENV_DIR"
  echo "✅ Virtual environment created."
else
  echo "✅ Virtual environment already exists."
fi

# Detect the OS and set activation script path
if [[ "$OSTYPE" == "msys" || "$OSTYPE" == "win32" ]]; then
  # Windows (Git Bash/MSYS)
  ACTIVATE_SCRIPT="$VENV_DIR/Scripts/activate"
else
  # Unix-like systems (Linux, macOS)
  ACTIVATE_SCRIPT="$VENV_DIR/bin/activate"
fi

# Activate virtual environment
echo "🔌 Activating virtual environment..."
# shellcheck disable=SC1090
source "$ACTIVATE_SCRIPT"

# Upgrade pip and install uv
echo "📥 Upgrading pip and installing uv..."
pip install --quiet --upgrade pip uv

# Install dependencies
echo "📥 Installing dependencies from requirements.txt..."
uv pip install --quiet -r requirements.txt

echo ""
echo "✅ Setup complete!"
echo ""
echo "🚀 To activate the virtual environment manually, run:"
if [[ "$OSTYPE" == "msys" || "$OSTYPE" == "win32" ]]; then
  echo "   source $VENV_DIR/Scripts/activate"
else
  echo "   source $VENV_DIR/bin/activate"
fi
echo ""
echo "📋 Available commands (using invoke):"
echo "   inv backfill   - Backfill feature groups with historical data"
echo "   inv features   - Run daily feature pipeline"
echo "   inv train      - Train the energy forecasting model"
echo "   inv inference  - Run inference pipeline and generate forecasts"
echo "   inv all        - Run all pipelines in sequence"
