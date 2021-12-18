[CmdletBinding()]
param (
    [ValidateSet(
        "1.0.0"
    )]
    [string]
    $Version = $(throw "$($MyInvocation.MyCommand.Name) -> You need to send the version of the script block")
);
Write-VerboseMessage "Selected version[$Version] of $($MyInvocation.MyCommand.Name)";
Write-Output -InputObject @{
    "1.0.0" = {
        [CmdletBinding()]
        param (
            [hashtable]
            $Parameters = $(throw "Parameters need to be defined.")
        );
        $JSON = $Buffers[$Parameters['key']] | ConvertTo-Json -Depth 10;
        Write-Message -Message $JSON -ForegroundColor White -BackgroundColor Magenta;
        Write-Output -InputObject @{
            JSON = $JSON;
            Success = $true;
        }
    };
}[$Version].ToString();
