$ErrorActionPreference = "stop";
$Invocation = $MyInvocation;
function Test-Program {
    [CmdletBinding()]
    param (
        [ValidateNotNullOrEmpty()]
        [string]
        $Program = $(throw "$($Invocation.MyCommand.Name) -> $($MyInvocation.MyCommand.Name) : The program parameter is mandatory.")
    );
    Write-Output -InputObject $($null -ne $(Get-Command -CommandType "Application" -Name $Program -ErrorAction SilentlyContinue))
}
function Invoke-Program{
    [CmdletBinding()]
    param (
        [ValidateNotNullOrEmpty()]
        [string]
        $Program = $(throw "$($Invocation.MyCommand.Name) -> $($MyInvocation.MyCommand.Name) : The program parameter is mandatory."),
        [ValidateNotNullOrEmpty()]
        [string[]]
        $Arguments = @(),
        [ValidateNotNull()]
        [string[]]
        $Inputs = @(),
        [ValidateNotNull()]
        [string]
        $WorkingDirectory = $(Get-Location).Path
    );
    if(-not (Test-Program -Program $Program)) {
        throw "$($Invocation.MyCommand.Name) -> $($MyInvocation.MyCommand.Name) : Cannot find the program[$Program] to execute."
    }
    $Argument = $Arguments -join " ";
    Write-VerboseMessage -Message "Program: $Program";
    Write-VerboseMessage -Message "Argument: $Argument";
    Write-VerboseMessage -Message "WorkingDirectory: $WorkingDirectory";
    Write-VerboseMessage -Message "Inputs: $($Inputs -join " ")";
    $StartInfo = [System.Diagnostics.ProcessStartInfo]::new();
    $StartInfo.FileName = $Program;
    $StartInfo.Arguments = $Arguments -join " ";
    $StartInfo.WorkingDirectory = $WorkingDirectory;
    $StartInfo.WindowStyle = "hidden";
    $StartInfo.RedirectStandardOutput = $true;
    $StartInfo.RedirectStandardError = $true;
    $StartInfo.RedirectStandardInput = $true;
    $StartInfo.UseShellExecute = $false;
    $StartInfo.CreateNoWindow = $false;
    $Process = [System.Diagnostics.Process]::new();
    $Process.StartInfo = $StartInfo;
    [void]$Process.Start();
    Write-Verbose "Process PID: $($Process.Id)";
    $OutputString = [System.Text.StringBuilder]::new();
    $OutputStream = $Process.StandardOutput.ReadLineAsync();
    $ErrorString = [System.Text.StringBuilder]::new();
    $ErrorStream = $Process.StandardError.ReadLineAsync();
    foreach ($Line in $Inputs) {
        $Process.StandardInput.WriteLine($Line);
    }
    while(-not $Process.HasExited) {
        if($OutputStream.IsCompletedSuccessfully) {
            if($null -ne $OutputStream.Result) {
                $Temp = $OutputStream.Result.Trim() + "`n";
                Write-Message -Message $Temp -NoNewLine;
                [void]$OutputString.Append($Temp);
            }
            $OutputStream = $Process.StandardOutput.ReadLineAsync();
        }
        if($ErrorStream.IsCompletedSuccessfully) {
            if($null -ne $ErrorStream.Result) {
                $Temp = $ErrorStream.Result.Trim() + "`n";
                Write-Message -Message $Temp -NoNewLine -Stream Error;
                [void]$ErrorString.Append($Temp);
            }
            $ErrorStream = $Process.StandardError.ReadLineAsync();
        }
    }
    Write-Output -InputObject @{
        Output = $OutputString.ToString();
        Error = $ErrorString.ToString();
        ExitCode = $Process.ExitCode;
    };
}
