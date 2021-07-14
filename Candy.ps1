#Requires -Version 7.1.3
[CmdletBinding()]
param(
    [switch]
    $NoColor,
    [Alias(
        "Quiet",
        "Hide"
    )]
    [switch]
    $Silent
);
$ErrorActionPreference = "stop";
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
        [Alias(
            "Mode"
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
        $Message = "",
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
        [Alias(
            "Mode"
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
    }
}
