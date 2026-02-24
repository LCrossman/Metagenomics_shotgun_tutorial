#!/bin/bash -e
#SBATCH --qos=bio-ds
#SBATCH -p bio-ds
#SBATCH --mem=40G
#SBATCH --cpus-per-task=16
#SBATCH --job-name=metagenomics_tutorial_readaligns
#SBATCH -o /gpfs/home/%u/scratch/Data/Metagenomics_tutorial/ReadAligns/Output_Messages/Metagenomics_tutorial-%a.out
#SBATCH -e /gpfs/home/%u/scratch/Data/Metagenomics_tutorial/ReadAligns/Error_Messages/Metagenomics_tutorial-%a.err
#SBATCH --mail-type=ALL
#SBATCH --mail-user=#<your.email@address>

#module load mamba/25.3.1-0  # Load mamba module (faster version of anaconda)
module load bowtie2/2.5.4
module load samtools/1.21

#mamba env create -f Metagenomics_env.yaml

#mamba activate Metagenomics_env

# Define input/output directories
GENOME_FASTA="$HOME/scratch/Metagenomics_shotgun_tutorial/RawData/CommunityScaffolds.fasta"
FASTQ_DIR="/gpfs/data/BIO-DSB/Session7/MG_workshop_2026/FASTQ/"
OUTPUT_DIR="$HOME/scratch/Metagenomics_shotgun_tutorial/ReadAligns/"

# Ensure OUTPUT_DIR exists
mkdir -p "$OUTPUT_DIR"
cp "$GENOME_FASTA" "$OUTPUT_DIR"
echo "copied reference fasta successfully"
cp "$FASTQ_DIR"/EDME*fastq.gz "$OUTPUT_DIR"
echo "copied read files successfully"
#Here we index the metagenome assembly for use with the read alignment tool bowtie2
bowtie2-build "$OUTPUT_DIR"CommunityScaffolds.fasta "$OUTPUT_DIR"CommunityScaffolds.fasta

#here we align the reads to the reference assembly, converting directly to bam format using a pipe to
#avoid saving a very large intermediate file to disk
bowtie2 -p 16 -x "$OUTPUT_DIR"CommunityScaffolds.fasta -1 "$OUTPUT_DIR"EDME200007170-1a_HCYHVDSXY_L2_1.fq.gz -2 "$OUTPUT_DIR"EDME200007170-1a_HCYHVDSXY_L2_2.fq.gz | samtools view -@ 16 -bS -  > Community_aligned.bam

echo "saved alignment file directly to bam file, sorting..."
samtools sort -@ 16 Community_aligned.bam -o Community_aligned.bam.sorted.bam
samtools index Community_aligned.bam.sorted.bam
echo "aligned reads, sorted and indexed"

rm Community_aligned.bam
#mamba deactivate


#delete intermediate files for cleanup


