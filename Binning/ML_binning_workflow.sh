#!/bin/bash -e
#SBATCH --qos=bio-ds
#SBATCH -p bio-ds
#SBATCH --mem=10G
#SBATCH --cpus-per-task=16
#SBATCH --job-name=metagenomics_tutorial
#SBATCH -o scratch/Data/Metagenomics_tutorial/Binning/Output_Messages/Metagenomics_tutorial-%a.out
#SBATCH -e scratch/Data/Metagenomics_tutorial/Binning/Error_Messages/Metagenomics_tutorial-%a.err
#SBATCH --mail-type=ALL
#SBATCH -j "ML_binning"
#SBATCH --mail-user=#<your.email@address>

module load mamba/25.3.1-0

mamba env create -f ML_binning_env.yaml

mamba activate ML_binning_env
echo "environment successfully created"

semibin2 single_easy_bin -i CommunityScaffolds.fasta --environment global -b Community_aligned.bam.sorted.bam -o semibinout --verbose




