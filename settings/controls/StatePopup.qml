import QtQuick
import ".."
import "../HyprK"

// Pop-up bound to one field of a state file: AppState[stateKey][field].
// choices: [[label, value], ...]. A stored value that isn't a choice (edited by
// hand or by the shell) is shown as an extra item labelled by formatValue.
Popup {
    property string stateKey
    property string field
    property var choices: []
    property var formatValue: v => String(v)
    readonly property var _value: AppState[stateKey][field]
    readonly property int _found: choices.findIndex(c => c[1] === _value)
    model: choices.map(c => c[0]).concat(_found < 0 ? [formatValue(_value)] : [])
    currentIndex: _found < 0 ? choices.length : _found
    onActivated: i => { if (i < choices.length) AppState.set(stateKey, { [field]: choices[i][1] }); }
}
