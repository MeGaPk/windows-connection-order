enum AppLanguage {
    case english
    case russian
    case estonian

    var shortName: String {
        switch self {
        case .english: "EN"
        case .russian: "RU"
        case .estonian: "ET"
        }
    }

    func text(_ key: String) -> String {
        switch self {
        case .english:
            switch key {
            case "title": "Windows Connection Order"
            case "subtitle": "Demo UI — no Windows network settings are read or changed."
            case "priority": "Connection priority"
            case "help": "Windows uses lower metrics first. This prototype only changes the demo list."
            case "order": "#"
            case "adapter": "Adapter"
            case "ipv4": "Local IPv4"
            case "ipv6": "Local IPv6"
            case "metric": "Metric"
            case "select": "Select"
            case "selected": "Selected"
            case "moveUp": "Move selected up"
            case "moveDown": "Move selected down"
            case "apply": "Apply demo changes"
            case "nothingSelected": "Select an adapter to change its position."
            case "demoApplied": "Demo order updated. No system settings were changed."
            default: key
            }
        case .russian:
            switch key {
            case "title": "Windows Connection Order"
            case "subtitle": "Демо-интерфейс — настройки сети Windows не читаются и не изменяются."
            case "priority": "Приоритет подключения"
            case "help": "Windows предпочитает меньшую метрику. В прототипе меняется только демонстрационный список."
            case "order": "№"
            case "adapter": "Адаптер"
            case "ipv4": "Локальный IPv4"
            case "ipv6": "Локальный IPv6"
            case "metric": "Метрика"
            case "select": "Выбрать"
            case "selected": "Выбрано"
            case "moveUp": "Поднять выбранный"
            case "moveDown": "Опустить выбранный"
            case "apply": "Применить демо-изменения"
            case "nothingSelected": "Выберите адаптер, чтобы изменить его позицию."
            case "demoApplied": "Демо-порядок обновлён. Системные настройки не изменялись."
            default: key
            }
        case .estonian:
            switch key {
            case "title": "Windows Connection Order"
            case "subtitle": "Demo kasutajaliides — Windowsi võrgusätteid ei loeta ega muudeta."
            case "priority": "Ühenduse prioriteet"
            case "help": "Windows eelistab väiksemat meetrikat. Prototüüp muudab ainult demoloendit."
            case "order": "#"
            case "adapter": "Adapter"
            case "ipv4": "Kohalik IPv4"
            case "ipv6": "Kohalik IPv6"
            case "metric": "Meetrika"
            case "select": "Vali"
            case "selected": "Valitud"
            case "moveUp": "Liiguta valitud üles"
            case "moveDown": "Liiguta valitud alla"
            case "apply": "Rakenda demo muudatused"
            case "nothingSelected": "Vali adapter, et muuta selle asukohta."
            case "demoApplied": "Demo järjekord on uuendatud. Süsteemi sätteid ei muudetud."
            default: key
            }
        }
    }
}
