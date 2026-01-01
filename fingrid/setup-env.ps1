# PowerShell setup script for Windows

$VENV_DIR = ".venv"
$REQUIRED_MIN = "3.11"
$REQUIRED_MAX = "3.13"

Write-Host "🔍 Locating Python..." -ForegroundColor Cyan

# Find Python
$PYTHON_BIN = $null
if (Get-Command python -ErrorAction SilentlyContinue) {
    $PYTHON_BIN = (Get-Command python).Source
} elseif (Get-Command python3 -ErrorAction SilentlyContinue) {
    $PYTHON_BIN = (Get-Command python3).Source
} else {
    Write-Host "❌ Python not found. Please install Python >= 3.11." -ForegroundColor Red
    exit 1
}

# Get Python version
$PY_VERSION = & $PYTHON_BIN -c "import sys; print(f'{sys.version_info.major}.{sys.version_info.minor}')"

Write-Host "🐍 Found Python $PY_VERSION at $PYTHON_BIN" -ForegroundColor Green

# Version check: >= 3.11 and < 3.13
$versionParts = $PY_VERSION.Split('.')
$majorVersion = [int]$versionParts[0]
$minorVersion = [int]$versionParts[1]

if (($majorVersion -eq 3) -and ($minorVersion -ge 11) -and ($minorVersion -lt 13)) {
    Write-Host "✅ Python version is compatible." -ForegroundColor Green
} else {
    Write-Host "❌ Python $PY_VERSION is not supported." -ForegroundColor Red
    Write-Host "   Required: 3.11 <= version < 3.13" -ForegroundColor Red
    exit 1
}

# Create virtual environment if it doesn't exist
if (-Not (Test-Path $VENV_DIR)) {
    Write-Host "📦 Creating virtual environment in $VENV_DIR..." -ForegroundColor Cyan
    & $PYTHON_BIN -m venv $VENV_DIR
    Write-Host "✅ Virtual environment created." -ForegroundColor Green
} else {
    Write-Host "✅ Virtual environment already exists." -ForegroundColor Green
}

# Activate virtual environment
Write-Host "🔌 Activating virtual environment..." -ForegroundColor Cyan
$ACTIVATE_SCRIPT = Join-Path $VENV_DIR "Scripts\Activate.ps1"

# Check if activation script exists
if (Test-Path $ACTIVATE_SCRIPT) {
    & $ACTIVATE_SCRIPT
} else {
    Write-Host "❌ Could not find activation script at $ACTIVATE_SCRIPT" -ForegroundColor Red
    exit 1
}

# Upgrade pip and install uv
Write-Host "📥 Upgrading pip and installing uv..." -ForegroundColor Cyan
python -m pip install --quiet --upgrade pip uv

# Install dependencies
Write-Host "📥 Installing dependencies from requirements.txt..." -ForegroundColor Cyan
uv pip install --quiet -r requirements.txt

Write-Host ""
Write-Host "✅ Setup complete!" -ForegroundColor Green
Write-Host ""
Write-Host "🚀 To activate the virtual environment manually, run:" -ForegroundColor Yellow
Write-Host "   .\.venv\Scripts\Activate.ps1" -ForegroundColor White
Write-Host ""
Write-Host "📋 Available commands (using invoke):" -ForegroundColor Yellow
Write-Host "   inv backfill   - Backfill feature groups with historical data" -ForegroundColor White
Write-Host "   inv features   - Run daily feature pipeline" -ForegroundColor White
Write-Host "   inv train      - Train the energy forecasting model" -ForegroundColor White
Write-Host "   inv inference  - Run inference pipeline and generate forecasts" -ForegroundColor White
Write-Host "   inv all        - Run all pipelines in sequence" -ForegroundColor White
