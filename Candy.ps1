#!/usr/bin/env pwsh
#Requires -Version 7.1.3
[CmdletBinding()]
param(
    [Alias(
        "Wrapper",
        "JSON",
        "JSONs"
    )]
    [System.Object[]]
    $Wrappers = $null,
    [ValidateNotNull()]
    [string[]]
    $Include = @(),
    [ValidateNotNull()]
    [string[]]
    $Exclude = @(),
    [ValidateNotNullOrEmpty()]
    [string]
    $Macro = "",
    [Alias(
        "System"
    )]
    [ValidateSet(
        "Execute",
        "Repositories",
        "Validate",
        "Version"
    )]
    [string]
    $CandySystem = "Execute",
    [Alias(
        "Mode",
        "ControlMode"
    )]
    [string]
    $Control = "",
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
    $Compress,
    [switch]
    $JoinStreams,
    [switch]
    $KeepEvents,
    [switch]
    $KeepModules,
    [switch]
    $Log,
    [switch]
    $NoBreak,
    [switch]
    $NoColor,
    [switch]
    $NoExit,
    [switch]
    $NoInteractive,
    [switch]
    $NoLastExitCode,
    [switch]
    $NoLogFile,
    [Alias(
        "Quiet",
        "Hide",
        "Mute"
    )]
    [switch]
    $Silent,
    [switch]
    $SuccessAtCtrlC
);
$ErrorActionPreference = "stop";
$Invocation = $MyInvocation;
$CandyVersion = "1.0.0";
$SelectedVersion = "$Major.$Minor.$Build";
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
            'message' = $Object;
            'Stream' = $Stream;
        }
        if(-not $NoColor) {
            if($MessageForegroundColor) {
                $Parameters['ForegroundColor']  = $MessageForegroundColor;
            }
            if($MessageBackgroundColor) {
                $Parameters['BackgroundColor'] = $MessageBackgroundColor;
            }
        }
        Write-Message @Parameters;
    } else {
        $CornerParameter = @{
            'message' = $Corner;
            'Stream' = $Stream;
            'NoNewline' = $true;
        };
        $LineParameter = @{
            'message' = $Line;
            'Stream' = $Stream;
            'NoNewline' = $true;
        };
        $MessageParameter = @{
            'message' = $Message;
            'Stream' = $Stream;
            'NoNewline' = $true;
        };
        if(-not $NoColor) { 
            if($LineForegroundColor) {
                $CornerParameter['ForegroundColor'] = $LineForegroundColor;
                $LineParameter['ForegroundColor'] = $LineForegroundColor;
            }
            if($LineBackgroundColor) {
                $CornerParameter['BackgroundColor'] = $LineBackgroundColor;
                $LineParameter['BackgroundColor'] = $LineBackgroundColor;
            }
            if($MessageForegroundColor) {
                $MessageParameter['ForegroundColor'] = $MessageForegroundColor;
            }
            if($MessageBackgroundColor) {
                $MessageParameter['BackgroundColor'] = $MessageBackgroundColor;
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
        'Object' = $Message;
        'NoNewLine' = $true;
    };
    if(-not $NoColor) {
        if($ForegroundColor) {
            $Parameters['ForegroundColor'] = $ForegroundColor;
        }
        if($BackgroundColor) {
            $Parameters['BackgroundColor'] = $BackgroundColor;
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
        $Message = $(throw "$($Invocation.MyCommand.Name) -> $($MyInvocation.MyCommand.Name) : The Message parameter is mandatory"),
        [switch]
        $NoDisplay
    );
    if($Silent -or $NoDisplay) {
        return;
    }
    Write-Message -Message $Message -Stream $($JoinStreams ? "Output" : "Error") -ForegroundColor Red -BackgroundColor Black;
}
function Write-VerboseMessage {
    [CmdletBinding()]
    param(
        [ValidateNotNullOrEmpty()]
        [string]
        $Message = $(throw "$($Invocation.MyCommand.Name) -> $($MyInvocation.MyCommand.Name) : The Message parameter is mandatory"),
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
        $Message = $(throw "$($Invocation.MyCommand.Name) -> $($MyInvocation.MyCommand.Name) : The Message parameter is mandatory"),
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
        Write-Output -InputObject $(ConvertTo-Json -Depth 10 -Compress:$Compress -InputObject $Output);
    } elseif($Type -eq "Hashtable") {
        Write-Output -InputObject $Output;
    }
}
function ConvertFrom-Buffer {
    [CmdletBinding()]
    param (
        [ValidateNotNull()]
        [string]
        $Value
    );
    if($Value -match "^.*({\s*[a-zA-Z0-9_\-\/\\]+([.]\w+)+\s*}).*$") {
        $Groups = [System.Collections.ArrayList]::new();
        Select-String -Pattern "({\s*[a-zA-Z0-9_\-\/\\]+([.]\w+)+\s*})" -InputObject $Value -AllMatches
            | Select-Object -ExpandProperty Matches
            | Select-Object -ExpandProperty Captures
            | Select-Object -ExpandProperty value
            | ForEach-Object -Process {
                $New = $Buffers;
                foreach($Item in $($_ -replace "{|}" -split "[.]")) {
                    $New = $New[$Item];
                }
                if($null -eq $New) {
                    $New = $_;
                }
                [void]$Groups.Add(@{
                    'Old' = $_;
                    'New' = [System.String]$New;
                });
            };
        foreach ($Group in $Groups) {
            $Value = $Value -replace $Group['Old'],$Group['New'];
        }
    }
    Write-Output -InputObject $Value;
}
function Exit-CandyWrappers {
    [CmdletBinding()]
    param ();
    $RegisterObjectsEvents = Get-EventSubscriber | Where-Object -FilterScript {$_.SourceIdentifier -like "cw/control/*"};
    if($RegisterObjectsEvents -and -not $KeepEvents) {
        Write-Message;
        Write-Line -Message "Remove events" -LineForegroundColor DarkCyan -MessageForegroundColor Cyan;
        Write-Message;
        foreach($ObjectEvent in $RegisterObjectsEvents) {
            $Identifier = $ObjectEvent.SourceIdentifier;
            Unregister-Event -SourceIdentifier $Identifier;
            Write-Line -Message $Identifier -Line " " -Corner " " -MessageForegroundColor Magenta;
        }
    }
    $Output['exitcode'] = $Output['exitcode'] ?? 1;
    if($NoLastExitCode) {
        foreach ($Execution in $Output['history']) {
            if($Execution['exitcode'] -ne 0) {
                $Output['exitcode'] = 1;
                break;
            }
        }
    }
    if($Log -and -not $NoLogFile) {
        $LogDirectory = "./.candy/logs";
        $LogFile = "$LogDirectory/$($(Get-Date).ToFileTime())";
        if(-not (Test-Path -LiteralPath $LogDirectory)) {
            New-Item -ItemType Directory -Path $LogDirectory | Out-Null;
        }
        Write-Message;
        Write-Line -Message "Log" -LineForegroundColor DarkCyan -MessageForegroundColor Cyan;
        Write-Message;
        Write-Line -Message $LogFile -Line " " -Corner " " -MessageForegroundColor Magenta;
        Out-File -FilePath $LogFile -Encoding utf8 -InputObject $(Format-Output -Type JSON -Output $Output);
    }
    Write-Message;
    Write-Line -Message "Result of execution" -LineForegroundColor DarkCyan -MessageForegroundColor Cyan;
    Write-Message;
    if($Output['exitcode'] -eq 0) {
        Write-Line -Message "Success" -Line " " -Corner " " -MessageForegroundColor Green;
    } else {
        Write-Line -Message "Failure" -Line " " -Corner " " -MessageForegroundColor Red;
    }
    Write-Message;
    Write-Line -LineForegroundColor DarkCyan;
    Write-Output -InputObject $(Format-Output -Type $Type -Output $Output);
    if(-not $NoExit) {
        exit $ExitCode;
    }
}
function Write-Note {
    [CmdletBinding()]
    param (
        [string]
        $Note = $null,
        [ValidateSet(
            "control_pause",
            "control_break",
            "wrapper_pause",
            "undefined"
        )]
        [string]
        $Type = "undefined"
    );
    if(-not $Note) {
        return;
    }
    if($null -eq $Output['notes']) {
        $Output['notes'] = @();
    }
    $Output['notes'] += @{
        'datetime' = $(Get-Date -Format "O");
        'type' = $Type;
        'note' = ConvertFrom-Buffer -Value $Note;
    };
}
$Configuration = @{
    'Wrapper' = @{
        'Execution' = Join-Path -Path $(Get-Location).Path -ChildPath ".candy" -AdditionalChildPath @("wrappers");
        'Program' = Join-Path -Path $PSScriptRoot -ChildPath ".candy" -AdditionalChildPath @("wrappers");
        'Schema' = Join-Path -Path $PSScriptRoot -ChildPath ".schemas" -AdditionalChildPath @("wrappers",$SelectedVersion,"wrapper.schema.json");
        'SchemaGeneral' = Join-Path -Path $PSScriptRoot -ChildPath ".schemas" -AdditionalChildPath @("wrappers",$SelectedVersion,"wrapper.general.schema.json");
    };
    'Tasks' = @{
        'Script' = Join-Path -Path $PSScriptRoot -ChildPath ".tools" -AdditionalChildPath @("tasks",$SelectedVersion,"Tasks.ps1");
    };
    'Modules' = @{
        'Script' = Join-Path -Path $PSScriptRoot -ChildPath ".tools" -AdditionalChildPath @("modules",$SelectedVersion,"Modules.ps1");
    };
    'Selector' = @{
        'Script' = Join-Path -Path $PSScriptRoot -ChildPath ".tools" -AdditionalChildPath @("tasks","selector","selector.ps1");
    };
    'Control' = @{
        'Execution' = Join-Path -Path $(Get-Location).Path -ChildPath ".candy" -AdditionalChildPath @("control",$Control);
        'Program' = Join-Path -Path $PSScriptRoot -ChildPath ".candy" -AdditionalChildPath @("control",$Control);
        'Schema' = Join-Path -Path $PSScriptRoot -ChildPath ".schemas" -AdditionalChildPath @("control","control.schema.json");
        'commandspath' = Join-Path -Path $(Get-Location).Path -ChildPath ".candy" -AdditionalChildPath @("control","commands");
        'Default' = '{"mode":"once"}';
    };
    'Macro' = @{
        'Execution' = Join-Path -Path $(Get-Location).Path -ChildPath ".candy" -AdditionalChildPath @("macro",$Macro);
        'Program' = Join-Path -Path $PSScriptRoot -ChildPath ".candy" -AdditionalChildPath @("macro",$Macro);
        'Schema' = Join-Path -Path $PSScriptRoot -ChildPath ".schemas" -AdditionalChildPath @("macro","macro.schema.json");
    };
}
$Output = @{};
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
Write-Line -Message "Parameters" -LineForegroundColor DarkCyan -MessageForegroundColor Cyan;
Write-Message;
try {
    $Output['ctrl-c'] = $true;
    $Parameters = @{};
    foreach($Item in $Invocation.BoundParameters.GetEnumerator()) {
        $Parameters[$Item.Key] = @{
            'value' = $Item.Value;
            'type' = "parameter";
        };
    }
    if($Macro) {
        if(Test-Path -LiteralPath $Macro) {
            $Macro = Get-Content -Raw -LiteralPath $Macro;
        } elseif(Test-Path -LiteralPath $Configuration['Macro']['Execution']) {
            $Macro = Get-Content -Raw -LiteralPath $Configuration['Macro']['Execution'];
        } elseif(Test-Path -LiteralPath $Configuration['Macro']['Program']) {
            $Macro = Get-Content -Raw -LiteralPath $Configuration['Macro']['Program'];
        } else {
            throw "$($Invocation.MyCommand.Name) : Cannot find any macro with that path or name[$Macro]";
        }
        try {
            Test-Json -Json $Macro -SchemaFile $Configuration['Macro']['Schema'] | Out-Null;
        } catch {
            $ErrorDetails = $_.ErrorDetails.Message;
            if($ErrorDetails) {
                Write-ErrorMessage -Message "$ErrorDetails";
            }
            throw $_.Exception.Message;
        }
        foreach($Item in $(ConvertFrom-Json -AsHashtable -InputObject $Macro).GetEnumerator()) {
            if($Parameters.Contains($Item.Key)) {
                continue;
            }
            $Var = Get-Variable -Name $Item.Key;
            $Var.Value = $Item.Value;
            $Parameters[$Item.Key] = @{
                'value' = $Var.Value;
                'type' = "macro";
            };
        }
    }
    if($Parameters.Keys.Count -gt 0) {
        foreach($Key in $Parameters.Keys) {
            Write-Line -Message "-$($Key) $(ConvertTo-Json -Compress -InputObject $Parameters[$Key]['value'])" -Line " " `
                -Corner " " -MessageForegroundColor $($Parameters[$Key]['type'] -eq "macro" ? "Blue" : "Magenta");
        }
    } else {
        Write-Line -Message "Nothing to show" -Line " " -Corner " " -MessageForegroundColor DarkGray;
    }
    $Output['parameters'] = $Parameters;
    $Output['ctrl-c'] = $false;
} catch {
    Write-ErrorMessage -Message $_.Exception.Message;
    $Output['exitcode'] = 1;
    $Output['ctrl-c'] = $false;
} finally {
    if($Output['exitcode'] -eq 1 -or $Output['ctrl-c']) {
        Exit-CandyWrappers;
    }
}
Write-Message;
try {
    $Output['ctrl-c'] = $true;
    Write-Line -Message "Control" -LineForegroundColor DarkCyan -MessageForegroundColor Cyan;
    Write-Message;
    if($Control) {
        if(Test-Path -LiteralPath $Control) {
            $Control = Get-Content -Raw -LiteralPath $Control;
        } elseif(Test-Path -LiteralPath $Configuration['Control']['Execution']) {
            $Control = Get-Content -Raw -LiteralPath $Configuration['Control']['Execution'];
        } elseif(Test-Path -LiteralPath $Configuration['Control']['Program']) {
            $Control = Get-Content -Raw -LiteralPath $Configuration['Control']['Program'];
        } else {
            throw "$($Invocation.MyCommand.Name) : Cannot find any Control with that path or name[$Macro]";
        }
    } else {
        $Control = $Configuration['Control']['Default'];
    }
    try {
        Test-Json -Json $Control -SchemaFile $Configuration['Control']['Schema'] | Out-Null;
    } catch {
        $ErrorDetails = $_.ErrorDetails.Message;
        if($ErrorDetails) {
            Write-ErrorMessage -Message "$ErrorDetails";
        }
        throw $_.Exception.Message;
    }
    $ControlObject = ConvertFrom-Json -InputObject $Control -AsHashtable;
    $ControlObject['manual'] = $ControlObject['manual'] ?? $false;
    $ControlObject['delay'] = $ControlObject['delay'] ?? 0;
    $ControlObject['commandspath'] = $ControlObject['commandspath'] ?? $Configuration['Control']['commandspath']; 
    $ControlObject['commands'] = @{
        'break' = Join-Path -Path $ControlObject['commandspath'] -ChildPath "break";
        'pause' = Join-Path -Path $ControlObject['commandspath'] -ChildPath "pause";
        'note' = Join-Path -Path $ControlObject['commandspath'] -ChildPath "note";
        'event' = Join-Path -Path $ControlObject['commandspath'] -ChildPath "event";
    };
    $ControlObject['force'] = $ControlObject['force'] ?? $false; 
    Write-Message -Message "Mode      : " -NoNewLine -ForegroundColor DarkCyan;
    Write-Message -Message $ControlObject['mode'] -ForegroundColor Cyan;
    Write-Message -Message "Commands  : " -NoNewLine -ForegroundColor DarkCyan;
    Write-Message -Message $ControlObject['commandspath'] -ForegroundColor Cyan;
    Write-Message -Message "Delay     : " -NoNewLine -ForegroundColor DarkCyan;
    Write-Message -Message $ControlObject['delay'] -ForegroundColor Cyan;
    Write-Message -Message "Manual    : " -NoNewLine -ForegroundColor DarkCyan;
    Write-Message -Message $ControlObject['manual'] -ForegroundColor Cyan;
    Write-Message -Message "Force     : " -NoNewLine -ForegroundColor DarkCyan;
    Write-Message -Message $ControlObject['force'] -ForegroundColor Cyan;
    if($ControlObject['mode'] -eq "loop") {
        $ControlObject['repeat'] = $ControlObject['repeat'] ?? 0;
        Write-Message -Message "Repeat    : " -NoNewLine -ForegroundColor DarkCyan;
        Write-Message -Message $ControlObject['repeat'] -ForegroundColor Cyan;
        $ControlObject['counter'] = 0;
        $ControlScriptBlock = {
            [CmdletBinding()]
            param (
                [hashtable]
                $ControlObject = $(throw "$($Invocation.MyCommand.Name) : The you need to send the ControlObject")
            );
            $ControlObject['counter'] = $ControlObject['counter'] + 1;
            Write-Message;
            Write-Line -Message "Repeated $($ControlObject['counter']) of $($ControlObject['repeat'])" -Line " " -Corner " " -MessageForegroundColor White -MessageBackgroundColor Magenta -LineBackgroundColor Magenta;
            Write-Output -InputObject $($ControlObject['counter'] -lt $ControlObject['repeat']);
        };
    } elseif($ControlObject['mode'] -eq "infinite") {
        $ControlScriptBlock = {
            [CmdletBinding()]
            param (
                [hashtable]
                $ControlObject = $(throw "$($Invocation.MyCommand.Name) : The you need to send the ControlObject")
            );
            Write-Message;
            Write-Line -Message "Repeat again" -Line " " -Corner " " -MessageForegroundColor White -MessageBackgroundColor Magenta -LineBackgroundColor Magenta;
            Write-Output -InputObject $true;
        }
    } elseif ($ControlObject['mode'] -eq "file_system_watcher") {
        if($null -eq $ControlObject['paths']) {
            $ControlObject['paths'] = @(
                @{
                    'path' = $(Get-Location).Path;
                    'filter' = "*";
                }
            );
        }
        $Action = {
            if($Event.SourceEventArgs.FullPath -like "$($Event.MessageData.CommandsPath)/*") {
                return;
            }
            if(-not (Test-Path -LiteralPath $Event.MessageData.CommandsPath)) {
                New-Item -ItemType Directory -Path $Event.MessageData.CommandsPath | Out-Null;
            }
            if(-not (Test-Path -LiteralPath $Event.MessageData.EventPath)) {
                Out-File -FilePath $Event.MessageData.EventPath;
            }
        };
        $ActionObject = [PSCustomObject]@{
            'commandspath' = $ControlObject['commandspath'];
            'EventPath' = $ControlObject['commands']['event'];
            
        };
        Write-Message;
        Write-Line -Message "Control[Paths]" -Line "." -LineForegroundColor DarkCyan -MessageForegroundColor Cyan;
        Write-Message;
        for ($i = 0; $i -lt $ControlObject['paths'].Count; $i++) {
            $Path = $ControlObject['paths'][$i];
            if(-not $(Test-Path -LiteralPath $Path['path'])) {
                throw "$($Invocation.MyCommand.Name) : The path[$($Path['path'])] to watch doesn't exist";
            }
            $Path['filter'] = $Path['filter'] ?? "*";
            $Path['created'] = $Path['created'] ?? $true;
            $Path['changed'] = $Path['changed'] ?? $true;
            $Path['deleted'] = $Path['deleted'] ?? $true;
            $Path['renamed'] = $Path['renamed'] ?? $true;
            if(-not ($Path['created'] -or $Path['changed'] -or $Path['deleted'] -or $Path['renamed'])) {
                throw "$($Invocation.MyCommand.Name) : At least one event(created, changed, deleted or renamed) must be true";
            }
            $Path['subdirectories'] = $Path['subdirectories'] ?? $true;
            write-Verbose -Message "Subdirectories: $($Path['subdirectories'])";
            write-Verbose -Message "Created: $($Path['created'])";
            write-Verbose -Message "Changed: $($Path['changed'])";
            write-Verbose -Message "Deleted: $($Path['deleted'])";
            write-Verbose -Message "Renamed: $($Path['renamed'])";
            $Guid = "cw/control/$($(New-Guid).Guid)";
            Write-Line -Message "$($Path['path'])($($Path['filter'])) - $Guid" -Line " " -Corner " " -MessageForegroundColor Magenta;
            $Watcher = [System.IO.FileSystemWatcher]::new();
            $Watcher.Path = $Path['path'];
            $Watcher.Filter = $Path['filter'];
            $Watcher.IncludeSubdirectories = $Path['subdirectories'];
            $Watcher.EnableRaisingEvents = $true;
            if($Path['created']) {
                Register-ObjectEvent -EventName "Created" -Action $Action -InputObject $Watcher -SourceIdentifier "$Guid/created" -MessageData $ActionObject | Out-Null;
            }
            if($Path['changed']) {
                Register-ObjectEvent -EventName "Changed" -Action $Action -InputObject $Watcher -SourceIdentifier "$Guid/changed" -MessageData $ActionObject | Out-Null;
            }
            if($Path['deleted']) {
                Register-ObjectEvent -EventName "Deleted" -Action $Action -InputObject $Watcher -SourceIdentifier "$Guid/deleted" -MessageData $ActionObject | Out-Null;
            }
            if($Path['renamed']) {
                Register-ObjectEvent -EventName "Renamed" -Action $Action -InputObject $Watcher -SourceIdentifier "$Guid/renamed" -MessageData $ActionObject | Out-Null;
            }
        }
        $ControlScriptBlock = {
            [CmdletBinding()]
            param (
                [hashtable]
                $ControlObject = $(throw "$($Invocation.MyCommand.Name) : The you need to send the ControlObject")
            );
            Write-Message;
            Write-Line -Message "Waiting for event" -Line " " -Corner " " -MessageForegroundColor White -MessageBackgroundColor Magenta -LineBackgroundColor Magenta;
            $Waiting = $true;
            $EventTrigger = $true;
            while($Waiting) {
                if(Test-Path -LiteralPath $ControlObject['commands']['break']) {
                    $EventTrigger = $false;
                    Remove-Item -LiteralPath $ControlObject['commands']['break'] -Force | Out-Null;
                    break;
                }
                if(Test-Path -LiteralPath $ControlObject['commands']['event']) {
                    $Waiting = $false;
                }
                Start-Sleep -Milliseconds 100;
            }
            if(Test-Path -LiteralPath $ControlObject['commands']['event']) {
                Remove-Item -LiteralPath $ControlObject['commands']['event'] -Force | Out-Null;
            }
            Write-Output -InputObject $EventTrigger;
        };        
    } else {
        $ControlScriptBlock = {
            [CmdletBinding()]
            param (
                [hashtable]
                $ControlObject = $(throw "$($Invocation.MyCommand.Name) : The you need to send the ControlObject")
            );
            Write-Message;
            Write-Line -Message "Done" -Line " " -Corner " " -MessageForegroundColor White -MessageBackgroundColor Magenta -LineBackgroundColor Magenta;
            Write-Output -InputObject $false;
        }
    }
    $Output['control'] = $ControlObject;
    $Output['ctrl-c'] = $false;
} catch {
    Write-ErrorMessage -Message $_.Exception.Message;
    $Output['exitcode'] = 1;
    $Output['ctrl-c'] = $false;
} finally {
    if($Output['exitcode'] -eq 1 -or $Output['ctrl-c']) {
        Exit-CandyWrappers;
    }
}
$Working = $true;
$Output['history'] = @();
$Output['version'] = $CandyVersion;
$Output['selected'] = $SelectedVersion;
try {
    $Output['ctrl-c'] = $true;
    :working_loop do {
        if($CandySystem -eq "Execute") {
            try {
                if($null -eq $Wrappers -or $Wrappers.Count -eq 0) {
                    if(Test-Path -LiteralPath $(Join-Path -Path $Configuration['Wrapper']['Execution'] -ChildPath "wrapper.json")) {
                        $Wrappers = @(Join-Path -Path $Configuration['Wrapper']['Execution'] -ChildPath "wrapper.json");
                    } elseif (Test-Path -LiteralPath $(Join-Path -Path $Configuration['Wrapper']['Program'] -ChildPath "wrapper.json")) {
                        $Wrappers = @(Join-Path -Path $Configuration['Wrapper']['Program'] -ChildPath "wrapper.json");
                    } else {
                        throw "$($Invocation.MyCommand.Name) : Cannot find any wrapper to execute";
                    }
                }
                Write-Message;
                Write-Line -Message "Import modules" -LineForegroundColor DarkCyan -MessageForegroundColor Cyan;
                Write-Message;
                if(-not (Test-Path -LiteralPath $Configuration['Modules']['Script'])) {
                    throw "$($Invocation.MyCommand.Name) : Cannot find the modules[$($Configuration['Modules']['Script'])] file to import the modules list";
                }
                $ModulesList = [System.Collections.ArrayList]::new();
                foreach($Module in $(. $Configuration['Modules']['Script'])) {
                    $ModuleVersion = $(Import-PowerShellDataFile -Path $Module).ModuleVersion;
                    $ModuleName = $(Import-Module -Force -Name $Module -PassThru).Name;
                    Write-Line -Message "$ModuleName($ModuleVersion)" -MessageForegroundColor Magenta -Corner " " -Line " ";
                    [void]$ModulesList.Add(@{
                        'name' = $ModuleName;
                        'path' = $Module;
                        'version' = $ModuleVersion;
                    });
                }
                if($Log) {
                    $Output['modules'] = $ModulesList.ToArray();
                }
                Write-Message;
                Write-Line -Message "Wrappers" -LineForegroundColor DarkCyan -MessageForegroundColor Cyan;
                Write-Message;
                if(-not (Test-Path -LiteralPath $Configuration['Wrapper']['SchemaGeneral'])) {
                    throw "$($Invocation.MyCommand.Name) : Cannot find the General schema path[$($Configuration['Wrapper']['SchemaGeneral'])]";
                }
                if(-not (Test-Path -LiteralPath $Configuration['Wrapper']['Schema'])) {
                    throw "$($Invocation.MyCommand.Name) : Cannot find the schema path[$($Configuration['Wrapper']['Schema'])]";
                }
                $Output['wrappers'] = @();
                $Tasks = [System.Collections.ArrayList]::new();
                for ($i = 0; $i -lt $Wrappers.Count; $i++) {
                    $Wrapper = $Wrappers[$i];
                    if($Wrapper -is [hashtable]) {
                        if($null -eq $Wrapper['path']) {
                            throw "$($Invocation.MyCommand.Name) : The wrapper[$i] hash property path is mandatory";
                        }
                        $Task = @{
                            'path' = $Wrapper['path'];
                            'include' = $Wrapper['include'] + $Include;
                            'exclude' = $Wrapper['exclude'] + $Exclude;
                        };
                    } elseif ($Wrapper -is [string]) {
                        $Task = @{
                            'path' = $Wrapper;
                            'include' = $Include;
                            'exclude' = $Exclude;
                        };
                    } else {
                        throw "$($Invocation.MyCommand.Name) : The wrapper element[$i] is not a valid type[$($Wrapper.GetType().Name)]";
                    }
                    if(Test-Path -LiteralPath $Task['path']) {
                        $Task['path'] = $(Resolve-Path -LiteralPath $Task['path']).Path;
                    } elseif(Test-Path -LiteralPath $(Join-Path -Path $Configuration['Wrapper']['Execution'] -ChildPath $Task['path'])) {
                        $Task['path'] = $(Join-Path -Path $Configuration['Wrapper']['Execution'] -ChildPath $Task['path']);
                    } elseif(Test-Path -LiteralPath $(Join-Path -Path $Configuration['Wrapper']['Program'] -ChildPath $Task['path'])) {
                        $Task['path'] = $(Join-Path -Path $Configuration['Wrapper']['Program'] -ChildPath $Task['path']);
                    } else {
                        throw "$($Invocation.MyCommand.Name) : The wrapper path[$($Task['path'])] doesn't exist";
                    }
                    $Output['wrappers'] += $Task['path'];
                    $WrapperJSON = Get-Content -LiteralPath $Task['path'] -Raw;
                    try {
                        Test-Json -Json $WrapperJSON -SchemaFile $Configuration['Wrapper']['SchemaGeneral'] | Out-Null;
                    } catch {
                        $ErrorDetails = $_.ErrorDetails.Message;
                        if($ErrorDetails) {
                            Write-ErrorMessage -Message "$ErrorDetails";
                        }
                        throw $_.Exception.Message;
                    }
                    try {
                        Test-Json -Json $WrapperJSON -SchemaFile $Configuration['Wrapper']['Schema'] | Out-Null;
                    } catch {
                        $ErrorDetails = $_.ErrorDetails.Message;
                        if($ErrorDetails) {
                            Write-ErrorMessage -Message "$ErrorDetails";
                        }
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
                if($Log) {
                    $Output['tasks'] = $Tasks.ToArray();
                }
                Write-Message;
                Write-Line -Message "Execution" -LineForegroundColor DarkCyan -MessageForegroundColor Cyan;
                if(-not (Test-Path -LiteralPath $Configuration['Tasks']['Script'])) {
                    throw "$($Invocation.MyCommand.Name) : Cannot find the task[$($Configuration['Tasks']['Script'])] file to import the wrappers";
                }
                $TasksImplementation = . $Configuration['Tasks']['Script'];
                $TasksExecution = @{};
                $Buffers = @{};
                $AllIgnored = $true;
                if($Log) {
                    $Output['execution'] = @();
                }
                for ($i = 0; $i -lt $Tasks.Count; $i++) {
                    $Task = $Tasks[$i];
                    $TaskExecution = $TasksImplementation[$Task['task']];
                    if($Task['ignore'] -eq $true) {
                        continue;
                    }
                    if($Task['dependof']) {
                        $DependencyTask = $TasksExecution[$Task['dependof']['id']];
                        $DependencyValue = $Task['dependof']['success'] ?? $true;
                        if($null -ne $DependencyTask -and $DependencyTask -eq $DependencyValue) {
                            Write-VerboseMessage -Message "`nThe dependency[$($Task['dependof']['id'])] of the wrapper[$($Task['id'])] is correct";
                        } else {
                            Write-VerboseMessage -Message "Ignored wrapper because the dependency had a wrong value or it was not executed";
                            continue;
                        }
                    }
                    $AllIgnored = $false;
                    $NoNewScope = $Task['nonewscope'] ?? $false -or @("buffer_create","buffer_show","cw_break", "cw_pause") -contains $Task['task'];
                    Write-Message;
                    Write-Line -Message "$($Task['task'])[$($Task['id'])]" -Line "." -Corner "*" -LineForegroundColor DarkYellow -MessageForegroundColor Yellow;
                    Write-Message;
                    Write-VerboseMessage -Message "index: $i";
                    Write-VerboseMessage -Message "NoNewScope: $NoNewScope";
                    if($Task['version']) {
                        try {
                            $TaskExecution = . $Configuration['Selector']['Script'] -Wrapper $Task['task'] -Version $Task['version'];
                        } catch {
                            $Output['exitcode'] = 1;
                            Write-ErrorMessage -Message $_.Exception.Message;
                            break;
                        }
                    } elseif($null -eq $TaskExecution) {
                        $Output['exitcode'] = 1;
                        Write-ErrorMessage -Message "The task[$($Task['task'])] doesn't exist in the selected version[$SelectedVersion]";
                        break;
                    }
                    $Keys = [System.String[]]$Task.Keys;
                    for ($j = 0; $j -lt $Keys.Count; $j++) {
                        $Key = $Keys[$j];
                        $Property = $Task[$Key];
                        if (@("id","task","dependof","onerror") -contains $Key) {
                            continue;
                        }
                        if($Property -isnot [System.String] -and $Property -isnot [System.Object[]]) {
                            continue;
                        }
                        if($Property -is [System.Object[]]) {
                            for ($k = 0; $k -lt $Property.Count; $k++) {
                                $Property[$k] = ConvertFrom-Buffer -Value $Property[$k];
                            }
                        } else {
                            $Property = ConvertFrom-Buffer -Value $Property;
                        }
                        $Task[$Key] = $Property;
                    }
                    $Response = Invoke-Command -NoNewScope:$NoNewScope -ScriptBlock $TaskExecution -ArgumentList $Task;
                    $Output['exitcode'] = 0;
                    $TasksExecution[$Task['id']] = $Response['success'];
                    if($Task['buffer']) {
                        $Buffers['cw/last'] = $Response;
                        $Buffers[$Task['id']] = $Response;
                        $Buffers['cw/last/task'] = $Task;
                        $Buffers["cw/task/$($Task['id'])"] = $Task;
                    }
                    if($Log) {
                        $Output['execution'] += @{
                            'task' = $Task;
                            'response' = $Response;
                        };
                    }
                    if($Response['success'] -eq $true) {
                        $Output['exitcode'] = 0;
                    } else {
                        $ErrorAction = $Task['onerror'] ?? $OnError;
                        if($ErrorAction -eq "ignore" -or $ErrorAction -eq "silent_ignore"){
                            Write-ErrorMessage -Message "`nError in the wrapper[$($Task['task'])] was ignored" -NoDisplay:$($ErrorAction -eq "silent_ignore");
                        } else {
                            $Output['exitcode'] = 1;
                            $Response['break'] = $true;
                        }
                    }
                    if($Response['break'] -eq $true) {
                        break;
                    }
                }
                Write-Message;
                Write-Line -Message "Result" -LineForegroundColor DarkCyan -MessageForegroundColor Cyan;
                Write-Message;
                if($AllIgnored) {
                    Write-Line -Message "Nothing executed" -Line " " -Corner " " -MessageForegroundColor Gray;
                } elseif($Output['exitcode'] -eq 0) {
                    Write-Line -Message "Success" -Line " " -Corner " " -MessageForegroundColor Green;
                } else {
                    Write-Line -Message "Failure" -Line " " -Corner " " -MessageForegroundColor Red;
                }
            } catch {
                Write-Message;
                Write-Line -Message "Result" -LineForegroundColor DarkCyan -MessageForegroundColor Cyan;
                Write-Message;
                Write-Line -Message "Candy wrappers error" -Line " " -Corner " " -MessageForegroundColor Red;
                Write-Message;
                Write-Line -Message "Error details" -LineForegroundColor DarkCyan -MessageForegroundColor Cyan;
                Write-Message;
                Write-ErrorMessage -Message $_.Exception.Message;
                $Output['exitcode'] = 1;
            } finally {
                $ExecutionHistory = @{
                    'exitcode' = $Output['exitcode'];
                };
                if($Output['tasks']) {
                    $ExecutionHistory['tasks'] = $Output['tasks'];
                }
                if($Output['modules']) {
                    $ExecutionHistory['modules'] = $Output['modules'];
                }
                if($Output['execution']) {
                    $ExecutionHistory['execution'] = $Output['execution'];
                }
                $Output['history'] += $ExecutionHistory;
                if($null -ne $ModulesList -and -not $KeepModules) {
                    Write-Message;
                    Write-Line -Message "Remove modules" -LineForegroundColor DarkCyan -MessageForegroundColor Cyan;
                    Write-Message;
                    foreach ($Module in $ModulesList) {
                        $ModuleName = $Module['Name'];
                        $ModuleVersion = $Module['Version'];
                        Write-Line -Message "$ModuleName($ModuleVersion)" -MessageForegroundColor Magenta -Corner " " -Line " ";
                        Remove-Module -Force -Name $Module['Name'];
                    }
                }
            }
        } elseif($CandySystem -eq "Repositories") {
            $Output['exitcode'] = 0;
            $GithubRepository = "https://github.com/RobertoRojas/CandyWrappers";
            Write-Message;
            Write-Line -Message "Repositories" -LineForegroundColor DarkCyan -MessageForegroundColor Cyan;
            Write-Message;
            Write-Line -Message $GithubRepository -Line " " -Corner " " -MessageForegroundColor Green;
            $Output['githubrepository'] = $GithubRepository;
            $Output['history'] += @{
                'exitcode' = $Output['exitcode'];
                'githubrepository' = $GithubRepository;
            };
        } elseif ($CandySystem -eq "Validate") {
            $Output['exitcode'] = 0;
            $Output['wrappers'] = @();
            try {
                if($null -eq $Wrappers -or $Wrappers.Count -eq 0) {
                    if(Test-Path -LiteralPath $(Join-Path -Path $Configuration['Wrapper']['Execution'] -ChildPath "wrapper.json")) {
                        $Wrappers = @(Join-Path -Path $Configuration['Wrapper']['Execution'] -ChildPath "wrapper.json");
                    } elseif (Test-Path -LiteralPath $(Join-Path -Path $Configuration['Wrapper']['Program'] -ChildPath "wrapper.json")) {
                        $Wrappers = @(Join-Path -Path $Configuration['Wrapper']['Program'] -ChildPath "wrapper.json");
                    } else {
                        throw "$($Invocation.MyCommand.Name) : Cannot find any wrapper to execute";
                    }
                }
                for ($i = 0; $i -lt $Wrappers.Count; $i++) {
                    $Wrapper = $Wrappers[$i];
                    if($Wrapper -is [hashtable]) {
                        if($null -eq $Wrapper['path']) {
                            Write-Message;
                            $Output['exitcode'] = 1;
                            $Output['wrappers'] += @{
                                'path' = "uknown";
                                'message' = "The wrapper[$i] hash property path is mandatory";
                                'success' = $false;
                            };
                            continue;
                        }
                        $Task = @{
                            'path' = $Wrapper['path'];
                        };
                    } elseif ($Wrapper -is [string]) {
                        $Task = @{
                            'path' = $Wrapper;
                        };
                    } else {
                        $Output['exitcode'] = 1;
                        $Output['wrappers'] += @{
                            'path' = "uknown";
                            'message' = "The wrapper element[$i] is not a valid type[$($Wrapper.GetType().Name)]";
                            'success' = $false;
                        };
                        continue;
                    }
                    if(Test-Path -LiteralPath $Task['path']) {
                        $Task['path'] = $(Resolve-Path -LiteralPath $Task['path']).Path;
                    } elseif(Test-Path -LiteralPath $(Join-Path -Path $Configuration['Wrapper']['Execution'] -ChildPath $Task['path'])) {
                        $Task['path'] = $(Join-Path -Path $Configuration['Wrapper']['Execution'] -ChildPath $Task['path']);
                    } elseif(Test-Path -LiteralPath $(Join-Path -Path $Configuration['Wrapper']['Program'] -ChildPath $Task['path'])) {
                        $Task['path'] = $(Join-Path -Path $Configuration['Wrapper']['Program'] -ChildPath $Task['path']);
                    } else {
                        $Output['exitcode'] = 1;
                        $Output['wrappers'] += @{
                            'path' = $Task['path'];
                            'message' = "The wrapper path[$($Task['path'])] doesn't exist";
                            'success' = $false;
                        };
                        continue;
                    }
                    $WrapperJSON = Get-Content -LiteralPath $Task['path'] -Raw;
                    try {
                        Test-Json -Json $WrapperJSON -SchemaFile $Configuration['Wrapper']['SchemaGeneral'] | Out-Null;
                    } catch {
                        $Message = $_.Exception.Message;
                        $ErrorDetails = $_.ErrorDetails.Message;
                        if($ErrorDetails) {
                            $Message += "`n$ErrorDetails";
                        }
                        $Output['exitcode'] = 1;
                        $Output['wrappers'] += @{
                            'path' = $Task['path'];
                            'message' = $Message;
                            'success' = $false;
                        };
                        continue;
                    }
                    try {
                        Test-Json -Json $WrapperJSON -SchemaFile $Configuration['Wrapper']['Schema'] | Out-Null;
                    } catch {
                        $Message = $_.Exception.Message;
                        $ErrorDetails = $_.ErrorDetails.Message;
                        if($ErrorDetails) {
                            $Message += "`n$ErrorDetails";
                        }
                        $Output['exitcode'] = 1;
                        $Output['wrappers'] += @{
                            'path' = $Task['path'];
                            'message' = $Message;
                            'success' = $false;
                        };
                        continue;
                    }
                    $Output['wrappers'] += @{
                        'path' = $Task['path'];
                        'message' = "Valid JSON";
                        'success' = $true;
                    };
                }
                Write-Message;
                Write-Line -Message "Wrappers files" -LineForegroundColor DarkCyan -MessageForegroundColor Cyan;
                Write-Message;
                for ($i = 0; $i -lt $Output['wrappers'].Count; $i++) {
                    $Test = $Output['wrappers'][$i];
                    Write-Line -Message "[$i] - $($Test['path'])" -Line " " -Corner " " -MessageForegroundColor Magenta;
                }
                Write-Message;
                Write-Line -Message "Validate" -LineForegroundColor DarkCyan -MessageForegroundColor Cyan;
                Write-Message;
                for ($i = 0; $i -lt $Output['wrappers'].Count; $i++) {
                    $Test = $Output['wrappers'][$i];
                    Write-Line -Message "wrapper[$i]" -Line "." -Corner "*" -LineForegroundColor DarkYellow -MessageForegroundColor Yellow;
                    Write-Message;
                    if($Test['success']) {
                        Write-Line -Message "Valid" -Line " " -Corner " " -LineBackgroundColor Green -MessageForegroundColor White -MessageBackgroundColor Green;
                    } else {
                        Write-Line -Message "No valid" -Line " " -Corner " " -LineBackgroundColor Red -MessageForegroundColor White -MessageBackgroundColor Red;
                    }
                    Write-VerboseMessage -Message $Test['message'];
                }
            } catch {
                $Output['exitcode'] = 1;
                Write-ErrorMessage -Message $_.Exception.Message;
            } finally {
                $Output['history'] += @{
                    'exitcode' = $Output['exitcode'];
                    'wrappers' = $Output['wrappers'];
                };
            }
        } elseif($CandySystem -eq "Version") {
                $Output['exitcode'] = 0;
                Write-Message;
                Write-Line -Message "Version" -LineForegroundColor DarkCyan -MessageForegroundColor Cyan;
                Write-Message;
                Write-Line -Message $CandyVersion -Line " " -Corner " " -MessageForegroundColor Green;
                if($CandyVersion -ne $SelectedVersion) { 
                    Write-Message;
                    Write-Line -Message "Selected version" -LineForegroundColor DarkCyan -MessageForegroundColor Cyan;
                    Write-Message;
                    Write-Line -Message $SelectedVersion -Line " " -Corner " " -MessageForegroundColor Green;
                }
                $Output['version'] = $CandyVersion;
                $Output['selected'] = $SelectedVersion;
                $Output['history'] += @{
                    'exitcode' = $Output['exitcode'];
                    'version' = $CandyVersion;
                    'selected' = $SelectedVersion;
                };
        } else {
            Write-ErrorMessage -Message "The CandySystem[$($CandySystem)] is not implemented";
        }
        $Elapsed = 0;
        $Paused = $false;
        Write-Message;
        Write-Line -Message "Control[Delay]" -LineForegroundColor DarkCyan -MessageForegroundColor Cyan;
        Write-Message;
        Write-Line -Message "Wait for $($ControlObject['delay']) milliseconds" -Line " " -Corner " " -MessageForegroundColor White -MessageBackgroundColor Magenta -LineBackgroundColor Magenta;
        while($Elapsed -lt $ControlObject['delay']) {
            if(Test-Path -LiteralPath $ControlObject['commands']['break']) {
                Remove-Item -LiteralPath $ControlObject['commands']['break'] -Force | Out-Null;
                break working_loop;
            }
            if(Test-Path -LiteralPath $ControlObject['commands']['note']) {
                if(-not $NoInteractive) {
                    $Note = Read-Host -Prompt "Press enter to continue or write a note";
                    Write-Note -Type control_pause -Note $Note;
                    Remove-Item -LiteralPath $ControlObject['commands']['note'] -Force | Out-Null;
                } else {
                    Write-Line -Message "Cannot execute a note in a non interactive context" -Line " " -Corner " " -MessageForegroundColor White -MessageBackgroundColor Yellow -LineBackgroundColor Yellow;
                }
            }
            if(-not (Test-Path -LiteralPath $ControlObject['commands']['pause'])) {
                $Paused = $false;
                $Elapsed++;
                if($Elapsed % 1000 -eq 0) {
                    Write-VerboseMessage -Message "Waited $Elapsed of $($ControlObject['delay'])";
                }
            } else {
                if(-not $NoInteractive) {
                    if(-not $Paused) {
                        $Paused = $true;
                        Write-Line -Message "Execution paused, delete [$($ControlObject['commands']['pause'])] to continue" -Line " " -Corner " " -MessageForegroundColor White -MessageBackgroundColor Magenta -LineBackgroundColor Magenta;
                    } 
                } else {
                    Remove-Item -LiteralPath $ControlObject['commands']['pause'] -Force | Out-Null;
                    Write-Line -Message "Cannot execute a pause in a non interactive context" -Line " " -Corner " " -MessageForegroundColor White -MessageBackgroundColor Yellow -LineBackgroundColor Yellow;
                }
            }
            Start-Sleep -Milliseconds 1;
        }
        Write-VerboseMessage -Message "Waited $Elapsed of $($ControlObject['delay'])";
        if($ControlObject['manual']) {
            Write-Message;
            Write-Line -Message "Control[Manual]" -LineForegroundColor DarkCyan -MessageForegroundColor Cyan;
            Write-Message;
            if(-not $NoInteractive) {
                $Note = Read-Host -Prompt "Press enter to continue or write a note";
                Write-Note -Type control_break -Note $Note;
            } else {
                Write-Line -Message "Cannot execute a manual wait in a non interactive context" -Line " " -Corner " " -MessageForegroundColor White -MessageBackgroundColor Yellow -LineBackgroundColor Yellow;
            }
        }
        Write-Message;
        Write-Line -Message "Control[$($ControlObject['mode'])]" -LineForegroundColor DarkCyan -MessageForegroundColor Cyan;
        $Working = $Output['exitcode'] -eq 0 -or $ControlObject['force'] -eq $true;
        if(-not $Working) {
            Write-Message;
            Write-Line -Message "Execution failure" -Line " " -Corner " " -MessageForegroundColor White -MessageBackgroundColor Red -LineBackgroundColor Red;
        }
    } while($Working -and $(Invoke-Command -ScriptBlock $ControlScriptBlock -ArgumentList $ControlObject));
    $Output['ctrl-c'] = $false;
} catch {
    Write-Message;
    Write-Line -Message "Unexpected exception" -LineForegroundColor DarkCyan -MessageForegroundColor Cyan;
    Write-Message;
    Write-ErrorMessage -Message $_.Exception.Message;
    $Output['exitcode'] = 1;
    $Output['ctrl-c'] = $false;
} finally {
    if($Output['ctrl-c']) {
        $Output['exitcode'] = $SuccessAtCtrlC ? 0 : 1;
        $Color = $Output['exitcode'] -eq 0 ? "Yellow" : "Red";
        Write-Message;
        Write-Line -Message "Execution skipped by ctrl-c" -Line " " -Corner " " -MessageForegroundColor White -MessageBackgroundColor $Color -LineBackgroundColor $Color;
    }
    Exit-CandyWrappers;
}