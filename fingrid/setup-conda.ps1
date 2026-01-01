# PowerShell setup script using Conda for Windows

$ENV_NAME = "mlfs-fingrid"

Write-Host "Checking for conda..." -ForegroundColor Cyan

# Check if conda is available
if (-not (Get-Command conda -ErrorAction SilentlyContinue)) {
    Write-Host "ERROR: Conda not found. Please install Anaconda or Miniconda." -ForegroundColor Red
    exit 1
}

Write-Host "SUCCESS: Conda found!" -ForegroundColor Green

# Check if environment already exists
$envExists = conda env list | Select-String -Pattern "^$ENV_NAME\s"

if ($envExists) {
    Write-Host "Environment '$ENV_NAME' already exists." -ForegroundColor Yellow
    Write-Host "To recreate it, first run: conda env remove -n $ENV_NAME" -ForegroundColor Yellow
}
else {
    Write-Host "Creating conda environment '$ENV_NAME' with Python 3.11..." -ForegroundColor Cyan
    conda create -n $ENV_NAME python=3.11 -y
    Write-Host "SUCCESS: Environment created!" -ForegroundColor Green
}

Write-Host ""
Write-Host "To activate the environment, run:" -ForegroundColor Yellow
Write-Host "   conda activate $ENV_NAME" -ForegroundColor White
Write-Host ""
Write-Host "Then install dependencies with:" -ForegroundColor Yellow
Write-Host "   pip install -r requirements.txt" -ForegroundColor White
Write-Host ""
Write-Host "Available commands (after activation):" -ForegroundColor Yellow
Write-Host "   inv backfill   - Backfill feature groups with historical data" -ForegroundColor White
Write-Host "   inv features   - Run daily feature pipeline" -ForegroundColor White
Write-Host "   inv train      - Train the energy forecasting model" -ForegroundColor White
Write-Host "   inv inference  - Run inference pipeline and generate forecasts" -ForegroundColor White
Write-Host "   inv all        - Run all pipelines in sequence" -ForegroundColor White
