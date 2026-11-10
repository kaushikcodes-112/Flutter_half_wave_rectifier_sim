$ErrorActionPreference = 'Stop'
Set-Location (Split-Path -Parent $PSScriptRoot)
flutter run -d chrome --no-web-resources-cdn @args
