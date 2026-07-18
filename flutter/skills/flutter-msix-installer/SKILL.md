---
name: flutter-msix-installer
description: 'Create a self-contained MSIX installer for a Flutter Windows app that includes all dependencies (Flutter engine, plugins, FFI, and Visual C++ Redistributable). Use when the user needs to package a Flutter desktop app for Windows distribution.'
argument-hint: 'Project root folder (optional — defaults to current workspace)'
---

# Flutter MSIX Installer

## When to Use
- Packaging a Flutter Windows app for distribution outside the Microsoft Store.
- Creating an installer that runs on any Windows 10/11 machine without Visual Studio.
- Ensuring the installer bundles all runtime dependencies (Flutter engine DLLs, plugin DLLs, VC++ Redist).
- Signing the MSIX with an existing `.pfx` certificate.

## Prerequisites (verify before proceeding)
- [ ] Project compiles: `flutter build windows --release` succeeds.
- [ ] A `.pfx` certificate exists in the project root (self-signed or CA-issued).
- [ ] A logo image exists (PNG, at least 256×256 px).
- [ ] `msix` is listed in `pubspec.yaml` → `dev_dependencies`.

## Procedure

### Step 1 — Remove conflicting config file
If a standalone `<project>/msix_config.yaml` exists, delete it.
All configuration lives in `pubspec.yaml` to avoid conflicts.

```bash
Remove-Item <project>/msix_config.yaml -ErrorAction SilentlyContinue
```

### Step 2 — Update `pubspec.yaml`

#### 2a. Ensure `msix` dev dependency is on the latest version
```yaml
dev_dependencies:
  msix: ^3.18.0
```
> **Critical:** v3.18.0+ automatically sources the version-matched Visual C++
> runtime DLLs from the VS redistributable. Versions below 3.18.0 do NOT
> bundle `vcruntime140.dll`, `msvcp140.dll`, etc., causing the app to fail
> on machines without Visual Studio installed.

#### 2b. Configure the `msix_config:` block
Add or update the block below, replacing `{{PLACEHOLDERS}}` with project values:

```yaml
msix_config:
  display_name: {{APP_NAME}}
  publisher_display_name: {{PUBLISHER_NAME}}
  identity_name: {{IDENTITY}}.app
  publisher: CN={{APP_NAME}}
  msix_version: 1.0.0.0
  logo_path: {{LOGO_PATH}}
  capabilities: internetClient
  install_certificate: true
  sign_msix: true
  certificate_path: {{CERTIFICATE_PATH}}
  certificate_password: {{CERTIFICATE_PASSWORD}}
  output_path: build\windows\x64\runner\Release
  output_name: {{OUTPUT_NAME}}
```

| Placeholder | Description | Example |
|---|---|---|
| `{{APP_NAME}}` | Visible app name | `MyFlutterApp` |
| `{{PUBLISHER_NAME}}` | Publisher / company name | `MyCompany` |
| `{{IDENTITY}}` | Unique identity (reverse-domain) | `com.mycompany.app` |
| `{{LOGO_PATH}}` | Relative path to logo PNG | `assets/images/icon.png` |
| `{{CERTIFICATE_PATH}}` | Relative path to .pfx file | `certificate.pfx` |
| `{{CERTIFICATE_PASSWORD}}` | Certificate password | (your certificate password) |
| `{{OUTPUT_NAME}}` | Output .msix filename (no ext) | `MyFlutterApp` |

### Step 3 — Resolve dependencies
```bash
cd <project>
flutter pub get
```

### Step 4 — Build and package the MSIX
```bash
dart run msix:create
```

- This runs `flutter build windows --release` automatically (unless `--build-windows false` is passed).
- When prompted "Do you want to install the certificate?", answer `y`.

### Step 5 — Verify bundled dependencies
Open the generated `.msix` as a ZIP and list all included DLLs:

