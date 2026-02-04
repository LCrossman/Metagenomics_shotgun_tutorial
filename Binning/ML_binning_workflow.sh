#!/bin/bash -e
#SBATCH --qos=bio-ds
#SBATCH -p bio-ds
#SBATCH --mem=10G
#SBATCH --cpus-per-task=16
#SBATCH --job-name=metagenomics_tutorial_MLbinning
#SBATCH -o /gpfs/home/%u/scratch/Data/Metagenomics_tutorial/Binning/Output_Messages/Metagenomics_tutorial-%a.out
#SBATCH -e /gpfs/home/%u/scratch/Data/Metagenomics_tutorial/Binning/Error_Messages/Metagenomics_tutorial-%a.err
#SBATCH --mail-type=ALL
#SBATCH -j "ML_binning"
#SBATCH --mail-user=#<your.email@address>

module load SemiBin2/2.2.0
echo "environment successfully created"

SemiBin single_easy_bin -i CommunityScaffolds.fasta --environment global -b Community_aligned.bam.sorted.bam -o semibinout --verbose




