# Metagenomics_shotgun_tutorial 

Metagenomics | shotgun workflow tutorial | Data Science and Bioinformatics (BIO-7051B)

<hr style="height:5px; border:none; color:#333; background-color:#333;">

Currently *NOT FULLY WORKING* this is a draft only

# Learning Objectives 

- Understand the basics of shotgun Metagenomics analysis to go from reads -> metagenome bins
- To investigate bins in terms of 'who is there' and 'how much'
- Understand some limitations of current analyses

---

Background 

You are provided with a paired-end Illumina short read dataset.  In this tutorial we will investigate the
quality of the reads and align them to a provided metagenome assembly.  The assembly is provided for
you because assembling metagenomic data requires significant compute in both time and resource.  
Multiple metagenome assembly programs are available.  This assembly was carried out with Megahit software. 
Once reads are aligned, we calculate the coverage of the reads on each of the contigs in the assembly.
We use the assembly and coverage stats along with different binning software to extract single genomes (bins)
from the dataset.  We then identify the quality of these bins and assign them to microbial taxa. 

<hr style="height:5px; border:none; color:#333; background-color:#333;">

# Step 1. - Read Alignments
(Recommended to begin *before* the session because it takes ~ 20 minutes to align the reads)

*Contents* 

1.1 Raw Data
You will find the metagenome assembly in the GitHub repository (CommunityScaffolds.fasta).  The paired-end
short read data is at /gpfs/data/BIO-DBS/Session7/MG_workflow_2026/RawData/  You will need these three files for the next step.

Fasta Assembly file:  CommunityScaffolds.fasta 

Short Reads R1: EDME200007170-1a_HCYHVDSXY_L2_1.fq.gz

Short Reads R2: EDME200007170-1a_HCYHVDSXY_L2_2.fq.gz

1.2 Read Aligns
You have already carried out read alignments in this module. You can use either these scripts to align these reads (since these
reads have already been quality checked) or go through your previous methods with BWA to produce the required output
of this stage - which is a *sorted* Bam file containing all the read alignments to the metagenome assembly.

Script: ReadAligns/readalign_bam_and_sort.sh

Purpose: Aligning illumina short reads to sam format, convert to bam and sort alignments

Output: A sorted bam file containing read alignment data

<hr style="height:5px; border:none; color:#333; background-color:#333;"> 

# Step 2. - Binning 
- Try to run the binning pipeline
- Investigate the questions
---->>  if you are building on any system other than HPC you will need to build metabat2 directly from mamba or conda

2.1 Binning with Metabat2 
Here you can use alternative binning software to investigate the metagenome.  We first use Metabat2 and
some python scripts to identfy some bins.  We then use binspreader-R to improve the bins.

Script: Binning/binning_workflow.sh

Purpose: Metagenomic binning to extract single genomes from the mixture 

Outputs: For each binning program you will output some stats and bins as a set of genome fasta files 

2.2 Binning with Semibin2
Next you can use a newer machine learning binning algorithm (Sembin2) to bin the metagenome assembly. 
Semibin2 use deep learning neural networks to bin the assembly contigs instead of rules and statistic based methods

Script: Binning/ML_binning_workflow.sh

Purpose: Metagenomic binning to extract single genomes from a mixture using a machine learning method

Outputs: Stats and bins as a set of genome fasta files

# Step 3. - Assess Bin Quality
-->> it is *highly* recommended to run this on HPC because installation of checkM can be tricky! 

Check Quality of the bins
You will need to check the quality of all the bins using the program CheckM which outputs statistics such
as the completeness and contamination.

Script: CheckQual/checkm_quality.sh

Purpose: To identify the quality of each bin. 

Output Files: set of checkm output files

# Step 4. Identify Taxa
Now you can identify taxa on the best quality bins using Kraken2.

Script: taxa_classify_bins.sh

Purpose: Identify Taxa for each bin fasta file

Output: Bin reports - for each bin there will be a taxa report with abundance from Kraken/Bracken

# Step 5. Conclusions
Make some conclusions about your results both technically and biologically. 

# Step 6. Optional - Plotting scripts in R programming language

Scripts: Optional_plotting/plot_metabat_statistics.R

Data: Your output from steps 4 or 5. 

Purpose:  Starting material for Group Project 

Output:  Result figures 


<hr style="height:5px; border:none; color:#333; background-color:#333;"> 

# Group Project Ideas 

Take the analyses further with the following suggestions:

- Binning parameters:  Metabat2 has a large number of parameters that can be used to fine-tune your results.
Read the short software manual for metabat2 to identify these parameters, alter some and identify using checkM whether the parameters improved the bin qualities or not.  Try to make some conclusions about why.

- Data Visualization (use R): Plot graphs of the data from step 4 (e.g. numbers of bins, length in bp of each fasta, N50) and/or step 5 (e.g. contamination, heterogeneity, completeness of different binning methods) using R ggplot2 or similar.  Do the results show any particular trends?

- Long Reads:  You can find a dataset of long reads for the same data (Oxford Nanopore) in [..]  You can use these in the Metabat2 binning
program together with the short read assembly CommunityScaffolds.fasta as if they are metagenomic contigs.
HINT: use linux to join the files together using:

```
cat CommunityScaffolds.fasta LongReads.fasta > TotalDataset.fasta
```

After binning, use checkM on each of the bin fasta files to identify if the long reads improved the results or not. 

- Real world Garden Data:  Ask me for the link to three separate short read metagenomic datasets from soil in a Professor's garden.  Is the microbial
composition in the three samples identical/similar or different?









