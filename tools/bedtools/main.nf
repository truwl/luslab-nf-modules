#!/usr/bin/env nextflow

nextflow.enable.dsl=2

process bedtools_intersect {
    publishDir "${params.outdir}/${opts.publish_dir}",
        mode: "copy", 
        overwrite: true,
        saveAs: { filename ->
                      if (opts.publish_results == "none") null
                      else filename }

    container 'luslab/nf-modules-bedtools:latest'

    input:
        val opts
        tuple val(meta), path(reads)
        path regions_file

    output:
        tuple val(meta), path("*.bed"), emit: bed

    script:
        args = ""
        if(opts.args && opts.args != '') {
            ext_args = opts.args
            args += ext_args.trim()
        }

        prefix = opts.suffix ? "${meta.sample_id}${opts.suffix}" : "${meta.sample_id}"

        intersect_command = "bedtools intersect -a ${regions_file} -b $reads ${args} > ${prefix}.bed"
        if (params.verbose){
            println ("[MODULE] bedtools/intersect command: " + intersect_command)
        }

        //SHELL
        """
        ${intersect_command}
        """
}


process bedtools_intersect2 {
    publishDir "${params.outdir}/${opts.publish_dir}",
        mode: "copy", 
        overwrite: true,
        saveAs: { filename ->
                      if (opts.publish_results == "none") null
                      else filename }

    container 'luslab/nf-modules-bedtools:latest'

    input:
        val opts
        tuple val(meta), path(file_a)
        path(file_b)

    output:
        tuple val(meta), path("*.bed"), emit: bed

    script:
        args = ""
        if(opts.args && opts.args != '') {
            ext_args = opts.args
            args += ext_args.trim()
        }

        prefix = opts.suffix ? "${meta.sample_id}${opts.suffix}" : "${meta.sample_id}"

        intersect_command = "bedtools intersect -a ${file_a} -b ${file_b} ${args} > ${prefix}.bed"
        if (params.verbose){
            println ("[MODULE] bedtools/intersect command: " + intersect_command)
        }

        //SHELL
        """
        ${intersect_command}
        """
}