# dizziee.system-stats

CPU, GPU, memory, and storage monitor for the Omarchy bar. Displays real-time usage with per-compartment toggles and configurable poll intervals.

This fork is based on [JJDizz1L/dizziee.system-stats](https://github.com/JJDizz1L/dizziee.system-stats), the original System Stats plugin for Omarchy Quattro. It keeps the plugin ID `dizziee.system-stats` and the upstream MIT license.

## Changes in this fork

- Bar readouts put the percentage to the left of the metric icon and use the battery widget's font and size.
- The popup uses large percentages above rounded usage bars, styled after Omarchy's battery popup.
- The **Show in bar** row at the bottom of the popup lets you toggle CPU, Memory, and Storage directly. A checkmark shows which metrics are active.

## Requirements

- Python 3
- `lspci` (for GPU name detection)
- NVIDIA needs `nvidia-utils`

## Installation

For a fresh local install of this fork, run these commands from the checkout:

```sh
plugin_dir="${XDG_CONFIG_HOME:-$HOME/.config}/omarchy/plugins/dizziee.system-stats"
mkdir -p "$(dirname "$plugin_dir")" &&
mkdir "$plugin_dir" &&
cp -R manifest.json Panel.qml Model.js i18n scripts "$plugin_dir/" &&
omarchy plugin validate "$plugin_dir" &&
omarchy-shell shell rescanPlugins &&
omarchy plugin enable dizziee.system-stats --after omarchy.power
```

For placement elsewhere, use `omarchy bar move dizziee.system-stats --section right` with your preferred section.

## Configuration
Configuration lives in `~/.config/omarchy/shell.json`.

| Key | Type | Default | Description |
|---|---|---|---|
| `compartments.cpu.enabled` | boolean | true | Show CPU usage |
| `compartments.cpu.showInBar` | boolean | false | Show CPU stats in the bar |
| `compartments.cpu.barDisplay` | string (`usage`, `temp`, `both`) | `usage` | CPU metric to show in the bar |
| `compartments.cpu.pollIntervalSec` | integer | 30 | CPU poll interval |
| `compartments.gpu.enabled` | boolean | false | Show GPU usage |
| `compartments.gpu.showInBar` | boolean | false | Show GPU stats in the bar |
| `compartments.gpu.barDisplay` | string (`usage`, `temp`, `both`) | `usage` | GPU metric to show in the bar |
| `compartments.gpu.pollIntervalSec` | integer | 30 | GPU poll interval |
| `compartments.memory.enabled` | boolean | true | Show memory usage |
| `compartments.memory.showInBar` | boolean | false | Show memory stats in the bar |
| `compartments.memory.pollIntervalSec` | integer | 30 | Memory poll interval |
| `compartments.storage.enabled` | boolean | true | Show storage usage |
| `compartments.storage.showInBar` | boolean | false | Show storage stats in the bar |
| `compartments.storage.pollIntervalSec` | integer | 30 | Storage poll interval |

## Show stats in the bar

Left-click the widget and use the **Show in bar** buttons at the bottom to toggle CPU, Memory, or Storage. Changes apply immediately and are saved to the Omarchy shell configuration.

Right-click the widget for advanced settings, including GPU, polling intervals, and the CPU and GPU display modes (`usage`, `temp`, or `both`). Metrics shown in the bar keep updating while the panel is closed.

## Preview

![Upstream System Stats preview](preview.png)

## Uninstall

```sh
omarchy plugin remove dizziee.system-stats
```

## License

MIT
