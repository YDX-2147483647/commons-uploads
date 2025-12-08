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

    // Items to be drawn at last.
    let overlay = (a: (), b: ())

    // Enable the crossing illusion.
    // The drawback is that some lines need to be drawn twice to fix the crossing, so use with caution.
    let cross = (crossing: true, crossing-thickness: 3)

    // Draw subspaces in U
    {
      let origin = (name: "u-origin")
      /// Coordinate relative to the origin
      let xy(x, y) = rel(x, y, to: origin.name)

      node((0, 0), ..origin)
      node(xy(-0.7, 3.5), name: "u-title", text(1.5em)[$U$])

      let shift = rel(-0.5, -0.4)
      overlay.b.push({
        edge(origin, auto)
        node(xy(..shift.rel), name: "u-share")
        node(rel(-0.6, 0), $im X ∩ ker A$)
      })

      edge(origin, auto)
      node(xy(-0.6, 2), name: "im X only")
      node(shift, name: "im X")
      node(rel(-0.2, 0.1), $im X$)

      edge(origin, auto)
      node(xy(-0.3, -1.6), name: "ker A only")
      node(shift, name: "ker A")
      node(rel(-0.1, -0.2), $ker A$)
    }

    // Draw subspaces in V
    {
      let origin = (name: "v-origin")
      /// Coordinate relative to the origin
      let xy(x, y) = rel(x, y, to: origin.name)

      node((2, 0), ..origin)
      node(xy(0.5, 3.5), name: "v-title", text(1.5em)[$V$])

      overlay.b.push({
        edge(origin, auto)
        node(rel(0.4, -0.3, to: origin), name: "v-rest")
        node(rel(0.6, 0), $(im A plus.o ker X)^complement$)

        edge(origin, auto)
        node(xy(0.3, 2), name: "im A")
        node(rel(0.1, 0.3), $im A$)
      })

      overlay.a.push({
        edge(origin, auto)
        node(xy(0.3, -1.8), name: "ker X")
        node(rel(0.1, -0.2), $ker X$)
      })
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

      biject((name: "im X only"), (name: "im A"))

      // Declare other edges

      let zero = biject(
        (name: "u-origin"),
        (name: "v-origin"),
        bend-a: 20deg,
        bend-x: 5deg,
      )

      let x-v-rest = arguments((name: "v-rest"), (name: "u-share"), bend: 20deg)
      let a-u-share = arguments(
        (name: "u-share"),
        (name: "v-origin"),
        bend: -10deg,
      )

      let ker-a = map-a((name: "ker A only"), (name: "v-origin"), bend: -27deg)
      let ker-x = map-x((name: "ker X"), (name: "u-origin"), bend: 17deg)

      // Draw other edges
      // The order below affects the crossing.
      ker-x
      map-a(..a-u-share, ..cross)
      ker-a + zero

      overlay.a.push({
        map-x(..x-v-rest, ..cross)
        map-a(..a-u-share)
      })

      // Draw the title
      map-a(
        (name: "u-title"),
        (name: "v-title"),
        text(1.2em, orange, $A$),
        bend: 5deg,
      )
      map-x(
        (name: "v-title"),
        (name: "u-title"),
        text(1.2em, blue, $X$),
        bend: 5deg,
      )
    }

    // Draw overlay
    overlay.values().flatten().join()
  },
  render: (grid, nodes, edges, options) => {
    let node(key) = nodes.find(n => n.name == label(key)).pos.xyz
    let u-origin = node("u-origin")

    import fletcher: cetz, draw-diagram
    cetz.canvas({
      import cetz.draw: line

      // Draw the parallelograms in U
      let parallelogram = line.with(fill: luma(90%), stroke: none)
      parallelogram(
        u-origin,
        node("u-share"),
        node("ker A"),
        node("ker A only"),
      )
      parallelogram(
        u-origin,
        node("u-share"),
        node("im X"),
        node("im X only"),
      )

      // Put the original diagram on top of the parallelograms
      draw-diagram(grid, nodes, edges, debug: options.debug)
    })
  },
)
