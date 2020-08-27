#!/usr/bin/env nextflow

// Specify DSL2
nextflow.enable.dsl=2

// Process definition
process icount {
    publishDir "${params.outdir}/${opts.publish_dir}",
        mode: "copy", 
        overwrite: true,
        saveAs: { filename ->
                      if (opts.publish_results == "none") null
                      else filename }

    container 'luslab/nf-modules-icount:latest'

    input:
        val opts
        tuple val(meta), path(bed)
        path seg

    output:
        tuple val(meta), path("${prefix}.peaks.bed.gz"), emit: peaks
        tuple val(meta), path("${prefix}.scores.tsv"), emit: peak_scores
        tuple val(meta), path("${prefix}.clusters.bed.gz"), emit: clusters
    
    script:
        prefix = opts.suffix ? "${meta.sample_id}${opts.suffix}" : "${meta.sample_id}"

        //SHELL
        """
        iCount peaks $seg $bed ${prefix}.peaks.bed.gz \
            --scores ${prefix}.scores.tsv \
            --half_window ${opts.half_window} \
            --fdr ${opts.fdr}

        zcat ${prefix}.peaks.bed.gz | \
        bedtools merge -i stdin -s -d ${opts.half_window} -c 4,5,6 -o distinct,sum,distinct | \
        gzip > ${prefix}.clusters.bed.gz
        """
}