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
        $URI = $Parameters['uri'];
        $File = $Parameters['file'];
        $Force = $Parameters['force'] ?? $false;
        try {
            if(Test-Path -LiteralPath $File) {
                if($Force) {
                    Remove-Item -LiteralPath $File;
                } else {
                    throw "The path[$($Parameters['path'])] already exist, please use 'force' to delete it.";
                }
            }
            Invoke-WebRequest -Uri $URI -OutFile $File;
            Write-Line -Message "File downloaded successfully" -Line " " -Corner " " -MessageForegroundColor Green;
            Write-Output -InputObject @{
                FilePath = $(Resolve-Path -LiteralPath $File).Path;
                Success = $true;
            };
        } catch {
            Write-ErrorMessage -Message "$($MyInvocation.MyCommand.Name) -> $($Parameters['task']) -> $($_.Exception.Message)";
            Write-Output -InputObject @{
                Success = $false;
            };
        }
    };
}[$Version].ToString();
