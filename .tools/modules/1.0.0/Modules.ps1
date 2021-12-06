Write-Output -InputObject @(
    $(Resolve-Path -LiteralPath "$PSScriptRoot/program/program.psd1")
);
