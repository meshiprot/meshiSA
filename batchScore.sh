#!/bin/sh

APP_PATH=/home/cluster/users/siditom/code/meshiSA/new/meshiBatch
AUX_PATH=${APP_PATH}/aux/
APP_SCRIPTS=${APP_PATH}/scripts/

export APP_SCRIPTS
export APP_PATH

if [ $# -ne 1 ]; then
  echo "USAGE: [APP NAME] [Large PDB file]"
  exit
fi
pdb=$1

# step 1 - generate sequence data 
dir=`dirname $pdb`
cd $dir
out=`pwd -P`


iDecoy=`basename $pdb`  
t=`echo $iDecoy | sed '$s/.\w*$//'`
pdb=$out/${t}.pdb

if [ ! -e $out/${t}.fasta ]; then
  echo "Error - fasta file $out/${t}.fasta doesn't exists."
  exit
fi

# Blast , secondary structure prediction and solvent accessability
echo "$APP_SCRIPTS/sequenceAuxFiles.sh $t $out/$iDecoy $out"
$APP_SCRIPTS/sequenceAuxFiles.sh $t $out/$iDecoy $out



# step 2 - init pdb
java -cp $APP_PATH/meshi.jar programs.InitPdbIndex -inFileName=$pdb -nModels=100



# step 3 - create a file with the execution lines corresponding to the index file.
numOfGroups=`head -10 ${pdb}.inx | grep "Number Of Groups In PDB File: " | awk '{print $NF}'`
for iGroup in $(seq 1 $numOfGroups)
do
	echo "MALLOC_ARENA_MAX=2; java -XX:ParallelGCThreads=1 -XX:MaxRAM=4g -XX:MinRAMFraction=128 -XX:MaxRAMFraction=16 -XX:InitialRAMFraction=128 -Xms4000m -Xmx4000m -cp $APP_PATH/meshi.jar programs.BatchMeshi -commands=$APP_PATH/commands -inFileName=$pdb -iGroup=$iGroup -seed=$RANDOM -out=$out/" >> meshi_execs.dat
done
