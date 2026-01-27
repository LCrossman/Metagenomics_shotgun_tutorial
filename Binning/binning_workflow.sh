#!/bin/bash
#SBATCH --mem=10G
#SBATCH --cpus-per-task=16
#SBATCH --job-name=metagenomics_tutorial
#SBATCH -o /gpfs/home/hrj09fju/scratch/Data/Metagenomics_tutorial/Binning/Output_Messages/Metagenomics_tutorial-%a.out
#SBATCH -e /gpfs/home/hrj09fju/scratch/Data/Metagenomics_tutorial/Binning/Error_Messages/Metagenomics_tutorial-%a.err
#SBATCH --mail-type=ALL
#SBATCH --mail-user=$(USER)


source /gpfs/software/hali/mamba/25.3.1-0/etc/profile.d/mamba.sh
module add mamba/25.3.1-0   #load mamba module to install binspreader
#mamba is a faster version of anaconda/conda
# however, the binning software metabat2 uses boost C++ libraries which takes a really long time (~ 10 mins) to install on HPC
# what we can do instead is to use conda-pack to create an archived environment.  This archived environment
# is only for HPC and you would have to use mamba to fully build the environment on any other system
# ----------------------------------------------------------------------
# setup for HPC using conda-pack
# 1. You will need the packed (binning_env.tar.gz) file
# 2. source /gpfs/software/hali/mamba/25.3.1-0/etc/profile.d/mamba.sh
# 3. module add mamba/25.3.1
# 4. mkdir -p my_binning # you need to create the environment inside a directory or there will be a huge amount of files in your home dir
# 5. tar -xvf newbiopython.tar.gz -C my_binning
# 6. source my_binning/bin/activate
#
# For use in any other environment you will need to setup with the usual method 
# mamba environment setup
# To recreate the RNA-Seq_env conda environment used by this script:
# mamba env create -n binning_env -f binmetabat.yaml
# -

mkdir -p ~/my_binning
tar -xvf binning_env.tar.gz -C my_binning
source my_binning/bin/activate

echo "successfully created environment from paths"


# Define input/output directories
GENOME_FASTA="~/scratch/Data/References/CommunityScaffolds.fasta"
FASTQ_DIR="/gpfs/data/BIO-DSB/Session8/FastQ/"
INPUT_DIR="~/scratch/Data/Community/ReadAligns"
OUTPUT_DIR="~/scratch/Data/Community/Bins"

# Ensure OUTPUT_DIR exists
mkdir -p "$OUTPUT_DIR"

echo "defined directories, commencing depth statistics calculation"

jgi_summarize_bam_contig_depths --referenceFasta CommunityScaffolds.fasta --outputDepth depth.txt Community_aligned.bam.sorted.bam

metabat2 -t 16 -a depth.txt -i CommunityScaffolds.fasta -o EDMEBins --minContig 2000 --noAdd -v
echo "completed metabat2 binning process"

#renaming files which finish in .fa from metabat2 but need to finish .fasta for binspreader_protocol
for file in EDMEBins*.fa; do mv $file $file"sta"; done

echo "renamed files for converting to tab delimited format
convert_fasta_bins_to_tsv_format.py --o binning.tsv EDMEBins*

echo "refining current bins using the metagenomics assembly graph with our newly calculated binning.tsv"
bin-refine CommunityAssembly_graphwithscaffolds.gfa binning.tsv binspreader-Rcorr --bin-dist -t 16 -Rcorr | tee binspreader-Rcorr.log

echo "bin refining process complete"
visualize_bin_dist.py -i binspreader-Rcorr/bin_dist.tsv -o result/dendrogram.png

for FOLDER in binspreader-Rcorr ; do extract_fasta_bins.py -b binning.tsv -i CommunityScaffolds.fasta -o $FOLDER/bins/ ; done
echo "bin fasta files extracted"
#binspreader
#python scripts wide2long.py, extract_fasta_bins.py, visualise_bin_dist.py, convert_fasta_bins_to_tsv_format.py

mamba deactivate
#delete intermediate files for cleanup
