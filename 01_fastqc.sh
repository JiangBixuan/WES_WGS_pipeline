rawdata_path=/home/PubData/Biox-center-METS/Biox-center-METS-raw_data
output_path=/home/zhouwei/zhou_data/WES/fastqc
fastqc=~/miniconda3/bin/fastqc
multiqc=~/miniconda3/bin/multiqc

# 单个样本qc
# ${fastqc} -t 8  ${rawdata_path}/DX120129*  -o ${output_path}

#批量QC
for i in 'ls /home/PubData/Shanghaiertongcenter-HP/mRNA/P101SC17071301-04-B1-6_20171206/CleanData/*.gz'; \
do fastqc -t 8 -o ${output_path}/$i; done
#或者
# ls /home/zhouwei/zhou_data/RNAanalysis/MetsmRNA/cleanData/*.gz | xargs -I [] echo nohup 'fastqc -t 24 [] -o /home/zhouwei/zhou_data/RNAanalysis/MetsmRNA/QC &' > fastqc.sh

#合并QC结果
multiqc ${output_path}