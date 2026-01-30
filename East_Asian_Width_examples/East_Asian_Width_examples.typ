#set page(height: auto, width: 20em, margin: 1em)
#set text(
  font: "Source Han Serif",
  fallback: false,
  top-edge: "ascender",
  bottom-edge: "descender",
)

/// East Asian Width
/// https://www.unicode.org/reports/tr11/tr11-44.html
#let eaw = (
  (
    A: [Ambiguous],
    N: [Neutral],
    Na: [Narrow],
    W: [Wide],
    H: [Halfwidth],
    F: [Fullwidth],
  )
    .pairs()
    .map(((k, v)) => (
      k,
      {
        set text(font: "Libertinus Sans")
        show k: set text(purple.lighten(15%))
        v
      },
    ))
    .to-dict()
)

/// Display characters and their widths
#let char(characters) = {
  characters
    .clusters()
    .map(c => highlight(stroke: green + 0.3pt, fill: none, {
      // Use `h` to turn off punctuation width adjustment
      h(0.0001pt)
      c
      h(0.0001pt)
    }))
    .join()
}

#set page(background: {
  let paint = rgb("#6366f3")

  /// Adds a cubic Bézier curve by specifying control points relative to end points.
  let drag(end, control-end, control-start: auto, last: none) = {
    let add(x, y) = x.zip(y).map(((x, y)) => x + y)

    if control-start == auto {
      curve.cubic(auto, add(end, control-end), end)
    } else {
      assert.ne(last, none, message: "the last end point is needed when control-start is not `auto`")
      curve.cubic(add(last, control-start), add(end, control-end), end)
    }
  }

  set block(spacing: 0pt)

  block(height: 0%, width: 90%, inset: (bottom: 0.1em), {
    set align(right + bottom)
    set text(0.7em, paint.darken(10%))
    `$EastAsian`
  })

  show: block.with(width: 90%, height: 40%)
  let y = (
    far-top: 0%, // top of Na–F
    top: 40%, // top of H–W
    bottom: 68%, // bottom of H–W
    far-bottom: 100%, // bottom of (empty)–W
  )
  curve(
    stroke: stroke(paint: paint, thickness: 0.5pt, dash: "dashed"),
    curve.move((100%, y.far-top)),
    drag((65%, y.far-top), (20%, 0%)),
    drag((32%, y.top), (20%, 0%)),
    drag((10%, y.top), (15%, 0%)),
    drag((10%, y.bottom), (-15%, 0%)),
    drag((32%, y.bottom), (-20%, 0%)),
    drag((65%, y.far-bottom), (-20%, 0%)),
    drag((100%, y.far-bottom), (-20%, 0%)),
  )
})

#import table: cell
#table(
  columns: (auto, 1fr, 1fr, auto),
  stroke: none,
  align: (left, center, center, left),

  cell(colspan: 2, align: center)[*Narrow*],
  cell(colspan: 2, align: center)[*Wide*],

  table.vline(x: 2, stroke: 0.5pt),

  eaw.N, char("©ñ"), [], [],
  eaw.Na, char("a,."), char("ａ，．"), eaw.F,
  eaw.H, char("ｶ｡"), char("カ。"), eaw.W,
  [], [], char("力量"), eaw.W,

  cell(colspan: 4, align: center, inset: (left: 2.4em), grid(
    columns: 2,
    column-gutter: 0.5em,
    row-gutter: 0.3em,
    align: bottom,
    // Noto Serif CJK's § does not support the pwid feature, so we have to use another font.
    text(font: "Libertinus Serif", char("§“”")), char("§“”"),
    grid.cell(colspan: 2, eaw.A),
  )),
)
