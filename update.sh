#!/bin/bash

# u - Undeclared variables
# x - Trace
set -ux

# CLI configurables
verbosity=""
arg_git_dir=""

# Function return codes
environment_directory_exists_return=0

while getopts "d:hv" opt; do
  case "$opt" in
    d)
      arg_git_dir=$OPTARG
      ;;
    h)
      echo "Usage:"
      echo "$0 -d <git-directory>"
      echo
      echo "Clone / update Rascal999 git repos"
      echo "-d Absolute git directory on local machine"
      echo
      exit
      ;;
    v)
      verbosity="v"
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      ;;
  esac
done

if [[ "$arg_git_dir" == "" ]]; then
   echo "Do you need (-h)elp?"
   exit
fi

# Script variables

# Error codes
ERR_1="Error 1: Missing argument"
ERR_2="Error 2: Must be run as root!"
ERR_3="Error 3: Directory already exists"
ERR_4="Error 4: Directory does not exist"
ERR_5="Error 5: Utility not available"
ERR_50="Error 50: Environment related error"
ERR_100="Error 100: Inventory related error"
ERR_150="Error 150: Action related error"
ERR_151="Error 151: Git clone failed"
ERR_152="Error 152: Git pull failed"

###
### MISC FUNCTIONS
###

function environment_directory_exists()
{
   if [[ $# == 0 ]]; then
      exit_error 1
   fi

   if [[ ! -d $1 ]]; then
      exit_error 3
   fi
}

function environment_directory_not_exist()
{
   if [[ $# == 0 ]]; then
      exit_error 1
   fi

   if [[ -d $1 ]]; then
      exit_error 4
   fi
}

function environment_distribution()
{
   # Should probobly include checks for /etc/* if lsb_release unavailable
   determine_distribution_command=$(lsb_release -a 2>/dev/null)
   determine_distribution_result=$(echo $?)

   determine_distribution_is_debian=$(echo $determine_distribution_command | grep "Distributor ID" | grep -i "Debian" | wc -l)
   determine_distribution_is_redhat=$(echo $determine_distribution_command | grep "Distributor ID" | grep -i "CentOS" | wc -l)
      
   if [[ "$determine_distribution_is_debian" == "1" ]]; then
      global_distribution="debian"
   fi
   
   if [[ "$determine_distribution_is_redhat" == "1" ]]; then
      global_distribution="redhat"
   fi 
      
   # Check the files
   if [[ "$determine_distribution_result" != 0 ]]; then
      if [[ -f "/etc/debian_version" ]]; then
         global_distribution="debian"
         determine_distribution_result=0
      fi

      if [[ -f "/etc/redhat-release" ]]; then
         global_distribution="redhat"
         determine_distribution_result=0
      fi
   fi

   if [[ "$determine_distribution_result" != 0 || "$global_distribution" == "" ]]; then
      exit_error 101
   fi
}

function environment_utility_exists()
{
   if [[ $# == 0 ]]; then
      exit_error 1
   fi

   environment_utility_exists_command=$(which $1)
   environment_utility_exists_result=$(echo $?)

   if [[ "$environment_utility_exists_result" != "0" ]]; then
      echo "Missing utility: $1"
      exit_error 5
   fi
}

###
### ENVIRONMENTAL FUNCTIONS
###

function environment_a_func()
{
   environment_a_func_command=$(echo $FUNCNAME)
   environment_a_func_result=$(echo $?)

   if [[ "$environment_a_func_result" != 0 ]]; then
      exit_error 50
   fi
}

###
### INVENTORY FUNCTIONS
###

function determine_a_func()
{
   environment_a_func_command=$(echo $FUNCNAME)
   environment_a_func_result=$(echo $?)

   if [[ "$environment_a_func_result" != 0 ]]; then
      exit_error 100
   fi
}

###
### ACTION FUNCTIONS
###

function action_git_clone()
{
   action_git_clone_command=$(git clone https://github.com/rascal999/${1}.git ${arg_git_dir}/${1} 2>/dev/null)
   action_git_clone_result=$(echo $?)

   # git dir already exists
   if [[ "$action_git_clone_result" == 128 ]]; then
      echo "Clone of ${1} already exists"
      return 0
   fi

   if [[ "$action_git_clone_result" != 0 ]]; then
      exit_error 151
   fi

   echo "Clone of ${1} complete"
}

function action_git_pull()
{
   action_git_pull_result=$(git --git-dir=${arg_git_dir}/${1}/.git pull)
   action_git_pull_result=$(echo $?)

   if [[ "$action_git_pull_result" != 0 ]]; then
      exit_error 152
   fi

   echo "Pull of ${1} complete"
}

###
### META FUNCTIONS
###

function exit_error
{
   case "$1" in
      1) echo $ERR_1
         exit $1
         ;;
      2) echo $ERR_2
         exit $1
         ;;
      3) echo $ERR_3
         exit $1
         ;;
      4) echo $ERR_4
         exit $1
         ;;
      5) echo $ERR_5
         exit $1
         ;;
      50) echo $ERR_50
         exit $1
         ;;
      100) echo $ERR_100
         exit $1
         ;;
      150) echo $ERR_150
         exit $1
         ;;
      151) echo $ERR_151
         exit $1
         ;;
      152) echo $ERR_152
         exit $1
         ;;
      0)
         ;;
      *) echo "Unknown error $1"
         exit 1
         ;;
   esac
}

function environment_steps
{
   environment_utility_exists "git"
   environment_directory_exists "$arg_git_dir"
}

function action_steps()
{
   action_git_pull "git-my-repos"

   action_git_clone "gameboy-emulator"
   action_git_pull "gameboy-emulator"

   action_git_clone "dotfiles"
   action_git_pull "dotfiles"

   action_git_clone "gitignore"
   action_git_pull "gitignore"

   action_git_clone "bash-template"
   action_git_pull "bash-template"

   action_git_clone "chess-games"
   action_git_pull "chess-games"

   action_git_clone "etc"
   action_git_pull "etc"
}

function main()
{
   environment_steps
   action_steps

   exit 0
}

# RUN!
main
