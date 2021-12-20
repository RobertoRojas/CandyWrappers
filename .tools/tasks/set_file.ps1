[CmdletBinding()]
param (
    [ValidateSet(
        "1.0.0"
    )]
    [string]
    $Version = $(throw "$($MyInvocation.MyCommand.Name) -> You need to send the version of the script block")
);
Write-VerboseMessage "Selected version[$Version] of $($MyInvocation.MyCommand.Name)";
@{
    "1.0.0" = {
        [CmdletBinding()]
        param (
            [hashtable]
            $Parameters = $(throw "Parameters need to be defined.")
        );
        $Content = $Parameters['content'] ?? @();
        $Encoding = $Parameters['encoding'] ?? "ascii";
        $NoNewLine = $Parameters['nonewline'] ?? $false;
        try {
            if($(Test-Path -LiteralPath $Parameters['path']) -and $Parameters['force']) {
                Remove-Item -Recurse -Force -LiteralPath $Parameters['path'];
            }
            Out-File -LiteralPath $Parameters['path'] -InputObject $Content -Encoding $Encoding -Append -NoNewline:$NoNewLine;
            $Success = $true;
            Write-Line -Message "Content added" -Line " " -Corner " " -MessageForegroundColor Green;
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
