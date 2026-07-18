# Flutter MSIX Installer Skill

## What Changed

Added a new pattern-specific skill `flutter-msix-installer` for creating self-contained MSIX installers for Flutter Windows desktop apps. This skill fills a gap in the Flutter pattern — previously, the framework provided scaffolding, feature development, specification, and testing skills for Flutter, but had no dedicated skill for Windows packaging and distribution.

## Why It Changed

Flutter Windows desktop projects require MSIX packaging for distribution outside the Microsoft Store. The packaging process involves:
1. Configuring the `msix` dev dependency (v3.18.0+ required for VC++ redistributable bundling).
2. Setting up the `msix_config:` block in `pubspec.yaml` with certificate signing, logo, and identity.
3. Bundling all runtime dependencies (Flutter engine DLLs, plugin DLLs, FFI DLLs, and Visual C++ Redistributable DLLs) into the MSIX.
4. Verifying the MSIX archive contains the correct set of DLLs.

Without a dedicated skill, developers had to research this process manually or rely on outdated documentation. This skill provides a repeatable, checklist-driven procedure that ensures the MSIX is self-contained and runs on any Windows 10/11 machine without requiring Visual Studio or additional runtimes.

## Files Affected

| File | Change |
|---|---|
| `flutter/skills/flutter-msix-installer/SKILL.md` | **New** — Complete MSIX installer creation skill for Flutter Windows apps, adapted from the NpGmao project |
| `Docs/framework-ai-enhancement-phase.md` | **Updated** — Added entry for this change |
| `VERSION` | **Updated** — Bumped from 0.2.5 to 0.3.0 |
| `.github/copilot-memory.md` | **Updated** — Added MSIX Installer section |

## Skill Capabilities

The `flutter-msix-installer` skill covers:

- **Prerequisites verification**: Release build succeeds, .pfx certificate exists, logo image, `msix` dependency.
- **Configuration**: Removes legacy `msix_config.yaml`, configures `msix` dev dependency v3.18.0+, sets up the `msix_config:` block with all required fields.
- **Build & package**: Runs `flutter pub get` and `dart run msix:create` to produce the `.msix` file.
- **DLL verification**: Scripted PowerShell check to enumerate all DLLs inside the MSIX archive, with a minimum expected set (Flutter engine, plugins, VC++ Redist).
- **Beta distribution**: Certificate copying alongside the MSIX for manual installation.
- **Storage path guidance**: Documents the MSIX container path issue (`Platform.resolvedExecutable` resolves to protected `WindowsApps` directory) and recommends `path_provider` alternatives.
- **Sign-off checklist**: 7-item checklist for quality assurance.
- **Self-signed cert generation**: PowerShell command to create a test certificate.

## Skill Usage

When a Flutter Windows project needs distribution packaging:

1. The agent invokes `flutter-msix-installer` either directly or through the main PovoAgent workflow.
2. The skill walks through prerequisites verification, configuration, build, and verification.
3. Produces a final report with output path, bundled DLL list, and any warnings.
