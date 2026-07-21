import Domain
import Localization
import SwiftCrossUI
import UIUtils

public struct SettingsScreen: View {
    @State private var viewModel: SettingsViewModel
    private let localizablesProvider: LocalizablesProvider

    public init(
        viewModel: SettingsViewModel,
        localizablesProvider: LocalizablesProvider
    ) {
        _viewModel = State(wrappedValue: viewModel)
        self.localizablesProvider = localizablesProvider
    }

    public var body: some View {
        Group {
            if let colorScheme {
                content
                    .colorScheme(colorScheme)
                    .preferredColorScheme(colorScheme)
            }
            else {
                content
            }
        }
        .environment(\.localizablesProvider, localizablesProvider)
    }

    private var content: some View {
        VStack(alignment: .leading, spacing: 16) {
            screenHeader
            languageSettings
            appearanceSettings
        }
        .padding(20)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(UIColors.Surface.page)
    }

    private var screenHeader: some View {
        HStack {
            Text(localizables.main.settingsTitle).emphasized()

            Spacer()

            Button(localizables.main.actionBack) {
                viewModel.goBack()
            }
        }
    }

    private var languageSettings: some View {
        HStack(spacing: 6) {
            Text(localizables.main.languageLabel)

            if !languageOptions.isEmpty {
                Picker(of: languageOptions, selection: languageSelection)
            }
        }
    }

    private var appearanceSettings: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(localizables.main.settingsThemeLabel)
            Picker(of: colorSchemeOptions, selection: colorSchemeSelection)
                .pickerStyle(.radioGroup)
        }
    }

    private var localizables: Localizables {
        localizablesProvider.current
    }

    private var colorScheme: ColorScheme? {
        switch viewModel.appColorScheme {
            case .automatic:
                nil
            case .light:
                .light
            case .dark:
                .dark
        }
    }

    private var availableLocales: [AppLocale] {
        viewModel.localeSettings?.availableLocales ?? []
    }

    private var languageOptions: [String] {
        availableLocales.map(localizedLanguageName)
    }

    private var languageSelection: Binding<String?> {
        let options = languageOptions

        return Binding(
            get: {
                guard let selectedLocale = viewModel.localeSettings?.selectedLocale,
                      let index = availableLocales.firstIndex(of: selectedLocale)
                else {
                    return nil
                }
                return options[index]
            },
            set: { selectedOption in
                guard let selectedOption,
                      let index = options.firstIndex(of: selectedOption)
                else {
                    return
                }
                viewModel.selectLocale(availableLocales[index])
            }
        )
    }

    private var colorSchemeOptions: [String] {
        [
            localizables.main.colorSchemeAutomatic,
            localizables.main.colorSchemeLight,
            localizables.main.colorSchemeDark
        ]
    }

    private var colorSchemeSelection: Binding<String?> {
        let options = colorSchemeOptions

        return Binding(
            get: {
                switch viewModel.appColorScheme {
                    case .automatic:
                        options[0]
                    case .light:
                        options[1]
                    case .dark:
                        options[2]
                }
            },
            set: { selectedOption in
                guard let selectedOption,
                      let index = options.firstIndex(of: selectedOption)
                else {
                    return
                }

                switch index {
                    case 0:
                        viewModel.selectColorScheme(.automatic)
                    case 1:
                        viewModel.selectColorScheme(.light)
                    default:
                        viewModel.selectColorScheme(.dark)
                }
            }
        )
    }

    private func localizedLanguageName(for locale: AppLocale) -> String {
        switch locale {
            case .english:
                localizables.main.languageEnglish
            case .russian:
                localizables.main.languageRussian
            case .estonian:
                localizables.main.languageEstonian
        }
    }
}
