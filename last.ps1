[hashtable]$stores = @{}

[hashtable]$projs = @{}

[hashtable]$langs = @{}

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
        Last-Set-Location
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
        
    }

	# echo "$action $prop $v"
}

function Last-Set-Location {
    Set-Location -Path "$($last[0])/$($last[1])/$($last[2])/v$($last[3])-$($last[4])/"
}


function Last-Config-Parse {

	$config_check = Last-Config-Check
	if ($config_check) {
		echo "Config just created"
		return
	}
	
	$config_file = Get-Content -Path $Env:APPDATA/last/config.txt

    $last_count = 0
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
                if ($last_count -eq 0) {
                    $root = (Get-PSDrive | Where-Object {$_.Description -eq $store}).Root
                    
                    $store_loc = $stores[$store]
                    $last[0] = "${root}$store_loc"
                    $last[1] = $($line_arr[1])
                    $last[2] = $($line_arr[2])
                    $last[3] = $($line_arr[3])
                    $last[4] = $($line_arr[4])
                    $last_count = 1
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

New-Alias -Force last Last-Parse-Line
Last-Config-Parse

