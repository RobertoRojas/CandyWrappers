<p align="center">
  <img src="./.images/LOGO.png" alt="Gimp"/>
</p>

---

- [What is this?](#what-is-this)
- [Hello world!](#hello-world)
- [How to feed candy with wrappers](#how-to-feed-candy-with-wrappers)
- [How to filter my wrappers](#how-to-filter-my-wrappers)
- [Log of the execution](#log-of-the-execution)
- [How to create notes](#how-to-create-notes)
- [Share information between wrappers](#share-information-between-wrappers)
- [Wrappers dependencies](#wrappers-dependencies)
- [What is a macro?](#what-is-a-macro)
- [Execution per version](#execution-per-version)
- [How to change the execution mode](#how-to-change-the-execution-mode)

---

<a id="what-is-this"></a>
# What is this?

Candy wrappers is a program to execute tasks, programs, routines, functions, etc. defined in a JSON file. With this, you can define a big amount of tasks to execute a process, like a process to compile a C program(even using a MAKE commands in the process) or maintenance process to generate a report. It use wrappers, that is nothing but a defined task to execute, expecting a minimum amount of information to can realize the process.

<a id="hello-world"></a>
# Hello world!

Lets get to work, the first thing to use this is define the JSON file with the definition, in this case I will use **cw_echo**:

```JSON
{
    "wrappers": [
        {
            "id": "my_hello_world",
            "task": "cw_echo",
            "message": "Hello world!"
        }
    ]
}
```

For now, you must use the default path *./.candy/wrappers/wrapper.json*, it can be changed using the parameter **-Wrappers** but I will explain in more detail soon.

Output:
```Plain
PS> ./Candy.ps1
#-----------------------------Candy Wrappers-----------------------------# 

Candy     : 1.0.0
Wrapper   : 1.0.0
Execution : /home/rrojas/Projects/CandyWrappers
Script    : /home/rrojas/Projects/CandyWrappers
 
#-------------------------------Parameters-------------------------------# 

                              Nothing to show                              

#---------------------------------Control--------------------------------# 

Mode      : once
Commands  : /home/rrojas/Projects/CandyWrappers/.candy/control/commands
Delay     : 0
Manual    : False
Force     : False
 
#-----------------------------Import modules-----------------------------# 

                              program(1.0.0)                               

#--------------------------------Wrappers--------------------------------# 

                              my_hello_world                               

#--------------------------------Execution-------------------------------# 

*.........................cw_echo[my_hello_world]........................* 

Hello world!
 
#---------------------------------Result---------------------------------# 

                                  Success                                  

#-----------------------------Remove modules-----------------------------# 

                              program(1.0.0)                               

#-----------------------------Control[Delay]-----------------------------# 

                          Wait for 0 milliseconds                          

#------------------------------Control[once]-----------------------------# 

                                   Done                                    

#---------------------------Result of execution--------------------------# 

                                  Success                                  

#------------------------------------------------------------------------#
```

And here, you have the result of the execution, without the necesity to write a script. Obviusly 

<a id="how-to-feed-candy-with-wrappers"></a>
# How to feed candy with wrappers?

You have two different default paths of the wrapper when you don't send it throw the script parameter, the first to check is in the current path where you run the **Candy.ps1** and the second is relative to the script. For example, if you have these paths:

> Current path -> c:/myproject/.candy/wrappers

> Script path  -> c:/candy/.candy/wrappers

Candy will check first in **c:/myproject/.candy/wrappers/wrapper.json** and if the file doesn't exist, it will check in **c:/candy/.candy/wrappers/wrapper.json**, this is a very usefull property when you have a standart process to compile your code for different projects, in the case that you need to send a different path, you can add the full path, but if the JSON file is into ant of the both default folders, you can send only the file name. Because you don't need to define it in all the projects, only in the candy script path. In some cases you will need to run wrappers from several files, to do that, you need to send them to the script using the **-Wrappers** parameter, for example:

a.json
```JSON
{
    "wrappers": [
        {
            "id": "task/a",
            "task": "cw_echo",
            "message": "My A task!"
        },
        {
            "id": "report/a",
            "task": "cw_echo",
            "message": "My A report!"
        }
    ]
}
```

b.json
```JSON
{
    "wrappers": [
        {
            "id": "task/b",
            "task": "cw_echo",
            "message": "My B task!"
        },
        {
            "id": "report/b",
            "task": "cw_echo",
            "message": "My B report!"
        }
    ]
}
```

Output:
```Plain
PS> ./Candy.ps1 -Wrappers ./.candy/wrappers/a.json,b.json
#-----------------------------Candy Wrappers-----------------------------# 

Candy     : 1.0.0
Wrapper   : 1.0.0
Execution : /home/rrojas/Projects/CandyWrappers
Script    : /home/rrojas/Projects/CandyWrappers
 
#-------------------------------Parameters-------------------------------# 

     -Wrappers ["./.candy/wrappers/a.json","b.json"]     

#---------------------------------Control--------------------------------# 

Mode      : once
Commands  : /home/rrojas/Projects/CandyWrappers/.candy/control/commands
Delay     : 0
Manual    : False
Force     : False
 
#-----------------------------Import modules-----------------------------# 

                              program(1.0.0)                               
                              
#--------------------------------Wrappers--------------------------------# 

                                  task/a
                                  report/a
                                  task/b
                                  report/b
                                  
#--------------------------------Execution-------------------------------# 

*.............................cw_echo[task/a]............................* 

My A task!
 
*............................cw_echo[report/a]...........................* 

My A report!
 
*.............................cw_echo[task/b]............................* 

My B task!
 
*............................cw_echo[report/b]...........................* 

My B report!
 
#---------------------------------Result---------------------------------# 

                                  Success                                  

#-----------------------------Remove modules-----------------------------# 

                              program(1.0.0)                               

#-----------------------------Control[Delay]-----------------------------# 

                          Wait for 0 milliseconds                          

#------------------------------Control[once]-----------------------------# 

                                   Done                                    

#---------------------------Result of execution--------------------------# 

                                  Success                                  

#------------------------------------------------------------------------#
```

The order that you use in the parameter will determinate the order to execute them. 

<a id="how-to-filter-my-wrappers"></a>
# How to filter my wrappers

Sometimes, you don't want to execute all the wrapeprs defined in the JSON files. So you can filter them using the parameters:

- Include
- Exclude

The order of the operations are first exclude any wrapper ID that match with the exclude and next it include it if the wrapper match with the include pattern, for example:

a.json
```JSON
{
    "wrappers": [
        {
            "id": "task/a",
            "task": "cw_echo",
            "message": "My A task!"
        },
        {
            "id": "report/a",
            "task": "cw_echo",
            "message": "My A report!"
        },
        {
            "id": "exeucte/a",
            "task": "cw_echo",
            "message": "My A execution!"
        }
    ]
}
```

b.json
```JSON
{
    "wrappers": [
        {
            "id": "task/b",
            "task": "cw_echo",
            "message": "My B task!"
        },
        {
            "id": "report/b",
            "task": "cw_echo",
            "message": "My B report!"
        },
        {
            "id": "exeucte/b",
            "task": "cw_echo",
            "message": "My B execution!"
        }
    ]
}
```

Output:
```Pain
PS> ./Candy.ps1 -Wrappers ./.candy/wrappers/a.json,./.candy/wrappers/b.json -Exclude @("task/*") -Include @("report/*")
#-----------------------------Candy Wrappers-----------------------------# 

Candy     : 1.0.0
Wrapper   : 1.0.0
Execution : /home/rrojas/Projects/CandyWrappers
Script    : /home/rrojas/Projects/CandyWrappers
 
#-------------------------------Parameters-------------------------------# 

                            -Exclude ["task/*"]                                
      -Wrappers ["./.candy/wrappers/a.json","./.candy/wrappers/b.json"]
                           -Include ["report/*"]                           

#---------------------------------Control--------------------------------# 
Mode      : once
Commands  : /home/rrojas/Projects/CandyWrappers/.candy/control/commands
Delay     : 0
Manual    : False
Force     : False
 
#-----------------------------Import modules-----------------------------# 

                              program(1.0.0)                               

#--------------------------------Wrappers--------------------------------# 

                                 report/a
                                 report/b                                  

#--------------------------------Execution-------------------------------# 

*............................cw_echo[report/a]...........................* 

My A report!
 
*............................cw_echo[report/b]...........................* 

My B report!
 
#---------------------------------Result---------------------------------# 

                                  Success                                  
#-----------------------------Remove modules-----------------------------# 

                              program(1.0.0)                               

#-----------------------------Control[Delay]-----------------------------# 

                          Wait for 0 milliseconds                          

#------------------------------Control[once]-----------------------------# 

                                   Done                                    

#---------------------------Result of execution--------------------------# 

                                  Success                                  

#------------------------------------------------------------------------#
```

Using the same example as base, but in this case, if you only want to apply these filters to *b.json* you can doing send them in the **-Wrappers** parameter like this:

```Plain
PS> ./Candy.ps1 -Wrappers ./.candy/wrappers/a.json,@{Path="./.candy/wrappers/b.json";Exclude=@("task/*");Include=@("report/*")}
#-----------------------------Candy Wrappers-----------------------------# 

Candy     : 1.0.0
Wrapper   : 1.0.0
Execution : /home/rrojas/Projects/CandyWrappers
Script    : /home/rrojas/Projects/CandyWrappers
 
#-------------------------------Parameters-------------------------------# 

-Wrappers ["./.candy/wrappers/a.json",{"Exclude":["task/*"],"Path":"./.candy/wrappers/b.json","Include":["report/*"]}]
 
#---------------------------------Control--------------------------------# 

Mode      : once
Commands  : /home/rrojas/Projects/CandyWrappers/.candy/control/commands
Delay     : 0
Manual    : False
Force     : False
 
#-----------------------------Import modules-----------------------------# 

                              program(1.0.0)                               

#--------------------------------Wrappers--------------------------------# 

                                  task/a
                                  report/a
                                  execute/a
                                  report/b
                                                                  
#--------------------------------Execution-------------------------------# 

*.............................cw_echo[task/a]............................* 
My A task!
 
*............................cw_echo[report/a]...........................* 
My A report!
 
*...........................cw_echo[execute/a]...........................* 
My A execution!
 
*............................cw_echo[report/b]...........................* 
My B report!
 
#---------------------------------Result---------------------------------# 

                                  Success                                  

#-----------------------------Remove modules-----------------------------# 

                              program(1.0.0)                               

#-----------------------------Control[Delay]-----------------------------# 

                          Wait for 0 milliseconds                          

#------------------------------Control[once]-----------------------------# 

                                   Done                                    

#---------------------------Result of execution--------------------------# 

                                  Success                                  

#------------------------------------------------------------------------#
```

<a id="log-of-the-execution"></a>
# Log of the execution

To generate a report of the execution, you only need to add the parameter **-Log** to Candy.ps1. It will generate a JSON file in the follow path:

> ./.candy/logs

The name of the file will be the convertion of the current date time when the log is generated (at the end of the execution) to a file time. Sometimes, you will want to view the content of the log in the shell, the way to display it is using the parameter **-Output**, this parameter can return the information in a JSON, Hashtable, PSCustomObject or Null. You can prevent the creation of the log file adding **-NoLogFile**. Something to take in count is that **-Output** still returning information even if the **-Log** parameter is not present, the only difference is the detail of the information.

<a id="how-to-create-notes"></a>
# How to create notes

If you want to create a notes in the log of the execution, you can do it in three:

- Pause
- Manual
- cw_pause

For now, lets only check the last one, the rest of them will be explain in detail later, in the **ModeXXXXXChange to link** section. First you need to define the wrapper:

```JSON
{
    "wrappers": [
        {
            "id": "echo/first",
            "task": "cw_echo",
            "message": "Before pause wrapper..."
        },
        {
            "id": "pause",
            "task": "cw_pause"
        },
        {
            "id": "echo/second",
            "task": "cw_echo",
            "message": "After pause wrapper..."
        }
    ]
}
```

When you run this definitions, the system will write the fist message and wait until you press enter. You can write any text in the input and it will be reflected in the log file:

Output:
```Pain
PS> ./Candy.ps1 -Output JSON  
#-----------------------------Candy Wrappers-----------------------------# 

Candy     : 1.0.0
Wrapper   : 1.0.0
Execution : /home/rrojas/Projects/CandyWrappers
Script    : /home/rrojas/Projects/CandyWrappers
 
#-------------------------------Parameters-------------------------------# 

                               -Type "JSON"                                

#---------------------------------Control--------------------------------# 

Mode      : once
Commands  : /home/rrojas/Projects/CandyWrappers/.candy/control/commands
Delay     : 0
Manual    : False
Force     : False
 
#-----------------------------Import modules-----------------------------# 

                              program(1.0.0)                               

#--------------------------------Wrappers--------------------------------# 

                                echo/first
                                pause
                                echo/second                                

#--------------------------------Execution-------------------------------# 

*...........................cw_echo[echo/first]..........................* 

Before pause wrapper...
 
*.............................cw_pause[pause]............................* 

Press enter to continue or write a note: this is a note
 
*..........................cw_echo[echo/second]..........................* 

After pause wrapper...
 
#---------------------------------Result---------------------------------# 

                                  Success                                  

#-----------------------------Remove modules-----------------------------# 

                              program(1.0.0)                               

#-----------------------------Control[Delay]-----------------------------# 

                          Wait for 0 milliseconds                          

#------------------------------Control[once]-----------------------------# 

                                   Done                                    

#---------------------------Result of execution--------------------------# 

                                  Success                                  

#------------------------------------------------------------------------#
{
  "Success": true,
  "ctrl-c": false,
  "history": [
    {
      "exitcode": 0
    }
  ],
  "notes": [
    {
      "datetime": "2021-12-31T15:06:47.4146241-06:00",
      "note": "this is a note",
      "type": "wrapper_pause"
    }
  ],
  "exitcode": 0,
  "Note": "this is a note"
}
```

<a id="share-information-between-wrappers"></a>
# Share information between wrappers

Sometimes you need to share information between the wrappers, for example to create a automatic releases notes of your development. To do it use the property **Buffer** in the wrapper definition and consume it using {TaskID.JSON_property}, it can be only use it in String or String[]. For example:

```JSON
{
    "wrappers": [
        {
            "id": "echo/first",
            "task": "cw_echo",
            "message": "Before pause wrapper..."
        },
        {
            "id": "my_pause",
            "task": "cw_pause",
            "buffer": true
        },
        {
            "id": "echo/second",
            "task": "cw_echo",
            "message": "After pause wrapper... Note: {my_pause.note}"
        }
    ]
}
```

When you run this definitions, the system will write the fist message and wait until you press enter. You can write any text in the input and it will be reflected in the log file:

Output:
```Pain
PS> ./Candy.ps1                                                           
#-----------------------------Candy Wrappers-----------------------------# 

Candy     : 1.0.0
Wrapper   : 1.0.0
Execution : /home/rrojas/Projects/CandyWrappers
Script    : /home/rrojas/Projects/CandyWrappers
 
#-------------------------------Parameters-------------------------------# 

                              Nothing to show                              

#---------------------------------Control--------------------------------# 

Mode      : once
Commands  : /home/rrojas/Projects/CandyWrappers/.candy/control/commands
Delay     : 0
Manual    : False
Force     : False
 
#-----------------------------Import modules-----------------------------# 

                              program(1.0.0)                               

#--------------------------------Wrappers--------------------------------# 

                                echo/first
                                my_pause
                                echo/second   

#--------------------------------Execution-------------------------------# 

*...........................cw_echo[echo/first]..........................* 

Before pause wrapper...
 
*...........................cw_pause[my_pause]...........................* 

Press enter to continue or write a note: this is a note
 
*..........................cw_echo[echo/second]..........................* 

After pause wrapper... Note: this is a note
 
#---------------------------------Result---------------------------------# 

                                  Success                                  

#-----------------------------Remove modules-----------------------------# 

                              program(1.0.0)                               

#-----------------------------Control[Delay]-----------------------------# 

                          Wait for 0 milliseconds                          

#------------------------------Control[once]-----------------------------# 
                                   Done                                    

#---------------------------Result of execution--------------------------# 

                                  Success                         

#------------------------------------------------------------------------#
```

If you don't want to specify the ID of the buffer, you can use cw/last and the system will use the last buffer stored. Something like this:

```JSON
{
    "wrappers": [
        {
            "id": "echo/first",
            "task": "cw_echo",
            "message": "Before pause wrapper..."
        },
        {
            "id": "my_pause",
            "task": "cw_pause",
            "buffer": true
        },
        {
            "id": "echo/second",
            "task": "cw_echo",
            "message": "After pause wrapper... Note: {cw/last.note}"
        }
    ]
}
```

This will show us the same output as before.  You can also use the buffer of the wrapper properties, for example:

```JSON
{
    "wrappers": [
        {
            "id": "my_task",
            "task": "cw_echo",
            "message": "This is my message",
            "buffer": true
        },
        {
            "id": "echo/second",
            "task": "cw_echo",
            "message": "The execution of the wrapper[{cw/task/my_task.id}] have the follow message: {cw/last.message}"
        }
    ]
}
```

Output:
```Pain
PS> ./Candy.ps1
#-----------------------------Candy Wrappers-----------------------------# 

Candy     : 1.0.0
Wrapper   : 1.0.0
Execution : /home/rrojas/Projects/CandyWrappers
Script    : /home/rrojas/Projects/CandyWrappers
 
#-------------------------------Parameters-------------------------------# 

                              Nothing to show                              

#---------------------------------Control--------------------------------# 

Mode      : once
Commands  : /home/rrojas/Projects/CandyWrappers/.candy/control/commands
Delay     : 0
Manual    : False
Force     : False
 
#-----------------------------Import modules-----------------------------# 

                              program(1.0.0)                               

#--------------------------------Wrappers--------------------------------# 

                                  my_task
                                  echo/second               

#--------------------------------Execution-------------------------------# 

*............................cw_echo[my_task]............................* 

This is my message
 
*..........................cw_echo[echo/second]..........................* 

The execution of the wrapper[my_task] have the follow message: This is my message
 
#---------------------------------Result---------------------------------# 

                                  Success                                  

#-----------------------------Remove modules-----------------------------# 

                              program(1.0.0)                               

#-----------------------------Control[Delay]-----------------------------# 

                          Wait for 0 milliseconds                          

#------------------------------Control[once]-----------------------------# 

                                   Done                                    

#---------------------------Result of execution--------------------------# 

                                  Success                                  

#------------------------------------------------------------------------#
```

You can use *cw/last/task* at the same way as *cw/last* to get the properties of the last wrapper buffer. The system doesn't validate if the ID is unique, so, if you declare two wrappers with the same ID, it will store the information of the first and override it when it execute the second wrapper.

<a id="wrappers-dependencies"></a>
# Wrappers dependencies

You can define a dependency of a wrapper with other, and in this way can provide different behaivors for differents situations, for example:

```JSON
{
    "wrappers": [
        {
            "id": "dependency",
            "task": "get_file",
            "path": "my_file",
            "displaycontent": false,
            "buffer": true,
            "raw": true,
            "onerror": "ignore"
        },
        {
            "id": "dependency",
            "task": "buffer_create",
            "object": {
                "Content": "Default content on failure"
            },
            "dependof": {
                "id": "dependency",
                "success": false
            }
        },
        {
            "id": "final/display",
            "task": "buffer_show",
            "key": "dependency"
        }
    ]
}
```

This wrappers will read the content of a file and display the content of the buffer, like this:

Output:
```Pain
PS> ./Candy.ps1
#-----------------------------Candy Wrappers-----------------------------# 

Candy     : 1.0.0
Wrapper   : 1.0.0
Execution : /home/rrojas/Projects/CandyWrappers
Script    : /home/rrojas/Projects/CandyWrappers
 
#-------------------------------Parameters-------------------------------# 

                              Nothing to show                              

#---------------------------------Control--------------------------------# 

Mode      : once
Commands  : /home/rrojas/Projects/CandyWrappers/.candy/control/commands
Delay     : 0
Manual    : False
Force     : False
 
#-----------------------------Import modules-----------------------------# 

                              program(1.0.0)                               

#--------------------------------Wrappers--------------------------------# 

                                dependency
                                dependency
                                final/display         

#--------------------------------Execution-------------------------------# 

*..........................get_file[dependency]..........................* 

                             Content obtained                              

*.......................buffer_show[final/display].......................* 

{
  "Success": true,
  "Content": "a\nb\nc\nd\ne\nf\ng"
}
 
#---------------------------------Result---------------------------------# 

                                  Success                                  

#-----------------------------Remove modules-----------------------------# 

                              program(1.0.0)                             

#-----------------------------Control[Delay]-----------------------------# 

                          Wait for 0 milliseconds                          

#------------------------------Control[once]-----------------------------# 

                                   Done                                    

#---------------------------Result of execution--------------------------# 

                                  Success                                  

#------------------------------------------------------------------------#
```

This work as expected, but if the file doesn't exists the dependent wrapper will create the content with the default value:

Output:
```Pain
PS> ./Candy.ps1
#-----------------------------Candy Wrappers-----------------------------# 

Candy     : 1.0.0
Wrapper   : 1.0.0
Execution : /home/rrojas/Projects/CandyWrappers
Script    : /home/rrojas/Projects/CandyWrappers
 
#-------------------------------Parameters-------------------------------# 

                              Nothing to show                              

#---------------------------------Control--------------------------------# 

Mode      : once
Commands  : /home/rrojas/Projects/CandyWrappers/.candy/control/commands
Delay     : 0
Manual    : False
Force     : False
 
#-----------------------------Import modules-----------------------------# 

                              program(1.0.0)                               

#--------------------------------Wrappers--------------------------------# 

                                dependency
                                dependency
                                final/display    

#--------------------------------Execution-------------------------------# 

*..........................get_file[dependency]..........................* 

Candy.ps1 -> get_file -> The path[my_file] doesn't exists

Error in the wrapper[get_file] was ignored
 
*........................buffer_create[dependency].......................* 

                              Buffer created                               

*.......................buffer_show[final/display].......................* 

{
  "Success": true,
  "Object": {
    "Content": "Default content on failure"
  }
}
 
#---------------------------------Result---------------------------------# 

                                  Success                                  

#-----------------------------Remove modules-----------------------------# 

                              program(1.0.0)                               

#-----------------------------Control[Delay]-----------------------------# 

                          Wait for 0 milliseconds                          

#------------------------------Control[once]-----------------------------# 

                                   Done                                    

#---------------------------Result of execution--------------------------# 

                                  Success                                  

#------------------------------------------------------------------------#
```

<a id="what-is-a-macro"></a>
# What is a macro?

To have some parameters predefined in the execution of **Candy.ps1** you can use a macro JSON, there you can add any parameter to use in the execution of the script first you need to define the JSON file, something like this:

macro.json
```JSON
{
    "Wrappers": [
        "./.candy/wrappers/a.json",
        {
            "path": "b.json"
        }
    ],
    "include": [
        "*/*"
    ],
    "NoLogFile": true
}
```

As the same way as **-Wrappers** parameter, it looks in for the path and the default current and script path. In the case of macro, the default path is **(curernt path or Candy.ps1 directory)./.candy/macro**. You can override the parameters defined in the JSON file with an explict parameter in the script execution, for example:

Output:
```Pain
PS> ./Candy.ps1 -Wrappers $Null -Macro macro.json
#-----------------------------Candy Wrappers-----------------------------# 

Candy     : 1.0.0
Wrapper   : 1.0.0
Execution : /home/rrojas/Projects/CandyWrappers
Script    : /home/rrojas/Projects/CandyWrappers
 
#-------------------------------Parameters-------------------------------#

                            -Macro "macro.json"
                            -include ["*/*"]
                            -Wrappers null
                            -NoLogFile {"IsPresent":true}      

#---------------------------------Control--------------------------------# 

Mode      : once
Commands  : /home/rrojas/Projects/CandyWrappers/.candy/control/commands
Delay     : 0
Manual    : False
Force     : False
 
#-----------------------------Import modules-----------------------------# 

                              program(1.0.0)                               

#--------------------------------Wrappers--------------------------------# 

                                my/default                                 

#--------------------------------Execution-------------------------------# 

*...........................cw_echo[my/default]..........................* 

Default wrapper
 
#---------------------------------Result---------------------------------# 

                                  Success                                  

#-----------------------------Remove modules-----------------------------# 

                              program(1.0.0)                               

#-----------------------------Control[Delay]-----------------------------# 

                          Wait for 0 milliseconds                          

#------------------------------Control[once]-----------------------------# 

                                   Done                                    

#---------------------------Result of execution--------------------------# 

                                  Success                                  

#------------------------------------------------------------------------#
```

<a id="execution-per-version"></a>
# Execution per version

By default **Candy.ps1** execute the latest version of the wrappers, but you can choose another version with the parameters **-Major**, **-Minor** and **-Build**. It will modify the modules and the wrappers, but in some cases you only want to change the version of a single wrapper, to do it you can add the *version* property in the JSON. To make an example I will use the generic wrapper cw_task, here you can define any Powershell rutine and use it like any other wrapper:

**Note:** This example use the version 1.0.0 as default

```JSON
{
    "wrappers": [
        {
            "id": "version/1.0.0",
            "task": "cw_task"
        },
        {
            "id": "version/2.0.0",
            "task": "cw_task",
            "version": "2.0.0"
        }
    ]
}
```

cw_task.ps1
```Powershell
[CmdletBinding()]
param (
    [ValidateSet(
        "1.0.0",
        "2.0.0"
    )]
    [string]
    $Version = $(throw "$($MyInvocation.MyCommand.Name) -> You need to send the version of the script block")
);
$ErrorActionPreference = "stop";
Write-VerboseMessage "Selected version[$Version] of $($MyInvocation.MyCommand.Name)";
@{
    '1.0.0' = {
        [CmdletBinding()]
        param (
            [hashtable]
            $Parameters = $(throw "Parameters need to be defined")
        );
        Write-Line -Message "Generic task version 1.0.0" -Line " " -Corner " " -MessageForegroundColor White -MessageBackgroundColor Cyan -LineBackgroundColor Cyan;
        Write-Output -InputObject @{
            'Success' = $true;
        }
    };
    '2.0.0' = {
        [CmdletBinding()]
        param (
            [hashtable]
            $Parameters = $(throw "Parameters need to be defined")
        );
        Write-Line -Message "Generic task version 2.0.0" -Line " " -Corner " " -MessageForegroundColor White -MessageBackgroundColor Green -LineBackgroundColor Green;
        Write-Output -InputObject @{
            'Success' = $true;
        }
    };
}[$Version] | Write-Output;
```

Output:
```Pain
PS> ./Candy.ps1
#-----------------------------Candy Wrappers-----------------------------# 

Candy     : 1.0.0
Wrapper   : 1.0.0
Execution : /home/rrojas/Projects/CandyWrappers
Script    : /home/rrojas/Projects/CandyWrappers
 
#-------------------------------Parameters-------------------------------# 

                              Nothing to show                              

#---------------------------------Control--------------------------------# 

Mode      : once
Commands  : /home/rrojas/Projects/CandyWrappers/.candy/control/commands
Delay     : 0
Manual    : False
Force     : False
 
#-----------------------------Import modules-----------------------------# 

                              program(1.0.0)                               

#--------------------------------Wrappers--------------------------------# 

                               version/1_0_0
                               version/2_0_0       

#--------------------------------Execution-------------------------------# 

*.........................cw_task[version/1_0_0].........................*


                        Generic task version 1.0.0                         

*.........................cw_task[version/2_0_0].........................* 

                        Generic task version 2.0.0                         

#---------------------------------Result---------------------------------# 

                                  Success                                  

#-----------------------------Remove modules-----------------------------# 

                              program(1.0.0)                               

#-----------------------------Control[Delay]-----------------------------# 

                          Wait for 0 milliseconds                          

#------------------------------Control[once]-----------------------------# 

                                   Done                                    

#---------------------------Result of execution--------------------------# 

                                  Success                                  

#------------------------------------------------------------------------#
```

**Note:** Be carefull, when you change the version **Candy.ps1** doesn't validate the JSON file.

<a id="how-to-change-the-execution-mode"></a>
# How to change the execution mode

The normal execution of **Candy.ps1** is run the wrappers a single time. But the system have defined 4 modes:

- once: Run only one time
- loop: Run a certain amount of executions
- infinite: Run until you break the execution
- file_system_watcher: Run when it detects a change in a file of folder of some path (by default use the current directory)

You only need to define the control JSON file, it works as the same way as macro; path, exeuction or script path. The default path is **./.candy/control**. To create a loop to run 3 times the script you can use the follow example as base:

```JSON
{
    "wrappers": [
        {
            "id": "dependency",
            "task": "execute",
            "commands": [
                "Write-Message -Message $(Get-Date -Format o)"
            ],
            "nonewscope": true
        }
    ]
}
```

control.json
```JSON
{
    "mode": "loop",
    "repeat": 3,
    "delay": 1000
}
```

Output:
```Pain
PS> ./Candy.ps1 -Control control.json
#-----------------------------Candy Wrappers-----------------------------# 

Candy     : 1.0.0
Wrapper   : 1.0.0
Execution : /home/rrojas/Projects/CandyWrappers
Script    : /home/rrojas/Projects/CandyWrappers
 
#-------------------------------Parameters-------------------------------# 

                          -Control "control.json"                          

#---------------------------------Control--------------------------------# 

Mode      : loop
Commands  : /home/rrojas/Projects/CandyWrappers/.candy/control/commands
Delay     : 1000
Manual    : False
Force     : False
Repeat    : 3
 
#-----------------------------Import modules-----------------------------# 

                              program(1.0.0)                               

#--------------------------------Wrappers--------------------------------# 

                                dependency                                 

#--------------------------------Execution-------------------------------# 

*...........................execute[dependency]..........................* 

2022-01-02T01:24:49.8059757-06:00
 
#---------------------------------Result---------------------------------# 

                                  Success                                  

#-----------------------------Remove modules-----------------------------# 

                              program(1.0.0)                               

#-----------------------------Control[Delay]-----------------------------# 

                        Wait for 1000 milliseconds                         

#------------------------------Control[loop]-----------------------------# 

                              Repeated 1 of 3                              

#-----------------------------Import modules-----------------------------# 

                              program(1.0.0)                               

#--------------------------------Wrappers--------------------------------# 

                                dependency                                 

#--------------------------------Execution-------------------------------# 

*...........................execute[dependency]..........................* 

2022-01-02T01:24:52.0817755-06:00
 
#---------------------------------Result---------------------------------# 

                                  Success                                  

#-----------------------------Remove modules-----------------------------# 

                              program(1.0.0)                               

#-----------------------------Control[Delay]-----------------------------# 

                        Wait for 1000 milliseconds                         

#------------------------------Control[loop]-----------------------------# 

                              Repeated 2 of 3                              

#-----------------------------Import modules-----------------------------# 

                              program(1.0.0)                               

#--------------------------------Wrappers--------------------------------# 

                                dependency                                 

#--------------------------------Execution-------------------------------# 

*...........................execute[dependency]..........................* 

2022-01-02T01:24:54.5138845-06:00
 
#---------------------------------Result---------------------------------# 

                                  Success                                  

#-----------------------------Remove modules-----------------------------# 

                              program(1.0.0)                               

#-----------------------------Control[Delay]-----------------------------# 

                        Wait for 1000 milliseconds                         

#------------------------------Control[loop]-----------------------------# 

                              Repeated 3 of 3                              

#---------------------------Result of execution--------------------------# 

                                  Success                                  

#------------------------------------------------------------------------#
```

You can define in all the cases the delay between executions, run even if the last execution finished with a non-success value or a manual prompt to continue, these are the properties:

- manual
- delay
- force

In all the cases, you can force the end of the execution, pause or creation of a note. To do it you need to write a file in the commands path:

- pause
- note
- break

The default path of the commands is **(current directory)/.candy/control/commands

**Note:** You can override the commands path using the property *commandspath* in the JSON file.