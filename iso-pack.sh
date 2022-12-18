#!/bin/bash

usage()
{
cat << EOF
usage: $0 -f <FOLDER NAME> -o <ISO NAME> [-s] [-l] [-h]

REQUIRED:
   -o  ISO file output name
   -i  Folder path containing all the files to place in ISO 
HIDE FILES:
   -x  Single file name or file extension to hide (ex: *.dll OR test.dll)
   -f  File containing all the files to hide in ISO
OTHER:
   -l  List files in ISO after its been packed
   -q  Quiet Mode: Dont Show Tool Header

EOF
}

ToolHeader()
{
cat << EOF
┏━━┓┏━━━┓┏━━━┓━━━━┏━━━┓━━━━━━━━━┏┓━━
┗┫┣┛┃┏━┓┃┃┏━┓┃━━━━┃┏━┓┃━━━━━━━━━┃┃━━
━┃┃━┃┗━━┓┃┃━┃┃━━━━┃┗━┛┃┏━━┓━┏━━┓┃┃┏┓
━┃┃━┗━━┓┃┃┃━┃┃━━━━┃┏━━┛┗━┓┃━┃┏━┛┃┗┛┛
┏┫┣┓┃┗━┛┃┃┗━┛┃━━━━┃┃━━━┃┗┛┗┓┃┗━┓┃┏┓┓
┗━━┛┗━━━┛┗━━━┛━━━━┗┛━━━┗━━━┛┗━━┛┗┛┗┛
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
EOF
}

ListIsoContent()
{
  # View the contents of the ISO file including the hidden files
  isoinfo -l -i "$outName"
}

MakeISO_Single()
{
  echo "Packing ISO $outName and hiding the following file (type): $hide  "
  mkisofs -o "$outName" -input-charset utf-8 -r -J -D -V "$outName" -hidden "$hide" "$folder"
}

MakeISO_Multiple()
{
  echo "Packing ISO $outName and hiding the following list of files list in $listHide  "
  # Package an ISO file
  mkisofs -o "$outName" -input-charset utf-8 -r -J -D -V "$outName" -hidden-list "$listHide" "$folder"
}

MakeISO_Basic()
{
  echo "Packing Basic ISO: $outName "
  # Package an ISO file
  mkisofs -o "$outName" -input-charset utf-8 -r -J -D -V "$outName".iso "$folder"
}

unset -v outName
unset -v hide
unset -v folder
unset -v listHide
list="FALSE"
quiet="FALSE"

while getopts ho:x:i:f:lq opt; do
  case $opt in
    h) 
    usage
    exit 1 
    ;;
    o) outName=$OPTARG ;;
    x) hide=$OPTARG ;;
    i) folder=$OPTARG ;;
    f) listHide=$OPTARG ;;
    l) list="TRUE" ;;
    q) quiet="TRUE" ;;
    *)
    echo '*****ERROR: Missing Value*****' >&2
    usage
    exit 1
  esac
done

shift "$(( OPTIND - 1 ))"

if [ -z "$(which mkisofs)" ] || [ -z "$(which isoinfo)" ];
then
  echo "Please install mkisofs and isoinfo"
  exit 0
fi

if [ -z "$outName" ] || [ -z "$folder" ];
then
  echo '*****ERROR: Missing Required Parameters*****' >&2
  usage
  exit 1
fi

if [ -n "$listHide" ] && [ -n "$hide" ];
then
  echo '*****ERROR: Must provide either -l or -s *****' >&2
  usage
  exit 1
fi

if [ -n "$hide" ];
then
  if [ $quiet == "FALSE" ];
  then
    ToolHeader
  fi
  echo "Packing $folder into ISO named $outName"
  MakeISO_Single
fi

if [ -n "$listHide" ];
then
  if [ $quiet == "FALSE" ];
  then
    ToolHeader
  fi
  echo "Packing $folder into ISO named $outName"
  MakeISO_Multiple
fi

if [ -z "$listHide" ] && [ -z "$hide" ];
then
  if [ $quiet == "FALSE" ];
  then
    ToolHeader
  fi
  echo "Packing $folder into ISO named $outName"
  MakeISO_Basic
fi

if [ $list == "TRUE" ];
then
  ListIsoContent
fi

exit 0



