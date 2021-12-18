[CmdletBinding()]
param (
    [ValidateSet(
        "1.0.0"
    )]
    [string]
    $Version = $(throw "$($MyInvocation.MyCommand.Name) -> You need to send the version of the script block")
);
Write-VerboseMessage "Selected version[$Version] of $($MyInvocation.MyCommand.Name)";
Write-Output -InputObject @{
    "1.0.0" = {
        [CmdletBinding()]
        param (
            [hashtable]
            $Parameters = $(throw "Parameters need to be defined.")
        );
        $Parameters['buffer'] = $Parameters['buffer'] ?? $true;
        Write-Line -Message "Buffer created" -Line " " -Corner " " -MessageForegroundColor White -MessageBackgroundColor Magenta -LineBackgroundColor Magenta;
        Write-Output -InputObject @{
            Object = $Parameters['object'];
            Success = $true;
        }
    };
}[$Version].ToString();
