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
        $Program = $Parameters['program'];
        $Arguments = $Parameters['arguments'] ?? @();
        $Inputs = $Parameters['inputs'] ?? @();
        $WorkingDirectory = $Parameters['workingdirectory'] ?? $(Get-Location).Path;
        $Output = @{};
        try {
            $Result = Invoke-Program -Program $Program -Arguments $Arguments -Inputs $Inputs -WorkingDirectory $WorkingDirectory;
            $Output['Output'] = $Result['Output'];
            $Output['Error'] = $Result['Error'];
            $Output['ExitCode'] = $Result['ExitCode'];
            $Output['Success'] = $($Result['ExitCode'] -eq 0);
        } catch {
            Write-ErrorMessage -Message "$($MyInvocation.MyCommand.Name) -> $($Parameters['task']) -> $($_.Exception.Message)";
            $Output['Output'] = "";
            $Output['Error'] = "";
            $Output['ExitCode'] = -1;
            $Output['Success'] = $false;
        } finally {
            Write-Output -InputObject $Output;
        }
    };
}[$Version] | Write-Output;
