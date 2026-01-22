#!/bin/bash
#SBATCH --mem=10G
#SBATCH --cpus-per-task=16
#SBATCH --job-name=metagenomics_tutorial
#SBATCH -o /gpfs/home/hrj09fju/scratch/Data/Metagenomics_tutorial/Binning/Output_Messages/Metagenomics_tutorial-%a.out
#SBATCH -e /gpfs/home/hrj09fju/scratch/Data/Metagenomics_tutorial/Binning/Error_Messages/Metagenomics_tutorial-%a.err
#SBATCH --mail-type=ALL
#SBATCH --mail-user=$(USER)

module add mamba/25.3.1-0   #load mamba module to install binspreader
#mamba is a faster version of anaconda/conda
# ----------------------------------------------------------------------
# mamba environment setup
# To recreate the RNA-Seq_env conda environment used by this script:
# mamba env create -n binning_env -f binmetabat.yaml

# Make sure RNA-Seq_env.yml and RNA-Seq_env.txt are present in this directory.
# -
source /gpfs/software/hali/mamba/25.3.1-0/etc/profile.d/mamba.sh
echo "successfully sourced paths"

# initialize Mamba
mamba activate binning_env
module add python/anaconda/2024.10/3.12.7
echo "environment activated"

# Define input/output directories
GENOME_FASTA="/gpfs/home/hrj09fju/scratch/References/CommunityScaffolds.fasta"
FASTQ_DIR="/gpfs/home/hrj09fju/scratch/Data/Community/FastQ/raw_data"
INPUT_DIR="/gpfs/home/hrj09fju/scratch/Data/Community/ReadAligns"
OUTPUT_DIR="/gpfs/home/hrj09fju/scratch/Data/Community/Bins"

# Ensure OUTPUT_DIR exists
mkdir -p "$OUTPUT_DIR"

echo "defined directories, commencing depth statistics calculation"

jgi_summarize_bam_contig_depths --referenceFasta CommunityScaffolds.fasta --outputDepth depth.txt Community_aligned.bam.sorted.bam

metabat2 -t 16 -a depth.txt -i CommunityScaffolds.fasta -o EDMEBins --minContig 2000 --noAdd -v
echo "completed metabat2 binning process"

#renaming files which finish in .fa from metabat2 but need to finish .fasta for binspreader_protocol
for file in EDMEBins*.fa; do mv $file $file"sta"; done

echo "renamed files for converting to tab delimited format
python scripts/convert_fasta_bins_to_tsv_format.py --o binning.tsv EDMEBins*

echo "refining current bins using the metagenomics assembly graph with our newly calculated binning.tsv"
bin-refine CommunityAssembly_graphwithscaffolds.gfa binning.tsv binspreader-Rcorr --bin-dist -t 16 -Rcorr | tee binspreader-Rcorr.log

echo "bin refining process complete"
python scripts/visualize_bin_dist.py -i binspreader-Rcorr/bin_dist.tsv -o result/dendrogram.png

for FOLDER in binspreader-Rcorr ; do python scripts/extract_fasta_bins.py -b binning.tsv -i CommunityScaffolds.fasta -o $FOLDER/bins/ ; done
echo "bin fasta files extracted"
#binspreader
#python scripts wide2long.py, extract_fasta_bins.py, visualise_bin_dist.py, convert_fasta_bins_to_tsv_format.py

mamba deactivate
#delete intermediate files for cleanup
