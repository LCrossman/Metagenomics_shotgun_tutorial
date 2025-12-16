#!/bin/bash
#SBATCH --mem=10G
#SBATCH --cpus-per-task=16
#SBATCH --job-name=metagenomics_tutorial
#SBATCH -o /gpfs/home/hrj09fju/scratch/Data/Metagenomics_tutorial/ReadAligns/Output_Messages/Metagenomics_tutorial-%a.out
#SBATCH -e /gpfs/home/hrj09fju/scratch/Data/Metagenomics_tutorial/ReadAligns/Error_Messages/Metagenomics_tutorial-%a.err
#SBATCH --mail-type=ALL
#SBATCH --mail-user=hrj09fju@uea.ac.uk

# Load Anaconda module to enable Conda commands
module load python/anaconda/2024.10/3.12.7

# Initialize Conda
source /gpfs/software/hali/python/anaconda/2024.10/etc/profile.d/conda.sh

conda env create -f Metagenomics_quality_env.yaml

conda activate Metagenomics_quality_env


# Define input/output directories
GENOME_FASTA="/gpfs/home/hrj09fju/scratch/References/Communityscaffolds.fasta"
FASTQ_DIR="/gpfs/home/hrj09fju/scratch/Data/Community/FastQ/raw_data"
INPUT_DIR="/gpfs/home/hrj09fju/scratch/Data/Community/ReadAligns"
OUTPUT_DIR="/gpfs/home/hrj09fju/scratch/Data/Community/Bins"

# Ensure OUTPUT_DIR exists
mkdir -p "$OUTPUT_DIR"

conda activate checkm

#You would need to run this if you are running checkm locally
#checkm data setRoot .

for FOLDER in binspreader-Rcorr ; do checkm lineage_wf -t 16 -x fasta --tab_table -f $FOLDER/checkm_result.tsv $FOLDER/bins $FOLDER/checkm ; done


#Requirements
#checkm
#checkm_database


#conda deactivate
#delete intermediate files for cleanup
