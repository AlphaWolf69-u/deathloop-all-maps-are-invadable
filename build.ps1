$ErrorActionPreference='Stop'
New-Item -ItemType Directory -Path (Join-Path $PSScriptRoot 'dist') -Force | Out-Null
Compress-Archive -LiteralPath (Join-Path $PSScriptRoot 'mod\mod.toml'),(Join-Path $PSScriptRoot 'mod\main.lua'),(Join-Path $PSScriptRoot 'README.md') -DestinationPath (Join-Path $PSScriptRoot 'dist\AllMapsAreInvadable-1.0.2.zip') -Force
