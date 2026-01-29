#!/bin/bash
#SBATCH --mem=30G
#SBATCH --cpus-per-task=16
#SBATCH --job-name=metagenomics_tutorial
#SBATCH -o /gpfs/home/hrj09fju/scratch/Data/Metagenomics_tutorial/Classify/Output_Messages/Metagenomics_tutorial-%a.out
#SBATCH -e /gpfs/home/hrj09fju/scratch/Data/Metagenomics_tutorial/Classify/Error_Messages/Metagenomics_tutorial-%a.err
#SBATCH --mail-type=ALL
#SBATCH --mail-user=$(USER)

module add mamba/25.3.1-0   #load mamba module to install binspreader
#mamba is a faster version of anaconda/conda
# ----------------------------------------------------------------------
# mamba environment setup
# mamba env create -n classify_env -f classifykraken.yaml

source /gpfs/software/hali/mamba/25.3.1-0/etc/profile.d/mamba.sh
echo "successfully sourced paths"

# initialize Mamba
mamba activate classify_env
module add python/anaconda/2024.10/3.12.7
echo "environment activated"

# Define input/output directories
GENOME_FASTA="/gpfs/home/hrj09fju/scratch/References/CommunityScaffolds.fasta"
DB_DIR="/gpfs/data/BIO-DSB/Session8/MG_workshop_2026/Classify/k2_pluspf_16GB_20251015"
BINS_DIR=
OUTPUT_DIR="scratch/Data/Classify"

# Ensure OUTPUT_DIR exists
mkdir -p "$OUTPUT_DIR"

for bin in $BINS_DIR/*fasta; do 
     kraken2 --threads 16 --db $DB_DIR $bin --quick --report --output $bin.krak ; done

echo "completed classification with kraken"
for report in $OUTPUT_DIR/*krak; do
    bracken -d $DB_DIR -i $report -o $report.bracken -w -r 100 -l S -t 16 ; done
echo "completed report on the bins with bracken"

