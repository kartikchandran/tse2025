# Viral sequencing workflow
## Published in Tse et al., PLoS Pathogens, 2025

### Hardware, operating systen, software
- Mac (arm64)
- Mac OS v15.1 (Sequoia)
- Terminal v2.14
- GNU bash v3.2.57(1)-release (arm64-apple-darwin24)
- minimap2 v2.30-r1287 (available [here](https://github.com/lh3/minimap2))
- samtools v1.22.1
- bcftools v1.22
- htslib v1.22
  - Available [here](https://www.htslib.org)
- Integrative Genomics Viewer (IGV) v2.19.5 (available [here](https://www.igv.org))
   
### Data acquisition
A genome-scale CRISPR/Cas9 cell-survival screen for virus dependency factors was performed as described in Mittler et al.

A549 cells transduced with a lentiviral pool encoding the [Gecko-v2 CRISPR/Cas9-based gene inactivation library](https://www.addgene.org/pooled-library/zhang-human-gecko-v2/) were either left untreated or exposed to virus. The surviving cells were expanded and their genomic DNA was isolated. Experiments were performed in biological duplicate to yield 4 samples (control-rep1, virus-rep1, control-rep2, virus-rep2). 

Amplicons containing single-guide RNA (sgRNA) sequences were prepared from the genomic gDNA and ligated to Illumina adapters. Libraries were pooled and sequenced on the Illumina NextSeq 500 (2x150 bp, paired-end mode). FASTQ files were demultiplexed and processed to remove technical adapter sequences.

#### Input data files
1. control-rep1_R1.fastq
2. control-rep1_R2.fastq
3. virus-rep1_R1.fastq
4. virus-rep1_R2.fastq
5. control-rep2_R1.fastq
6. control-rep2_R2.fastq
7. virus-rep2_R1.fastq
8. virus-rep2_R2.fastq

rep = replicate, 
R1 = P7 read, 
R2 = P5 read

#### Read structure
<img width="1256" alt="Screenshot 2024-10-27 at 9 27 45 AM" src="https://github.com/user-attachments/assets/a3114525-5088-4117-8189-991ae055bf35">

#### Reorienting reads with `pooled_CRISPR_screen_Gecko_v2_reorient.sh`
Because adapter ligation is orientation-independent, the R1 and R2 read files for each sample are expected to contain ~50% of the 'forward' reads of interest (containing the sgRNA sequence). 

The bash script `pooled_CRISPR_screen_Gecko_v2_reorient.sh` extracts reads from the R1 and R2 FASTQ files that are in the desired forward orientation and compiles them into a new `_reoriented_R1.fastq` file. Reverse reads only contain sgRNA scaffold and lentiviral framework sequences and are discarded.

#### Running `mageck count`

See [mageck count](https://sourceforge.net/p/mageck/wiki/usage/#count) for documentation. 

Launch mageck count from Terminal command line to determine sgRNA readcounts in each fileset as follows:

`mageck count -l Human_GeCKOv2_Library_combine.csv --fastq control_rep1_reoriented_R1.fastq control_rep2_reoriented_R1.fastq virus_rep1_reoriented_R1.fastq virus_rep2_reoriented_R1.fastq --norm-method median -n virus_screen --unmapped-to-file --sample-label control1,control2,virus1,virus2`

Library file containing Gecko-v2 sgRNA sequences is available [here](https://github.com/chandranlab/mittler_2024/blob/main/Human_GeCKOv2_Library_combine.csv).

Output file `virus_screen.count.txt` containing sgRNA readcounts for each sample is used as input for `mageck test`.

#### Running `mageck test`
See [mageck test](https://sourceforge.net/p/mageck/wiki/usage/#test) for documentation. 

Launch mageck test from Terminal to rank sgRNAs and genes based on the read count table provided:

`mageck test -k virus_screen.count.txt -t 2,3 -c 0,1 -n virus --norm-method median --pdf-report`

The gene-specific positive selection score in output file `virus.gene_summary.txt` was used to identify gene hits (see the manuscript).

#### Demo dataset

A sample dataset for testing the bash script (gzipped FASTQ R1 and R2 files containing 2,500 reads) can be downloaded [here](https://github.com/chandranlab/mittler_2024/tree/main/demo_fastq_files).

A raw CRISPR/Cas9 screen dataset from [Kulsuptrakul et al.](https://doi.org/10.1016/j.celrep.2021.108859) was used for testing the mageck subcommands and is available for download on [EBI ArrayExpress](https://www.ebi.ac.uk/biostudies/arrayexpress/studies/E-MTAB-8646). 

---

### B. CellProfiler analysis of immunofluorescence microscopy images

#### Hardware, operating systen, software
- Mac (arm64)
- Mac OS v14.6.1 (Sonoma)
- CellProfiler v4.2.6 (available [here](https://cellprofiler.org/))

#### Data acquisition
Experiments to detect and measure virus attachment and internalization into A549 cells was performed. Cells were fluorescently labeled for plasma membrane glycans (wheat germ aggluttinin (WGA)), virus glycoprotein E, and nuclei. 

Cells were visualized by confocal microscopy, and fields containing cells were captured in three fluorescent channels: WGA - red, E - green, nuclei - blue. 

See Mittler et al. for details.

#### CellProfiler analysis

See the [Cellprofiler website](https://cellprofiler.org/) for documentation.

The following custom CellProfiler pipelines used in this study are available:

[Enumerating cell fluorescent puncta](https://github.com/chandranlab/mittler_2024/blob/main/cellprofiler_pipelines/cell_fluorescent_puncta_count.cpproj).
A sample image (Nikon nd2 format) to test the pipeline is available [here](https://github.com/chandranlab/mittler_2024/blob/main/sample_image.nd2). The image contains the three fluorescent channels above.
Cells were segmented according to nuclei (primary objects) and WGA (secondary objects).
Cell-associated fluorescent E puncta were segmented as primary objects, enumerated, and assigned as child objects to Cells.

[Neural progenitor cells | nestin-positive cells](https://github.com/chandranlab/mittler_2024/blob/main/cellprofiler_pipelines/analysing_NPC_nestin_positive_cells_exclude_dying_cells.cpproj)

[Neural progenitor cells | sox2-positive cells](https://github.com/chandranlab/mittler_2024/blob/main/cellprofiler_pipelines/analysing_NPC_sox2%20positive_exclude_dying_cells.cpproj)

[Neural progenitor cells | CD140a/PDGFRa-positive cells](https://github.com/chandranlab/mittler_2024/blob/main/cellprofiler_pipelines/analysing_NPC_cd140a_PDGFRa_positive_cells.cpproj)

[Neural progenitor cells | olig2-positive cells](https://github.com/chandranlab/mittler_2024/blob/main/cellprofiler_pipelines/analysing_NPC_olig2_positive_cells.cpproj)

[Neural cultures | tubb3_receptor_coloc](https://github.com/chandranlab/mittler_2024/blob/main/cellprofiler_pipelines/analysing_60day_neural_cells_express_tubb3_receptor.cpproj)

[Neural cultures | gfap_receptor_coloc](https://github.com/chandranlab/mittler_2024/blob/main/cellprofiler_pipelines/analysing_60day_neural_cells_express_gfap_receptor.cpproj)

[Neural cultures | virus_infected](https://github.com/chandranlab/mittler_2024/blob/main/cellprofiler_pipelines/analysing_60day_neural_cells_virus_infected_updated.cpproj)
