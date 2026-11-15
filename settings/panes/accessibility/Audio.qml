import QtQuick
import "../.."
import "../../controls"
import "../../HyprK"
import "parts"

// Accessibility > Audio (ax-acc-audio-00..03). Flash and mono are saved in state/accessibility.json (no reader yet);
// the rest keeps its own state. The Mac's dump also has a group for the AirPods connected to it; not here.
AxPage {
    id: page
    Card {
        AxRow { h: 37.5; label: "Flash the screen when an alert sound occurs"
                Switch { checked: page.ctl.a.flashScreen; onToggled: on => page.ctl.set({ flashScreen: on }) } }
        AxRow { h: 37.5; label: "Play stereo audio as mono"
                Switch { checked: page.ctl.a.monoAudio; onToggled: on => page.ctl.set({ monoAudio: on }) } }
        AxRow { h: 36.5; label: "Spatial audio follows head movements"; LocalSwitch { checked: true } }
    }
    Card {
        AxRow { h: 37; label: "Background Sounds" }
        AxRow { h: 95; label: "Background sounds"; subWidth: 383
                sub: "Plays background sounds to mask unwanted environmental noise. These sounds can minimize distractions, increase sense of focus and help you cope with symptoms related to tinnitus."
                link: "Learn more…"; linkY: 70; linkUrl: "https://support.apple.com/109346"
                LocalSwitch {} }
        AxRow { h: 41; ctlY: 18; spacing: 10; label: "Background sound"
                Text { text: "Rain"; font: Typography.body; color: Theme.secondaryLabel }
                Button { text: "Choose…" } }
        AxRow { h: 39.5; ctlY: 18.5; label: "Background sounds volume"
                AxSlider { width: 244.5; leftGlyph: "speaker.fill"; rightGlyph: "speaker.wave.3.fill"; tickMarks: 7; value: 1 } }
        AxRow { h: 53; ctlY: 18; spacing: 10; label: "Equalizer"
                sub: "Personalize your listening experience to minimize distractions."
                Text { text: "Off"; font: Typography.body; color: Theme.secondaryLabel }
                Button { text: "Choose…" } }
        AxRow { h: 41; ctlY: 18; spacing: 10; label: "Timer"
                Text { text: "Off"; font: Typography.body; color: Theme.secondaryLabel }
                Button { text: "Choose…" } }
        AxRow { h: 66; label: "Turn off background sounds when your Mac is not in use"; subWidth: 379.5
                sub: "Turn off background sounds automatically with Lock Screen and Screen Saver modes."
                LocalSwitch {} }
    }
    Card {
        AxRow { h: 44; ctlY: 22; sub: "System volume can be adjusted in Sound settings."
                Button { text: "Sound Settings…"; onClicked: AppState.navigate("sound", "") } }
    }
    Card {
        title: "Headphone Accommodations"
        AxRow { h: 80.5; label: "Headphone Accommodations"; subWidth: 375.5
                sub: "Once enabled, you can customize audio for supported Apple and Beats headphones."
                link: "Learn more…"; linkY: 56; linkUrl: "https://support.apple.com/120634"
                LocalSwitch {} }
        AxRow { h: 44.5; ctlY: 22.5; Button { text: "Customize Audio" } }
    }
    Card {
        AxRow { h: 66; ctlY: 18.5; label: "Audio tuning"; subWidth: 286
                sub: "Optimizing for balanced tone will provide boost over a range of frequencies."
                LocalPopup { model: ["Balanced Tone", "Vocal Range", "Brightness"] } }
        AxRow { h: 67.5; ctlY: 25.5; label: "Optimization"; subWidth: 195
                sub: "Soft sounds will be boosted slightly, moderately or strongly."
                AxSlider { width: 236.5; value: 0.5; onMoved: v => value = Math.round(v * 2) / 2   // slightly, moderately, strongly
                           labels: [["Slight", 0], ["Moderate", 0.5], ["Strong", 1]] } }
        AxRow { h: 44.5; ctlY: 22.5; Button { text: "Play Sample"; enabled: false } }
    }
    Card {
        AxRow { h: 36.5; spacing: 16; label: "Customized audio"
                AxCheck { text: "Phone"; checked: true }
                AxCheck { text: "Media"; checked: true } }
    }
    PaneFooter {}
}
