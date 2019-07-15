# Author：weizhou
# Data: 20190605

######################
# This pipeline was used to remove adaptor and low quality reads from raw fastq data
# filelist1.txt file contain the names of raw fastq data
######################


# software: https://github.com/OpenGene/fastp
# install fastp
# method 1:
# wget http://opengene.org/fastp/fastp && chmod a+x ./fastp

# method 2:
# conda install -c bioconda fastp

# check the file
md5sum -c md5.txt

# loop for multi sample
fastp=/home/zhouwei/miniconda3/fastp
inputpath=/newdisk/PubData/Biox-center-METS/Biox-center-METS-WES/2019711/
outpath=/home/zhouwei/zhou_data/WES/batch3cleandata/

for f in $(cat filelist1.txt); do
    {
    ${fastp} -i ${inputpath}/${f}.R1.fastq.gz \
    -o ${outpath}/${f}.R1.clean.fastq.gz \
    -I ${inputpath}/${f}.R2.fastq.gz \
    -O ${outpath}/${f}.R2.clean.fastq.gz \
    --thread=6 -c --length_required 40 \
    --adapter_sequence=AGATCGGAAGAGCACACGTCTGAACTCCAGTCA \
    --adapter_sequence_r2=AGATCGGAAGAGCGTCGTGTAGGGAAAGAGTGT
    }
done

# for single sample

nohup /home/zhouwei/miniconda3/fastp \
-i /newdisk/PubData/Biox-center-METS/Biox-center-METS-WES/2019711/J9_L3_J9002.R1.fastq.gz \
-o /home/zhouwei/zhou_data/WES/batch3cleandata/J9_L3_J9002.R1.clean.fastq.gz \
-I /newdisk/PubData/Biox-center-METS/Biox-center-METS-WES/2019711/J9_L3_J9002.R2.fastq.gz \
-O /home/zhouwei/zhou_data/WES/batch3cleandata/J9_L3_J9002.R2.clean.fastq.gz \
--thread=5 -c --length_required 40 \
--adapter_sequence=AGATCGGAAGAGCACACGTCTGAACTCCAGTCA \
--adapter_sequence_r2=AGATCGGAAGAGCGTCGTGTAGGGAAAGAGTGT &


# or enable adapter auto-detection
# --detect_adapter_for_pe

