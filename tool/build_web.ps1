$ErrorActionPreference = 'Stop'
Set-Location (Split-Path -Parent $PSScriptRoot)
flutter build web --release --no-web-resources-cdn @args
