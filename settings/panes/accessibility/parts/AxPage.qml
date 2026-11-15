import QtQuick
import "../../.."

// An Accessibility sub-pane: groups 10 pt apart from the content's top (ax-acc-*.jsonl: first group at window y 64).
Column {
    property var ctl
    property var info
    spacing: Theme.content.sectionGap
}
