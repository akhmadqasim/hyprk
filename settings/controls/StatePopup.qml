import QtQuick
import ".."

// Pop-up bound to one field of a state file: AppState[stateKey][field].
// choices: [[label, value], ...]
MacPopup {
    property string stateKey
    property string field
    property var choices: []
    model: choices.map(c => c[0])
    currentIndex: Math.max(0, choices.findIndex(c => c[1] === AppState[stateKey][field]))
    onActivated: i => AppState.set(stateKey, { [field]: choices[i][1] })
}
