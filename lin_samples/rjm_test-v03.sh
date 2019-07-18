#! /bin/ksh

print -R $@

for arg in "$@"
do
   shift

   case $arg in
      --workflow)   workflow=$1 ;;
      --folder)     folder=$1 ;;
      --batch)      batch=$1 ;;
      --context)    context=$1 ;;
      --po_id)      po_id=$1 ;;
      --ds_conn)    ds_conn=$1 ;;
      --dw_conn)    dw_conn=$1 ;;
      --p_workflow) p_workflow=$1 ;;
      --eod_flg)    eod_flg=$1 ;;
   esac
done

print "Workflow   : $workflow"
print "Folder     : $folder"
print "Batch      : $batch"
print "Context    : $context"
print "Po Id      : $po_id"
print "DS Conn    : $ds_conn"
print "DW Conn    : $dw_conn"
print "P Workflow : $p_workflow"
print "EOD Flag   : $eod_flg"

exit $?
