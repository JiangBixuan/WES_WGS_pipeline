#! /usr/bin/perl -w
$j=1;
open IN,$ARGV[0]||die;
while(<IN>){
	chomp;
	$i=$_;
	$na=$i;
	$na=~s/.*\///g;
	push @name,'name'.$j.'='.$na;
	$ss=`ls /home/zhujh/biliary_atresia/$i/*_1.clean.fq.gz`;
	$ss=~s/\n/ /g;
	$out=$ss;
	$out=~s/_1.clean.fq.gz/_2.clean.fq.gz/g;
	$out=~s/\n/ /g;
	$out1= "$ss:$out";
	$out1=~s/ :/:/g;
	push @fq, 'fq'.$j.'='."$out1";
	push @dir,'dir'.$j.'=/home/zhujh/biliary_atresia/';
	$j++;

}
$out1=join("\n",@name);
$out2=join("\n",@dir);
$out3=join("\n",@fq);
print "[Sample.name]\n$out1\n[Sample.dir]\n$out2\n[Sample.data]\n$out3\n"

