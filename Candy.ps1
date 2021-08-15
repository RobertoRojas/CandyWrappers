#!/usr/bin/pwsh
#Requires -Version 7.1.3
[CmdletBinding()]
param(
    [Alias(
        "Wrapper",
        "JSON",
        "JSONs"
    )]
    [ValidateNotNullOrEmpty()]
    [System.Object[]]
    $Wrappers = $null,
    [ValidateNotNull()]
    [string[]]
    $Include = @(),
    [ValidateNotNull()]
    [string[]]
    $Exclude = @(),
    [Alias(
        "System"
    )]
    [ValidateSet(
        "Execute",
        "Version",
        "Github"
    )]
    [string]
    $CandySystem = "Execute",
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
    [ValidateRange(0, [int]::MaxValue)]
    [int]
    $Major = 1,
    [ValidateRange(0, [int]::MaxValue)]
    [int]
    $Minor = 0,
    [ValidateRange(0, [int]::MaxValue)]
    [int]
    $Build = 0,
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
$CandyVersion = "1.0.0";
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
    Write-Message -Message $Message -Stream Error -ForegroundColor Red;
}
function Write-VerboseMessage {
    [CmdletBinding()]
    param(
        [ValidateNotNullOrEmpty()]
        [string]
        $Message = $(throw "$($Invocation.MyCommand.Name) -> $($MyInvocation.MyCommand.Name) : The Message parameter is mandatory.")
    );
    if($Silent) {
        return;
    }
    write-Verbose -Message $Message;
}
function Write-DebugMessage {
    [CmdletBinding()]
    param(
        [ValidateNotNullOrEmpty()]
        [string]
        $Message = $(throw "$($Invocation.MyCommand.Name) -> $($MyInvocation.MyCommand.Name) : The Message parameter is mandatory.")
    );
    if($Silent) {
        return;
    }
    Write-Debug -Message $Message;
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
    $SelectedVersion = "$Major.$Minor.$Build";
    $Configuration = @{
        Wrapper = @{
            Execution = Join-Path -Path $(Get-Location).Path -ChildPath ".candy" -AdditionalChildPath "wrappers","wrapper.json";
            Program = Join-Path -Path $PSScriptRoot -ChildPath ".candy" -AdditionalChildPath "wrappers","wrapper.json";
            Schema = Join-Path -Path $PSScriptRoot -ChildPath ".schemas" -AdditionalChildPath "json",$SelectedVersion,"wrapper.schema.json";
        };
    }
    if($null -eq $Wrappers) {
        if(Test-Path -LiteralPath $Configuration['Wrapper']['Execution']) {
            $Wrappers = @($Configuration['Wrapper']['Execution']);
        } elseif (Test-Path -LiteralPath $Configuration['Wrapper']['Program']) {
            $Wrappers = @($Configuration['Wrapper']['Program']);
        } else {
            throw "$($MyInvocation.Command) : Cannot find any wrapper to execute.";
        }
    }
    Write-Line -Message "Candy Wrappers" -LineForegroundColor DarkCyan -MessageForegroundColor Cyan;
    Write-Message;
    Write-Message -Message "Candy     : " -NoNewLine -ForegroundColor DarkCyan;
    Write-Message -Message $CandyVersion -ForegroundColor Cyan;
    Write-Message -Message "Wrapper   : " -NoNewLine -ForegroundColor DarkCyan;
    Write-Message -Message $SelectedVersion -ForegroundColor Cyan;
    Write-Message -Message "Execution : " -NoNewLine -ForegroundColor DarkCyan;
    Write-Message -Message $(Get-Location).Path -ForegroundColor Cyan;
    Write-Message -Message "Script    : " -NoNewLine -ForegroundColor DarkCyan;
    Write-Message -Message $PSScriptRoot -ForegroundColor Cyan;
    Write-Message;
    Write-Line -Message "Wrappers" -LineForegroundColor DarkCyan -MessageForegroundColor Cyan;
    Write-Message;
    if(-not (Test-Path -LiteralPath $Configuration['Wrapper']['Schema'])) {
        $ExitCode = 1;
        Write-ErrorMessage -Message "Cannot find the schema path[$($Configuration['Wrapper']['Schema'])]";
        Write-Message;
        Write-Line -LineForegroundColor DarkCyan;
    } else {
        $Tasks = [System.Collections.ArrayList]::new();
        for ($i = 0; $i -lt $Wrappers.Count; $i++) {
            $Wrapper = $Wrappers[$i];
            if($Wrapper -is [hashtable]) {
                if($null -eq $Wrapper['Path']) {
                    Write-ErrorMessage -Message "The wrapper[$i] property path is mandatory";
                    $Tasks.Clear();
                    break;
                }
                $Task = @{
                    Path = $Wrapper['Path'];
                    Include = $Wrapper['Include'] + $Include;
                    Exclude = $Wrapper['Exclude'] + $Exclude;
                };
            } elseif ($Wrapper -is [string]) {
                $Task = @{
                    Path = $Wrapper;
                    Include = $Include;
                    Exclude = $Exclude;
                };
            } else {
                Write-ErrorMessage -Message "The wrapper element[$i] is not a valid type[$($Wrapper.GetType().Name)]";
                $Tasks.Clear();
                break;
            }
            if(-not (Test-Path -LiteralPath $Task['Path'])) {
                Write-ErrorMessage -Message "The wrapper path[$()] doesn't exist";
                $Tasks.Clear();
                break;
            }
            $WrapperJSON = Get-Content -LiteralPath $Task['Path'] | Out-String;
            try {
                Test-Json -Json $WrapperJSON -SchemaFile $Configuration['Wrapper']['Schema'] | Out-Null;
            } catch {
                Write-ErrorMessage -Message $_.Exception.Message;
                Write-VerboseMessage -Message $_.ErrorDetails.Message;
                $Tasks.Clear();
                break;
            }
            $(ConvertFrom-Json -InputObject $WrapperJSON -Depth 10 -AsHashtable)['wrappers'] | ForEach-Object -Process {
                $ID = $_['id'];
                $IncludeTask = $true;
                foreach($ExcludeID in $Task['exclude']) {
                    if($ID -like $ExcludeID) {
                        Write-VerboseMessage -Message "Exclude task[$ID]";
                        $IncludeTask = $false;
                        break;
                    }
                }
                foreach($IncludeID in $Task['include']) {
                    Write-Host $IncludeID
                    if($ID -like $IncludeID) {
                        Write-VerboseMessage -Message "Include task[$ID]";
                        $IncludeTask = $true;
                        break;
                    }
                }
                if($IncludeTask) {
                    Write-Line -Message $_['id'] -MessageForegroundColor Magenta -Corner " " -Line " ";
                    [void]$tasks.Add($_);
                }
            }
        }
        if($i -eq $Wrappers.Count -and $tasks.Count -eq 0) {
            Write-ErrorMessage -Message "Nothing to execute";
        }
        Write-Message;
        if($Tasks.Count -eq 0) {
            Write-Line -LineForegroundColor DarkCyan;
            $ExitCode = 1;
        }  else {
            Write-Line -Message "To do" -LineForegroundColor DarkCyan -MessageForegroundColor Cyan;
        }
    }
} elseif($CandySystem -eq "Version") {
    $ExitCode = 0;
    Write-Line -Message "Version" -LineForegroundColor DarkCyan -MessageForegroundColor Cyan;
    Write-Message;
    Write-Line -Message $CandyVersion -Line " " -Corner " " -MessageForegroundColor Green;
    Write-Message;
    Write-Line -LineForegroundColor DarkCyan;
    $Output.Add("Version",$CandyVersion);
} elseif($CandySystem -eq "Github") {
    $ExitCode = 0;
    Write-Line -Message "Github" -LineForegroundColor DarkCyan -MessageForegroundColor Cyan;
    Write-Message;
    Write-Line -Message $GithubRepository -Line " " -Corner " " -MessageForegroundColor Green;
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
