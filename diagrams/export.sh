#!/usr/bin/env bash
set -euo pipefail

# Render every published figure from the editable source with draw.io Desktop.
# DRAWIO_BIN can point to the executable inside the macOS application bundle.
diagram_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
drawio_bin="${DRAWIO_BIN:-drawio}"
diagram_source="$diagram_dir/farm-direct-architecture.drawio"
diagram_profile="${DRAWIO_PROFILE_DIR:-${TMPDIR:-/tmp}/farm-direct-diagram-export}"

export_page() {
  local page_index="$1"
  local figure_name="$2"
  "$drawio_bin" --user-data-dir="$diagram_profile" --disable-update \
    --export --timeout 30 --page-index "$page_index" --size page --theme light \
    --format svg --scale 1 --embed-diagram --uncompressed --embed-svg-fonts false \
    --output "$diagram_dir/$figure_name.svg" "$diagram_source"
  "$drawio_bin" --user-data-dir="$diagram_profile" --disable-update \
    --export --timeout 30 --page-index "$page_index" --size page --theme light \
    --format png --scale 2 --embed-diagram \
    --output "$diagram_dir/$figure_name.png" "$diagram_source"
}

# draw.io Desktop 32.6.1 uses one-based page indices.
export_page 1 figure-7-1-system-context
export_page 2 figure-7-2-use-cases
export_page 3 figure-7-3-components
