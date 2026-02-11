#!/bin/bash -e
#SBATCH --qos=bio-ds
#SBATCH -p bio-ds
#SBATCH --mem=24G
#SBATCH --cpus-per-task=8
#SBATCH --job-name=metagenomics_tutorial_classification
#SBATCH -o /gpfs/home/%u/scratch/Data/Metagenomics_tutorial/Classify/Output_Messages/Metagenomics_tutorial-%a.out
#SBATCH -e /gpfs/home/%u/scratch/Data/Metagenomics_tutorial/Classify/Error_Messages/Metagenomics_tutorial-%a.err
#SBATCH --mail-type=ALL
#SBATCH --mail-user=#<your.email@address>

module add mamba/25.3.1-0   #load mamba module to install binspreader
#mamba is a faster version of anaconda/conda
# ----------------------------------------------------------------------
# mamba environment setup
# mamba env create -n classify_env -f classifykraken.yaml

source /gpfs/software/hali/mamba/25.3.1-0/etc/profile.d/mamba.sh
echo "successfully sourced paths"
mamba create -n unpack-env
# initialize Mamba
mamba activate unpack-env
source /gpfs/data/BIO-DSB/Session7/MG_workshop_2026/Classify/classify_env/bin/activate
echo "environment activated"

# Define input/output directories
GENOME_FASTA="$HOME/Metagenomics_shotgun_tutorial/RawData/Communityscaffolds.fasta"
DB_DIR="/gpfs/data/BIO-DSB/Session7/MG_workshop_2026/Classify/k2_pluspf_16GB_20251015"
BINS_DIR="$HOME/Metagenomics_shotgun_tutorial/CheckQual/bins/"
OUTPUT_DIR="$HOME/Metagenomics_shotgun_tutorial/Classify/output/"

# Ensure OUTPUT_DIR exists
mkdir -p "$OUTPUT_DIR"
echo $DB_DIR

for bin in "$BINS_DIR*fasta"; do
     echo $bin;	
     kraken2 --db "$DB_DIR" --memory-mapping --threads 8 $bin --report $bin.krak --output $bin.out ; done

echo "completed classification with kraken"
for report in "$OUTPUT_DIR/*krak"; do
    bracken -d "$DB_DIR" -i $report -o $report.bracken -w -r 100 -l S -t 16 ; done
echo "completed report on the bins with bracken"

