#let mode = sys.inputs.at("mode", default: "reflexive")
#assert(("reflexive", "left", "right").contains(mode))

#import "@preview/fletcher:0.5.8" as fletcher: diagram, edge, node

#set page(height: auto, width: auto, margin: 15pt)

#diagram(
  axes: (ltr, btt),
  // Disable node inset. We'll control spacings manually.
  node-inset: 0pt,
  {
    let rel(x, y, to: auto) = (
      rel: (x, y),
      ..if to != auto { (to: to) },
    )

    // Draw subspaces in U
    {
      let origin = (name: "u-origin")
      /// Coordinate relative to the origin
      let xy(x, y) = rel(x, y, to: origin.name)

      node((0, 0), ..origin)
      node(rel(-0.2, 0), $O$)

      node(xy(-0.2, 3.5), name: "u-title", text(1.5em)[$U$])

      edge(origin, auto)
      node(xy(-0.3, 1.8), name: "im X")
      node(rel(-0.1, 0.3), $im X$)

      if mode != "left" {
        edge(origin, auto)
        node(xy(-0.3, -1.8), name: "ker A")
        node(rel(-0.1, -0.2), $ker A$)
      }
    }

    // Draw subspaces in V
    {
      let origin = (name: "v-origin")
      /// Coordinate relative to the origin
      let xy(x, y) = rel(x, y, to: origin.name)

      node((2, 0), ..origin)
      node(rel(0.2, 0), $O$)

      node(xy(0.2, 3.5), name: "v-title", text(1.5em)[$V$])

      edge(origin, auto)
      node(xy(0.3, 1.8), name: "im A")
      node(rel(0.1, 0.3), $im A$)

      if mode != "right" {
        edge(origin, auto)
        node(xy(0.3, -1.8), name: "ker X")
        node(rel(0.1, -0.2), $ker X$)
      }
    }

    // Draw the maps
    {
      let map-a(..args, bend: 10deg, stroke: orange + 1pt) = edge(
        ..args,
        "-}>-",
        bend: bend,
        stroke: stroke,
      )
      let map-x = map-a.with(stroke: blue + 1pt, dash: "dashed")
      let biject(u, v, bend-a: 10deg, bend-x: 10deg) = {
        // Put the dashed line (x) below the solid line (a)
        map-x(v, u, bend: bend-x)
        map-a(u, v, bend: bend-a)
      }

      biject((name: "im X"), (name: "im A"))

      if mode != "left" {
        map-a((name: "ker A"), (name: "v-origin"), bend: 7deg)
      }
      if mode != "right" {
        map-x((name: "ker X"), (name: "u-origin"), bend: -7deg)
      }

      biject((name: "u-origin"), (name: "v-origin"))

      // Draw the title
      map-a(
        (name: "u-title"),
        (name: "v-title"),
        text(1.2em, orange, $A$),
      )
      map-x(
        (name: "v-title"),
        (name: "u-title"),
        text(1.2em, blue, $X$),
      )
    }
  },
)
