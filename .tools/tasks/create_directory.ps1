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
        $Output = @{};
        try {
            if(Test-Path -LiteralPath $Parameters['path']) {
                if($Parameters['force']) {
                    Remove-Item -Path $Parameters['path'] -Recurse -Force;
                } else {
                    throw "The path[$($Parameters['path'])] already exist, please use 'force' to delete it";
                }
            }
            New-Item -Path $Parameters['path'] -ItemType directory | Out-Null;
            Write-Line -Message "Directory created" -Line " " -Corner " " -MessageForegroundColor Green;
            $Output['Path'] = $(Resolve-Path -LiteralPath $Parameters['path']).Path;
            $Output['Success'] = $true;
        } catch {
            Write-ErrorMessage -Message "$($MyInvocation.MyCommand.Name) -> $($Parameters['task']) -> $($_.Exception.Message)";
            $Output['Success'] = $false;
        } finally {
            Write-Output -InputObject $Output;
        }
    };
}[$Version] | Write-Output;
