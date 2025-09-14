#!/bin/bash
# Usage: mm2_batch_v1.sh ref.fasta

if [ $# -eq 0 ]; then
    echo "Error: No reference FASTA file provided!"
    exit 1
fi

ref_fasta=$1

#Iterate on fastq files in folder
for fastqfile in *.fastq; do
	#Extract file prefix and create other filenames as vars
	prefix=${fastqfile%.*}
	samfile=$prefix"_mm2.sam"
	bamfile=$prefix"_mm2.bam"
	bamfile_rh=$prefix"_mm2_rh.bam"
	bamfile_sorted=$prefix"_mm2_rh_sorted.bam"
	bamfile_variant_calls=$prefix"_mm2_variant_calls.vcf"	
	
	echo "Processing "$fastqfile
	#Run minimap2 aligner
	minimap2 -ax map-ont --cs $ref_fasta $fastqfile > $samfile
	#Convert sam to bam file
	samtools view -hSbo $bamfile $samfile
	#Extract header from bam file
	samtools view -H $bamfile > header.txt
	#Add readgroups to bamfile header
	printf "@RG\tID:"$prefix"\tSM:"$prefix"\n" >> header.txt
	#replace header
	samtools reheader header.txt $bamfile > $bamfile_rh
	#Sort bamfile
	samtools sort $bamfile_rh -o $bamfile_sorted
	#Index sorted BAM file
	samtools index $bamfile_sorted
	#Call mpileup > bcftools and generate variant calls
	bcftools mpileup -d 8000 -f $ref_fasta $bamfile_sorted | bcftools call -mv -Ov -o $bamfile_variant_calls
done