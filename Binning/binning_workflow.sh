#!/bin/bash
#SBATCH --mem=10G
#SBATCH --cpus-per-task=16
#SBATCH --job-name=metagenomics_tutorial
#SBATCH -o /gpfs/home/hrj09fju/scratch/Data/Metagenomics_tutorial/Binning/Output_Messages/Metagenomics_tutorial-%a.out
#SBATCH -e /gpfs/home/hrj09fju/scratch/Data/Metagenomics_tutorial/Binning/Error_Messages/Metagenomics_tutorial-%a.err
#SBATCH --mail-type=ALL
#SBATCH --mail-user=$(USER)

module add mamba/25.3.1
source /gpfs/software/hali/mamba/25.3.1-0/etc/profile.d/mamba.sh
mamba create -n unpackenv
mamba activate unpackenv

# mamba is a faster version of anaconda/conda
# however, the binning software metabat2 uses boost C++ libraries which takes a really long time (~ 10 mins) to install on HPC
# what we can do instead is to use conda-pack to create an archived environment.  This archived environment
# is only for HPC and you would have to use mamba to fully build the environment on any other system

# to build the env for yourself use this after copying /gpfs/data/BIO-DSB/Session7/MG_workflow_2026/binning_env.tar.gz to your scratch
# mkdir -p scratch/my_binning_env
# tar -xvf scratch/binning_env.tar.gz -C scratch/my_binning_env
# source scratch/my_binning_env/bin/activate

# to build straightaway from the BIO-DSB dir - fastest but the environemnt will be read-only
source /gpfs/data/BIO-DSB/Session7/MG_workshop_2026/Binning_env/bin/activate


# Define input/output directories
GENOME_FASTA="/gpfs/data/BIO-DSB/Session7/MG_workshop_2026/Communityscaffolds.fasta"
FASTQ_DIR="/gpfs/data/BIO-DSB/Session7/MG_workshop_2026/FASTQ/"
INPUT_DIR="$HOME/scratch/Data/Community/ReadAligns"
SCRIPT_DIR="/gpfs/data/BIO-DSB/Session7/MG_workshop_2026/scripts/"
OUTPUT_DIR="$HOME/scratch/Data/Community/Bins"

# For use in any other environment you will need to setup with the usual method 
# mamba environment setup 
# mamba env create -n binning_env -f leanbinmetabat.yaml

echo "successfully created environment from paths"

# Ensure OUTPUT_DIR exists
mkdir -p "$OUTPUT_DIR"


jgi_summarize_bam_contig_depths --referenceFasta $INPUT_DIR/Communityscaffolds.fasta --outputDepth depth.txt $INPUT_DIR/Community_aligned.bam.sorted.bam

echo "defined directories, commencing depth statistics calculation"

metabat2 -t 16 -a $OUTPUT_DIR/depth.txt -i $INPUT_DIR/CommunityScaffolds.fasta -o $OUTPUT_DIR/EDMEBins --minContig 2000 --noAdd -v
echo "completed metabat2 binning process"

#renaming files which finish in .fa from metabat2 but need to finish .fasta for binspreader_protocol
for file in $OUTPUT_DIR/EDMEBins*.fa; do mv $file $file"sta"; done

echo "renamed files for converting to tab delimited format
python $SCRIPT_DIR/convert_fasta_bins_to_tsv_format.py --o binning.tsv $OUTPUT_DIR/EDMEBins*

echo "refining current bins using the metagenomics assembly graph with our newly calculated binning.tsv"
bin-refine CommunityScaffolds_assembly.gfa binning.tsv binspreader-Rcorr --bin-dist -t 16 -Rcorr | tee binspreader-Rcorr.log

<<<<<<< HEAD
python $SCRIPT_DIR/visualize_bin_dist.py -i binspreader-Rcorr/bin_dist.tsv -o result/dendrogram.png

for FOLDER in binspreader-Rcorr ; do python $SCRIPT_DIR/extract_fasta_bins.py -b $FOLDER/binning.tsv -i $INPUT_DIR/CommuityScaffolds.fasta -o $FOLDER/bins/ ; done

echo "bin refining process complete"

# these scripts could be of interest to look into in more depth
#python scripts wide2long.py, extract_fasta_bins.py, convert_fasta_bins_to_tsv_format.py

mamba deactivate

