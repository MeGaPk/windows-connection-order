import Domain
import SwiftCrossUI

public struct MainNode<Dependencies: MainViewModelDependencies>: View {
    @State private var viewModel: MainViewModel<Dependencies>

    public init(viewModel: MainViewModel<Dependencies>) {
        _viewModel = State(wrappedValue: viewModel)
    }

    public var body: some View {
        VStack {
            HStack {
                VStack {
                    Text(viewModel.localizables.main.appTitle)
                    Text(viewModel.localizables.main.appSubtitle)
                }

                Spacer()

                HStack {
                    Text(viewModel.localizables.main.languageLabel)
                    Button(viewModel.localizables.main.languageEnglish) { viewModel.selectLocale(.english) }
                    Button(viewModel.localizables.main.languageRussian) { viewModel.selectLocale(.russian) }
                    Button(viewModel.localizables.main.languageEstonian) { viewModel.selectLocale(.estonian) }
                }
            }

            Text(viewModel.localizables.main.priorityTitle)
            Text(viewModel.localizables.main.priorityHelp)

            HStack {
                Text(viewModel.localizables.main.columnOrder)
                Text(viewModel.localizables.main.columnAdapter)
                Text(viewModel.localizables.main.columnIPv4)
                Text(viewModel.localizables.main.columnIPv6)
                Text(viewModel.localizables.main.columnMetric)
            }

            ForEach(viewModel.adapters) { adapter in
                HStack {
                    Text("\(adapter.priority)")
                    Text(adapter.name)
                    Text(adapter.ipv4.address.description)
                    Text(adapter.ipv6.address.description)
                    Text(viewModel.localizables.main.adapterMetrics(adapter.ipv4.metric, adapter.ipv6.metric))
                    Button(adapter.id == viewModel.selectedAdapterID ? viewModel.localizables.main.actionSelected : viewModel.localizables.main.actionSelect) {
                        viewModel.selectAdapter(id: adapter.id)
                    }
                }
            }

            HStack {
                Button(viewModel.localizables.main.actionMoveUp) { viewModel.moveSelectedAdapter(by: -1) }
                Button(viewModel.localizables.main.actionMoveDown) { viewModel.moveSelectedAdapter(by: 1) }
                Button(viewModel.localizables.main.actionApplyDemo) { viewModel.applyAdapterOrder() }
            }

            Text(viewModel.statusMessage.isEmpty ? viewModel.localizables.main.statusNothingSelected : viewModel.statusMessage)
        }
        .padding()
    }
}
