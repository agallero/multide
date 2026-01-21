# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

MultIDE is a Delphi VCL Windows application for managing multiple Embarcadero Delphi IDE installations. It allows users to configure IDE profiles, manage TMS component builds, and switch between IDE instances with custom configurations.

## Build Commands

Build using MSBuild (requires RAD Studio/Delphi installed):

```bash
tms build multide
```

Output: `multide.exe` in `project root\multide`. DCU files go to `project root\multide\$(Platform)\$(Config)\`.

## Architecture

### Layer Structure

**Presentation Layer (Forms)** - `src/Form.*.pas`
- `Form.Main` - Main window with IDE list (TControlList), keyboard shortcuts (B=Build, C=Config, G=GlobalConfig, 1-9=Run)
- `Form.Config` - Per-IDE configuration (4 tab cards: General, IDEVersions, SmartSetup, Sync)
- `Form.GlobalConfig` - App-wide settings (theme, item size)
- `Form.Build` - Component build executor with progress tracking
- `Form.AddConfig`, `Form.Message` - Dialogs

**Model Layer** - `src/Model.*.pas`
- `Model.Entry` - Core IDE configuration model (ID, icon, Delphi version, SmartSetup paths, TMS build files)
- `Model.EntryReader/Writer` - Registry persistence for IDE configs
- `Model.GlobalSettings` + Reader/Writer - App-wide settings persistence
- `Model.DelphiVersions` + Reader - Installed Delphi version detection
- `Model.Persistence` - Registry path management

**Infrastructure** - `src/*.pas`
- `Launcher.BDS` - Finds and launches BDS executable from registry
- `Launcher.Shortcuts` - Shortcut-based IDE launching
- `Shortcut.Manager/Creator` - Windows .lnk file management
- `ICO.Creator` - Image to .ico conversion
- `Theme.Manager/Colors` - Dark/light theme system with Windows theme detection
- `Global.Config` - Global paths for ide-images, ide-shortcuts directories
- `Deget.CommandLine` - CLI argument parsing for component builds
- `Util.AppInstances` - Single instance enforcement
- `Util.Screen` - Screen scaling utilities

### Data Flow

1. `Form.Main` loads IDE list from registry via `Model.EntryReader`
2. User selects IDE → `Launcher.Shortcuts.Launch()` or `Launcher.BDS.Launch()`
3. BDS executable found in registry → ShellExecute with custom parameters

### Persistence

All configuration stored in Windows Registry under:
`HKEY_CURRENT_USER\Software\Embarcadero\multide\`

### Command-Line Mode

When invoked with parameters: `multide.exe <IDEName> <ProjectPath> [extra params]`
- Bypasses main form
- Directly launches BDS via `TBDSLauncher.Launch()`

## Key Technologies

- Language: Object Pascal (Delphi 12+)
- Framework: VCL (Visual Component Library)
- UI: TControlList, TCardPanel, TVirtualImage/TImageCollection
- Storage: Windows Registry
- Threading: System.Threading for background builds
