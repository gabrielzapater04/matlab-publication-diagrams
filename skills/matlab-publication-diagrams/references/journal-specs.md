# Journal figure specifications (quick reference)

These are typical values as of 2025–2026, and they are what the
`pd_style` presets encode. Publishers revise author guides, so **before
final submission, check the specific journal's "Guide for Authors"** and
override any field, e.g. `pd_style('elsevier', 'colWidth', 8.3)`.

| Preset | Single col | 1.5 col | Double col | Font in preset | Min. text | Preferred formats | Raster dpi (line art) |
|---|---|---|---|---|---|---|---|
| `ieee` | 8.89 cm (3.5 in) | — | 18.13 cm (7.16 in) | Helvetica 8 pt | 8 pt recommended | PDF, EPS, TIFF | 600 |
| `elsevier` | 9.0 cm | 14.0 cm | 19.0 cm | Arial 8 pt | 7 pt (6 pt sub/superscripts) | EPS, PDF, TIFF | 1000 (line), 500 (combo) |
| `springer` | 8.4 cm | 12.9 cm | 17.4 cm | Helvetica 8 pt | 8–12 pt | EPS/PDF vector, TIFF | 1200 (line) |
| `acs` | 8.25 cm (3.25 in) | 12.7 cm | 17.78 cm (7 in) | Helvetica 7 pt | 4.5 pt | PDF, EPS, TIFF | 1200 (line) |
| `mdpi` | 8.5 cm | 13 cm | 16 cm | Palatino 8 pt | 8 pt | PNG/TIFF in Word, or PDF | 1000 |
| `thesis` | 15 cm text width | — | — | Helvetica 9 pt | 8 pt | PDF | 600 |
| `slides` | 25 cm | — | 33.8 cm (16:9) | Helvetica 16 pt | 12 pt | PDF, PNG, SVG | 300 |

Elsevier mineral-processing journals (Minerals Engineering, Powder
Technology, Hydrometallurgy, Chemical Engineering Science) use the
`elsevier` preset. So do Elsevier's *Journal of Process Control*, *Computers
& Chemical Engineering*, *Engineering Applications of AI* and *Expert
Systems with Applications*. MDPI *Minerals*, *Processes* and *Metals* use
`mdpi`. IEEE Access and IEEE Transactions on Industrial Informatics use
`ieee`.

## Practical rules

- **Design at final size.** Choose the width first and never rescale
  afterwards. In LaTeX, `\includegraphics{fig.pdf}` with no `width=` keeps it
  1:1. `width=\columnwidth` is fine only if the preset matches the class's
  column width.
- **Font**: sans-serif (Helvetica or Arial) for diagrams, even when the body
  text is serif. Within one figure use at most 2 sizes, plus bold for panel
  letters and group titles.
- **Line weights**: 0.5–1.5 pt. Nothing thinner than about 0.25–0.3 pt
  (0.1 mm).
- **Colour**: journals print online in colour, but many readers print in
  grayscale. Use colour-blind-safe palettes and line styles that carry
  meaning on their own.
- **File naming**: `fig1_process.pdf`, `fig2_architecture.pdf`. Many
  submission systems require one figure per file.
- **Embedded fonts**: `pd_export` uses MATLAB's vector renderer
  (`-vector` / `-painters`) so fonts are embedded as text. If a journal
  demands outlined fonts, convert in a vector editor after export.
- **TIFF**: some systems (older Elsevier / Springer flows) still want TIFF.
  Use `pd_export(fig, name, 'Formats',{'tif'}, 'Resolution',1000)`.
