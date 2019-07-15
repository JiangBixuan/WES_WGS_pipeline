# 6. combine gvcf and filter snp/indel

GATK = /home/zhouwei/software/GenomeAnalysisTK-3.8/GenomeAnalysisTK.jar
Java=/usr/bin/java
ref = /home/RefData/reference/ucsc.hg19.fasta
inputpath = /home/zhouwei/zhou_data/WES/GermlineVariantCalling
outputpath = /home/zhouwei/zhou_data/WES/callingsnp

known1=/home/RefData/VQSR_resources/hapmap_3.3.hg19.vcf
known2=/home/RefData/VQSR_resources/1000G_omni2.5.hg19.vcf
known3=/home/RefData/1000g/1000G_phase1.snps.high_confidence.hg19.vcf
known4=/home/RefData/dbsnp/dbsnp_138.hg19.vcf

hapmap=/home/RefData/VQSR_resources/hapmap_3.3.hg19.vcf
omni=/home/RefData/1000g/1000G_omni2.5.hg19.vcf
dbsnp=/home/RefData/dbsnp/dbsnp_138.hg19.vcf
dbsnp1=/home/RefData/dbsnp/dbsnp_138.hg19.excluding_sites_after_129.vcf
known1=/home/RefData/1000g/1000G_phase1.snps.high_confidence.hg19.vcf
known2=/home/RefData/1000g/Mills_and_1000G_gold_standard.indels.hg19.sites.vcf
axiom=/home/RefData/VQSR_resources/Axiom_Exome_Plus.genotypes.all_populations.poly.vcf


${Java} -jar ${GATK} -T	GenotypeGVCFs	\
	 -R	${ref}	\
	 -V	${outputpath}/exonSeq100Sample1.g.vcf	\
	 -V	${outputpath}/exonSeq100Sample2.g.vcf	\
	 –o	${outputpath}/raw_variants.vcf
	 


echo -e The Step VariantFiltering started at `date` "\n" >>${outpath4step}/run.log

${picard} MakeSitesOnlyVcf \
	INPUT=${inputtarget} \
	OUTPUT=${outpath4step}/sites_only.unfiltered.vcf.gz


##Variant Quality Score Recalibration (VQSR)
for file in ${inputtarget}
do
if [ ! -f "${file}" ]; then
	echo -e the target file ${file} cannot be generated successfully!!
	exit 0
fi
done

echo -e The Step VariantFiltering started at `date` "\n" >>${outpath4step}/run.log
	
java -jar ${GATK} -T VariantRecalibrator \
	--disable_auto_index_creation_and_locking_when_reading_rods \
	-R ${ref} -input ${outpath4step}/sites_only.unfiltered.vcf.gz \
	-recalFile ${outpath4step}/metsExon100.snps.recal -tranchesFile ${outpath4step}/metsExon100.snps.tranches -allPoly \
	-tranche 100.0 -tranche 99.95 -tranche 99.9 -tranche 99.8 -tranche 99.6 -tranche 99.5 \
	-tranche 99.4 -tranche 99.3 -tranche 99.0 -tranche 98.0 -tranche 97.0 -tranche 90.0 \
	-an DP -an QD -an FS -an SOR -an MQ -an MQRankSum -an ReadPosRankSum -an InbreedingCoeff  \
	-resource:hapmap,known=false,training=true,truth=true,prior=15 ${hapmap} \
	-resource:omni,known=false,training=true,truth=true,prior=12 ${omni} \
	-resource:1000G,known=false,training=true,truth=false,prior=10 ${known1} \
	--resource:dbsnp137,known=false,training=false,truth=false,prior=7 ${dbsnp} \
	--resource:dbsnp129,known=true,training=false,truth=false,prior=3 ${dbsnp1} \
	--maxGaussians 6 -mode SNP -rscriptFile ${outpath4step}/metsExon100.snps.recalibration_plots.rscript >> ${outpath4step}/vqsr.log

java -jar ${GATK} -T VariantRecalibrator \
	--disable_auto_index_creation_and_locking_when_reading_rods \
	-R ${ref} -input ${outpath4step}/sites_only.unfiltered.vcf.gz \
    -recalFile ${outpath4step}/metsExon100.indels.recal -tranchesFile ${outpath4step}/metsExon100.indels.tranches -allPoly \
	-tranche 100.0 -tranche 99.95 -tranche 99.9 -tranche 99.5 -tranche 99.0 -tranche 97.0 \
	-tranche 96.0 -tranche 95.0 -tranche 94.0 -tranche 93.5 -tranche 93.0 -tranche 92.0 \
	-tranche 91.0 -tranche 90.0 \
	-an DP -an QD -an FS -an SOR -an MQRankSum -an ReadPosRankSum -an InbreedingCoeff  \
	-resource:mills,known=false,training=true,truth=true,prior=12 ${known2} \
	-resource:axiomPoly,known=false,training=true,truth=false,prior=10 ${axiom}  \
	-resource:dbsnp137,known=true,training=false,truth=false,prior=2 ${dbsnp} \
	--maxGaussians 6 -mode INDEL -rscriptFile ${outpath4step}/metsExon100.indels.recalibration_plots.rscript >> ${outpath4step}/vqsr.log

java -jar ${GATK} -T ApplyRecalibration \
	--disable_auto_index_creation_and_locking_when_reading_rods \
	-R ${ref}  \
	-input ${inputtarget} -recalFile ${outpath4step}/metsExon100.snps.recal \
	-o ${outpath4step}/metsExon100.recalibrated_snps_raw_indels.vcf.gz \
	-tranchesFile ${outpath4step}/metsExon100.snps.tranches \
	-ts_filter_level 99.6 -mode SNP >> ${outpath4step}/vqsr.log 

java -jar ${GATK} -T ApplyRecalibration \
	--disable_auto_index_creation_and_locking_when_reading_rods \
	-R ${ref} \
	-input ${outpath4step}/metsExon100.recalibrated_snps_raw_indels.vcf.gz \
	-o ${outpath4step}/metsExon100.recalibrated.vcf \
	-recalFile ${outpath4step}/metsExon100.indels.recal \
	-tranchesFile ${outpath4step}/metsExon100.indels.tranches \
	-ts_filter_level 95.0 -mode INDEL >> ${outpath4step}/vqsr.log 
	

echo -e The Step VariantFiltering by VQSR ended at `date` "\n" >>${outpath4step}/run.log

for file in ${outpath4step}/${outtarget}
do
if [ ! -f "${file}" ]; then
	echo -e the target file ${file} cannot be generated successfully!!
	exit 0
fi
done

mv ${outpath4step}/run.log ${outpath4step}/VariantFiltering.log