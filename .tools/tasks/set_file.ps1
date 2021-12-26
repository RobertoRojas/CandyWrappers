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
        $Parameters['content'] = $Parameters['content'] ?? @();
        $Parameters['encoding'] = $Parameters['encoding'] ?? "ascii";
        $Parameters['nonewline'] = $Parameters['nonewline'] ?? $false;
        $Output = @{
            'Content' = $Parameters['content'];
            'Encoding' = $Parameters['encoding'];
            'NoNewLine' = $Parameters['nonewline'];
        };
        try {
            if($(Test-Path -LiteralPath $Parameters['path']) -and $Parameters['force']) {
                Remove-Item -Recurse -Force -LiteralPath $Parameters['path'];
            }
            Out-File -LiteralPath $Parameters['path'] -InputObject $Parameters['content'] -Encoding $Parameters['encoding'] -Append -NoNewline:$Parameters['nonewline'];
            $Output['Success'] = $true;
            Write-Line -Message "Content added" -Line " " -Corner " " -MessageForegroundColor Green;
        } catch {
            Write-ErrorMessage -Message "$($MyInvocation.MyCommand.Name) -> $($Parameters['task']) -> $($_.Exception.Message)";
            $Output['Success'] = $false;
        } finally {
            Write-Output -InputObject $Output;
        }
    };
}[$Version] | Write-Output;
