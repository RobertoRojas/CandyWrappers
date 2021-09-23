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
        Write-Output -InputObject @{
            Success = $true;
        };
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
        Write-Output -InputObject @{
            Success = $true;
        };
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
        Write-Output -InputObject @{
            Break = $Break;
            Success = $true;
        };
    };
    "test_program" = {
        [CmdletBinding()]
        param (
            [hashtable]
            $Parameters = $(throw "Parameters need to be defined.")
        );
        $Program = $Parameters['program'];
        Write-VerboseMessage -Message "Program: $Program";
        $Result = Test-Program -Program $Program;
        if($Result) {
            Write-Line -Message "Found" -Line " " -Corner " " -MessageForegroundColor White -MessageBackgroundColor Green -LineBackgroundColor Green;
        } else {
            Write-Line -Message "Not found" -Line " " -Corner " " -MessageForegroundColor White -MessageBackgroundColor Red -LineBackgroundColor Red;
        }
        Write-Output -InputObject @{
            Result = $Result;
            Success = $Result;
        }
    };
    "invoke_program" = {
        [CmdletBinding()]
        param (
            [hashtable]
            $Parameters = $(throw "Parameters need to be defined.")
        );
        $Program = $Parameters['program'];
        $Arguments = $Parameters['arguments'] ?? @();
        $Inputs = $Parameters['inputs'] ?? @();
        $WorkingDirectory = $Parameters['workingdirectory'] ?? $(Get-Location).Path;
        try {
            $Result = Invoke-Program -Program $Program -Arguments $Arguments -Inputs $Inputs -WorkingDirectory $WorkingDirectory;
            $InputObject = @{
                Output = $Result['Output'];
                Error = $Result['Error'];
                ExitCode = $Result['ExitCode'];
                Success = $($Result['ExitCode'] -eq 0);
            };
        } catch {
            Write-ErrorMessage -Message "$($MyInvocation.MyCommand.Name) -> $($_.Exception.Message)";
            $InputObject = @{
                Output = "";
                Error = "";
                ExitCode = -1;
                Success = $false;
            };
        } finally {
            Write-Output -InputObject $InputObject;
        }
    };
    "execute" = {
        [CmdletBinding()]
        param (
            [hashtable]
            $Parameters = $(throw "Parameters need to be defined.")
        );
        $ScriptBlock = [scriptblock]::Create($($Parameters['commands'] -join ";"));
        try {
            Invoke-Command -NoNewScope:$Parameters['nonewscope'] -ScriptBlock $ScriptBlock;
            $Success = $true;
        } catch {
            Write-ErrorMessage -Message "$($MyInvocation.MyCommand.Name) -> $($Parameters['task']) -> $($_.Exception.Message)";
            $Success = $false;
        }
        Write-Output -InputObject @{
            Success = $Success;
        }
    };
};
