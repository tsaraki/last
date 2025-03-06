# last command
## solving problem of

if you tired of setupping your powershell every day before actual coding
from home to work to laptop to home to git to someone else, just use last (wip)

last command allowing you to get to your last project *blazing fast*

it managing your project by volumes, storing all of your project (mainly code)
at specified locations, and if you dont have time to save project to usb flash
type: "last save" (not implemented yet) and ready to go

## so many things are going to have

## prefered editor is helix-editor
https://github.com/helix-editor/helix

## semver

### major version control is left to the user

major versioning is debatable, but it mostly done by pr stuff and general feelings
so we will not support it

### minor version control

last command have this semver template "v1-feature", if feature is not set, default is dev
your dir tree will be look like:

- lang
  - project
    - v1-dev
    - v1-tokenizer
    - v1-parser
    - v1-merged (not implemented yet)
    - v2-dev

### patch version is a feature

last would have git action, so it will be calculated automatically

## actions

  ### last

   - cd path/to/your/last/project

  ### last config

   - cd APPDATA/last
   - editor config.txt

  ### last open

   - cd path/to/your/last/project
   - editor subdir? filepath1 filepath2 --vsplit
  
## usage

creating powershell profile if it not set

```
if (!(Test-Path -Path $profile)) {
  New-Item -ItemType File -Path $PROFILE -Force
}
```

clonning repository and adding code to $profile
```
git clone https://github.com/tsaraki/last
cd last
cat last.ps1 >> $profile
```
