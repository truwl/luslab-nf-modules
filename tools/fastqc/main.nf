#!/usr/bin/env nextflow

// Specify DSL2
nextflow.enable.dsl=2

// Process definition
process fastqc {
    publishDir "${params.outdir}/${opts.publish_dir}",
        mode: "copy", 
        overwrite: true,
        saveAs: { filename ->
                      if (opts.publish_results == "none") null
                      else filename }
    
    container 'biocontainers/fastqc:v0.11.9_cv6'

    input:
        val opts
        tuple val(meta), path(reads)

    output:
        path "*.zip", emit: report

    script:
    args = ""
        if(opts.args && opts.args != '') {
            ext_args = opts.args
            args += ext_args.trim()
        }

    prefix = opts.suffix ? "${meta.sample_id}${opts.suffix}" : "${meta.sample_id}"

    fastqc_command = "fastqc ${args} --threads ${task.cpus} $reads"
    if (params.verbose){
        println ("[MODULE] fastqc command: " + fastqc_command)
    }
    
    //SHELL
    readList = reads.collect{it.toString()}
    if(readList.size > 1){
            """
            ${fastqc_command}
            mv ${reads[0].simpleName}*.zip ${prefix}_fastqc.zip
            mv ${reads[1].simpleName}*.zip ${prefix}_fastqc.zip
            """
    }
    else {
            """
            ${fastqc_command}
            mv ${reads[0].simpleName}*.zip ${prefix}_fastqc.zip
            """
    }
}