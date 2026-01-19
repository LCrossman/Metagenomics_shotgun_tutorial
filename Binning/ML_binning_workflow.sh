#!/bin/bash
#SBATCH --mem=10G
#SBATCH --cpus-per-task=16
#SBATCH --job-name=metagenomics_tutorial
#SBATCH -o /gpfs/home/hrj09fju/scratch/Data/Metagenomics_tutorial/Binning/Output_Messages/Metagenomics_tutorial-%a.out
#SBATCH -e /gpfs/home/hrj09fju/scratch/Data/Metagenomics_tutorial/Binning/Error_Messages/Metagenomics_tutorial-%a.err
#SBATCH --mail-type=ALL
#SBATCH --mail-user=#<your.email@address>

module load mamba/25.3.1-0

mamba env create -f ML_binning_env.yaml

mamba activate ML_binning_env

semibin2 single_easy_bin -i Mockscaffolds.fasta --environment global -b Mocked.bam.sorted.bam -o semibinout --verbose




