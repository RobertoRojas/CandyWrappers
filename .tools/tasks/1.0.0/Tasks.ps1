Write-Output -InputObject @{
    "cw_echo" = {
        [CmdletBinding()]
        param (
            [hashtable]
            $Parameters = $(throw "Parameters need to be defined.")
        );
        $Parameters['foregroundcolor'] = $Parameters['foregroundcolor'] ?? "White";
        $Parameters['backgroundcolor'] = $Parameters['backgroundcolor'] ?? "Magenta";
        $Parameters['stream'] = $Parameters['stream'] ?? "error";
        Write-Message -Message $Parameters['message'] -ForegroundColor $Parameters['foregroundcolor'] -BackgroundColor $Parameters['backgroundcolor'] `
            -Stream $Parameters['stream'];
        Write-Output -InputObject @{};
    };
    "cw_pause" = {
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
        Write-Output -InputObject @{};
    };
    "cw_break" = {
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
    };
};
