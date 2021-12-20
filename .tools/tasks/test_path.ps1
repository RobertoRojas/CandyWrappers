[CmdletBinding()]
param (
    [ValidateSet(
        "1.0.0"
    )]
    [string]
    $Version = $(throw "$($MyInvocation.MyCommand.Name) -> You need to send the version of the script block")
);
$ErrorActionPreference = "stop";
Write-VerboseMessage "Selected version[$Version] of $($MyInvocation.MyCommand.Name)";
@{
    "1.0.0" = {
        [CmdletBinding()]
        param (
            [hashtable]
            $Parameters = $(throw "Parameters need to be defined")
        );
        $Parameters['exist'] = $Parameters['exist'] ?? $true;
        $Success = $(Test-Path -LiteralPath $Parameters['path']) -eq $Parameters['exist'];
        if($Success) {
            Write-Line -Message "Match" -Line " " -Corner " " -MessageForegroundColor Green;
        } else {
            Write-Line -Message "Not match" -Line " " -Corner " " -MessageForegroundColor Red;
        }
        Write-Output -InputObject @{
            Success = $Success;
        };
    };
}[$Version] | Write-Output;
