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
        $Parameters['force'] = $Parameters['force'] ?? $false;
        $Output = @{};
        try {
            if(-not (Test-Path -LiteralPath $Parameters['path'])) {
                throw "The path[$($Parameters['path'])] doesn't exist";
            } 
            $Output['Path'] = $(Resolve-Path -LiteralPath $Parameters['path']).Path;
            Expand-Archive -LiteralPath $Parameters['path'] -DestinationPath $Parameters['destination'] -Force:$Parameters['force'];
            Write-Line -Message "Files decompressed" -Line " " -Corner " " -MessageForegroundColor Green;
            $Output['Destination'] = $(Resolve-Path -LiteralPath $Parameters['destination']).Path;
            $Output['Success'] = $true;
        } catch {
            Write-ErrorMessage -Message "$($MyInvocation.MyCommand.Name) -> $($Parameters['task']) -> $($_.Exception.Message)";
            $Output['Success'] = $false;
        } finally {
            Write-Output -InputObject $Output;
        }
    };
}[$Version].ToString();
