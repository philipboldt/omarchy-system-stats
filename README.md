# dizziee.system-stats

CPU, GPU, memory, and storage monitor for the Omarchy bar. Displays real-time usage with per-compartment toggles and configurable poll intervals.

[philipboldt/omarchy-system-stats](https://github.com/philipboldt/omarchy-system-stats) is a fork of [JJDizz1L/dizziee.system-stats](https://github.com/JJDizz1L/dizziee.system-stats), the original System Stats plugin for Omarchy Quattro. It keeps the plugin ID `dizziee.system-stats` and the upstream MIT license.

## Changes in this fork

- Bar readouts put the percentage to the left of the metric icon and use the battery widget's font and size.
- The popup uses large percentages above rounded usage bars, styled after Omarchy's battery popup.
- The **Show in bar** row at the bottom of the popup lets you toggle CPU, Memory, and Storage directly. A checkmark shows which metrics are active.
- Drag the handle on the left of a metric card to reorder it. The order is saved, and the bar shows selected metrics from right to left in the popup's top-to-bottom order.

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
cp -R manifest.json Panel.qml BarLayoutEditor.qml Model.js i18n scripts "$plugin_dir/" &&
omarchy plugin validate "$plugin_dir" &&
omarchy-shell shell rescanPlugins &&
omarchy plugin enable dizziee.system-stats --after omarchy.power
```

For placement elsewhere, use `omarchy bar move dizziee.system-stats --section right` with your preferred section.

## Configuration
Configuration lives in `~/.config/omarchy/shell.json`.

| Key | Type | Default | Description |
|---|---|---|---|
| `metricOrder` | array of strings | `["cpu", "gpu", "memory", "storage"]` | Saved order of the popup cards and bar readouts |
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

To reorder the metrics, drag a card by the dotted handle on its left edge. The bar reads the popup order from top to bottom and displays enabled metrics from right to left. For example, drag Storage above CPU to put Storage to the right of CPU when both are shown. The order persists across shell restarts.

Right-click the widget for advanced settings, including GPU, polling intervals, and the CPU and GPU display modes (`usage`, `temp`, or `both`). Metrics shown in the bar keep updating while the panel is closed.

## Reorder Omarchy widgets

Open **Bar Layout** from the System Stats popup. Drag a widget above or below another widget, or drop it on a section heading to move it to the start of that section. Omarchy applies and saves each move. The list also shows installed plugins that have no position in the bar.

System Stats refreshes the installed plugin list each time you open the popup.

## Development checks

Run `omarchy plugin validate .` to validate the manifest and
`node --test tests/model.test.js` to check the model helpers from the repository root.

## Preview

![Upstream System Stats preview](preview.png)

## Uninstall

```sh
omarchy plugin remove dizziee.system-stats
```

## License

MIT
