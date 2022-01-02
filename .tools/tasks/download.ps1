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
        $OutputTask = @{
            'URI' = $Parameters['uri'];
        };
        try {
            if(Test-Path -LiteralPath $Parameters['file']) {
                if($Parameters['force']) {
                    Remove-Item -LiteralPath $Parameters['file'];
                } else {
                    throw "The path[$($Parameters['path'])] already exist, please use 'force' to delete it";
                }
            }
            $Response = Invoke-WebRequest -Uri $Parameters['uri'] -OutFile $Parameters['file'] -PassThru;
            Write-Line -Message "File downloaded successfully" -Line " " -Corner " " -MessageForegroundColor Green;
            $OutputTask['Response'] = $Response;
            $OutputTask['File'] = $(Resolve-Path -LiteralPath $Parameters['file']).Path;
            $OutputTask['Success'] = $true;
        } catch {
            Write-ErrorMessage -Message "$($MyInvocation.MyCommand.Name) -> $($Parameters['task']) -> $($_.Exception.Message)";
            $OutputTask['Success'] = $false;
        } finally {
            Write-Output -InputObject $OutputTask;
        }
    };
}[$Version] | Write-Output;
