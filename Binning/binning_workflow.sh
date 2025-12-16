#!/bin/bash
#SBATCH --mem=10G
#SBATCH --cpus-per-task=16
#SBATCH --job-name=metagenomics_tutorial
#SBATCH -o /gpfs/home/hrj09fju/scratch/Data/Metagenomics_tutorial/ReadAligns/Output_Messages/Metagenomics_tutorial-%a.out
#SBATCH -e /gpfs/home/hrj09fju/scratch/Data/Metagenomics_tutorial/ReadAligns/Error_Messages/Metagenomics_tutorial-%a.err
#SBATCH --mail-type=ALL
#SBATCH --mail-user=hrj09fju@uea.ac.uk

module load python/anaconda/2024.10/3.12.7  # check path and load Anaconda module to enable Conda commands


# Initialize Conda
#source /gpfs/software/hali/python/anaconda/2024.10/etc/profile.d/conda.sh

#conda env create -f Metagenomics_env.yaml

#conda activate Metagenomics_env


# Define input/output directories
GENOME_FASTA="/gpfs/home/hrj09fju/scratch/References/Communityscaffolds.fasta"
FASTQ_DIR="/gpfs/home/hrj09fju/scratch/Data/Community/FastQ/raw_data"
INPUT_DIR="/gpfs/home/hrj09fju/scratch/Data/Community/ReadAligns"
OUTPUT_DIR="/gpfs/home/hrj09fju/scratch/Data/Community/Bins"

# Ensure OUTPUT_DIR exists
mkdir -p "$OUTPUT_DIR"

module load metabat2

jgi_summarize_bam_contig_depths --referenceFasta Communityscaffolds.fasta --outputDepth depth.txt EDMECommunity.bam.sorted.bam

metabat2 -t 16 -a depth.txt -i Communityscaffolds.fasta -o EDMEBins --minContig 2000 --noAdd -v

#renaming files which finish in .fa from metabat2 but need to finish .fasta for binspreader_protocol
for file in EDMEBins*.fa; do mv $file $file"sta"; done

python scripts/convert_fasta_bins_to_tsv_format.py --o binning.tsv EDMEBins*

bin-refine Mock_assembly_graphwithscaffolds.gfa binning.tsv binspreader-Rcorr --bin-dist -t 16 -Rcorr | tee binspreader-Rcorr.log

python scripts/visualize_bin_dist.py -i binspreader-Rcorr/bin_dist.tsv -o result/dendrogram.png

for FOLDER in binspreader-Rcorr ; do python scripts/extract_fasta_bins.py -b $FOLDER/binning.tsv -i Mockscaffolds.fasta -o $FOLDER/bins/ ; done

binspreader
python scripts wide2long.py, extract_fasta_bins.py, visualise_bin_dist.py, convert_fasta_bins_to_tsv_format.py

conda deactivate
#delete intermediate files for cleanup

