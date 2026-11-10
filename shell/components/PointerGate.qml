import QtQuick

// "Only a real pointer move selects." A surface that maps, scales or fills in under a resting
// pointer gets enter and motion events at that same point, so hover reacted without the user
// touching the mouse (Spotlight mode buttons emerging, Cmd-Tab flipping between two apps, the
// Spotlight Apps grid selecting the cell under the pointer on open). Feed every hover event to
// note(); it returns true once the pointer has moved more than 2 px from where it was first seen.
// reset() re-arms it (new content under the pointer, keyboard navigation).
QtObject {
    property bool moved: false
    property point first: Qt.point(NaN, NaN)
    function reset() { moved = false; first = Qt.point(NaN, NaN); }
    // item: the item whose local (mx, my) the event carries; compared in scene coordinates, so
    // a panel scaling under the pointer does not count as a move
    function note(item, mx, my) {
        if (moved) return true;
        const p = item.mapToItem(null, mx, my);
        if (isNaN(first.x)) first = p;
        else if (Math.abs(p.x - first.x) + Math.abs(p.y - first.y) > 2) moved = true;
        return moved;
    }
}
