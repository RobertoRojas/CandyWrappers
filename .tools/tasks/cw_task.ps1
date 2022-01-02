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
    '1.0.0' = {
        [CmdletBinding()]
        param (
            [hashtable]
            $Parameters = $(throw "Parameters need to be defined")
        );
        Write-Line -Message "Generic task not implemented" -Line " " -Corner " " -MessageForegroundColor White -MessageBackgroundColor DarkGray -LineBackgroundColor DarkGray;
        Write-Output -InputObject @{
            'Success' = $true;
        }
    };
}[$Version] | Write-Output;
