Write-Output -InputObject @{
    'buffer_create' = . "$PSScriptRoot\..\buffer_create.ps1" -Version "1.0.0";
    'buffer_show' = . "$PSScriptRoot\..\buffer_show.ps1" -Version "1.0.0";
    'compress' = . "$PSScriptRoot\..\compress.ps1" -Version "1.0.0";
    'create_directory' = . "$PSScriptRoot\..\create_directory.ps1" -Version "1.0.0";
    'decompress' = . "$PSScriptRoot\..\decompress.ps1" -Version "1.0.0";
    'cw_break' = . "$PSScriptRoot\..\cw_break.ps1" -Version "1.0.0";
    'cw_echo' = . "$PSScriptRoot\..\cw_echo.ps1" -Version "1.0.0";
    'cw_pause' = . "$PSScriptRoot\..\cw_pause.ps1" -Version "1.0.0";
    'cw_task' = . "$PSScriptRoot\..\cw_task.ps1" -Version "1.0.0";
    'download' = . "$PSScriptRoot\..\download.ps1" -Version "1.0.0";
    'execute' = . "$PSScriptRoot\..\execute.ps1" -Version "1.0.0";
    'get_file' = . "$PSScriptRoot\..\get_file.ps1" -Version "1.0.0";
    'invoke_program' = . "$PSScriptRoot\..\invoke_program.ps1" -Version "1.0.0";
    'remove_path' = . "$PSScriptRoot\..\remove_path.ps1" -Version "1.0.0";
    'set_file' = . "$PSScriptRoot\..\set_file.ps1" -Version "1.0.0";
    'test_path' = . "$PSScriptRoot\..\test_path.ps1" -Version "1.0.0";
    'test_program' = . "$PSScriptRoot\..\test_program.ps1" -Version "1.0.0";
};
