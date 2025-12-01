#!/bin/bash
#SBATCH --mem=10G
#SBATCH --cpus-per-task=16
#SBATCH --job-name=metagenomics_tutorial
#SBATCH -o /gpfs/home/hrj09fju/scratch/Data/Metagenomics_tutorial/ReadAligns/Output_Messages/Metagenomics_tutorial-%a.out
#SBATCH -e /gpfs/home/hrj09fju/scratch/Data/Metagenomics_tutorial/ReadAligns/Error_Messages/Metagenomics_tutorial-%a.err
#SBATCH --mail-type=ALL
#SBATCH --mail-user=hrj09fju@uea.ac.uk

module load python/anaconda/2024.06  # Load Anaconda module to enable Conda commands


# Initialize Conda
source /gpfs/software/hali/python/anaconda/2024.06/etc/profile.d/conda.sh

conda env create -f Metagenomics_quality_env.yaml

conda activate Metagenomics_quality_env

#export PATH=

# Define input/output directories
GENOME_FASTA="/gpfs/home/hrj09fju/scratch/References/Mockscaffolds.fasta"
FASTQ_DIR="/gpfs/home/hrj09fju/scratch/Data/MockCommunity/FastQ/raw_data"
INPUT_DIR="/gpfs/home/hrj09fju/scratch/Data/MockCommunity/ReadAligns"
OUTPUT_DIR="/gpfs/home/hrj09fju/scratch/Data/MockCommunity/Bins"

# Ensure OUTPUT_DIR exists
mkdir -p "$OUTPUT_DIR"

conda activate checkm

checkm data setRoot .

for FOLDER in binspreader-Rcorr ; do checkm lineage_wf -t 16 -x fasta --tab_table -f $FOLDER/checkm_result.tsv $FOLDER/bins $FOLDER/checkm ; done


Requirements
checkm
checkm_database


conda deactivate
#delete intermediate files for cleanup


