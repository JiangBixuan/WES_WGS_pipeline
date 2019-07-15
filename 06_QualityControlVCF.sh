###Basic
name=metsExon100
cd /home/zhouwei/zhou_data/WES/VariantFiltering

outpath4step=/home/zhouwei/zhou_data/WES/VariantFiltering
inputtarget=(/home/zhouwei/zhou_data/WES/VariantFiltering/${name}.recalibrated.vcf)
outtarget=(${outpath4step}/${name}.Filtered_SNP.vcf)

###software
GATK=/home/zhouwei/software/GenomeAnalysisTK-3.8/GenomeAnalysisTK.jar
Java=/usr/bin/java
plink=~/miniconda3/bin/plink

###QualityControlVCF.parameter
method=VQSR

###reference
ref=/home/RefData/reference/ucsc.hg19.fasta
dbsnp=/home/RefData/dbsnp/dbsnp_138.hg19.vcf
ped=/home/zhouwei/zhou_data/WES/VariantFiltering/metsExon100.ped

###inhouse_scripts
module_path=/home/limo/Pipelines/Advanced_Modules

for file in ${inputtarget[@]}
do
if [ ! -f "${file}" ]; then
	echo -e the target file ${file} cannot be generated successfully!!
	exit 0
fi
done
echo -e The Step QualityControlVCF started at `date` "\n" >>${outpath4step}/run.log;

${Java} -jar ${GATK} -T VariantEval  \
	-R ${ref} \
	--eval ${inputtarget} \
	-D ${dbsnp} -noST -ST Sample \
	-noEV -EV CompOverlap -EV IndelSummary \
	-EV TiTvVariantEvaluator -EV CountVariants \
	-EV MultiallelicSummary -o ${outpath4step}/${name}.rawqc.txt 

perl ${module_path}/QCvcf_table.pl \
	${outpath4step}/${name}.rawqc.txt \
	>${outpath4step}/${name}.qc.xls

${Java} -jar ${GATK} -T VariantAnnotator \
	-R ${ref} -V ${inputtarget}  \
	--dbsnp ${dbsnp} \
	-o ${outpath4step}/${name}.annotated.vcf  
	
${Java} -jar ${GATK} -T SelectVariants \
	-R ${ref} \
	-V ${outpath4step}/${name}.annotated.vcf \
	-selectType SNP --setFilteredGtToNocall -ef \
    -o  ${outpath4step}/${name}.Filtered_SNP.vcf
	
${Java} -jar ${GATK} -T SelectVariants \
	-R ${ref} \
	-V ${outpath4step}/${name}.annotated.vcf \
	-selectType INDEL --setFilteredGtToNocall -ef \
    -o  ${outpath4step}/${name}.Filtered_INDEL.vcf

#java -jar ${GATK} -T VariantsToBinaryPed \
	-R ${ref} -V ${outpath4step}/${name}.Filtered_SNP.vcf  \
	-m  ${outpath4step}/${name}.data.fam  -mgq 20 \
	-bed ${outpath4step}/${name}.Filtered_SNP.bed \
	-bim ${outpath4step}/${name}.Filtered_SNP.bim \
	-fam ${outpath4step}/${name}.Filtered_SNP.fam

echo -e The Step QualityControlVCF ended at `date` "\n" >>${outpath4step}/run.log;
for file in ${outtarget[@]}
do
if [ ! -f "${file}" ]; then
	echo -e the target file ${file} cannot be generated successfully!!
	exit 0
fi
done
mv ${outpath4step}/run.log ${outpath4step}/QualityControlVCF.log
