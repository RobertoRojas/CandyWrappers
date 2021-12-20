[CmdletBinding()]
param (
    [ValidateSet(
        "1.0.0"
    )]
    [string]
    $Version = $(throw "$($MyInvocation.MyCommand.Name) -> You need to send the version of the script block")
);
Write-VerboseMessage "Selected version[$Version] of $($MyInvocation.MyCommand.Name)";
@{
    "1.0.0" = {
        [CmdletBinding()]
        param (
            [hashtable]
            $Parameters = $(throw "Parameters need to be defined.")
        );
        $Total = $Elapsed = $Parameters['milliseconds'] / 1000;
        Write-VerboseMessage -Message "Total seconds to wait: $Total";
        if($Total -eq 0) {
            if($NoInteractive) {
                Write-Line -Message "No interactive, skip pause." -Line " " -Corner " " `
                    -MessageForegroundColor Black -MessageBackgroundColor DarkGray `
                    -LineBackgroundColor DarkGray;
            } else {
                Read-Host -Prompt "Press enter to continue: " | Out-Null;
            }
        } else {
            do {
                $Sleep = [System.Math]::Min($Elapsed, 1.0);
                Write-Line -Message "Remaining $([System.Math]::Round($Elapsed, 2)) of $([System.Math]::Round($Total, 2)) (Seconds)" -Line " " -Corner " " `
                    -MessageForegroundColor White -MessageBackgroundColor Magenta `
                    -LineBackgroundColor Magenta;
                Start-Sleep -Seconds $Sleep;
                $Elapsed--;
            } while ($Elapsed -gt 0);
        }
        Write-Output -InputObject @{
            Success = $true;
        };
    };
}[$Version] | Write-Output;