```powershell
Add-Type -AssemblyName System.IO.Compression.FileSystem
$msix = [System.IO.Compression.ZipFile]::OpenRead("<path/to/output>.msix")
$msix.Entries | Where-Object { $_.Name -like "*.dll" } | Sort-Object Name |
    Select-Object Name, @{N="KB";E={[math]::Round($_.Length/1KB,1)}}
$msix.Dispose()
```

### Expected DLLs (minimum set)

| Category | DLL |
|---|---|
| **Flutter Engine** | `flutter_windows.dll` |
| **Project Plugins** | `share_plus_plugin.dll`*, `url_launcher_windows_plugin.dll`*, etc. |
| **FFI Plugins** | `dartjni.dll`* |
| **VC++ Redist** | `vcruntime140.dll`, `vcruntime140_1.dll`, `msvcp140.dll`, `msvcp140_1.dll`, `msvcp140_2.dll`, `msvcp140_atomic_wait.dll`, `msvcp140_codecvt_ids.dll`, `concrt140.dll`, `vccorlib140.dll`, `vcruntime140_threads.dll` |

*Plugin DLLs vary by project. The VC++ Redist set is the critical check.

If the VC++ Redist DLLs are present, the installer is **self-contained**
and will run on any Windows 10/11 machine without additional runtime installation.

## Beta Distribution
- Place certificate in the project root and set `install_certificate: true` in `pubspec.yaml`.
- **After the MSIX is generated, copy the `.pfx` certificate to the output folder alongside the `.msix`.** Users need the certificate file to install it manually before running the installer, since self-signed certificates are not trusted by Windows by default.
  ```powershell
  Copy-Item <project>/certificate.pfx <output_path>/certificate.pfx
  ```

## MSIX Storage Path Considerations
When an app runs inside an MSIX container, `Platform.resolvedExecutable` resolves to a protected `C:\Program Files\WindowsApps\...` directory that may be read-only or virtualized inconsistently.
To ensure your Flutter Windows app writes data (databases, logs, documents) correctly:

- **Use `path_provider`** instead of `Platform.resolvedExecutable` for runtime paths.
- Database path: `getApplicationDocumentsDirectory()` or `getApplicationSupportDirectory()`
- Documents path: `getApplicationDocumentsDirectory()`
- Avoid hardcoded absolute paths; always resolve paths through `path_provider`.

## Final Report
- Show the user a summary of the MSIX build, including the output path, included DLLs, and any warnings about missing dependencies.

## Sign-off Checklist
- [ ] `msix_config.yaml` deleted (only `pubspec.yaml` contains msix config).
- [ ] `msix` updated to `^3.18.0` in `dev_dependencies`.
- [ ] `msix_config:` block complete with all 8 required fields.
- [ ] `flutter pub get` completed without errors.
- [ ] `dart run msix:create` succeeded and `.msix` exists.
- [ ] VC++ Redist DLLs verified inside the MSIX archive.
- [ ] Certificate `.pfx` copied alongside `.msix` in output folder (for beta distribution).

## Notes
- **Self-signed certificate**: Windows shows "unknown publisher" warning. For public distribution, obtain a certificate from a trusted CA (DigiCert, Sectigo, etc.).
- **Generate a new self-signed cert** (if needed):
  ```powershell
  New-SelfSignedCertificate -Type Custom -Subject "CN={{APP_NAME}}" `
    -KeyUsage DigitalSignature -FriendlyName "{{APP_NAME}}" `
    -CertStoreLocation "Cert:\CurrentUser\My" `
    -TextExtension @("2.5.29.37={text}1.3.6.1.5.5.7.3.3", "2.5.29.19={text}")
  ```
  Then export to `.pfx` via `certmgr.msc`.
- **CI/CD**: Set `install_certificate: false` and use `--install-certificate false` in CI environments.

## Reference
- Follow Flutter conventions defined in `conventions.md` within this pattern.
- For general guidance on Flutter Windows desktop, refer to `flutter docs/flutter/desktop`.
