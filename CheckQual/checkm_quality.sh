#!/bin/bash -e
#SBATCH --qos=bio-ds # User group
#SBATCH -p bio-ds  
#SBATCH --mem=10G
#SBATCH --cpus-per-task=16
#SBATCH --job-name=metagenomics_tutorial_qual
#SBATCH -o /gpfs/home/%u/scratch/Data/Metagenomics_tutorial/ReadAligns/Output_Messages/Metagenomics_tutorial-%a.out
#SBATCH -e /gpfs/home/%u/scratch/Data/Metagenomics_tutorial/ReadAligns/Error_Messages/Metagenomics_tutorial-%a.err
#SBATCH --mail-type=ALL
#SBATCH --mail-user=#<your.email@address>


module add checkm/1.2.4

# Define input/output directories
GENOME_FASTA="$HOME/scratch/References/CommunityScaffolds.fasta"
FASTQ_DIR="$HOME/scratch/Data/Community/FastQ/raw_data"
INPUT_DIR="$HOME/scratch/Data/Community/ReadAligns"
OUTPUT_DIR="$HOME/scratch/Data/Community/CheckQual"

# Ensure OUTPUT_DIR exists
mkdir -p "$OUTPUT_DIR"

#You would need to run this if you are running checkm locally
#checkm data setRoot .
gunzip "$OUTPUT_DIR/semibinout/*gz"
for file in "$OUTPUT_DIR"/binspreader-Rcorr/*fasta ; do checkm lineage_wf -t 16 -x fasta --tab_table -f "$file/checkm_result.tsv" "$file/bins" "$file/checkm" ; done
for file in "$OUTPUT_DIR"/semibinout/*fa; do checkm lineage_wf -t 16 -x fa --tab_table -f "$OUTPUT_DIR/$file"/checkm_result.tsv "$OUTPUT_DIR/$file"/bins" "$OUTPUT_DIR/$file"/checkm ;done 

#Requirements
#checkm
#checkm_database


#conda deactivate
#delete intermediate files for cleanup
