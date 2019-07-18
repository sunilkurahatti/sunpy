#! /bin/ksh

print -R $@

for arg in "$@"
do
   case $arg in
      --workflow) shift
                  workflow=$1
                  shift
                  ;;
      --folder)   shift
                  folder=$1
                  shift
                  ;;
      --batch)   shift
                 batch=$1
                 shift
                 ;;
      --context) shift
                 context=$1
                 shift
                 ;;
   esac
done

print "Workflow: $workflow"
print "Folder  : $folder"
print "Batch   : $batch"
print "Context   : $context"

exit $?
