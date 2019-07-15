###Basic
cd /home/zhouwei/zhou_data/WES/VariantFiltering
mkdir Annotation
inputtarget=/home/zhouwei/zhou_data/WES/VariantFiltering/metsExon100.Filtered_INDEL.vcf
outpath4step=/home/zhouwei/zhou_data/WES/VariantFiltering/Annotation
outtarget=(${outpath4step}/metsExon100_INDEL.annovar.txt)
###software
annovar=/home/zhouwei/software/annovar
###reference
database=refGene,cytoBand,avsnp147,clinvar_20160302,cosmic70,1000g2015aug_all,1000g2015aug_afr,1000g2015aug_amr,1000g2015aug_eas,1000g2015aug_eur,1000g2015aug_sas,esp6500siv2_all,esp6500siv2_ea,esp6500siv2_aa,exac03,popfreq_max_20150413,cadd13gt20,gerp++gt2,dbnsfp30a,wgRna,targetScanS,genomicSuperDups,dgvMerged,gwasCatalog,tfbsConsSites,phastConsElements46way
operation=g,r,f,f,f,f,f,f,f,f,f,f,f,f,f,f,f,f,f,r,r,r,r,r,r,r
###inhouse_scripts
module_path=/home/limo/Pipelines/Modules

###Annotation.parameter
sample=multiple

for file in ${inputtarget[@]}
do
if [ ! -f "${file}" ]; then
	echo -e the target file ${file} cannot be generated successfully!!
	exit 0
fi
done
echo -e The Step Annotation started at `date` "\n" >>${outpath4step}/run.log;

if [ ${sample} == multiple ] ; then
	para1="-format vcf4 -allsample -withfreq"
	para2=metsExon100_INDEL.avinput
else
	para1="--format vcf4 --allsample"
	para2=annovar.metsExon100_INDEL.avinput
fi

perl ${annovar}/convert2annovar.pl --includeinfo ${para1} \
	--outfile ${outpath4step}/metsExon100_INDEL.avinput \
	${inputtarget}

perl ${annovar}/table_annovar.pl --buildver hg19 \
	--thread 6 --remove  --otherinfo \
	--protocol ${database} \
	-operation ${operation}  \
	-nastring . ${outpath4step}/${para2} ${annovar}/humandb \
	--outfile ${outpath4step}/metsExon100_INDEL.annovar
	-csvout > ${outpath4step}/metsExon100_INDEL.annovar.log

for file in ${outtarget[@]}
do
if [ ! -f "${file}" ]; then
	echo -e the target file ${file} cannot be generated successfully!!
	exit 0
fi
done
	
mv ${outpath4step}/run.log ${outpath4step}/annovar.log