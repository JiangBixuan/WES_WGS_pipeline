# Author：weizhou
# Data: 20190605

# software: https://github.com/OpenGene/fastp
# install fastp
# method 1:
# wget http://opengene.org/fastp/fastp && chmod a+x ./fastp

# method 2:
# conda install -c bioconda fastp

fastp=~/miniconda3/bin/fastp
${fastp} –i read1.raw.fastq.gz –o read1.clean.fastq.gz \
-I read2.raw.fastq.gz –O read2.clean.fastq.gz \
-w 4 -q 3 –u 50 –length_required 150 \
-adapter_sequence=AGATCGGAAGAGCACACGTCTGAACTCCAGTCA \
-adapter_sequence_r2=AGATCGGAAGAGCGTCGTGTAGGGAAAGAGTGT


# or enable adapter auto-detection
# --detect_adapter_for_pe