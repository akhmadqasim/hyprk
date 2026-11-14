import QtQuick
import qs
import qs.HyprK
import qs.services

// 27.2.1 slider module (MAC-ANSWERS.md Q-panels-08, -09) on the shared HyprK Slider: white fill over a plus-lighter
// T + 20 track 4 pt tall; no knob at rest, a white 18 x 14 knob while the module is hovered, pressed the shared
// glass lens 24 x 20 (Knob: refraction, rim, light and shadow from the Mac's pressed-knob filter and recording)
// centred on the fill end, which is kept half a knob inside the track ends. A press on the track sends the fill end
// half a knob ahead of the pointer and springs to it (about 0.2 s), a drag follows 1:1; past an end the track and
// fill stretch up to 5 pt and spring back in 0.13 s on release. The Sound module (CcSoundPanel) uses the same
// slider with its knob always shown.
Slider {
    trackHeight: Theme.cc.trackHeight
    fillColor: Theme.cc.sliderFillColor
    trackFill: Component {
        ShaderEffect {   // track: plus-lighter T + 20 (shaders/plusfill.frag)
            property vector4d fill: Qt.vector4d(Theme.cc.trackLift, Theme.cc.trackLift, Theme.cc.trackLift, 0)
            property size sizePt: Qt.size(width, height)
            property real radius: height / 2
            property real dpr: Screen.devicePixelRatio
            fragmentShader: Qt.resolvedUrl("../shaders/plusfill.frag.qsb")
        }
    }
    knobWidth: Theme.cc.knobW
    knobHeight: Theme.cc.knobH
    lensWidth: Theme.cc.lensW
    lensHeight: Theme.cc.lensH
    lensBackdrop: "transparent"
    lensGain: Theme.cc.lensGain
    fillToEnds: true
    trackPressOffset: Theme.cc.knobW / 2
    overdrag: Theme.cc.overdrag
    overdragBackMs: Theme.cc.overdragBackMs
    jumpResponse: Theme.anim.sliderJumpResponse
    reduceMotion: A11y.reduceMotion
    hitMargin: 10
    activeFocusOnTab: false
}
