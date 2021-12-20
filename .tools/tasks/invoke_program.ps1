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
}[$Version] | Write-Output;
