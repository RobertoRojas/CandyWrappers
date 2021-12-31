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
        $OutputTask = @{};
        try {
            if(Test-Path -LiteralPath $Parameters['path']) {
                Remove-Item -Path $Parameters['path'] -Recurse -Force;
            }
            $OutputTask['Success'] = $true;
            Write-Line -Message "Path deleted" -Line " " -Corner " " -MessageForegroundColor Green;
        } catch {
            Write-ErrorMessage -Message "$($MyInvocation.MyCommand.Name) -> $($Parameters['task']) -> $($_.Exception.Message)";
            $OutputTask['Success'] = $false;
        } finally {
            Write-Output -InputObject $OutputTask;
        }
    };
}[$Version] | Write-Output;
