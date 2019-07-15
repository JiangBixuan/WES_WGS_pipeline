###Basic
name=metsExon100
cd /home/zhouwei/zhou_data/WES
mkdir Assoc_analysis
outpath4step=/home/zhouwei/zhou_data/WES/Assoc_analysis
inputtarget=(/home/zhouwei/zhou_data/WES/VariantFiltering/${name}.Filtered_SNP.vcf)
outtarget=(${outpath4step}/${name}.final_common_variants.assoc )

###software
GATK=/home/limo/software/Minicoda2/opt/gatk-3.8/GenomeAnalysisTK.jar
Java=/usr/bin/java
plink=~/miniconda3/bin/plink
vcftools=~/miniconda3/bin/vcftools
Rscript=/usr/bin/Rscript

###reference
ref=/home/RefData/reference/ucsc.hg19.fasta
dbsnp=/home/RefData/dbsnp/dbsnp_138.hg19.vcf
fam=/home/zhouwei/zhou_data/WES/metsExon100.Filtered_SNP.vcf_raw.fam

###inhouse_scripts
module_path=/home/zhouwei/zhou_data/script/Pipelines/Modules

for file in ${inputtarget[@]}
do
if [ ! -f "${file}" ]; then
	echo -e the target file ${file} cannot be generated successfully!!
	exit 0
fi
done
echo -e The Step TDT started at `date` "\n" >>${outpath4step}/run.log;

###vcf2plink
${vcftools} --vcf ${inputtarget} \
	--plink \
	--out ${outpath4step}/${name}_raw	

##QC1: Remove SNPs with missing genotype rate >5% 
${plink} --file ${outpath4step}/${name}_raw --missing --out ${outpath4step}/${name}.plink 
awk 'NR < 2 { next } $5 > 0.05' ${outpath4step}/${name}.plink.lmiss > ${outpath4step}/${name}.plink.lmiss.exclude 

${plink} --file ${outpath4step}/${name}_raw \
	--exclude ${outpath4step}/${name}.plink.lmiss.exclude \
	--make-bed --out ${outpath4step}/${name}.plink_QC1 
cp ${fam} ${outpath4step}/${name}.plink_QC1.fam

#cheack IBD and sex
${plink} --bfile ${name}.plink_QC1 \
	--maf 0.01 --genome rel-check \
	--out ${name}.plink_QC1

${plink} --bfile ${name}.plink_QC1 \
	--check-sex \
	--out ${name}.plink_QC1
##QC2: Remove Individuals with missing genotype rate >5% and heterozygosity rate > 3*sigma 
${plink} --bfile ${outpath4step}/${name}.plink_QC1 \
	--missing --out ${outpath4step}/${name}.plink_QC1 
${plink} --bfile ${outpath4step}/${name}.plink_QC1 \
	--het --out ${outpath4step}/${name}.plink_QC1  
${Rscript} ${module_path}/missing_genotype_heterogygosity.R \
	${outpath4step}/${name}.plink_QC1.imiss \
	${outpath4step}/${name}.plink_QC1.het \
	${outpath4step}/${name}.plink.imiss.het.pdf \
	${outpath4step}/${name}.plink.imiss.het.remove 
${plink} --bfile ${outpath4step}/${name}.plink_QC1 \
	--remove ${outpath4step}/${name}.plink.imiss.het.remove \
	--make-bed --out ${outpath4step}/${name}.plink_QC2 
# cp /home/limo/Project_data/ZW-WES/metsExon100.Filtered_SNP.vcf_raw_qc2.fam ${outpath4step}/${name}.plink_QC2.fam

##QC3: Remove SNPs missing genotype rate >1%
${plink} --bfile ${outpath4step}/${name}.plink_QC2  \
	--missing --out ${outpath4step}/${name}.plink_QC2 
awk 'NR < 2 { next } $5 > 0.01' ${outpath4step}/${name}.plink_QC2.lmiss \
	> ${outpath4step}/${name}.plink_QC2.lmiss.exclude  
${plink} --bfile ${outpath4step}/${name}.plink_QC2   \
	--exclude ${outpath4step}/${name}.plink_QC2.lmiss.exclude   \
	--make-bed --out ${outpath4step}/${name}.plink_QC3 

##QC5 :Remove SNPs deviated from HWE (10e-6)
${plink} --bfile ${outpath4step}/${name}.plink_QC3 \
	--hardy --out ${outpath4step}/${name}.plink_QC3 
