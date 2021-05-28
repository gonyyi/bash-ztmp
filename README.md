# zTmp

(c) 2021 Gon Y Yi. https://gonyyi.com.
Apache License 2.0

zTmp is a bash script that helps to create and manage temporary directories for 
daily task.


## Installation

```sh
# download ztmp
git clone https://github.com/gonyyi/bash-ztmp.git
cd bash-ztmp

# install
./install-ztmp.sh

# zTmp install
# (c)Gon Y. Yi (gonyyi.com)
# 
# Install location:
#   (1) bash
#   (2) zshrc
# Where to install? (1/2): 1
# Installing for bash
# [OK] Copy script to home directory (/Users/myName/)
# [OK] successfully added to /Users/myName/.bashrc
```

__NOTE:__ After installation, you restart the bash or zsh to have this applied.


## Usage

`ztmp <COMMAND> <OPTIONAL PARAM>`

Commands

- `help`: help menu
- `new`: create new, `ztmp new test1`
- `go`: go to tmp dir created, `ztmp go test1`
    - Partial name can be used, `ztmp go t1` (go to `test1`)
- `last`: go to the last tmp folder created, `ztmp last`
- `today`: list tmp folder created today, `ztmp today`
- `list` or `-ls`: list tmp folders, `ztmp list`
- `find` or `-f`: search tmp folders, `ztmp find t1`
    - This will search tmp folders as well as archived folders.
- `remove` or `-rm`: remove current tmp folder, `ztmp remove`
    - This can only be used inside the target tmp directory.
    - This moves the current tmp directory into trash folder set from
        the `.bashrc-ztmp.sh` file. -- Default: `~/ztmp/.trash/`
- `archive` or `-a`: archive current tmp folder, `ztmp archive`
    - This moves the current tmp directory into archived folder set from
        the `.bashrc-ztmp.sh` file. -- Default: `~/ztmp/archive/`


### ztmp new

To create a temporary directory called "test", a command `ztmp new test` 
will create the directory and `cd` to the newly created directory.

```sh
~ $ ztmp new test
Created /Users/myName/zTmp/2021-0528-test
~/zTmp/2021-0528-test $ 
```


### ztmp go

The `go` option takes you to the directory without the full path.
Assume you have following temp folders in your ztmp directory:

```sh
~ $ ztmp -ls
/Users/myName/zTmp/2021-0528-blahblah/
/Users/myName/zTmp/2021-0528-myTest/
/Users/myName/zTmp/2021-0528-test/
```

Command `ztmp go test` will take you to the first directory (`2021-0528-test`),
as there aren't any other candidate with the name matching with "test".

But, if you try `ztmp go est`, both `2021-0528-myTest` and `2021-0528-test`
matches with `est. Therefore it will give a suggestions as below:

```sh
~ $ ztmp go est 
More than 1 result (total of 2):

/Users/myName/zTmp/2021-0528-myTest/
/Users/myName/zTmp/2021-0528-test/
```


### ztmp rm

__Note:__ This can be used only inside the tmp directory.

One removed, it will be moved to designated trash directory. 
(default: `.trash`)

```sh
~ $ ztmp go test
~/zTmp/2021-0528-test $ ztmp remove
Successfully moved /2021-0528-test to trash (.trash)
~ $ ls .trash 
2021-0528-test
~ $
```


### ztmp archive

__Note:__ This can be used only inside the tmp directory.

One removed, it will be moved to designated archive directory. 
(default: `archive`)

```sh
~ $ ztmp go est
~/zTmp/2021-0528-myTest $ ztmp archive
Successfully moved /2021-0528-myTest to archive (archive)
~ $ ls archive
2021-0528-myTest
~ $
```
