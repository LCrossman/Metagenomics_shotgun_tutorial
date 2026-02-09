#!/bin/bash -e
#SBATCH --qos=bio-ds # User group
#SBATCH -p bio-ds  
#SBATCH --mem=40G
#SBATCH --cpus-per-task=16
#SBATCH --job-name=metagenomics_tutorial_qual
#SBATCH -o /gpfs/home/%u/scratch/Data/Metagenomics_tutorial/CheckQual/Output_Messages/Metagenomics_tutorial-%a.out
#SBATCH -e /gpfs/home/%u/scratch/Data/Metagenomics_tutorial/CheckQual/Error_Messages/Metagenomics_tutorial-%a.err
#SBATCH --mail-type=ALL
#SBATCH --mail-user=#<your.email@address>


module add checkm/1.2.4

# Define input/output directories
GENOME_FASTA="$HOME/Metgenomics_shotgun_tutorial/Binning/CommunityScaffolds.fasta"
FASTQ_DIR="/gpfs/data/BIO-DSB/Session7/MG_workshop_tutorial/FASTQ/"
INPUT_DIR_METABAT="$HOME/scratch/Data/Community/Bins/"
INPUT_DIR_SEMIBIN="$HOME/Metagenomics_shotgun_tutorial/Binning/semibinout/output_bins/"
INPUT_DIR="$HOME/Metagenomics_shotgun_tutorial/CheckQual/bins"
OUTPUT_DIR="$HOME/Metagenomics_shotgun_tutorial/CheckQual/checkm_output/"


# Ensure OUTPUT_DIR exists
mkdir -p "$OUTPUT_DIR"
mkdir -p "$INPUT_DIR"

find "$INPUT_DIR_METABAT" -maxdepth 1 -name "*fasta" -exec cp {} "$INPUT_DIR" \;

#You would need to run this if you are running checkm locally
#checkm data setRoot .
find "$INPUT_DIR_SEMIBIN" -maxdepth 1 -name "*.gz" -exec gunzip {} \;

cp "$INPUT_DIR_SEMIBIN"*fa "$INPUT_DIR"
for file in "$INPUT_DIR"*fa; do mv $file $file"sta"; done

for file in "$INPUT_DIR"* ; do checkm lineage_wf -t 16 -x fasta --reduced_tree --tab_table -f "$file".checkm_result.tsv "$INPUT_DIR" "$OUTPUT_DIR"$file.checkm ; done
#Requirements
#checkm
#checkm_database


#conda deactivate
#delete intermediate files for cleanup
