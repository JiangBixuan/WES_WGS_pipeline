for i in DX120004 DX120005 DX120006 DX120008 DX120009 DX120010
do
 
name=$i

outpath4step=/home/zhouwei/zhou_data/WES/GermlineVariantCalling
inputtarget=/home/zhouwei/zhou_data/WES/mappingAndCleanUp/${name}.recal.bam
outtarget=${name}.raw.gvcf.gz

GATK=/home/zhouwei/software/GenomeAnalysisTK-3.8/GenomeAnalysisTK.jar
Java=/usr/bin/java
ref=/home/RefData/reference/ucsc.hg19.fasta
dbsnp=/home/RefData/dbsnp/dbsnp_138.hg19.vcf
bait=/home/RefData/AgilentTarget/SureSelect_Exon_V6_Covered.interval_list

vcftype=gvcf
datatype=WES

for file in ${inputtarget}
do
if [ ! -f "${file}" ]; then
	echo -e the target file ${file} cannot be generated successfully!!
	exit 0
fi
done

echo -e The Step GermlineVariantCalling started at `date` "\n" >>${outpath4step}/run.log;

if [ ${vcftype} == gvcf ] ;then 
${Java} -jar ${GATK} -T HaplotypeCaller \
	-R ${ref} -I ${inputtarget} \
	-L $bait \
	-variant_index_type LINEAR -variant_index_parameter 128000 \
	-o ${outpath4step}/${name}.raw.gvcf.gz -ERC GVCF \
	
else
${Java} -jar ${GATK} -T HaplotypeCaller \
	-R ${ref} -I ${inputtarget} \
	 -o ${outpath4step}/${name}.raw.vcf \
	-stand_call_conf 30 --dbsnp ${dbsnp}  
fi

echo -e The Step GermlineVariantCalling ended at `date` "\n" >>${outpath4step}/run.log;

for file in ${outpath4step}/${outtarget}
do
if [ ! -f "${file}" ]; then
	echo -e the target file ${file} cannot be generated successfully!!
	exit 0
fi
done

mv ${outpath4step}/run.log ${outpath4step}/GermlineVariantCalling.log
done
