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
        $Parameters['milliseconds'] = $Parameters['milliseconds'] ?? 0;
        $Total = $Elapsed = $Parameters['milliseconds'] / 1000;
        $OutputTask = @{
            'Success' = $true;
        };
        Write-VerboseMessage -Message "Total seconds to wait: $Total";
        if($Total -eq 0) {
            if($NoInteractive) {
                Write-Line -Message "No interactive, skip pause" -Line " " -Corner " " `
                    -MessageForegroundColor Black -MessageBackgroundColor DarkGray `
                    -LineBackgroundColor DarkGray;
            } else {
                $Note = Read-Host -Prompt "Press enter to continue or write a note";
                Write-Note -Type wrapper_pause -Note $Note;
                if($Note) {
                    $OutputTask['Note'] = $Note;
                }
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
        Write-Output -InputObject $OutputTask;
    };
}[$Version] | Write-Output;
