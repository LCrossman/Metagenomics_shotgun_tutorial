#!/bin/bash
#SBATCH --mem=10G
#SBATCH --cpus-per-task=16
#SBATCH --job-name=metagenomics_tutorial
#SBATCH -o /gpfs/home/hrj09fju/scratch/Data/Metagenomics_tutorial/ReadAligns/Output_Messages/Metagenomics_tutorial-%a.out
#SBATCH -e /gpfs/home/hrj09fju/scratch/Data/Metagenomics_tutorial/ReadAligns/Error_Messages/Metagenomics_tutorial-%a.err
#SBATCH --mail-type=ALL
#SBATCH --mail-user=#<your.email@address>

#module load mamba/25.3.1-0  # Load mamba module (faster version of anaconda)
module load bowtie2/2.5.4
module load samtools/1.21

#mamba env create -f Metagenomics_env.yaml

#mamba activate Metagenomics_env

# Define input/output directories
GENOME_FASTA="/gpfs/data/BIO-DSB/Session8/MG_Workshop_2026/Communityscaffolds.fasta"
FASTQ_DIR="/gpfs/data/BIO-DSB/Session8/MG_Workshop_2026/FASTQ/"
OUTPUT_DIR="/gpfs/home/hrj09fju/scratch/Data/Community/ReadAligns/"

# Ensure OUTPUT_DIR exists
mkdir -p "$OUTPUT_DIR"

bowtie2-build Communityscaffolds.fasta Communityscaffolds.fasta
bowtie2 -p 16 -x Communityscaffolds.fasta -1 EDME200007170-1a_HCYHVDSXY_L2_1.fq.gz -2 EDME200007170-1a_HCYHVDSXY_L2_2.fq.gz -S Community_aligned.sam

samtools view -@ 16 Community_aligned.sam > Community_aligned.bam
samtools sort -@ 16 Community_aligned.bam -o Community_aligned.bam.sorted.bam
samtools index Community_aligned.bam.sorted.bam

#mamba deactivate


#delete intermediate files for cleanup


