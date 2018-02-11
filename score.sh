#!/bin/sh

APP_PATH=/home/cluster/users/siditom/code/meshiSA_v1.2
export APP_PATH

if [ $# -lt 1 ]; then
	echo "USAGE: [APP_NAME] [DECOY PATH] [0/1 - remove tmp folder]"
	exit
fi
remove_tmp=1
if [ $# -eq 2 ]; then
	remove_tmp=$2
fi
decoy_path=`realpath $1`

t="`basename $decoy_path`.$$"
out=`dirname $decoy_path`"/$t"
mkdir $out

${APP_PATH}/scripts/singleDecoyExecution.sh ${decoy_path} $out  &> $out/meshi.log 

# Feature Extraction - Meshi Package Execution
cd $out
iDecoy=`basename $decoy_path`
sDecoy=`basename $iDecoy | sed -e 's/.\w*$//' `.scwrl.pdb

echo "java -Xmx4000m -jar $APP_PATH/meshi9.38_light.jar -commands=$APP_PATH/commands -inFileName=$sDecoy" >>  $out/meshi.log
java -Xmx4000m -jar $APP_PATH/meshi9.38_light.jar -commands=$APP_PATH/commands -inFileName=$sDecoy

if [ ${remove_tmp} -eq 1 ]; then
	cd ..
	rm -r $out
fi
