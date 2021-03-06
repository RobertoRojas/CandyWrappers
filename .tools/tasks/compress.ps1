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
        $Parameters['force'] = $Parameters['force'] ?? $false;
        $Parameters['compression'] = $Parameters['compression'] ?? "Optimal";
        $OutputTask = @{
            'Paths' = $Parameters['paths'];
        };
        try {
            if((Test-Path -LiteralPath $Parameters['destination']) -and -not $Parameters['force']) {
                throw "The destination[$($Parameters['destination'])] already exist, please use 'force' to delete it";
            }
            $Parameters['paths'] = $Parameters['paths'] 
                | Select-Object -Property @{Name="FullName";Expression={$(Resolve-Path -LiteralPath $_).Path};} 
                | Select-Object -ExpandProperty "FullName";
            Compress-Archive -Path $Parameters['paths'] -DestinationPath $Parameters['destination'] -CompressionLevel $Parameters['compression'] -Force:$Parameters['force'];
            Write-Line -Message "Files compressed" -Line " " -Corner " " -MessageForegroundColor Green;
            $OutputTask['Success'] = $true;
            $OutputTask['Destination'] = $(Resolve-Path -LiteralPath $Parameters['destination']).Path;
        } catch {
            Write-ErrorMessage -Message "$($MyInvocation.MyCommand.Name) -> $($Parameters['task']) -> $($_.Exception.Message)";
            $OutputTask['Success'] = $false;
        } finally {
            Write-Output -InputObject $OutputTask;
        }
    };
}[$Version] | Write-Output;
