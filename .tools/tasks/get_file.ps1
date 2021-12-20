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
        $Parameters['raw'] = $Parameters['raw'] ?? $false;
        $Parameters['like'] = $Parameters['like'] ?? "*";
        $Parameters['encoding'] = $Parameters['encoding'] ?? "ascii";
        $Parameters['displaycontent'] = $Parameters['displaycontent'] ?? $true;
        $Output = @{};
        try {
            if(-not (Test-Path -LiteralPath $Parameters['path'])) {
                throw "The path[$($Parameters['path'])] doesn't exists.";
            }
            $Arguments = @{
                LiteralPath = $Parameters['path'];
                Raw = $Parameters['raw'];
                Encoding = $Parameters['encoding'];
            };
            if($Parameters['tail']) {
                $Arguments.Add('Tail', $Parameters['tail']);
            }
            if($Parameters['totalcount']) {
                $Arguments.Add('TotalCount', $Parameters['totalcount']);
            }
            $Content = Get-Content @Arguments | Where-Object -FilterScript {$_ -like $Parameters['like']};
            if($Parameters['displaycontent']) {
                for ($i = 0; $i -lt $Content.Count; $i++) {
                    Write-Message -Message "$i " -NoNewLine -ForegroundColor DarkCyan;
                    Write-Message -Message "~ " -NoNewLine -ForegroundColor DarkMagenta;
                    Write-Message -Message $Content[$i] -ForegroundColor White;
                }
            }
            Write-Line -Message "Content obtained" -Line " " -Corner " " -MessageForegroundColor Green;
            $Output.Add('Content', $Content);
            $Output.Add('Success', $true);
        } catch {
            Write-ErrorMessage -Message "$($MyInvocation.MyCommand.Name) -> $($Parameters['task']) -> $($_.Exception.Message)";
            $Output.Add('Success', $false);
        } finally {
            Write-Output -InputObject $Output;
        }
    };
}[$Version] | Write-Output;
