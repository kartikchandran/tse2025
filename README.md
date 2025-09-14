# Viral sequencing workflow
## Published in Tse et al., PLoS Pathogens, 2025

### Hardware, operating system, software
---
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
---
Viral RNA was isolated from rescue population supernatants. cDNA was then generated through reverse transcription with a VSV genome-specific primer and amplified by PCR with VSV-specific primers flanking the spike gene. Following this, long-read DNA sequencing on the Oxford Nanopore Technologies (ONT) platform (Plasmidsaurus) was performed to identify mutations present in the viral population.

### Data analysis
---
Nanopore sequencing reads (FASTQ) were aligned to a reference sequence ([codon-optimized Rs3367-CoV spike](Rs3367_CoV_S_ref.fasta); FASTA format) using minimap2. Genotype likelihoods and variant calls in the resulting alignment files (.bam) were determined using bcftools, and the sequence alignments and variant calls (were visualized with Integrative Genomics Browser. The sequencing alignments (.bam) are available in the Sequence Read Archive (SRA) under Bioproject PRJNA1313131.

The above analysis workflow is implemented in bash script [`pooled_CRISPR_screen_Gecko_v2_reorient.sh`](mm2_batch_v1.sh).

#### Demo dataset
---
A sample dataset for testing the bash script (gzipped FASTQ R1 and R2 files containing 2,500 reads) can be downloaded [here](https://github.com/chandranlab/mittler_2024/tree/main/demo_fastq_files).
---
