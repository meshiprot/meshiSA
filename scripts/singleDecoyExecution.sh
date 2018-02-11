#!/bin/sh

AUX_PATH=${APP_PATH}/aux/
APP_SCRIPTS=${APP_PATH}/scripts/

export APP_SCRIPTS
export APP_PATH 
if [ $# -eq 2 ]; then
  decoy_path=$1
  out=$2
else
  echo "Usage: [App Name] [Decoy Path]"
  exit
fi



echo "Copying Decoy $decoy_path ..."
cp $decoy_path $out


iDecoy=`basename $decoy_path`  
sDecoy=`basename $iDecoy | sed -e 's/.\w*$//' `.scwrl.pdb 
t=`echo $iDecoy | sed '$s/.\w*$//'`
output_filename=`echo $sDecoy | sed '$s/.\w*$//'`.dssp

# Blast , secondary structure prediction and solvent accessability
currPWD=`pwd -P`
cd $out

echo "$APP_SCRIPTS/sequenceAuxFiles.sh $t $out/$iDecoy $out"
$APP_SCRIPTS/sequenceAuxFiles.sh $t $out/$iDecoy $out


cd $currPWD
if [ ! -e $out/${t}.fasta ]; then
  echo "Error - fasta file doesn't exists."
  exit
fi


# Scwrl files

echo "$APP_PATH/aux/scwrl4/Scwrl4 -i $out/$iDecoy -o $out/$sDecoy > $out/${sDecoy}.scwrl"
$APP_PATH/aux/scwrl4/Scwrl4 -i $out/$iDecoy -o $out/$sDecoy > $out/${sDecoy}.scwrl

if [ ! -e $out/$sDecoy ]; then
  echo "Error - Scwrl4 file doesn't exists."
  exit
fi

# Dssp files

echo "$APP_PATH/aux/dssp/dsspcmbi $out/$sDecoy > $out/$output_filename"
$APP_PATH/aux/dssp/dsspcmbi $out/$sDecoy > $out/$output_filename

if [ ! -e $out/$output_filename ]; then
  echo "Error - Dssp file doesn't exists."
  exit
fi


