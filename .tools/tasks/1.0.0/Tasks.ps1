Write-Output -InputObject @{
    "compress" = [ScriptBlock]::Create($(. "$PSScriptRoot\..\compress.ps1" -Version "1.0.0"));
    "create_directory" = [ScriptBlock]::Create($(. "$PSScriptRoot\..\create_directory.ps1" -Version "1.0.0"));
    "cw_break" = [ScriptBlock]::Create($(. "$PSScriptRoot\..\cw_break.ps1" -Version "1.0.0"));
    "cw_echo" = [ScriptBlock]::Create($(. "$PSScriptRoot\..\cw_echo.ps1" -Version "1.0.0"));
    "cw_pause" = [ScriptBlock]::Create($(. "$PSScriptRoot\..\cw_pause.ps1" -Version "1.0.0"));
    "download_file" = [ScriptBlock]::Create($(. "$PSScriptRoot\..\download_file.ps1" -Version "1.0.0"));
    "execute" = [ScriptBlock]::Create($(. "$PSScriptRoot\..\execute.ps1" -Version "1.0.0"));
    "invoke_program" = [ScriptBlock]::Create($(. "$PSScriptRoot\..\invoke_program.ps1" -Version "1.0.0"));
    "remove_path" = [ScriptBlock]::Create($(. "$PSScriptRoot\..\remove_path.ps1" -Version "1.0.0"));
    "set_file" = [ScriptBlock]::Create($(. "$PSScriptRoot\..\set_file.ps1" -Version "1.0.0"));
    "test_path" = [ScriptBlock]::Create($(. "$PSScriptRoot\..\test_path.ps1" -Version "1.0.0"));
    "test_program" = [ScriptBlock]::Create($(. "$PSScriptRoot\..\test_program.ps1" -Version "1.0.0"));
};
