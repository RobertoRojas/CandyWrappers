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
        $Break = $Parameters['break'] ?? $($true -and -not $NoBreak);
        if($Break) {
            Write-Line -Message "Break" -Line " " -Corner " " -MessageForegroundColor White -MessageBackgroundColor Magenta -LineBackgroundColor Magenta;
        } else {
            Write-Line -Message "Skip break" -Line " " -Corner " " -MessageForegroundColor Black -MessageBackgroundColor DarkGray `
                -LineBackgroundColor DarkGray;
        }
        Write-Output -InputObject @{
            Break = $Break;
            Success = $true;
        };
    };
}[$Version].ToString();
