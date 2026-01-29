#!/bin/bash
#SBATCH --mem=10G
#SBATCH --cpus-per-task=16
#SBATCH --job-name=metagenomics_tutorial
#SBATCH -o /gpfs/home/hrj09fju/scratch/Data/Metagenomics_tutorial/ReadAligns/Output_Messages/Metagenomics_tutorial-%a.out
#SBATCH -e /gpfs/home/hrj09fju/scratch/Data/Metagenomics_tutorial/ReadAligns/Error_Messages/Metagenomics_tutorial-%a.err
#SBATCH --mail-type=ALL
#SBATCH --mail-user=hrj09fju@uea.ac.uk

module add mamba/25.3.1
source /gpfs/software/hali/mamba/25.3.1-0/etc/profile.d/mamba.sh
mamba create -n unpackenv
mamba activate unpackenv

# mkdir -p scratch/binning_env
# tar -xvf binning_env.tar.gz -C scratch/binning_env
# source scratch/binning_env/bin/activate

source /gpfs/data/BIO-DSB/Session7/MG_workshop_2026/Binning_env/bin/activate


# Define input/output directories
GENOME_FASTA="/gpfs/data/BIO-DSB/Session7/MG_workshop_2026/Communityscaffolds.fasta"
FASTQ_DIR="/gpfs/data/BIO-DSB/Session7/MG_workshop_2026/FASTQ/"
INPUT_DIR="$HOME/scratch/Data/Community/ReadAligns"
SCRIPT_DIR="/gpfs/data/BIO-DSB/Session7/MG_workshop_2026/scripts/"
OUTPUT_DIR="$HOME/scratch/Data/Community/Bins"

# Ensure OUTPUT_DIR exists
mkdir -p "$OUTPUT_DIR"

jgi_summarize_bam_contig_depths --referenceFasta Communityscaffolds.fasta --outputDepth depth.txt $INPUT_DIR/Community.bam.sorted.bam

metabat2 -t 16 -a depth.txt -i Communityscaffolds.fasta -o EDMEBins --minContig 2000 --noAdd -v

#renaming files which finish in .fa from metabat2 but need to finish .fasta for binspreader_protocol
for file in EDMEBins*.fa; do mv $file $file"sta"; done

python scripts/convert_fasta_bins_to_tsv_format.py --o binning.tsv EDMEBins*

bin-refine Mock_assembly_graphwithscaffolds.gfa binning.tsv binspreader-Rcorr --bin-dist -t 16 -Rcorr | tee binspreader-Rcorr.log

python $SCRIPT_DIR/visualize_bin_dist.py -i binspreader-Rcorr/bin_dist.tsv -o result/dendrogram.png

for FOLDER in binspreader-Rcorr ; do python $SCRIPT_DIR/extract_fasta_bins.py -b $FOLDER/binning.tsv -i Mockscaffolds.fasta -o $FOLDER/bins/ ; done

#python scripts wide2long.py, extract_fasta_bins.py, visualise_bin_dist.py, convert_fasta_bins_to_tsv_format.py

conda deactivate
#delete intermediate files for cleanup

