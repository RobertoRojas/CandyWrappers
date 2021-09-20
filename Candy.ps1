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
    [ValidateSet(
        "break",
        "ignore",
        "silent_ignore"
    )]
    [string]
    $OnError = "break",
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
    $Silent,
    [switch]
    $NoInteractive,
    [switch]
    $NoBreak
);
$ErrorActionPreference = "stop";
$Invocation = $MyInvocation;
$CandyVersion = "1.0.0";
$GithubRepository = "https://github.com/RobertoRojas/CandyWrappers";
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
        $Stream = "Output",
        [switch]
        $NoDisplay
    );
    if($Silent -or $NoDisplay) {
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
                $Parameters["ForegroundColor"]  = $MessageForegroundColor;
            }
            if($MessageBackgroundColor) {
                $Parameters["BackgroundColor"] = $MessageBackgroundColor;
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
                $CornerParameter["ForegroundColor"] = $LineForegroundColor;
                $LineParameter["ForegroundColor"] = $LineForegroundColor;
            }
            if($LineBackgroundColor) {
                $CornerParameter["BackgroundColor"] = $LineBackgroundColor;
                $LineParameter["BackgroundColor"] = $LineBackgroundColor;
            }
            if($MessageForegroundColor) {
                $MessageParameter["ForegroundColor"] = $MessageForegroundColor;
            }
            if($MessageBackgroundColor) {
                $MessageParameter["BackgroundColor"] = $MessageBackgroundColor;
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
        $NoNewLine,
        [switch]
        $NoDisplay
    );
    if($Silent -or $NoDisplay) {
        return;
    }
    $Parameters = @{
        Object = $Message;
        NoNewLine = $true;
    };
    if(-not $NoColor) {
        if($ForegroundColor) {
            $Parameters["ForegroundColor"] = $ForegroundColor;
        }
        if($BackgroundColor) {
            $Parameters["BackgroundColor"] = $BackgroundColor;
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
        [System.Console]::Error.Write($Message);
        if(-not $NoColor) {
            [System.Console]::ResetColor();
        }
    }
    if($NoNewLine -eq $false) {
        Write-Host;
    }
}
function Write-ErrorMessage {
    [CmdletBinding()]
    param(
        [ValidateNotNullOrEmpty()]
        [string]
        $Message = $(throw "$($Invocation.MyCommand.Name) -> $($MyInvocation.MyCommand.Name) : The Message parameter is mandatory."),
        [switch]
        $NoDisplay
    );
    if($Silent -or $NoDisplay) {
        return;
    }
    Write-Message -Message $Message -Stream Error -ForegroundColor Red -BackgroundColor Black;
}
function Write-VerboseMessage {
    [CmdletBinding()]
    param(
        [ValidateNotNullOrEmpty()]
        [string]
        $Message = $(throw "$($Invocation.MyCommand.Name) -> $($MyInvocation.MyCommand.Name) : The Message parameter is mandatory."),
        [switch]
        $NoDisplay
    );
    if($Silent -or $NoDisplay) {
        return;
    }
    write-Verbose -Message $Message;
}
function Write-DebugMessage {
    [CmdletBinding()]
    param(
        [ValidateNotNullOrEmpty()]
        [string]
        $Message = $(throw "$($Invocation.MyCommand.Name) -> $($MyInvocation.MyCommand.Name) : The Message parameter is mandatory."),
        [switch]
        $NoDisplay
    );
    if($Silent -or $NoDisplay) {
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
$ExitCode = -1;
$Output = @{};
if($CandySystem -eq "Execute") {
    $SelectedVersion = "$Major.$Minor.$Build";
    $Configuration = @{
        Wrapper = @{
            Execution = Join-Path -Path $(Get-Location).Path -ChildPath ".candy" -AdditionalChildPath @("wrappers","wrapper.json");
            Program = Join-Path -Path $PSScriptRoot -ChildPath ".candy" -AdditionalChildPath @("wrappers","wrapper.json");
            Schema = Join-Path -Path $PSScriptRoot -ChildPath ".schemas" -AdditionalChildPath @("json",$SelectedVersion,"wrapper.schema.json");
        };
        Tasks = @{
            Script = Join-Path -Path $PSScriptRoot -ChildPath ".tools" -AdditionalChildPath @("tasks",$SelectedVersion,"Tasks.ps1");
        };
        Modules = @{
            Script = Join-Path -Path $PSScriptRoot -ChildPath ".tools" -AdditionalChildPath @("modules",$SelectedVersion,"Modules.ps1");
        }
    }
    try {
        Write-Line -Message "Candy Wrappers" -LineForegroundColor DarkCyan -MessageForegroundColor Cyan;
        Write-Message;
        if($null -eq $Wrappers) {
            if(Test-Path -LiteralPath $Configuration['Wrapper']['Execution']) {
                $Wrappers = @($Configuration['Wrapper']['Execution']);
            } elseif (Test-Path -LiteralPath $Configuration['Wrapper']['Program']) {
                $Wrappers = @($Configuration['Wrapper']['Program']);
            } else {
                throw "$($Invocation.MyCommand.Name) : Cannot find any wrapper to execute.";
            }
        }
        Write-Message -Message "Candy     : " -NoNewLine -ForegroundColor DarkCyan;
        Write-Message -Message $CandyVersion -ForegroundColor Cyan;
        Write-Message -Message "Wrapper   : " -NoNewLine -ForegroundColor DarkCyan;
        Write-Message -Message $SelectedVersion -ForegroundColor Cyan;
        Write-Message -Message "Execution : " -NoNewLine -ForegroundColor DarkCyan;
        Write-Message -Message $(Get-Location).Path -ForegroundColor Cyan;
        Write-Message -Message "Script    : " -NoNewLine -ForegroundColor DarkCyan;
        Write-Message -Message $PSScriptRoot -ForegroundColor Cyan;
        Write-Message;
        Write-Line -Message "Import modules" -LineForegroundColor DarkCyan -MessageForegroundColor Cyan;
        Write-Message;
        if(-not (Test-Path -LiteralPath $Configuration['Modules']['Script'])) {
            throw "$($Invocation.MyCommand.Name) : Cannot find the modules[$($Configuration['Modules']['Script'])] file to import the modules list.";
        }
        $ModulesList = [System.Collections.ArrayList]::new();
        foreach($Module in $(. $Configuration['Modules']['Script'])) {
            $ModuleVersion = $(Import-PowerShellDataFile -Path $Module).ModuleVersion;
            $ModuleName = $(Import-Module -Force -Name $Module -PassThru).Name;
            Write-Line -Message "$ModuleName($ModuleVersion)" -MessageForegroundColor Magenta -Corner " " -Line " ";
            [void]$ModulesList.Add(@{
                Name = $ModuleName;
                Path = $Module;
                Version = $ModuleVersion;
            });
        }
        Write-Message;
        Write-Line -Message "Wrappers" -LineForegroundColor DarkCyan -MessageForegroundColor Cyan;
        Write-Message;
        if(-not (Test-Path -LiteralPath $Configuration['Wrapper']['Schema'])) {
            throw "$($Invocation.MyCommand.Name) : Cannot find the schema path[$($Configuration['Wrapper']['Schema'])]";
        }
        $Tasks = [System.Collections.ArrayList]::new();
        for ($i = 0; $i -lt $Wrappers.Count; $i++) {
            $Wrapper = $Wrappers[$i];
            if($Wrapper -is [hashtable]) {
                if($null -eq $Wrapper['Path']) {
                    throw "$($Invocation.MyCommand.Name) : The wrapper[$i] property path is mandatory";
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
                throw "$($Invocation.MyCommand.Name) : The wrapper element[$i] is not a valid type[$($Wrapper.GetType().Name)]";
            }
            if(-not (Test-Path -LiteralPath $Task['Path'])) {
                throw "$($Invocation.MyCommand.Name) : The wrapper path[$()] doesn't exist";
            }
            $WrapperJSON = Get-Content -LiteralPath $Task['Path'] | Out-String;
            try {
                Test-Json -Json $WrapperJSON -SchemaFile $Configuration['Wrapper']['Schema'] | Out-Null;
            } catch {
                Write-VerboseMessage -Message $_.ErrorDetails.Message;
                throw $_.Exception.Message;
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
                    if($ID -like $IncludeID) {
                        Write-VerboseMessage -Message "Include task[$ID]";
                        $IncludeTask = $true;
                        break;
                    } else {
                        $IncludeTask = $false;
                    }
                }
                if($IncludeTask) {
                    Write-Line -Message $_['id'] -MessageForegroundColor Magenta -Corner " " -Line " ";
                    [void]$Tasks.Add($_);
                }
            }
        }
        Write-Message;
        Write-Line -Message "Execution" -LineForegroundColor DarkCyan -MessageForegroundColor Cyan;
        if(-not (Test-Path -LiteralPath $Configuration['Tasks']['Script'])) {
            throw "$($Invocation.MyCommand.Name) : Cannot find the task[$($Configuration['Tasks']['Script'])] file to import the wrappers.";
        }
        $TasksImplementation =  . $Configuration['Tasks']['Script'];
        $TasksExecution = @{};
        $AllIgnored = $true;
        for ($i = 0; $i -lt $Tasks.Count; $i++) {
            $Break = $false;
            $Task = $Tasks[$i];
            $TaskExecution = $TasksImplementation[$Task['task']];
            if($Task['ignore'] -eq $true) {
                continue;
            }
            if($Task['dependof']) {
                $DependencyTask = $TasksExecution[$Task['dependof']['id']];
                $DependencyValue = $Task['dependof']['success'] ?? $true;
                if($null -ne $DependencyTask -and $DependencyTask -eq $DependencyValue) {
                    Write-VerboseMessage -Message "`nThe dependency[$($Task['dependof']['id'])] of the wrapper[$($Task['id'])] is correct.";
                } else {
                    Write-VerboseMessage -Message "Ignored wrapper because the dependency had a wrong value or it was not executed.";
                    continue;
                }
            }
            $AllIgnored = $false;
            $NoNewScope = $Task['nonewscope'] ?? $false -or @("cw_break") -contains $Task['task'];
            Write-Message;
            Write-Line -Message "$($Task['task'])[$($Task['id'])]" -Line "." -Corner "*" -LineForegroundColor DarkYellow -MessageForegroundColor Yellow;
            Write-Message;
            Write-VerboseMessage -Message "index: $i";
            Write-VerboseMessage -Message "NoNewScope: $NoNewScope";
            if($null -eq $TaskExecution) {
                $ExitCode = 2;
                Write-ErrorMessage -Message "The task[$($Task['task'])] doesn't exist in the selected version[$SelectedVersion]";
                break;
            }
            $Response = Invoke-Command -NoNewScope:$NoNewScope -ScriptBlock $TaskExecution -ArgumentList $Task;
            $ExitCode = 0;
            $TasksExecution[$Task['id']] = $Response['Success'];
            if($Response['Success'] -eq $true) {
                $ExitCode = 0;
            } else {
                $ErrorAction = $Task['onerror'] ?? $OnError;
                if($ErrorAction -eq "ignore" -or $ErrorAction -eq "silent_ignore"){
                    Write-ErrorMessage -Message "`nError in the wrapper[$($Task['task'])] was ignored." -NoDisplay:$($ErrorAction -eq "silent_ignore");
                } else {
                    $ExitCode = 2;
                    $Response['Break'] = $true;
                }
            }
            if($Response['Break'] -eq $true) {
                break;
            }
        }
        Write-Message;
        Write-Line -Message "Result" -LineForegroundColor DarkCyan -MessageForegroundColor Cyan;
        Write-Message;
        if($AllIgnored) {
            Write-Line -Message "Nothing executed" -Line " " -Corner " " -MessageForegroundColor Gray;
        } elseif($ExitCode -eq 0) {
            Write-Line -Message "Success" -Line " " -Corner " " -MessageForegroundColor Green;
        } else {
            Write-Line -Message "Failure" -Line " " -Corner " " -MessageForegroundColor Red;
        }
        Write-Message;
    } catch {
        Write-Message;
        Write-ErrorMessage -Message $_.Exception.Message;
        Write-Message;
        $ExitCode = 2;
    } finally {
        if($null -ne $ModulesList) {
            Write-Line -Message "Remove modules" -LineForegroundColor DarkCyan -MessageForegroundColor Cyan;
            Write-Message;
            foreach ($Module in $ModulesList) {
                $ModuleName = $Module['Name'];
                $ModuleVersion = $Module['Version'];
                Write-Line -Message "$ModuleName($ModuleVersion)" -MessageForegroundColor Magenta -Corner " " -Line " ";
                Remove-Module -Force -Name $Module['Name'];
            }
            Write-Message;
        }
        Write-Line -LineForegroundColor DarkCyan;
    }
} elseif($CandySystem -eq "Version") {
    $ExitCode = 0;
    Write-Line -Message "Version" -LineForegroundColor DarkCyan -MessageForegroundColor Cyan;
    Write-Message;
    Write-Line -Message $CandyVersion -Line " " -Corner " " -MessageForegroundColor Green;
    Write-Message;
    Write-Line -LineForegroundColor DarkCyan;
    $Output["Version"] = $CandyVersion;
} elseif($CandySystem -eq "Github") {
    $ExitCode = 0;
    Write-Line -Message "Github" -LineForegroundColor DarkCyan -MessageForegroundColor Cyan;
    Write-Message;
    Write-Line -Message $GithubRepository -Line " " -Corner " " -MessageForegroundColor Green;
    Write-Message;
    Write-Line -LineForegroundColor DarkCyan;
    $Output["GithubRepository"] = $GithubRepository;
} else {
    Write-ErrorMessage -Message "The CandySystem[$($CandySystem)] is not implemented.";
}
$Output["ExitCode"] = $ExitCode; 
Write-Output -InputObject $(Format-Output -Type $Type -Output $Output);
if(-not $NoExit) {
    exit $ExitCode;
}
