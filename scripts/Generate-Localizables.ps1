[CmdletBinding()]
param(
    [string]$ResourcesPath = (Join-Path (Split-Path -Parent $PSScriptRoot) 'Sources\Localization\Resources'),
    [string]$OutputPath = (Join-Path (Split-Path -Parent $PSScriptRoot) 'Sources\Localization\Generated\Localizables.generated.swift')
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Get-StringsEntries {
    param([Parameter(Mandatory)][string]$Path)

    $entries = [ordered]@{}
    $lineNumber = 0
    foreach ($line in Get-Content -LiteralPath $Path -Encoding utf8) {
        $lineNumber += 1
        $line = $line.Trim()
        if ($line.Length -eq 0 -or $line.StartsWith('//') -or $line.StartsWith('/*')) {
            continue
        }

        if ($line -notmatch '^"(?<key>(?:\\.|[^"\\])*)"\s*=\s*"(?<value>(?:\\.|[^"\\])*)"\s*;$') {
            throw "Unsupported .strings syntax in '$Path' at line $lineNumber."
        }

        if ($entries.Contains($Matches.key)) {
            throw "Duplicate key '$($Matches.key)' in '$Path'."
        }
        $entries[$Matches.key] = $Matches.value
    }
    return $entries
}

function ConvertToSwiftIdentifier {
    param([Parameter(Mandatory)][string]$Value, [Parameter(Mandatory)][bool]$UppercaseFirstLetter)

    $parts = @([regex]::Matches($Value, '[A-Za-z0-9]+') | ForEach-Object Value)
    if ($parts.Count -eq 0) {
        throw "Cannot create a Swift identifier from '$Value'."
    }

    $identifier = ''
    for ($index = 0; $index -lt $parts.Count; $index += 1) {
        $part = $parts[$index]
        $normalizedPart = switch ($part.ToLowerInvariant()) {
            'ipv4' { 'IPv4' }
            'ipv6' { 'IPv6' }
            default { $part }
        }
        if ($index -eq 0 -and -not $UppercaseFirstLetter) {
            $identifier += $normalizedPart.Substring(0, 1).ToLowerInvariant() + $normalizedPart.Substring(1)
        }
        else {
            $identifier += $normalizedPart.Substring(0, 1).ToUpperInvariant() + $normalizedPart.Substring(1)
        }
    }

    if ($identifier -match '^[0-9]') {
        $identifier = "_$identifier"
    }
    return $identifier
}

function Get-FormatParameterTypes {
    param([Parameter(Mandatory)][string]$Value)

    $pattern = '(?<!%)%(?:\d+\$)?[-+# 0]*\d*(?:\.\d+)?(?:hh|h|ll|l|L|z|t|j)?[@a-zA-Z]'
    $types = [System.Collections.Generic.List[string]]::new()
    foreach ($match in [regex]::Matches($Value, $pattern)) {
        switch ($match.Value.Substring($match.Value.Length - 1)) {
            '@' { $types.Add('String') }
            { $_ -in 'd', 'i', 'o', 'u', 'x', 'X', 'c', 'C' } { $types.Add('Int') }
            { $_ -in 'e', 'E', 'f', 'F', 'g', 'G', 'a', 'A' } { $types.Add('Double') }
            default { $types.Add('CVarArg') }
        }
    }
    return ,$types.ToArray()
}

if (-not (Test-Path -LiteralPath $ResourcesPath)) {
    throw "Resources directory not found: $ResourcesPath"
}

$referenceLocalePath = Join-Path $ResourcesPath 'en.lproj'
if (-not (Test-Path -LiteralPath $referenceLocalePath)) {
    throw "Missing reference localization: $referenceLocalePath"
}

$referenceTables = @(Get-ChildItem -LiteralPath $referenceLocalePath -Filter '*.strings' -File | Sort-Object Name)
if ($referenceTables.Count -eq 0) {
    throw "No .strings files found in '$referenceLocalePath'."
}

$referenceEntriesByTable = @{}
foreach ($table in $referenceTables) {
    $referenceEntriesByTable[$table.Name] = Get-StringsEntries -Path $table.FullName
}

foreach ($localeDirectory in Get-ChildItem -LiteralPath $ResourcesPath -Filter '*.lproj' -Directory) {
    $tableNames = @(Get-ChildItem -LiteralPath $localeDirectory.FullName -Filter '*.strings' -File | Select-Object -ExpandProperty Name | Sort-Object)
    $referenceTableNames = @($referenceTables | Select-Object -ExpandProperty Name)
    if (Compare-Object $referenceTableNames $tableNames) {
        throw "Tables in '$($localeDirectory.Name)' differ from the reference localization."
    }

    foreach ($table in $referenceTables) {
        $localizedEntries = Get-StringsEntries -Path (Join-Path $localeDirectory.FullName $table.Name)
        $referenceEntries = $referenceEntriesByTable[$table.Name]
        $missingKeys = @($referenceEntries.Keys | Where-Object { -not $localizedEntries.Contains($_) })
        $extraKeys = @($localizedEntries.Keys | Where-Object { -not $referenceEntries.Contains($_) })
        if ($missingKeys.Count -gt 0 -or $extraKeys.Count -gt 0) {
            throw "Keys in '$($localeDirectory.Name)\$($table.Name)' differ from the reference localization."
        }

        foreach ($key in $referenceEntries.Keys) {
            $referenceTypes = (Get-FormatParameterTypes $referenceEntries[$key]) -join ','
            $localizedTypes = (Get-FormatParameterTypes $localizedEntries[$key]) -join ','
            if ($referenceTypes -ne $localizedTypes) {
                throw "Format arguments for '$key' in '$($localeDirectory.Name)\$($table.Name)' differ from the reference localization."
            }
        }
    }
}

$lines = [System.Collections.Generic.List[string]]::new()
$lines.Add('// Generated by scripts/Generate-Localizables.ps1. Do not edit manually.')
$lines.Add('import Foundation')
$lines.Add('')
$lines.Add('extension Localizables {')

$usedTableProperties = @{}
foreach ($table in $referenceTables) {
    $tableName = [System.IO.Path]::GetFileNameWithoutExtension($table.Name)
    $tableType = ConvertToSwiftIdentifier -Value $tableName -UppercaseFirstLetter $true
    $tableProperty = ConvertToSwiftIdentifier -Value $tableName -UppercaseFirstLetter $false
    if ($usedTableProperties.Contains($tableProperty)) {
        throw "Table '$tableName' conflicts with another generated Swift property."
    }
    $usedTableProperties[$tableProperty] = $true

    $lines.Add(('    public var {0}: {1} {{' -f $tableProperty, $tableType))
    $lines.Add(('        {0}(bundle: bundle, locale: locale)' -f $tableType))
    $lines.Add('    }')
    $lines.Add('')
    $lines.Add(('    public struct {0} {{' -f $tableType))
    $lines.Add('        private let bundle: Bundle')
    $lines.Add('        private let locale: Locale')
    $lines.Add('')
    $lines.Add('        fileprivate init(bundle: Bundle, locale: Locale) {')
    $lines.Add('            self.bundle = bundle')
    $lines.Add('            self.locale = locale')
    $lines.Add('        }')

    $usedIdentifiers = @{}
    foreach ($key in $referenceEntriesByTable[$table.Name].Keys) {
        $identifier = ConvertToSwiftIdentifier -Value $key -UppercaseFirstLetter $false
        if ($usedIdentifiers.Contains($identifier)) {
            throw "Keys in '$($table.Name)' conflict as generated Swift identifier '$identifier'."
        }
        $usedIdentifiers[$identifier] = $true

        $parameterTypes = Get-FormatParameterTypes $referenceEntriesByTable[$table.Name][$key]
        if ($parameterTypes.Count -eq 0) {
            $lines.Add(('        public var {0}: String {{ string("{1}") }}' -f $identifier, $key))
            continue
        }

        $parameters = [System.Collections.Generic.List[string]]::new()
        $arguments = [System.Collections.Generic.List[string]]::new()
        for ($index = 0; $index -lt $parameterTypes.Count; $index += 1) {
            $argument = "argument$($index + 1)"
            $parameters.Add("_ ${argument}: $($parameterTypes[$index])")
            $arguments.Add($argument)
        }

        $lines.Add(('        public func {0}({1}) -> String {{' -f $identifier, ($parameters -join ', ')))
        $lines.Add(('            String(format: string("{0}"), locale: locale, arguments: [{1}])' -f $key, ($arguments -join ', ')))
        $lines.Add('        }')
    }

    $lines.Add('')
    $lines.Add('        private func string(_ key: String) -> String {')
    $lines.Add(('            bundle.localizedString(forKey: key, value: key, table: "{0}")' -f $tableName))
    $lines.Add('        }')
    $lines.Add('    }')
    $lines.Add('')
}

$lines.Add('}')

New-Item -ItemType Directory -Path (Split-Path -Parent $OutputPath) -Force | Out-Null
Set-Content -LiteralPath $OutputPath -Value $lines -Encoding utf8
Write-Host "Generated localization accessors: $OutputPath"
