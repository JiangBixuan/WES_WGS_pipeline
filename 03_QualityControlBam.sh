name=DX120129
mkdir ${name}
cd ${name}
outpath4step=/home/zhouwei/zhou_data/WES/QualityControlBam/${name}
inputtarget=/home/zhouwei/zhou_data/WES/mappingAndCleanUp/${name}.recal.bam

picard=~/miniconda3/bin/picard
verifyBamID=~/miniconda3/bin/verifyBamID
module_path=/home/zhouwei/zhou_data/WES_test/Modules
Java=/usr/bin/java


datatype=WES

ref=/home/RefData/reference/ucsc.hg19.fasta
bait=/home/RefData/AgilentTarget/SureSelect_Exon_V6_Covered.interval_list
target=/home/RefData/AgilentTarget/SureSelect_Exon_V6_Regions.interval_list
EAS_1000g=/home/RefData/1000g/EAS_1000g_Exon.vcf

echo -e The Step QualityControlBam started at `date` "\n" >> ${outpath4step}/run.log;

##verifyBamID
${verifyBamID} --vcf ${EAS_1000g} \
	--bam ${inputtarget} \
	--out ${outpath4step}/${name}.verifybamid \
	--verbose --ignoreRG
	
##Picard(Hs)
${picard} -Xmx20g CollectHsMetrics \
	I=${inputtarget} \
	O=${outpath4step}/$name.hs.raw \
	R=$ref \
	BAIT_INTERVALS=$bait \
	TARGET_INTERVALS=$target

##AlignmentSummary
${picard} CollectAlignmentSummaryMetrics \
	R=$ref \
	I=${inputtarget} \
	O=${outpath4step}/$name.alignment.raw

${picard} CollectQualityYieldMetrics \
	R=$ref \
	I=${inputtarget} \
	O=${outpath4step}/$name.qualigyYield.raw

##Insertsize
${picard} CollectInsertSizeMetrics \
    R=$ref \
	I=${outpath4step}/$name.recal.bam \
	O=${outpath4step}/$name.insert_size.txt \
	H=${outpath4step}/$name.insert_size.pdf M=0.5
 convert ${outpath4step}/$name.insert_size.pdf ${outpath4step}/$name.insert_size.png

perl ${module_path}/QCBam_table.pl ${name} \
 	${outpath4step}/$name.verifybamid.selfSM \
 	${outpath4step}/$name.hs.raw \
 	${outpath4step}/$name.alignment.raw \
 	${outpath4step}/$name.qualigyYield.raw ${datatype}

echo -e The Step QualityControlBam ended at `date` "\n" >>${outpath4step}/run.log
rm ${outpath4step}/${name}.verifybamid.log  ${outpath4step}/${name}.verifybamid.depthSM 
mv ${outpath4step}/run.log ${outpath4step}/QualityControlBam.log;
