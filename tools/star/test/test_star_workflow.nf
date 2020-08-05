#!/usr/bin/env nextflow

// Define DSL2
nextflow.enable.dsl=2

/*==============================
Test STAR genome indexing module
==============================*/

// Log
log.info ("Starting tests for STAR workflow: genomeGenerate -> alignReads...")

// Define main params
params.modules['star_genomeGenerate'].args = '--genomeSAindexNbases 9' 
params.modules['star_alignReads'].args = '--outFilterMultimapNmax 20 --quantMode TranscriptomeSAM'
params.verbose = true

// Define optional input
params.modules['star_genomeGenerate'].sjdbGTFfile = "$baseDir/../../../test_data/gtf/gencode.v30.primary_assembly.annotation_chr6_34000000_35000000.gtf"
params.modules['star_alignReads'].sjdbGTFfile = "$baseDir/../../../test_data/gtf/gencode.v30.primary_assembly.annotation_chr6_34000000_35000000.gtf" 
params.modules['star_genomeGenerate'].sjdbFileChrStartEnd = "$baseDir/../../../test_data/star_splice_junctions/Sample1.SJ.out.tab"
params.modules['star_alignReads'].sjdbFileChrStartEnd = "$baseDir/../../../test_data/star_splice_junctions/Sample1.SJ.out.tab"

// Module inclusions
include { star_genomeGenerate } from '../main.nf'
include { star_alignReads } from '../main.nf'

// Channel for FASTA file(s) 
Channel
    .fromPath("$baseDir/../../../test_data/fasta/GRCh38.primary_assembly.genome_chr6_34000000_35000000.fa")
    .set { ch_testData_fasta }

// Single-end test reads
testMetaDataSingleEnd = [
  [[sample_id:'Sample1'], "$baseDir/../../../test_data/fastq/prpf8_eif4a3_rep1.Unmapped.fq"],
  [[sample_id:'Sample2'], "$baseDir/../../../test_data/fastq/prpf8_eif4a3_rep2.Unmapped.fq"]
]

// Channel for single-end reads 
Channel
    .from( testMetaDataSingleEnd )
    .map { row -> [ row[0], file(row[1], checkIfExists: true) ] }
    .set { ch_testData_single_end }

// Run tests
workflow {
    // Run genome indexing and then read mapping
    log.info ("Run STAR workflow: genomeGenerate -> alignReads...")
    star_genomeGenerate ( params.modules['star_genomeGenerate'], ch_testData_fasta )
    // Connect the  star_alignReads to star_genomeGenerate module 
    star_alignReads ( params.modules['star_alignReads'], 
                      ch_testData_single_end, 
                      Channel.value ( file("${params.outdir}/${params.modules['star_genomeGenerate'].publish_dir}/genome_index") ) )                         
}
