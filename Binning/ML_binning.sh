#!/bin/bash
#SBATCH --mem=10G
#SBATCH --cpus-per-task=16
#SBATCH --job-name=metagenomics_tutorial
#SBATCH -o /gpfs/home/hrj09fju/scratch/Data/Metagenomics_tutorial/Binning/Output_Messages/Metagenomics_tutorial-%a.out
#SBATCH -e /gpfs/home/hrj09fju/scratch/Data/Metagenomics_tutorial/Binning/Error_Messages/Metagenomics_tutorial-%a.err
#SBATCH --mail-type=ALL
#SBATCH --mail-user=$(USER)

module add Semibin2/2.2.0

echo "environment activated"

# Define input/output directories
GENOME_FASTA="/gpfs/home/hrj09fju/scratch/References/CommunityScaffolds.fasta"
FASTQ_DIR="/gpfs/home/hrj09fju/scratch/Data/Community/FastQ/raw_data"
INPUT_DIR="/gpfs/home/hrj09fju/scratch/Data/Community/ReadAligns"
OUTPUT_DIR="/gpfs/home/hrj09fju/scratch/Data/Community/Bins"

# Ensure OUTPUT_DIR exists
mkdir -p "$OUTPUT_DIR"
