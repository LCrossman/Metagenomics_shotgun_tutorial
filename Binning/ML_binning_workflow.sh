#!/bin/bash -e
#SBATCH --qos=bio-ds
#SBATCH -p bio-ds
#SBATCH --mem=10G
#SBATCH --cpus-per-task=16
#SBATCH --job-name=metagenomics_tutorial_MLbinning
#SBATCH -o /gpfs/home/%u/scratch/Data/Metagenomics_tutorial/MLBinning/Output_Messages/Metagenomics_tutorial-%a.out
#SBATCH -e /gpfs/home/%u/scratch/Data/Metagenomics_tutorial/MLBinning/Error_Messages/Metagenomics_tutorial-%a.err
#SBATCH --mail-type=ALL
#SBATCH --mail-user=#<your.email@address>

module load SemiBin2/2.2.0
echo "environment successfully created"
GENOME_FASTA="$HOME/scratch/Metagenomics_shotgun_tutorial/RawData/CommunityScaffolds.fasta"
INPUT_DIR="$HOME/scratch/Metagenomics_shotgun_tutorial/ReadAligns/"

SemiBin single_easy_bin -i "$GENOME_FASTA" --environment global -b "$INPUT_DIR"Community_aligned.bam.sorted.bam -o semibinout --verbose




