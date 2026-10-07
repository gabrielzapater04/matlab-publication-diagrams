#!/bin/bash
# Render a pdlib diagram script headlessly with GNU Octave (preview/QA).
#   bash render_octave.sh my_diagram.m [workdir]
# The script is run from workdir (default: its own folder) so relative
# export paths land next to it. Installs Octave on first use if missing.
set -e
SCRIPT="$(realpath "$1")"; WD="${2:-$(dirname "$SCRIPT")}"
LIB="$(dirname "$(realpath "$0")")/pdlib"
if ! command -v octave >/dev/null 2>&1; then
  echo "Installing Octave (one-time, ~2 min)..."
  (apt-get update -q && apt-get install -y -q --no-install-recommends \
     octave ghostscript gnuplot-nox xvfb xauth fonts-freefont-otf fonts-dejavu-core) >/tmp/octave_install.log 2>&1
fi
export XDG_RUNTIME_DIR=/tmp/rt; mkdir -p $XDG_RUNTIME_DIR; chmod 700 $XDG_RUNTIME_DIR
cd "$WD"
xvfb-run -a -s "-screen 0 4000x3000x24" octave --no-gui -q --eval "addpath('$LIB'); pd_setup(); run('$SCRIPT');" 2>&1 \
  | grep -v -e XDG_RUNTIME -e "default font" -e "ft_manager" -e "^warning: called from" || true
