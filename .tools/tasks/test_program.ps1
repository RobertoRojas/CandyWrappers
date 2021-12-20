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
        $Program = $Parameters['program'];
        Write-VerboseMessage -Message "Program: $Program";
        $Result = Test-Program -Program $Program;
        if($Result) {
            Write-Line -Message "Found" -Line " " -Corner " " -MessageForegroundColor White -MessageBackgroundColor Green -LineBackgroundColor Green;
        } else {
            Write-Line -Message "Not found" -Line " " -Corner " " -MessageForegroundColor White -MessageBackgroundColor Red -LineBackgroundColor Red;
        }
        Write-Output -InputObject @{
            Result = $Result;
            Success = $Result;
        };
    };
}[$Version] | Write-Output;
