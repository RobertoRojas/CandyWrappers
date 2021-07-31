#Requires -Version 7.1.3
[CmdletBinding()]
param(
    [Alias(
        "System"
    )]
    [ValidateSet(
        "Execute",
        "Version",
        "Github"
    )]
    [string]
    $CandySystem = "Chancla",
    [Alias(
        "Output",
        "Return"
    )]
    [ValidateSet(
        "JSON",
        "PSCustomObject",
        "Hashtable",
        "Null"
    )]
    [string]
    $Type = "Null",
    [switch]
    $NoColor,
    [switch]
    $NoExit,
    [Alias(
        "Quiet",
        "Hide",
        "Mute"
    )]
    [switch]
    $Silent
);
$ErrorActionPreference = "stop";
$Invocation = $MyInvocation;
$Major = 0;
$Minor =0;
$Build = 1;
$GithubRepository = "https://github.com/RobertoRojas/CandyWrappers";
$ExitCode = -1;
function Write-Line {
    [CmdletBinding()]
    param(
        [ValidateNotNullOrEmpty()]
        [string]
        $Message = "",
        [ValidateLength(1,1)]
        [string]
        $Line = "-",
        [ValidateLength(1,1)]
        [string]
        $Corner = "#",
        [ValidateSet(
            "Black",
            "DarkBlue",
            "DarkGreen",
            "DarkCyan",
            "DarkRed",
            "DarkMagenta",
            "DarkYellow",
            "Gray",
            "DarkGray",
            "Blue",
            "Green",
            "Cyan",
            "Red",
            "Magenta",
            "Yellow",
            "White"
        )]
        [string]
        $MessageForegroundColor = "",
        [ValidateSet(
            "Black",
            "DarkBlue",
            "DarkGreen",
            "DarkCyan",
            "DarkRed",
            "DarkMagenta",
            "DarkYellow",
            "Gray",
            "DarkGray",
            "Blue",
            "Green",
            "Cyan",
            "Red",
            "Magenta",
            "Yellow",
            "White"
        )]
        [string]
        $MessageBackgroundColor = "",
        [ValidateSet(
            "Black",
            "DarkBlue",
            "DarkGreen",
            "DarkCyan",
            "DarkRed",
            "DarkMagenta",
            "DarkYellow",
            "Gray",
            "DarkGray",
            "Blue",
            "Green",
            "Cyan",
            "Red",
            "Magenta",
            "Yellow",
            "White"
        )]
        [string]
        $LineForegroundColor = "",
        [ValidateSet(
            "Black",
            "DarkBlue",
            "DarkGreen",
            "DarkCyan",
            "DarkRed",
            "DarkMagenta",
            "DarkYellow",
            "Gray",
            "DarkGray",
            "Blue",
            "Green",
            "Cyan",
            "Red",
            "Magenta",
            "Yellow",
            "White"
        )]
        [string]
        $LineBackgroundColor = "",
        [ValidateRange(1, [int]::MaxValue)]
        [int]
        $Width = -1,
        [ValidateSet(
            "Output",
            "Error"
        )]
        $Stream = "Output"
    );
    if($Silent) {
        return;
    }
    if($Width -eq -1) {
        try {
            $Width = [System.Console]::WindowWidth;
        } catch {
            $Width = 100;
        }
    }
    if($Width -le $Message.Length) {
        $Object = $Message;
        $Parameters = @{
            Message = $Object;
            Stream = $Stream;
        }
        if(-not $NoColor) {
            if($MessageForegroundColor) {
                $Parameters.Add("ForegroundColor", $MessageForegroundColor);
            }
            if($MessageBackgroundColor) {
                $Parameters.Add("BackgroundColor", $MessageBackgroundColor);
            }
        }
        Write-Message @Parameters;
    } else {
        $CornerParameter = @{
            Message = $Corner;
            Stream = $Stream;
            NoNewline = $true;
        };
        $LineParameter = @{
            Message = $Line;
            Stream = $Stream;
            NoNewline = $true;
        };
        $MessageParameter = @{
            Message = $Message;
            Stream = $Stream;
            NoNewline = $true;
        };
        if(-not $NoColor) { 
            if($LineForegroundColor) {
                $CornerParameter.Add("ForegroundColor", $LineForegroundColor);
                $LineParameter.Add("ForegroundColor", $LineForegroundColor);
            }
            if($LineBackgroundColor) {
                $CornerParameter.Add("BackgroundColor", $LineBackgroundColor);
                $LineParameter.Add("BackgroundColor", $LineBackgroundColor);
            }
            if($MessageForegroundColor) {
                $MessageParameter.Add("ForegroundColor", $MessageForegroundColor);
            }
            if($MessageBackgroundColor) {
                $MessageParameter.Add("BackgroundColor", $MessageBackgroundColor);
            }
        }
        $Width -= 2;
        $Left = $Right = [System.Math]::Floor(($Width - $Message.Length) / 2);
        if(($Right + $Left) -ne ($Width - $Message.Length)) {
            $Right++;
        }
        Write-Message @CornerParameter;
        for($i = 0; $i -lt $Right; $i++) {
            Write-Message @LineParameter; 
        }
        if($Message) {
            Write-Message @MessageParameter;
        }
        for($i = 0; $i -lt $Left; $i++) {
            Write-Message @LineParameter; 
        }
        Write-Message  @CornerParameter;
    }
}
function Write-Message {
    [CmdletBinding()]
    param(
        [ValidateNotNullOrEmpty()]
        [string]
        $Message = " ",
        [ValidateSet(
            "Black",
            "DarkBlue",
            "DarkGreen",
            "DarkCyan",
            "DarkRed",
            "DarkMagenta",
            "DarkYellow",
            "Gray",
            "DarkGray",
            "Blue",
            "Green",
            "Cyan",
            "Red",
            "Magenta",
            "Yellow",
            "White"
        )]
        [string]
        $ForegroundColor = "",
        [ValidateSet(
            "Black",
            "DarkBlue",
            "DarkGreen",
            "DarkCyan",
            "DarkRed",
            "DarkMagenta",
            "DarkYellow",
            "Gray",
            "DarkGray",
            "Blue",
            "Green",
            "Cyan",
            "Red",
            "Magenta",
            "Yellow",
            "White"
        )]
        [string]
        $BackgroundColor = "",
        [ValidateSet(
            "Output",
            "Error"
        )]
        $Stream = "Output",
        [switch]
        $NoNewLine
    );
    if($Silent) {
        return;
    } 
    $Parameters = @{
        Object = $Message;
        NoNewLine = $NoNewLine;
    };
    if(-not $NoColor) {
        if($ForegroundColor) {
            $Parameters.Add("ForegroundColor", $ForegroundColor);
        }
        if($BackgroundColor) {
            $Parameters.Add("BackgroundColor", $BackgroundColor);
        }
    }
    if($Stream -eq "Output") {
        Write-Host @Parameters;
    } else {
        if(-not $NoColor) {
            if($ForegroundColor) {
                [System.Console]::ForegroundColor = $ForegroundColor;
            }
            if($BackgroundColor) {
                [System.Console]::BackgroundColor = $BackgroundColor;
            }
        }
        if($NoNewLine) {
            [System.Console]::Error.Write($Message);
        } else {
            [System.Console]::Error.WriteLine($Message);
        }
        if(-not $NoColor) {
            [System.Console]::ResetColor();
        }
    }
}
function Write-ErrorMessage {
    [CmdletBinding()]
    param(
        [ValidateNotNullOrEmpty()]
        [string]
        $Message = $(throw "$($Invocation.MyCommand.Name) -> $($MyInvocation.MyCommand.Name) : The Message parameter is mandatory.")
    );
    Write-Message -Message $Message -Stream Error -ForegroundColor Red -BackgroundColor Black;
}
function Format-Output {
    [CmdletBinding()]
    param(
        [hashtable]
        $Output,
        [ValidateSet(
            "JSON",
            "PSCustomObject",
            "Hashtable",
            "Null"
        )]
        [string]
        $Type = "PSCustomObject"
    );
    if($Type -eq "PSCustomObject") {
        Write-Output -InputObject $([pscustomobject]$Output);
    } elseif($Type -eq "JSON") {
        Write-Output -InputObject $(ConvertTo-Json -Depth 10 -InputObject $Output);
    } elseif($Type -eq "Hashtable") {
        Write-Output -InputObject $Output;
    }
}
$Output = @{};
if($CandySystem -eq "Execute") {
    Write-Message -Message "Execute!";
} elseif($CandySystem -eq "Version") {
    $ExitCode = 0;
    Write-Line -Message "Version" -LineForegroundColor DarkCyan -MessageForegroundColor Cyan;
    Write-Message;
    Write-Line -Message "$Major.$Minor.$Build" -Line " " -Corner " ";
    Write-Message;
    Write-Line -LineForegroundColor DarkCyan;
    $Output.Add("Major",$Major);
    $Output.Add("Minor",$Minor);
    $Output.Add("Build",$Build);
} elseif($CandySystem -eq "Github") {
    $ExitCode = 0;
    Write-Line -Message "Github" -LineForegroundColor DarkCyan -MessageForegroundColor Cyan;
    Write-Message;
    Write-Line -Message $GithubRepository -Line " " -Corner " ";
    Write-Message;
    Write-Line -LineForegroundColor DarkCyan;
    $Output.Add("GithubRepository",$GithubRepository);
} else {
    Write-ErrorMessage -Message "The CandySystem[$($CandySystem)] is not implemented.";
}
$Output.Add("ExitCode", $ExitCode); 
Write-Output -InputObject $(Format-Output -Type $Type -Output $Output);
if(-not $NoExit) {
    exit $ExitCode;
}
