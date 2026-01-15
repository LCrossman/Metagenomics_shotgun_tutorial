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

Step 1 (begin at the session)
It is *highly* recommended to run this on HPC because the binning software and checkM is tricky to install!

- Try to run the full pipeline
- Investigate the questions

Step 2 (advanced) 

- tackle the advanced questions

<hr style="height:5px; border:none; color:#333; background-color:#333;"> 

# Contents 

1. Raw Data
You will find the metagenome assembly in the GitHub repository (CommunityScaffolds.fasta).  The paired-end
short read data is [..]  You will need these three files for the next step.

Fasta Assembly file:  CommunityScaffolds.fasta 
Short Reads R1: 
Short Reads R2: 

3. Read Aligns
You have already carried out read alignments in this module. You can either use these methods (since these
reads have already been quality checked) or go through your previous methods to produce the required output
of this stage - which is a *sorted* Bam file containing all the read alignments to the metagenome assembly.

Script: 
Purpose: 
Output: 

5. Binning
Here you can use alternative binning software to investigate the metagenome.  We first use Metabat2 and
some python scripts to identfy some bins.  We then use binspreader-R to improve the bins.

Next you can use a newer machine learning binning algorithm (Sembin2) to bin the metagenome assembly. 

Script: 
Purpose: Metagenomic binning to extract single genomes from the mixture 
Outputs: For each binning program you will output some stats and bins as a set of genome fasta files 

5. Check Quality of the bins
You will need to check the quality of all the bins using the program CheckM which outputs statistics such
as the completeness and contamination.

Script: 
Purpose: To identify the quality of each bin. 
Output Files: 

7. Finally, you can identify taxa on the best quality bins using Kraken2.

Script: 
Purpose: 
Output:  

9. Make some conclusions about your results both technically and biologically. 

10. Plotting

Scripts: 
Data: Your output from steps 4 or 5. 
Purpose:  Starting material for Group Project 
Output:  Result figures 

<hr style="height:5px; border:none; color:#333; background-color:#333;"> 

# Group Project Ideas 

Take the analyses further with the following suggestions:

- Binning parameters:  Metabat2 has a large number of parameters that can be used to fine-tune your results.
Read the short software manual for metabat2 to identify these parameters, alter some and identify using checkM whether the parameters improved the bin qualities or not.  Try to make some conclusions about why.

- Consider the composition of the provided dataset.  You may be able to find out what it is from online from the organisms you identified.  There are particular features of this dataset that make it both (a) easier and (b) more difficult to bin.
What are these features?

- Data Visualization (use R): Plot graphs of the data from step 4 (e.g. numbers of bins, length in bp of each fasta, N50) and/or step 5 (e.g. contamination, heterogeneity, completeness of different binning methods) using R ggplot2 or similar.  Do the results show any particular trends?

- Long Reads:  You can find a dataset of long reads for the same data (Oxford Nanopore) in [..]  You can use these in the binning
programs together with the short read assembly CommunityScaffolds.fasta as if they are metagenomic contigs.
HINT: use linux to join the files together using:

```
cat CommunityScaffolds.fasta LongReads.fasta > TotalDataset.fasta
```

Use checkM to identify if the long reads improved the results or not. 

- Garden Data:  Ask me for three separate short read metagenomic datasets from a Professor's garden.  Is the microbial
composition in the three samples identical/similar or different?









