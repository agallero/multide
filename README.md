# MultIDE

MultIDE is a Windows application for managing multiple Embarcadero RAD Studio (Delphi) configurations. It allows you to create and launch different IDE instances, each with its own registry settings, component sets, and environment configurations.

![MultIDE Main Screen](doc/multide-main-screen.png)

## Features

- **Multiple IDE Configurations**: Create separate configurations for different projects or component sets, each running with isolated registry keys
- **No CPU or Memory used if not running**: MultIDE is not a service or a background app. You open it, it does it job, and it closes.
- **Dark and Light Mode**: Automatically follows Windows theme or manually select your preferred appearance
- **Registry Synchronization**: Copy specific registry entries from the default RAD Studio configuration to your custom configurations
- **SmartSetup Integration**: Use different component sets for each configuration by integrating with TMS SmartSetup
- **PATH Filtering**: Control which PATH entries are passed to each IDE instance, so you can have different bpl versions for different configurations.

## Installation

MultIDE is designed to be pinned to either the Start menu or the Taskbar.
1. Grab the latest version from https://github.com/agallero/multide/releases/latest/download/multide.zip and unzip it somewhere in your hard disk.
2. Right-click multide.exe and pin it to your Taskbar or Start menu


## Usage

### Creating a Configuration

1. Open MultIDE and press **G** to open Global Configuration
2. Click **Add Configuration** to create a new IDE profile
3. Configure the profile settings:
   - Select the Delphi version
   - Set a custom icon (optional)
   - Configure SmartSetup paths (optional)
   - Set up registry and PATH synchronization rules

### Launching an IDE

- Click on a configuration in the main list, or
- Use keyboard shortcuts **1-9** to quickly launch configurations by position

### Keyboard Shortcuts

| Key | Action |
|-----|--------|
| 1-9 | Launch configuration by position |
| B | Build TMS components |
| C | Open configuration settings |
| G | Open global settings |

## Registry Synchronization

You can synchronize specific registry entries from the default RAD Studio installation to your custom configurations. This is useful for sharing settings like Known Packages, Library Paths, or other IDE preferences.

### Configuration Format

In the Registry Entries to Sync field, use the following syntax:

```
# Comments start with #
+Pattern    # Include entries matching pattern
-Pattern    # Exclude entries matching pattern
```

### Examples

```
# Sync all Known Packages except specific ones
+Known Packages\*
-Known Packages\*\dclTMS*

# Sync library paths
+Library\*
```

Patterns support wildcards (`*`) and are matched against the registry path relative to the RAD Studio version key.

## PATH Synchronization

Control which Windows PATH entries are passed to the launched IDE. This allows different configurations to use different tool versions.

### Configuration Format

Same syntax as Registry Synchronization:

```
# Include Embarcadero paths
+*\Embarcadero\*
+C:\Windows\*

# Exclude old RAD Studio versions
-*\RAD Studio\9.0\*
```

## SmartSetup Integration

MultIDE integrates with TMS SmartSetup to provide different component sets for each configuration:

1. Set the **SmartSetup Location** to point to your SmartSetup installation
2. Set the **SmartSetup Working Folder** for component builds
3. Use the `$(SmartSetup)` variable in your sync patterns to reference the working folder

## Building from Source

Requires RAD Studio (Delphi 12 or later).

```bash
# Debug build (Win64)
msbuild multide.dproj /p:Config=Debug /p:Platform=Win64

# Release build (Win64)
msbuild multide.dproj /p:Config=Release /p:Platform=Win64
```

## Export/Import Configurations

Use the **Export Configurations** and **Import Configurations** buttons in Global Settings to backup or transfer your MultIDE setup between machines.
