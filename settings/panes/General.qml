import QtQuick
import ".."
import "../controls"

Column {
    spacing: Theme.content.sectionGap
    HeroCard { iconId: "general"; tint: Theme.tile.gray; title: "General"; text: "Manage your overall setup and preferences for your computer, such as software updates, device language, AirDrop and more." }
    Card {
        // each row: its sub-pane extension's own icon (themes/icons/settings/graphic.json). About is ISCurrentDevice on the
        // Mac, the model's symbol: here a laptop with a battery, else a desktop computer.
        FormRow { iconId: AppState.hasBattery ? "general-about-laptop" : "general-about"; label: "About" }
        FormRow { iconId: "general-softwareupdate"; label: "Software Update" }
        FormRow { iconId: "general-storage"; label: "Storage" }
    }
    Card {
        FormRow { iconId: "general-airdrop"; label: "AirDrop & Handoff" }
        FormRow { iconId: "general-loginitems"; label: "Login Items & Extensions" }
    }
    Card {
        FormRow { iconId: "general-language"; label: "Language & Region" }
        FormRow { iconId: "general-datetime"; label: "Date & Time" }
        FormRow { iconId: "general-sharing"; label: "Sharing" }
        FormRow { iconId: "general-timemachine"; label: "Time Machine" }
        FormRow { iconId: "general-transfer"; label: "Transfer or Reset" }
        FormRow { iconId: "general-startupdisk"; label: "Startup Disk" }
    }
}
