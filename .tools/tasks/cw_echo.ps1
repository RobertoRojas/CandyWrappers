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
        $Parameters['foregroundcolor'] = $Parameters['foregroundcolor'] ?? "White";
        $Parameters['backgroundcolor'] = $Parameters['backgroundcolor'] ?? "Magenta";
        $Parameters['stream'] = $Parameters['stream'] ?? "Output";
        $Parameters['silent'] = $Parameters['silent'] ?? $false;
        Write-Message -Message $Parameters['message'] -ForegroundColor $Parameters['foregroundcolor'] -BackgroundColor $Parameters['backgroundcolor'] `
            -Stream $Parameters['stream'] -NoDisplay:$Parameters['silent'];
        Write-Output -InputObject @{
            Message = $Parameters['message'];
            Success = $true;
        };
    };
}[$Version].ToString();
