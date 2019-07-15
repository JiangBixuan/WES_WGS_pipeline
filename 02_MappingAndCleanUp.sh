name=SM206

cleandata=/home/PubData/Biox-center-METS/Biox-center-METS-clean_data
outpath4step=/home/zhouwei/zhou_data/WES/mappingAndCleanUp

bwa=~/miniconda3/bin/bwa
samtools=~/miniconda3/bin/samtools
picard=~/miniconda3/bin/picard
GATK=/home/zhouwei/software/GenomeAnalysisTK-3.8/GenomeAnalysisTK.jar
Java=/usr/bin/java

ref=/home/RefData/reference/ucsc.hg19.fasta
known1=/home/RefData/1000g/1000G_phase1.indels.hg19.vcf
known2=/home/RefData/1000g/Mills_and_1000G_gold_standard.indels.hg19.sites.vcf
dbsnp=/home/RefData/dbsnp/dbsnp_138.hg19.vcf

echo -e The Step MappingAndMarkDup started at `date` "\n" >>${outpath4step}/run.log;

${bwa} mem -t 7 -M -R "@RG\tID:QSY${name}\tLB:QSY${name}\tSM:${name}\tPL:ILLUMINA" \
	${ref} ${cleandata}/${name}_*1.clean.fq.gz ${cleandata}/${name}_*2.clean.fq.gz \
	|gzip -3 > ${outpath4step}/${name}.align.sam

${samtools} view -@ 7 -bS \
	${outpath4step}/${name}.align.sam \
	-o ${outpath4step}/${name}.align.bam

${picard} ReorderSam \
	I= ${outpath4step}/${name}.align.bam \
	O= ${outpath4step}/${name}.align.reorder.bam \
	R=${ref} VALIDATION_STRINGENCY=LENIENT

${samtools} sort -@ 7 -m 8G \
	${outpath4step}/${name}.align.reorder.bam \
	-o ${outpath4step}/${name}.align.reorder.sorted.bam

${samtools} index -@ 7 ${outpath4step}/${name}.align.reorder.sorted.bam

${picard} MarkDuplicates \
	I= ${outpath4step}/${name}.align.reorder.sorted.bam \
	O= ${outpath4step}/${name}.align.reorder.sorted.markdup.bam \
	ASSUME_SORTED=true METRICS_FILE= ${outpath4step}/${name}.align.metrics \
	VALIDATION_STRINGENCY=LENIENT CREATE_INDEX=true;
echo -e The Step MappingAndMarkDup ended at `date` "\n" >>${outpath4step}/run.log;

echo -e The Step IndelRealignAndBQSR started at `date` "\n" >>${outpath4step}/run.log;
${Java} -jar ${GATK} -T RealignerTargetCreator \
	-R ${ref} -I ${outpath4step}/${name}.align.reorder.sorted.markdup.bam \
	-known ${known1} -known ${known2} -nt 7 \
	-o ${outpath4step}/${name}.realigner.intervals

${Java} -jar ${GATK} -T IndelRealigner \
	-R ${ref} -I ${outpath4step}/${name}.align.reorder.sorted.markdup.bam \
	-known ${known1} -known ${known2} \
	-targetIntervals ${outpath4step}/${name}.realigner.intervals \
	-o ${outpath4step}/${name}.realigner.bam

${Java} -jar ${GATK} -T BaseRecalibrator \
	-R ${ref} -I ${outpath4step}/${name}.realigner.bam \
	-knownSites ${dbsnp} -knownSites ${known1} -knownSites ${known2} -nct 7 \
	-o ${outpath4step}/${name}.recal.table

${Java} -jar ${GATK} -T PrintReads \
	-R ${ref} -I ${outpath4step}/${name}.realigner.bam \
	-BQSR ${outpath4step}/${name}.recal.table -nct 7 \
	-o ${outpath4step}/${name}.recal.bam;
echo -e The Step IndelRealignAndBQSR ended at `date` "\n" >>${outpath4step}/run.log

for file in ${outpath4step}/${name}.recal.bam
do
if [ ! -f "${file}" ]; then
	echo -e the target file ${file} cannot bed generated successfully!!
	exit 0
fi
done
mv ${outpath4step}/run.log ${outpath4step}/MappingAndCleanUp.log;
rm ${outpath4step}/${name}*.align.*;
rm ${outpath4step}/${name}.realigner.*;
rm ${outpath4step}/${name}*recal.table
