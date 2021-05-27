#!/bin/sh

# ztmp 1.0.0
# (c) gon y. yi (gonyyi.com/copyright.txt)

# Setup
# 1. COPY this file to ~/.bashrc-ztmp
# 2. ADD `source ~/.bashrc-ztmp` to .bashrc or .zshrc
ztdir="/Users/gonyi/zTmp"
ztdir_archive="archive"
ztdir_trash=".trash"

ztmp() {
    # echo "used <$1>"

    if [ -z $1 ]; then
        cd $ztdir
        return 0; 
    fi 


    if [ $1 = "help" ] || [ $1 = "-help" ]; then
        echo "Usage: ztmp <new|go|find|help|last|ls|list|today|rm|archive> <optional>";
        return 0;
    fi 

    if [ $1 = "new" ]; then
        if [ -z $2 ]; then 
            echo "Usage: ztmp new <Name>"
            return 1;
        fi         
        # replace single occurance: ${VAR/word1/word2}
        # replace all occurance: ${VAR//word1/word2}
        # `$*` for all arguments with space
        today=$(date +"%Y-%m%d");
        today="$today $*"
        new_folder_name="${today// /-}"
        mkdir -p "$ztdir/$new_folder_name"
        if [ $? -ne 0 ]; then
            echo "Error: cannot created <$ztdir/$new_folder_name>"
            return 1 
        fi
        echo "Created $ztdir/$new_folder_name"
        cd $ztdir/$new_folder_name
        return 0; 
    fi

    if [ $1 = "search" ] || [ $1 = "find" ] || [ $1 = "-f" ]; then 
        if [ -z $2 ]; then 
            echo "Usage: ztmp <find|search|-f> <Name>"
            return 1;
        fi 
        
        ansiWhite="\033[1;37m"
        ansiNone="\033[0m"
        foundAny=0

        lastCreatedDir=$(ls -1dtU $ztdir/*/ | grep $2)
        howMany=$(echo $lastCreatedDir | wc -l | xargs)
        if [ $howMany -eq 1 ] && [ -z $lastCreatedDir ]; then 
            howMany=0;
        else
            foundAny=1
            echo "${ansiWhite}zTmp: (total: $howMany)${ansiNone}\n$lastCreatedDir"
        fi

        
        lastCreatedDir=$(ls -1dtU $ztdir/$ztdir_archive/*/ | grep $2)
        howMany=$(echo $lastCreatedDir | wc -l | xargs)
        if [ $howMany -eq 1 ] && [ -z $lastCreatedDir ]; then 
            howMany=0;
        else
            foundAny=1
            echo "${ansiWhite}Archive: (total: $howMany)${ansiNone}\n$lastCreatedDir"
        fi

        if [ $foundAny -lt 1 ]; then
            echo "Did not find <$2>"
            return 1
        fi 
        return 0;
    fi

    if [ $1 = "go" ]; then 
        if [ -z $2 ]; then 
            echo "Usage: ztmp go <Name>"
            return 1;
        fi 

        lastCreatedDir=$(ls -1dtU $ztdir/2*/ | grep $2)
        # xargs will trim the space coming from `wc -l`
        howMany=$(echo $lastCreatedDir | wc -l | xargs)

        if [ $howMany -eq 1 ] && [ -z $lastCreatedDir ]; then 
            howMany=0;
        fi

        if [ $howMany -eq 0 ]; then 
            echo "No result for <$2>"
            return 1;
        fi

        if [ $howMany -eq 1 ]; then 
            cd $lastCreatedDir;
            return 0;
        fi
        
        echo "More than 1 result (total of $howMany):\n"
        echo $lastCreatedDir
        return 1;
    fi

    if [ $1 = "last" ] || [ $1 = "-l" ]; then 
        # 2*/, so archive or other folders won't be catched
        lastCreatedDir=$(ls -1dtU $ztdir/2*/ | head -1)
        echo "Go to last: $lastCreatedDir"
        cd $lastCreatedDir
        return 0
    fi

    if [ $1 = "list" ] || [ $1 = "-ls" ]; then 
        if [ "$#" -gt 1 ]; then 
            lastCreatedDir=$(ls -1dtU $ztdir/2*/ | grep $2)
        else
            lastCreatedDir=$(ls -1dtU $ztdir/2*/)
        fi 
        echo $lastCreatedDir
        return 0
    fi

    if [ $1 = "today" ]; then 
        lastCreatedDir=$(ls -dltr $ztdir/2*/ | awk '{print $6,$7,$8,$9}' | grep "$(date '+%b %e')")
        echo "Last Created directories in <$ztdir>:"
        echo $lastCreatedDir
        return 0
    fi


    if [ $1 = "rm" ] || [ $1 = "archive" ] || [ $1 = "-a" ]; then 
        # get current dir; remove prefix (of ztmp dir)
        currDir=$(pwd)
        currDirShort=${${currDir}#"$ztdir"}
        
        if [ "$currDir" = "$currDirShort" ]; then
            echo "Error: this is not a zTmp directory."
            return 1    
        fi

        if [ "$currDir" = "$ztdir" ]; then
            echo "Error: cannot remove or move ztmp directory itself.";
            return 1
        fi 

        if [ "$currDir" = "$ztdir/$ztdir_archive" ] || [ "$currDir" = "$ztdir/$ztdir_trash" ]; then
            echo "Error: cannot remove or move speical ztmp directory.";
            return 1
        fi 


        if [ "$1" = "archive" ] || [ "$1" = "-a" ]; then 
            mkdir -p "$ztdir/$ztdir_archive"
            cd .. 
            mv $currDir $ztdir/$ztdir_archive/
            ret=$?
            if [ $ret -eq 0 ]; then 
                echo "Successfully moved $currDirShort to archive ($ztdir_archive)"
                return 0 
            else 
                echo "Failed, retCode=$ret"
                return 1 
            fi
        fi

        if [ "$1" = "rm" ]; then 
            # Now it can be deleted
            if [ "$#" -gt 1 ] && [ "$2" = "-y" ]; then 
                mkdir -p "$ztdir/$ztdir_trash"
                cd .. 
                mv $currDir $ztdir/$ztdir_trash/
                ret=$?
                if [ $ret -eq 0 ]; then 
                    echo "Successfully moved $currDirShort to trash ($ztdir_trash)"
                    return 0 
                else 
                    echo "Failed, retCode=$ret"
                    return 1 
                fi
            fi 
            echo "Use -y option to delete this tmp folder"
            echo "CurrDir: <$currDir>"
            return 0
        fi 
    fi
}