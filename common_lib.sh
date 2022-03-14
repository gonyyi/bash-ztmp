# common_lib.sh
# Version:      v0.1.0
# WrittenBy:    Gon Yi
# LastUpdated:  3/10/2022
# Note:
#     This is a bash script but can have different extension intentionally to
#     avoid confusion if necessary. This is meant to be used by
#     `source common_lib.sh` command in bash scripts.

# ================================================================================
# COMMON
# ================================================================================

# get_today will return today's date in 20060102 format
cl_get_today() {
  echo "$(date +'%Y%m%d')"
}

# defaults will take two arguments, variable name, and default value.
# if variable not wasn't set, this will set its value to given default value.
# usage: cl_defaults DT_ID "no-id"
cl_defaults() {
  value=$(eval echo '$'$1)
  if [ -z "$value" ]; then
    eval "$1=$2";
    cl_log "DBG" "use default: $1=$2"
  else
    eval $1='$value';
  fi
}

# required will check if param has a value. If not, this will stop.
# usage: cl_required DT_ID
# usage: cl_required DT_ID "Param DT_ID can't be empty"
cl_required() {
  value=$(eval echo '$'$1)
  if [ -z "$value" ]; then
    if [ -z "$2" ]; then
      cl_log "FTL" "Missing a required param <$1>";
    else
      cl_log "FTL" "$2";
    fi
    exit 1;
  fi
}

# ================================================================================
# FILE / DIRECTORY
# ================================================================================

# is_file_exist to check if the file exists
# IF exist, returns 1
# ELSE returns 0
cl_is_file_exist() {
  if [ -f "$1" ]; then
    echo 1
  else
    echo 0
  fi
}

# is_dir_exist to check if the directory exists
# IF exist, returns 1
# ELSE returns 0
cl_is_dir_exist() {
  if [ -d "$1" ]; then
    echo 1
  else
    echo 0
  fi
}

# get_dir returns a directory of where this command is called
cl_get_dir() {
  if [ -z $1 ]; then
    echo $(dirname "$0")
  else
    echo $(dirname "$1")
  fi
}

# get_filename will return base filename
cl_get_filename() {
  if [ -z $1 ]; then
    echo $(basename "$0")
  else
    echo $(basename "$1")
  fi
}

# ================================================================================
# STRING
# ================================================================================

# to_lower converts arg to lowercase
cl_to_lower() {
  echo $1 | tr '[:upper:]' '[:lower:]'
}

# to_upper converts arg to uppercase
cl_to_upper() {
  echo $1 | tr '[:lower:]' '[:upper:]'
}

# is_number check if the arg is number or not.
# IF it's a number, this returns 1
# ELSE returns 0
cl_is_number() {
  if [ -n "$1" ] && [ "$1" -eq "$1" ] 2>/dev/null; then
    echo 1
  else
    echo 0
  fi
}

# has_prefix <string> <prefix>
# this returns 0: does not have the prefix
# this returns 1: has the prefix
cl_has_prefix() {
  if [[ $1 == "$2"* ]]; then
    echo 1
  else
    echo 0
  fi
}

# has_suffix <string> <suffix>
# this returns 0: does not have the suffix
# this returns 1: has the suffix
cl_has_suffix() {
  if [[ $1 == *"$2" ]]; then
    echo 1
  else
    echo 0
  fi
}

