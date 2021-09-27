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
        };
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
            Write-ErrorMessage -Message "$($MyInvocation.MyCommand.Name) -> $($Parameters['task']) -> $($_.Exception.Message)";
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
        } finally {
            Write-Output -InputObject @{
                Success = $Success;
            };
        }
    };
    "test_path" = {
        [CmdletBinding()]
        param (
            [hashtable]
            $Parameters = $(throw "Parameters need to be defined.")
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
    "remove_path" = {
        [CmdletBinding()]
        param (
            [hashtable]
            $Parameters = $(throw "Parameters need to be defined.")
        );
        try {
            if(Test-Path -LiteralPath $Parameters['path']) {
                Remove-Item -Path $Parameters['path'] -Recurse -Force;
            }
            $Success = $true;
            Write-Line -Message "Path deleted" -Line " " -Corner " " -MessageForegroundColor Green;
        } catch {
            Write-ErrorMessage -Message "$($MyInvocation.MyCommand.Name) -> $($Parameters['task']) -> $($_.Exception.Message)";
            $Success = $false;
        } finally {
            Write-Output -InputObject @{
                Success = $Success;
            };
        }
    };
    "create_directory" = {
        [CmdletBinding()]
        param (
            [hashtable]
            $Parameters = $(throw "Parameters need to be defined.")
        );
        $Parameters['force'] = $Parameters['force'] ?? $false;
        try {
            if(Test-Path -LiteralPath $Parameters['path']) {
                if($Parameters['force']) {
                    Remove-Item -Path $Parameters['path'] -Recurse -Force;
                } else {
                    throw "The path[$($Parameters['path'])] already exist, please use 'force' to delete it.";
                }
            }
            New-Item -Path $Parameters['path'] -ItemType directory;
            $Success = $true;
            Write-Line -Message "Directory created" -Line " " -Corner " " -MessageForegroundColor Green;
        } catch {
            Write-ErrorMessage -Message "$($MyInvocation.MyCommand.Name) -> $($Parameters['task']) -> $($_.Exception.Message)";
            $Success = $false;
        } finally {
            Write-Output -InputObject @{
                Success = $Success;
            };
        }
    };
    "set_file" = {
        [CmdletBinding()]
        param (
            [hashtable]
            $Parameters = $(throw "Parameters need to be defined.")
        );
        $Content = $Parameters['content'] ?? @();
        $Encoding = $Parameters['encoding'] ?? "ascii";
        $NoNewLine = $Parameters['nonewline'] ?? $false;
        try {
            if($(Test-Path -LiteralPath $Parameters['path']) -and $Parameters['force']) {
                Remove-Item -Recurse -Force -LiteralPath $Parameters['path'];
            }
            Out-File -LiteralPath $Parameters['path'] -InputObject $Content -Encoding $Encoding -Append -NoNewline:$NoNewLine;
            $Success = $true;
            Write-Line -Message "Content added" -Line " " -Corner " " -MessageForegroundColor Green;
        } catch {
            Write-ErrorMessage -Message "$($MyInvocation.MyCommand.Name) -> $($Parameters['task']) -> $($_.Exception.Message)";
            $Success = $false;
        } finally {
            Write-Output -InputObject @{
                Success = $Success;
            };
        }
    };
};
