import AppComposition
import ArgumentParser
import Foundation

@main
struct WindowsConnectionOrderCLI: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "windows-connection-order",
        abstract: "Inspect Windows connection order from the command line.",
        subcommands: [AdaptersCommand.self]
    )
}

struct AdaptersCommand: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "adapters",
        abstract: "Work with network adapters.",
        subcommands: [ListAdaptersCommand.self]
    )
}

struct ListAdaptersCommand: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "list",
        abstract: "List network adapters."
    )

    enum OutputFormat: String, CaseIterable, ExpressibleByArgument {
        case table
        case json
    }

    @Option(name: .long, help: "Output format: table or json.")
    var format: OutputFormat = .table

    mutating func run() async throws {
        let useCases = AppComposition.makeSystemAdaptersUseCases()

        await useCases.refresh.execute()
        let stream = await useCases.stream.execute()
        var iterator = stream.makeAsyncIterator()

        guard let adapters = await iterator.next() else {
            throw ValidationError("Unable to load network adapters.")
        }

        let output = adapters.enumerated().map { index, adapter in
            AdapterOutput(
                priority: index + 1,
                luid: adapter.id.luid,
                name: adapter.name,
                ipv4: adapter.ipv4.address?.description,
                ipv6: adapter.ipv6.address?.description,
                metric: adapter.metric
            )
        }

        switch format {
            case .table:
                printTable(output)
            case .json:
                try printJSON(output)
        }
    }

    private func printJSON(_ adapters: [AdapterOutput]) throws {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        let data = try encoder.encode(adapters)
        print(String(decoding: data, as: UTF8.self))
    }

    private func printTable(_ adapters: [AdapterOutput]) {
        let header = ["#", "Adapter", "IPv4", "IPv6", "Metric", "LUID"]
        let rows = adapters.map {
            [
                String($0.priority),
                $0.name,
                $0.ipv4 ?? "—",
                $0.ipv6 ?? "—",
                String($0.metric),
                String($0.luid)
            ]
        }
        let widths = header.indices.map { index in
            ([header[index]] + rows.map { $0[index] }).map(\.count).max() ?? 0
        }

        print(tableLine(header, widths: widths))
        print(widths.map { String(repeating: "-", count: $0) }.joined(separator: "-+-"))
        rows.forEach { print(tableLine($0, widths: widths)) }
    }

    private func tableLine(_ values: [String], widths: [Int]) -> String {
        zip(values, widths)
            .map { value, width in
                value.padding(toLength: width, withPad: " ", startingAt: 0)
            }
            .joined(separator: " | ")
    }
}

private struct AdapterOutput: Encodable {
    let priority: Int
    let luid: UInt64
    let name: String
    let ipv4: String?
    let ipv6: String?
    let metric: Int
}
