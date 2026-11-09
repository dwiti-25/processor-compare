#!/usr/bin/env python3
"""Render a Markdown report to PDF (Markdown -> styled HTML -> headless Chrome print).
usage: scripts/md2pdf.py reports/initial_synthesis.md [out.pdf]
Needs the `markdown` package (in ~/tools/venv) and Google Chrome."""
import os
import subprocess
import sys
import tempfile

import markdown

CHROME = os.environ.get("CHROME", "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome")
CSS = """
@page { size: A4; margin: 16mm 14mm; }
body { font-family: -apple-system, "Helvetica Neue", Arial, sans-serif; font-size: 10pt;
       line-height: 1.4; color: #111; }
h1 { font-size: 16pt; margin: 0 0 4pt; }
h2 { font-size: 12.5pt; margin: 14pt 0 4pt; border-bottom: 1px solid #ccc; padding-bottom: 2pt; }
h3 { font-size: 11pt; margin: 10pt 0 3pt; }
table { border-collapse: collapse; width: 100%; margin: 6pt 0; font-size: 8.5pt; page-break-inside: avoid; }
th, td { border: 1px solid #bbb; padding: 3pt 4pt; vertical-align: top; }
th { background: #f0f0f0; }
td { font-variant-numeric: tabular-nums; }
code { font-family: Menlo, monospace; font-size: 8.5pt; background: #f4f4f4; padding: 0 2pt; }
li { margin: 2pt 0; }
"""


def main():
    src = sys.argv[1]
    out = sys.argv[2] if len(sys.argv) > 2 else os.path.splitext(src)[0] + ".pdf"
    body = markdown.markdown(open(src).read(), extensions=["tables", "sane_lists"])
    html = f"<!doctype html><html><head><meta charset='utf-8'><style>{CSS}</style></head><body>{body}</body></html>"
    with tempfile.TemporaryDirectory() as tmp:
        page = os.path.join(tmp, "report.html")
        open(page, "w").write(html)
        subprocess.run([CHROME, "--headless", "--disable-gpu", f"--user-data-dir={tmp}/profile",
                        "--no-pdf-header-footer", f"--print-to-pdf={os.path.abspath(out)}",
                        "file://" + page], check=True, capture_output=True)
    print(out)


if __name__ == "__main__":
    main()