cl_get_length() {
  echo ${#1}
}

# ================================================================================
# LOGGING
# ================================================================================

# log will append current time and level
# Usage: ts INF Loading files  ==>  2022/03/03 15:01:02 [INF] Loading files
cl_log() {
  if [ "$1" != "DBG" ] || [ "$VERBOSE" = "1" ]; then
    echo "$(date +'%Y-%m-%d %H:%M:%S') [$1] ${@:2}"
  fi
}

# log_var will log variable
# Usage: cl_log_var INF USER_ID
cl_log_var() {
  value=$(eval echo '$'$2)
  cl_log "$1" "$2 = \"$value\""
}

# cl_log_var_ife will log variable if it's set (not "")
# Usage: cl_log_var_ife INF USER_ID
cl_log_var_ife() {
  value=$(eval echo '$'$2)
  if [ "$value" != "" ]; then
    cl_log "$1" "$2 = \"$value\"";
  fi
}

# iferr will stop if returned value wasn't 0
# usage: iferr
# usage: iferr <desc>
# usage: iferr <desc> <retCode>
cl_if_err() {
  res="$?"
  desc=""
  if [ "$1" != "" ]; then desc="$1: "; fi # desc if given
  if [ "$2" != "" ]; then res="$2"; fi    # for override: usage: exe_check $res
  if [ "$res" -ne "0" ]; then
    cl_log FTL "${desc}Failed (exit code: $res)"
    exit 1
  fi
}

# ================================================================================
# TEST COMPATIBILITY
# ================================================================================

# cl_check will check against functions above.
# currently logs aren't included here.
cl_check() {
  # get_today
  {
    _test_tmp=$(cl_get_today)
    if [ "${#_test_tmp}" != "8" ]; then
      echo "ERR-1000"
      exit 1
    fi
  }

  # defaults
  {
    _test_tmp=""
    cl_defaults _test_tmp "123" # if _test_tmp is empty, set it to 123
    # echo $_test_tmp # 123
    if [ "$_test_tmp" != "123" ]; then
      echo "ERR-1010"
      exit 1
    fi
    _test_tmp="abc"
    cl_defaults _test_tmp "123" # if _test_tmp is empty, set it to 123
    # echo $_test_tmp # abc
    if [ "$_test_tmp" != "abc" ]; then
      echo "ERR-1011"
      exit 1
    fi
  }

  # is_file_exist
  {
    _test_tmp="$0" # current filename
    if [ "$(cl_is_file_exist $_test_tmp)" != "1" ]; then
      echo "ERR-1020"
      exit 1
    fi
    _test_tmp="$0.abctest" # current filename
    if [ "$(cl_is_file_exist $_test_tmp)" != "0" ]; then
      echo "ERR-1021"
      exit 1
    fi # this should return 0
  }

  # is_dir_exist
  {
    _test_tmp="$(pwd)" # current directory
    if [ "$(cl_is_dir_exist $_test_tmp)" != "1" ]; then
      echo "ERR-1030"
      exit 1
    fi
    _test_tmp="$(pwd).abctest" # current filename
    if [ "$(cl_is_dir_exist $_test_tmp)" != "0" ]; then
      echo "ERR-1031"
      exit 1
    fi # this should return 0
  }

  # get_dir, get_filename
  {
    _test_tmp="/bin/sh"
    if [ "$(cl_get_dir $_test_tmp)" != "/bin" ]; then
      echo "ERR-1040"
      exit 1
    fi
    if [ "$(cl_get_filename $_test_tmp)" != "sh" ]; then
      echo "ERR-1041"
      exit 1
    fi
  }

  # strings
  {
    # to_lower, to_upper
    {
      _test_tmp="My name is Gon"
      if [ "$(cl_to_lower "$_test_tmp")" != "my name is gon" ]; then
        echo "ERR-1050"
        exit 1
      fi
      if [ "$(cl_to_upper "$_test_tmp")" != "MY NAME IS GON" ]; then
        echo "ERR-1051"
        exit 1
      fi
    }

    # is num
    {
      _test_tmp="123"
      if [ "$(cl_is_number $_test_tmp)" != "1" ]; then
        echo "ERR-1060"
        exit 1
      fi
      _test_tmp="123a"
      if [ "$(cl_is_number $_test_tmp)" == "1" ]; then
        echo "ERR-1061"
        exit 1
      fi
    }

    # has_prefix, has_suffix
    {
      _test_tmp="hello this is gon bye"
      if [ $(cl_has_prefix "$_test_tmp" "hello") != "1" ]; then
        echo "ERR-1070"
        exit 1
      fi
      if [ $(cl_has_prefix "$_test_tmp" "hola") != "0" ]; then
        echo "ERR-1071"
        exit 1
      fi
      if [ $(cl_has_suffix "$_test_tmp" "bye") != "1" ]; then
        echo "ERR-1072"
        exit 1
      fi
      if [ $(cl_has_suffix "$_test_tmp" "bye-") != "0" ]; then
        echo "ERR-1073"
        exit 1
      fi
    }

    # get_length
    {
      if [ $(cl_get_length "gon yi") != 6 ]; then
        echo "ERR-1080"
        exit 1
      fi
      if [ $(cl_get_length 1234) != 4 ]; then
        echo "ERR-1081"
        exit 1
      fi
    }
  }
}
