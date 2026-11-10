import QtQuick

// The hidden-to-shown scale of a materializing glass surface (Materializer.scaleFor per axis)
// around (origin.x, origin.y): set `mat`, `w` and `h`.
Scale {
    property Materializer mat
    property real w: 0
    property real h: 0
    xScale: mat ? mat.scaleFor(w) : 1
    yScale: mat ? mat.scaleFor(h) : 1
}
