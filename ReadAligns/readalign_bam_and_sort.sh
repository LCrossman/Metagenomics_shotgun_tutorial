#!/bin/bash
#SBATCH --mem=10G
#SBATCH --cpus-per-task=16
#SBATCH --job-name=metagenomics_tutorial
#SBATCH -o /gpfs/home/hrj09fju/scratch/Data/Metagenomics_tutorial/ReadAligns/Output_Messages/Metagenomics_tutorial-%a.out
#SBATCH -e /gpfs/home/hrj09fju/scratch/Data/Metagenomics_tutorial/ReadAligns/Error_Messages/Metagenomics_tutorial-%a.err
#SBATCH --mail-type=ALL
#SBATCH --mail-user=hrj09fju@uea.ac.uk

module load python/anaconda/2024.10/3.12.7  # Load Anaconda module to enable Conda commands


# Initialize Conda
#source /gpfs/software/hali/python/anaconda/2024.06/etc/profile.d/conda.sh

#conda env create -f Metagenomics_env.yaml

#conda activate Metagenomics_env

#export PATH=

# Define input/output directories
GENOME_FASTA="/gpfs/home/hrj09fju/scratch/References/Communityscaffolds.fasta"
FASTQ_DIR="/gpfs/home/hrj09fju/scratch/Data/Community/FastQ/raw_data"
OUTPUT_DIR="/gpfs/home/hrj09fju/scratch/Data/Community/ReadAligns"

# Ensure OUTPUT_DIR exists
mkdir -p "$OUTPUT_DIR"

bowtie2-build Communityscaffolds.fasta Communityscaffolds.fasta
bowtie2 -p 16 -x Communityscaffolds.fasta -1 EDME200007170-1a_HCYHVDSXY_L2_1.fq.gz -2 EDME200007170-1a_HCYHVDSXY_L2_2.fq.gz -S Community_aligned.sam

samtools view -@ 16 Community_aligned.sam > Community_aligned.bam
samtools sort -@ 16 Community_aligned.bam -o Community_aligned.bam.sorted.bam
samtools index Community_aligned.bam.sorted.bam

#conda deactivate


#delete intermediate files for cleanup


