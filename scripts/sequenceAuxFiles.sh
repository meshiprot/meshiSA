#!/bin/sh

if [ $# -ne 3 ]; then
  echo "Uasage: [App Name] [Target name] [Decoy Name] [Path]"
  exit
fi

target_name=$1
decoyPath=$2
outputPath=$3

 echo "java -cp $APP_PATH/meshi.jar programs.Pdb2Fasta"
java -cp $APP_PATH/meshi.jar programs.Pdb2Fasta
 mv  $decoyPath.fasta  $outputPath/$target_name.fasta

echo "$APP_SCRIPTS/sequenceAuxCalc.sh $outputPath/$target_name.fasta"
$APP_SCRIPTS/sequenceAuxCalc.sh $outputPath/$target_name.fasta  # calculate blast files

if [ -e $outputPath/$target_name.fasta.acc.out ]; then
  acc_seq=`cat $outputPath/$target_name.fasta.acc.out | head -2 | tail -1 | wc -m`
  acc_pred=`cat $outputPath/$target_name.fasta.acc | wc -m`

  if [ $acc_seq -eq $acc_pred ]; then
    ln -s  $outputPath/$target_name.fasta.acc.out  $outputPath/sasaPrediction
  else 
    echo "Error - solvation accessability file $target_name.fasta.acc.out sequence prediction wasn't calculated."
    exit
  fi
else
  echo "Error - solvation accessability file $target_name.fasta.acc.out doesn't exist."
  exit
fi


if [ -e $outputPath/$target_name.fasta.ss2 ]; then
  ln -s  $outputPath/$target_name.fasta.ss2  $outputPath/secondaryStructurePrediction
else
  echo "Error - secondary structure prediction file $outputPath/$target_name.fasta.ss2 doesn't exist."
  exit
fi


