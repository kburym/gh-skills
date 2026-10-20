#!/usr/bin/env bash
# Build the animated diagrams.
#
#   ./assets/build-diagram.sh
#
# Graphviz has no animation support, so this script renders each graph and
# then injects a small <style> block that animates the edges (marching
# dashes) and the orchestrator nodes (pulse). The result is a self-contained,
# animated SVG that renders in any browser and still works as a static image.
set -euo pipefail

cd "$(dirname "$0")/.."

DIAGRAMS=(
  "assets/before-after.dot:assets/before-after.svg"
  "assets/pr-lifecycle.dot:assets/pr-lifecycle.svg"
  "assets/skill-calls.dot:assets/skill-calls.svg"
)

command -v dot >/dev/null 2>&1 || {
  echo "error: graphviz 'dot' not found — install graphviz and retry" >&2
  exit 1
}

for pair in "${DIAGRAMS[@]}"; do
  src="${pair%%:*}"
  out="${pair##*:}"
  dot -Tsvg "$src" -o "$out"
done

python3 - "${DIAGRAMS[@]}" <<'PY'
import sys

style = """
  <style type="text/css">
    @keyframes march { to { stroke-dashoffset: -24; } }
    @keyframes pulse { 0%, 100% { opacity: 1; } 50% { opacity: 0.55; } }
    @keyframes glow { 0%, 100% { stroke-opacity: 1; } 50% { stroke-opacity: 0.45; } }

    .edge .path {
      stroke-dasharray: 8 4;
      animation: march 1.1s linear infinite;
    }
    .edge .polygon { animation: march 1.1s linear infinite; }
    .node.pulse polygon, .node.pulse ellipse, .node.pulse path {
      animation: pulse 2.6s ease-in-out infinite;
    }
    .node.pulse ellipse, .node.pulse polygon {
      animation: glow 2.6s ease-in-out infinite;
    }
    .node.pulse text { animation: pulse 2.6s ease-in-out infinite; }

    @media (prefers-reduced-motion: reduce) {
      .edge .path, .edge .polygon, .node.pulse polygon,
      .node.pulse ellipse, .node.pulse path, .node.pulse text {
        animation: none;
      }
    }
  </style>
"""

for pair in sys.argv[1:]:
    src, out = pair.split(":")
    svg = open(out, encoding="utf-8").read()
    if "<style" not in svg:
        svg = svg.replace("</svg>", style + "</svg>")
        open(out, "w", encoding="utf-8").write(svg)
    print(f"wrote {out}")
PY
