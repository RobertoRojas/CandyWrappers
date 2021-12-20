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
}[$Version] | Write-Output;
