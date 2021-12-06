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
}[$Version].ToString();
