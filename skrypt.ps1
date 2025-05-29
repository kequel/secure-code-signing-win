<#
.SYNOPSIS
    Skrypt automatyzujący proces podpisywania kodu aplikacji w systemie Windows
.DESCRIPTION
    Skrypt wykonuje następujące kroki:
    1. Generuje własny Urząd Certyfikacji (CA)
    2. Dodaje CA do zaufanych certyfikatów w Windows
    3. Generuje certyfikat dla aplikacji
    4. Tworzy plik PFX do podpisywania
    5. Podpisuje plik wykonywalny z timestampem
    6. Weryfikuje podpis
.NOTES
    Wymagania:
    - OpenSSL zainstalowany i dostępny w PATH
    - PowerShell uruchomiony jako administrator
    - signtool.exe 
#>

# Parametry
$caName = "MKA2 CA"
$appName = "MKA_App2"
$password = "silnehaslo"
$exePath = "C:\Informatyka\SEM4\WprowadzenieDoCyberbezpieczenstwa\MKA_Demo_App2\MKA_Demo_App2\bin\Debug\MKA_Demo_App2.exe" # Ścieżka aplikacji do podpisania
$daysValid = 365
$timestampServer = "http://timestamp.digicert.com"

# Sprawdzenie czy OpenSSL jest dostępny
if (-not (Get-Command openssl -ErrorAction SilentlyContinue)) {
    Write-Error "OpenSSL nie jest zainstalowany lub nie jest w PATH."
    exit 1
}

# Krok 1: Generowanie własnego Urzędu Certyfikacji (CA)
Write-Host "`n[Krok 1] Generowanie wlasnego Urzedu Certyfikacji (CA)" -ForegroundColor Cyan

$caKey = "ca.key"
$caCrt = "ca.crt"

openssl req -x509 -newkey rsa:2048 -keyout $caKey -out $caCrt -days $daysValid -subj "/CN=$caName" -addext "basicConstraints=CA:TRUE" -passout pass:$password

if (-not (Test-Path $caKey) -or -not (Test-Path $caCrt)) {
    Write-Error "Nie udalo się wygenerowac certyfikatow CA"
    exit 1
}

Write-Host "Wygenerowano pliki CA:" -ForegroundColor Green
Write-Host "- $caKey (klucz prywatny CA)"
Write-Host "- $caCrt (certyfikat CA)"

# Krok 2: Dodanie CA do zaufanych certyfikatów w Windows
Write-Host "`n[Krok 2] Dodanie CA do zaufanych certyfikatow w Windows" -ForegroundColor Cyan

$store = New-Object System.Security.Cryptography.X509Certificates.X509Store "Root", "LocalMachine"
$store.Open("ReadWrite")
$cert = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2
$cert.Import((Get-Item $caCrt).FullName)
$store.Add($cert)
$store.Close()

Write-Host "Certyfikat CA został dodany do zaufanych certyfikatow glownych" -ForegroundColor Green

# Krok 3: Generowanie certyfikatów dla aplikacji
Write-Host "`n[Krok 3] Generowanie certyfikatow dla aplikacji" -ForegroundColor Cyan

$appKey = "app.key"
$appCsr = "app.csr"
$appCrt = "app.crt"
$v3Ext = "v3.ext"

# Plik z rozszerzeniami v3
@"
authorityKeyIdentifier=keyid,issuer
basicConstraints=CA:FALSE
keyUsage = digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment
subjectAltName = DNS:$appName
"@ | Out-File -FilePath $v3Ext -Encoding ASCII

# Generuj klucz prywatny i CSR
openssl req -newkey rsa:2048 -keyout $appKey -out $appCsr -nodes -subj "/CN=$appName"

# Podpisz CSR certyfikatem CA
openssl x509 -req -in $appCsr -CA $caCrt -CAkey $caKey -CAcreateserial -out $appCrt -days $daysValid -extfile $v3Ext -passin pass:$password

if (-not (Test-Path $appKey) -or -not (Test-Path $appCrt)) {
    Write-Error "Nie udalo się wygenerowac certyfikatow aplikacji"
    exit 1
}

Write-Host "Wygenerowano pliki aplikacji:" -ForegroundColor Green
Write-Host "- $appKey (klucz prywatny aplikacji)"
Write-Host "- $appCrt (certyfikat aplikacji)"

# Krok 4: Tworzenie pliku PFX
Write-Host "`n[Krok 4] Tworzenie pliku PFX" -ForegroundColor Cyan

$appPfx = "app.pfx"
openssl pkcs12 -export -out $appPfx -inkey $appKey -in $appCrt -passout pass:$password

if (-not (Test-Path $appPfx)) {
    Write-Error "Nie udało się wygenerowac pliku PFX"
    exit 1
}

Write-Host "Wygenerowano plik PFX: $appPfx" -ForegroundColor Green

# Krok 5: Podpisywanie pliku wykonywalnego
Write-Host "`n[Krok 5] Podpisywanie pliku wykonywalnego" -ForegroundColor Cyan

if (-not (Test-Path $exePath)) {
    Write-Error "Plik wykonywalny '$exePath' nie istnieje"
    exit 1
}

$signtoolPath = "C:\Program Files (x86)\Windows Kits\10\bin\*\x64\signtool.exe"
$signtool = Get-Item $signtoolPath | Select-Object -First 1

if (-not $signtool) {
    Write-Error "Nie znaleziono signtool.exe."
    exit 1
}

& $signtool.FullName sign /f $appPfx /p $password /fd SHA256 /tr $timestampServer /td SHA256 "$exePath"

if ($LASTEXITCODE -ne 0) {
    Write-Error "Podpisywanie nie powiodlo się"
    exit 1
}

Write-Host "Plik '$exePath' zostal pomyslnie podpisany" -ForegroundColor Green

# Krok 6: Weryfikacja podpisu
Write-Host "`n[Krok 6] Weryfikacja podpisu" -ForegroundColor Cyan

& $signtool.FullName verify /v /pa "$exePath"

if ($LASTEXITCODE -ne 0) {
    Write-Error "Weryfikacja podpisu nie powiodla sie"
    exit 1
}

Write-Host "`nProces podpisywania zakonczony pomyslnie!" -ForegroundColor Green