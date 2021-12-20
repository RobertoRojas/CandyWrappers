[CmdletBinding()]
param (
    [string]
    $Wrapper = $(throw "$($MyInvocation.MyCommand.Name) -> You need to send the wrapper name to select"),
    [string]
    $Version = $(throw "$($MyInvocation.MyCommand.Name) -> You need to send the version of the script block")
);
$ErrorActionPreference = "stop";
$ScriptPath = @(Get-ChildItem -File -Path "$PSScriptRoot/../*.ps1" | Select-Object -ExpandProperty "FullName"
    | Where-Object -FilterScript { [System.IO.Path]::GetFileNameWithoutExtension($_) -eq $Wrapper});
if(-not $ScriptPath) {
    throw "The wrapper[$Wrapper] doesn't exist";
}
. $ScriptPath -Version $Version | Write-Output;

