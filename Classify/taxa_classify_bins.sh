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
mamba install -c conda-forge parallel
# Define input/output directories
GENOME_FASTA="$HOME/scratch/Metagenomics_shotgun_tutorial/RawData/CommunityScaffolds.fasta"
DB_DIR="/gpfs/data/BIO-DSB/Session7/MG_workshop_2026/Classify/k2_pluspf_08_GB_20251015"
BINS_DIR="$HOME/scratch/Metagenomics_shotgun_tutorial/CheckQual/Bins/"
OUTPUT_DIR="$HOME/scratch/Metagenomics_shotgun_tutorial/Classify/output/"

# Ensure OUTPUT_DIR exists
mkdir -p "$OUTPUT_DIR"
echo $DB_DIR

find "$BINS_DIR" -maxdepth 1 -name "*fasta" -printf "%f\n" > basenames.txt

cat basenames.txt | parallel --jobs 4 "kraken2 --db '$DB_DIR' --memory-mapping --threads 4 '$BINS_DIR'{} --report '$OUTPUT_DIR'{}.krak --output '$OUTPUT_DIR'{}.out" 

echo "completed classification with kraken"
cat basenames.txt | parallel --jobs 1 "bracken -d '$DB_DIR' -i '$OUTPUT_DIR'{}.krak -o '$OUTPUT_DIR'{}.bracken -r 150 -l G"
echo "completed report on the bins with bracken"

