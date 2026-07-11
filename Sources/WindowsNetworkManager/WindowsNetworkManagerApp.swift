import DefaultBackend
import SwiftCrossUI

@main
struct WindowsNetworkManagerApp: App {
    @State private var language: AppLanguage = .english
    @State private var adapters = NetworkAdapter.demoAdapters
    @State private var selectedAdapterID: NetworkAdapter.ID?
    @State private var statusMessage = ""

    var body: some Scene {
        WindowGroup("Windows Connection Order") {
            VStack {
                HStack {
                    VStack {
                        Text(localized("title"))
                        Text(localized("subtitle"))
                    }

                    Spacer()

                    HStack {
                        Text("Language:")
                        Button("EN") { language = .english }
                        Button("RU") { language = .russian }
                        Button("ET") { language = .estonian }
                    }
                }

                Text(localized("priority"))
                Text(localized("help"))

                HStack {
                    Text(localized("order"))
                    Text(localized("adapter"))
                    Text(localized("ipv4"))
                    Text(localized("ipv6"))
                    Text(localized("metric"))
                }

                ForEach(adapters) { adapter in
                    HStack {
                        Text("\(adapter.priority)")
                        Text(adapter.name)
                        Text(adapter.ipv4Address)
                        Text(adapter.ipv6Address)
                        Text("IPv4: \(adapter.ipv4Metric), IPv6: \(adapter.ipv6Metric)")
                        Button(adapter.id == selectedAdapterID ? localized("selected") : localized("select")) {
                            selectedAdapterID = adapter.id
                            statusMessage = ""
                        }
                    }
                }

                HStack {
                    Button(localized("moveUp")) { moveSelectedAdapter(by: -1) }
                    Button(localized("moveDown")) { moveSelectedAdapter(by: 1) }
                    Button(localized("apply")) { applyDemoChanges() }
                }

                Text(statusMessage.isEmpty ? localized("nothingSelected") : statusMessage)
            }
            .padding()
        }
    }

    private func localized(_ key: String) -> String {
        language.text(key)
    }

    private func moveSelectedAdapter(by offset: Int) {
        guard let selectedAdapterID,
              let currentIndex = adapters.firstIndex(where: { $0.id == selectedAdapterID })
        else {
            statusMessage = localized("nothingSelected")
            return
        }

        let destinationIndex = currentIndex + offset
        guard adapters.indices.contains(destinationIndex) else { return }

        adapters.swapAt(currentIndex, destinationIndex)
        refreshPriorities()
        statusMessage = ""
    }

    private func applyDemoChanges() {
        statusMessage = localized("demoApplied")
    }

    private func refreshPriorities() {
        for index in adapters.indices {
            adapters[index].priority = index + 1
        }
    }
}
