[hashtable]$stores = @{}

[hashtable]$projs = @{}

[hashtable]$langs = @{}

[hashtable]$lasts = @{}

#root|lang|proj|version|feature
$last = @('', '', '', '', '')
$global:store = ""
$global:editor = ""
$global:open = ""
$global:open_subdir = ""

function Last-Parse-Line {
[CmdletBinding()]
Param ([parameter(Position=0)][string]$action,
	   [parameter(Position=1)][string]$prop,
							  [string]$v
)

    if (($action -eq "") -and ($prop -eq "") -and ($v -eq "")) {
        Last-Set-Location $last
    }

    if (($action -eq "config") -and ($prop -eq "") -and ($v -eq "")) {
        Invoke-Expression "$editor $Env:APPDATA/last/config.txt"
    }

    if (($action -eq "open") -and ($prop -eq "") -and ($v -eq "")) {
        if ($editor -eq "hx") {
            Last-Set-Location
            if ($global:open_subdir -ne "none") {
                cd $global:open_subdir
            }
            Invoke-Expression "$editor $open"
        }
    }

    if ($action -eq "set") {
        Last-Set-Action $prop $v
    }

    if ($action -eq "list") {
        Last-List
    }
    

    if (($action -eq "help") -and ($prop -eq "") -and ($v -eq "")) {
        echo 'info: Usage: last [action] [prop] [-v "value"]'
        echo ''
        echo 'Versioning: template "v1-feature"'
        echo 'major is up to user'
        echo 'minor is just number'
        echo 'patch is a feature'
        echo ''
        echo 'Commands:'
        echo ''
        echo 'last               cd path/of/proj'
        echo 'last config        editor APPDATA/last/config.txt'
        echo 'last open          cd path/of/proj'
        echo '                   editor subdir? pathfile1 pathfile2 --vsplit'
        echo 'last help          show this help'
        echo ''
        echo 'last [proj]        cd path/of/proj (proj name should be stored in config)'
        
    }

    if (($action -ne "") -and ($prop -ne "") -and ($v -eq "")) {
        Last-Set-Last $action $prop
    }

	# echo "$action $prop $v"
}

function Last-Set-Location {
Param (
    [array]$last_local
)
    Set-Location -Path "$($last_local[0])/$($last_local[1])/$($last_local[2])/v$($last_local[3])-$($last_local[4])/"
}


function Last-Config-Parse {

	$config_check = Last-Config-Check
	if ($config_check) {
		echo "Config just created"
		return
	}
	
	$config_file = Get-Content -Path $Env:APPDATA/last/config.txt

	foreach($line in $config_file) {
		if ($line -match $regex) {
			$line_arr = $line.split(" ")

			if ($($line_arr[0]) -eq "store") {
                $stores[$($line_arr[1])] = $($line_arr[2]) 
                if ($($line_arr[3]) -eq "default") {
                    $store = $($line_arr[1])
                }
			}

            if ($($line_arr[0]) -eq "proj") {
                $proj_name = $($line_arr[1])
                $proj_ver = $($line_arr[2])
                $proj_feature = $($line_arr[3])

                if (!($projs.ContainsKey($proj_name))) {
                    $projs[$proj_name] = [hashtable]@{}
                }
                $projs[$proj_name][$proj_ver] = $proj_feature
            }

            if ($($line_arr[0]) -eq "lang") {
                $langs[$($line_arr[1])] = $($line_arr[2])
            }

            if($($line_arr[0]) -eq "last_") {
                    $root = (Get-PSDrive | Where-Object {$_.Description -eq $store}).Root

                    $last_local = @('', '', '', '', '')
                    
                    $store_loc = $stores[$store]
                    $last_local[0] = "${root}$store_loc"
                    $last_local[1] = $($line_arr[1])
                    $last_local[2] = $($line_arr[2])
                    $last_local[3] = $($line_arr[3])
                    $last_local[4] = $($line_arr[4])

                    $lasts[@($($line_arr[1]), $($line_arr[2]))] = $last_local
                    if ($($line_arr[5]) -eq "1") {
                        $global:last = $last_local
                    }
                    

            }

            if ($($line_arr[0]) -eq "editor") {
                $global:editor = $($line_arr[1]) 
            }

            if ($($line_arr[0]) -eq "open") {
                $global:open = "$($line_arr[2]) $($line_arr[3]) --vsplit"
                $global:open_subdir = "$($line_arr[1])"
            }
		}

        
	}

}

function Last-Config-Save {
    #to rewrite last
    Set-Content -Path $Env:APPDATA/last/config.txt -Value (get-content -Path $Env:APPDATA/last.config.txt | Select-String -Pattern 'last_' -NotMatch)
    Out-File -Path $Env:APPDATA/last/config.txt -Append -Value "last_ $($last[0]) $($last[1]) $($last[2]) $($last[3])" 
}

function Last-Config-Check {
	$ret = $false
	if (!(Test-Path $Env:APPDATA/last)) {
		Set-Location -Path $Env:APPDATA
		New-Item -ItemType Derectory -Path $Env:APPDATA\last
		Set-Variable -Name ret -Value $true
	}

	if (!(Test-Path $Env:APPDATA/last/config.txt)) {
		Set-Location -Path $Env:APPDATA/last
		New-Item -ItemType File -Path $Env:APPDATA/last -Name "config.txt"
		Set-Variable -Name ret -Value $true
	}

	return $ret	
}

function Last-Set-Last {
Param (
    [string]$action,
    [string]$prop
)

    $search = @($action, $prop)
    foreach ($l in $lasts.GetEnumerator()) {
    
        $key = $($l.Name)
        $lang_local = $($key[0])
        $proj_local = $($key[1])

        if (($lang_local -eq $action) -and ($proj_local -eq $prop)) {
            Last-Set-Location $($lasts[($action, $prop)])
        }

    }

}

function Last-List {
    foreach($l in $lasts.GetEnumerator()) {
        $last_local = $($l.Value)
        echo "$($last_local[1])/$($last_local[2])/v$($last_local[3])-$($last_local[4])"
    }
}

New-Alias -Force last Last-Parse-Line
Last-Config-Parse

