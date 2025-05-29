# Secure Code Signing for Windows Applications

## Note: Code variables, comments, and report (report.pdf) are in Polish.

A practical implementation of code signing for Windows executables using self-signed certificates, OpenSSL, and signtool. Includes a detailed report (in Polish) and a PowerShell automation script. Developed as part of an Introduction to Cybersecurity course.

## Authors
- [Martyna Borkowska](https://github.com/martynkaqhe)
- [Karolina Glaza](https://github.com/kequel)
- [Amila Amarasekara](https://github.com/Amila321)

## Description  
- **Self-Signed CA**: Generates a local Certificate Authority using OpenSSL.  
- **Code Signing Workflow**:  
  - Creates application certificates signed by the CA  
  - Generates PFX files for Visual Studio integration  
  - Adds timestamping via DigiCert's TSA service  
- **Automation**: PowerShell script (`skrypt.ps1`) handles the entire process.  
- **Verification**: Validates signatures using Windows Explorer and `signtool`.  
- **Educational Report**: PDF documentation with theory and implementation details.  

## Files  
| File | Description |  
|------|-------------|  
| [`skrypt.ps1`](skrypt.ps1) | PowerShell automation script for signing |  
| [`report.pdf`](report.pdf) | Full technical report (in Polish) |  
| [`Prezentacja.pptx`](Prezentacja.pptx) | Presentation slides |  
| [`MKA_Demo_App/`](MKA_Demo_App/) | Sample application for signing |  

## Setup
Install prerequisites:
- OpenSSL
- Windows SDK (signtool)

Clone the repository:
```bash  
git clone https://github.com/your-repo/secure-code-signing-win.git
```

Run the automation script (as Admin):
```bash  
.\skrypt.ps1
```
