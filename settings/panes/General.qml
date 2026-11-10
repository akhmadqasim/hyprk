import QtQuick
import ".."
import "../controls"

Column {
    spacing: Theme.content.sectionGap
    HeroCard { iconId: "general"; glyph: "settings"; tint: Theme.tile.gray; title: "General"; text: "Manage your overall setup and preferences for your computer, such as software updates, device language, AirDrop and more." }
    Card {
        FormRow { glyph: "info"; tint: Theme.tile.gray; label: "About" }
        FormRow { glyph: "update"; tint: Theme.tile.gray; label: "Software Update" }
        FormRow { glyph: "storage"; tint: Theme.tile.gray; label: "Storage" }
    }
    Card {
        FormRow { glyph: "airplay"; tint: Theme.tile.blue; label: "AirDrop & Handoff" }
        FormRow { glyph: "login"; tint: Theme.tile.gray; label: "Login Items & Extensions" }
    }
    Card {
        FormRow { glyph: "language"; tint: Theme.tile.blue; label: "Language & Region" }
        FormRow { glyph: "schedule"; tint: Theme.tile.blue; label: "Date & Time" }
        FormRow { glyph: "share"; tint: Theme.tile.blue; label: "Sharing" }
        FormRow { glyph: "history"; tint: Theme.tile.gray; label: "Time Machine" }
        FormRow { glyph: "restart_alt"; tint: Theme.tile.gray; label: "Transfer or Reset" }
        FormRow { glyph: "album"; tint: Theme.tile.gray; label: "Startup Disk" }
    }
}
