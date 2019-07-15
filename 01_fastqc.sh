rawdata_path=/newdisk/PubData/Biox-center-METS/Biox-center-METS-clean_data/2018588
output_path=/home/zhouwei/zhou_data/WES/fastqc/batch2
fastqc=~/miniconda3/bin/fastqc
multiqc=~/miniconda3/bin/multiqc

# 单个样本qc
# ${fastqc} -t 8  ${rawdata_path}/DX120129*  -o ${output_path}

#批量QC
for i in 'ls /newdisk/PubData/Biox-center-METS/Biox-center-METS-clean_data/2018588/*.gz'; do fastqc -t 8 -o ${output_path}/$i; done
#或者
# ls /newdisk/PubData/Biox-center-METS/Biox-center-METS-clean_data/2018588/*.gz| xargs -i echo nohup fastqc -o /home/zhouwei/zhou_data/WES/fastqc/batch2 {} \& >fastqc.sh
#合并QC结果
multiqc ${output_path}
