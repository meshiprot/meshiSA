#!/bin/sh

blastdir=$APP_PATH/aux/blast/bin/
psipredExec=$APP_PATH/aux/psipred25/bin/
psipredData=$APP_PATH/aux/psipred25/data/
dbname=$APP_PATH/aux/uniref90/uniref90.fasta
sspro4Exec=$APP_PATH/aux/sspro4/script/

if [ $# -ne 1 ]; then
  echo "Input fasta sequence file is missing."
  exit
fi
echo "$!"
input_file=$1

#remove spaces in fasta file. the predict_acc.sh method of the sspro4 program requires a fasta file of a single line.
cat $input_file | tail -n +2 | tr -d '\n' > $input_file.tmp1
cat $input_file | head -1 > $input_file.tmp2

cat $input_file.tmp2 > $input_file.tmp
cat $input_file.tmp1 >> $input_file.tmp 
rm -f $input_file.tmp1 $input_file.tmp2

mv $input_file.tmp $input_file.nospaces
mv $input_file $input_file.tmp
mv $input_file.nospaces $input_file



#creating blast alignent files and different auxilary files
base_name=`basename $input_file`

if [ ! -f ".ncbi" ]; then
	echo "[ncbi]" > .ncbirc
	echo "Data=${blastdir}/../data/" >> .ncbirc	
fi

echo "$blastdir/blastpgp -a 8 -j 3 -h 0.001 -d $dbname -F F -i $input_file -C $input_file.chk -o $input_file.blastpgp -Q $input_file.psi > /dev/null"
$blastdir/blastpgp -a 8 -j 3 -h 0.001 -d $dbname -F F -i $input_file -C $input_file.chk -o $input_file.blastpgp -Q $input_file.psi > /dev/null #& $rootname.blast
echo "Running Makemat..."
echo $base_name.chk > $input_file.pn
echo $base_name > $input_file.sn


$blastdir/makemat -P $input_file

#psiPred - predicting secondary structure of the target sequence.
echo "Predicting secondary structure..."
echo Pass1 ...

$psipredExec/psipred $input_file.mtx $psipredData/weights.dat $psipredData/weights.dat2 $psipredData/weights.dat3 $psipredData/weights.dat4 > $input_file.ss

echo Pass2 ...

$psipredExec/psipass2 $psipredData/weights_p2.dat 1 1.0 1.0 $input_file.ss2 $input_file.ss 

#predicting solvent accessablity
# echo "$sspro4Exec/predict_acc.sh $input_file $input_file.acc.out"
echo "$sspro4Exec/predict_acc.pl $blastdir $sspro4Exec/../data/big/big_98_X $sspro4Exec/../data/nr/nr $sspro4Exec/../server/predict_seq_sa.sh $sspro4Exec/../script/ $input_file $input_file.acc.out"

$sspro4Exec/predict_acc.pl $blastdir $sspro4Exec/../data/big/big_98_X $sspro4Exec/../data/nr/nr $sspro4Exec/../server/predict_seq_sa.sh $sspro4Exec/../script/ $input_file $input_file.acc.out

# $sspro4Exec/predict_acc.sh $input_file $input_file.acc.out
cat $input_file.acc.out |tail -n 1 > $input_file.acc

mv $input_file $input_file.nospaces
mv $input_file.tmp $input_file 