awk '$3=="UNAFF" && $9 <0.000001 {print $2}' ${outpath4step}/${name}.plink_QC3.hwe  \
	> ${outpath4step}/${name}.plink_QC3.hwe.exclude 
${plink} --bfile ${outpath4step}/${name}.plink_QC3 \
	--exclude ${outpath4step}/${name}.plink_QC3.hwe.exclude \
	--make-bed --out ${outpath4step}/${name}.plink_QC4 

##QC6: Principal component analysis (PCA) 
${plink} --bfile ${outpath4step}/${name}.plink_QC4  \
	--indep-pairwise 200 5 0.2  \
	--out ${outpath4step}/${name}.plink_QC4  
${plink} --bfile ${outpath4step}/${name}.plink_QC4   \
	--extract ${outpath4step}/${name}.plink_QC4.prune.in     \
	--make-bed --out ${outpath4step}/${name}.plink_QC4_indep 
${plink} --bfile ${outpath4step}/${name}.plink_QC4_indep \
	--pca --out ${outpath4step}/${name}.plink_QC4_indep 

##Plot
${Rscript} ${module_path}/PCA.R ${outpath4step}/${name}.plink_QC4_indep.eigenvec \
	${outpath4step}/${name}.plink_QC4_indep.pca.pdf \
	${outpath4step}/${name}.plink_QC4_indep.remove

${plink} --bfile ${outpath4step}/${name}.plink_QC4  \
	--remove ${outpath4step}/${name}.plink_QC4_indep.remove \
	--make-bed --out ${outpath4step}/${name}.plink_clean 
${plink} --bfile ${outpath4step}/${name}.plink_clean \
	--pca --out ${outpath4step}/${name}.plink_clean \
##Plot
${Rscript} ${module_path}/PCA1.R ${outpath4step}/${name}.plink_clean.eigenvec \
	${outpath4step}/${name}.plink_clean.pca.pdf 
${plink} --bfile ${outpath4step}/${name}.plink_clean \
	--freq --out ${outpath4step}/${name}.plink_clean
##Plot
${Rscript} ${module_path}/Plot_alleleFQ.R ${outpath4step}/${name}.plink_clean.frq \
	${outpath4step}/${name}.plink_clean.maf.pdf 


###Assoc
##1)select common variations with MAF>1% 
${plink} --bfile ${outpath4step}/${name}.plink_clean \
	--maf 0.01 --make-bed \
	--out ${outpath4step}/${name}.final_common_variants 

##2)assoc
${plink} --bfile ${outpath4step}/${name}.final_common_variants \
	--assoc --adjust --ci 0.95 --out ${outpath4step}/${name}.final_common_variants 

##3)logsitc
${plink} --bfile ${outpath4step}/${name}.final_common_variants \
     --logistic --covar ${outpath4step}/${name}.plink_clean.eigenvec --covar-number 1-5 --ci 0.95 --out ${outpath4step}/${name}.final_common_variants

# perl ${module_path}/sort_TDT.pl ${outpath4step}/${name}.final_common_variants.assoc\
# 	>${outpath4step}/${name}.final_common_variants.assoc.sorted 
# head -500 ${outpath4step}/${name}.final_common_variants.assoc.sorted \
# 	>${outpath4step}/${name}.final_common_variants.assoc.sort_top500 

## Plot
${Rscript} ${module_path}/Plot.manhattan_qq_assoc.R \
	${outpath4step}/${name}.final_common_variants.assoc \
	${outpath4step}/${name}.final_common_variants.assoc.manhattan.jpg \
	${outpath4step}/${name}.final_common_variants.assoc.QQ.jpg
	
${Rscript} ${module_path}/Plot.manhattan_qq_logistic.R \
	${outpath4step}/${name}.final_common_variants.assoc.logistic \
	${outpath4step}/${name}.final_common_variants.assoc.logistic.manhattan.jpg \
	${outpath4step}/${name}.final_common_variants.assoc.logistic.QQ.jpg

echo -e The Step Assoc ended at `date` "\n" >>${outpath4step}/run.log;
for file in ${outtarget[@]}
do
if [ ! -f "${file}" ]; then
	echo -e the target file ${file} cannot be generated successfully!!
	exit 0
fi
done
mv ${outpath4step}/run.log ${outpath4step}/Assoc.log