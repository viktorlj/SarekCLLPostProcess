#!/usr/bin/env nextflow

/*
================================================================================
=                           C O N F I G U R A T I O N                          =
================================================================================
*/

params.sampleID = ''
sampleID = params.sampleID

directoryMap = defineDirectoryMap()
referenceMap = defineReferenceMap()

startMessage()

vcfToAnnotate = Channel.fromPath("${directoryMap.vep}/*.vcf")

/*
================================================================================
=                             P R O C E S S E S                                =
================================================================================
*/

process filterVCF {
    tag {vcf}

    input:
       file(vcf) from vcfToAnnotate
       set file(genomeFile), file(genomeIndex), file(genomeDict), file(lcrFilter), file(lcrIndex), file(igFilter), file(igIndex) from Channel.value([referenceMap.genomeFile, referenceMap.genomeIndex, referenceMap.genomeDict, referenceMap.lcrFilter, referenceMap.lcrIndex, referenceMap.igFilter, referenceMap.igIndex])

    output:
      file("${vcf.baseName}.filtered.vcf") into filteredvcf
        
    script:
    """
    grep -E '#|PASS' ${vcf} > ${vcf.baseName}.pass.vcf

    java -Xmx4g \
    -jar \$GATK_HOME/GenomeAnalysisTK.jar \
    -T VariantFiltration \
    --variant ${vcf.baseName}.pass.vcf \
    --mask ${lcrFilter} \
    -R ${genomeFile} \
    --maskName LCRfiltered \
    -o ${vcf.baseName}.lcrfiltered.vcf

    java -Xmx4g \
    -jar \$GATK_HOME/GenomeAnalysisTK.jar \
    -T VariantFiltration \
    --variant ${vcf.baseName}.lcrfiltered.vcf \
    --mask ${igFilter} \
    -R ${genomeFile} \
    --maskName IGRegion \
    -o ${vcf.baseName}.filtered.vcf
    """

}

process siftAddCosmic {
    tag {vcf}

    publishDir directoryMap.CosmicVCF, mode: 'link'

    input:
       file(vcf) from filteredvcf
       set file(cosmic), file(cosmicIndex) from Channel.value([
       referenceMap.cosmic,
       referenceMap.cosmicIndex,
    ])
    
    output:
        file("${vcf.baseName}.cosmic.ann.vcf") into filteredcosmicvcf

    script:
    """
    java -Xmx4g \
	  -jar \$SNPEFF_HOME/SnpSift.jar \
	  annotate \
	  -info CNT \
    ${cosmic} \
	  ${vcf} \
	  > ${vcf.baseName}.cosmic.ann.vcf
    """

}

process finishVCF {
    tag {vcf}

    publishDir directoryMap.txtAnnotate, mode: 'link'

    input:
        file(vcf) from filteredcosmicvcf
        val(sampleID) from Channel.value(sampleID)

    output:
        file("${vcf.baseName}.anno.done.txt") into finishedFile

    script:
    """
    seqtool vcf strelka -f ${vcf} -o ${vcf.baseName}.strelkaadjusted.vcf
    seqtool vcf melt -f ${vcf.baseName}.strelkaadjusted.vcf -o ${vcf.baseName}.melt.txt -s ${sampleID} --includeHeader
    pyenv global 3.6.3
    eval "\$(pyenv init -)"
    strelka2pandas.py -i ${vcf.baseName}.melt.txt -o ${vcf.baseName}.anno.txt

    grep -E -v 'LCRfiltered|IGRegion' ${vcf.baseName}.anno.txt > ${vcf.baseName}.anno.done.txt

    """ 

}

/*
================================================================================
=                            F U N C T I O N S                                 =
================================================================================
*/

def checkParamReturnFile(item) {
  params."${item}" = params.genomes[params.genome]."${item}"
  return file(params."${item}")
}

def defineDirectoryMap() {
  return [
    'vep_processed'    : "${params.outDir}/Annotation/Readable",
    'vep'              : "${params.outDir}/Annotation/VEP",
    'CosmicVCF'        : "${params.outDir}/Annotation/CosmicVCF",
    'txtAnnotate'      : "${params.outDir}/Annotation/AnnotatedTxt"
  ]
}

def defineReferenceMap() {
  if (!(params.genome in params.genomes)) exit 1, "Genome ${params.genome} not found in configuration"
  return [
    // genome reference dictionary
    'genomeDict'       : checkParamReturnFile("genomeDict"),
    // FASTA genome reference
    'genomeFile'       : checkParamReturnFile("genomeFile"),
    // genome .fai file
    'genomeIndex'      : checkParamReturnFile("genomeIndex"),
    // lcr filter file
    'lcrFilter'         : checkParamReturnFile("lcrFilter"),
    'lcrIndex'         : checkParamReturnFile("lcrIndex"),
    // lcr filter file
    'igFilter'         : checkParamReturnFile("igFilter"),
    'igIndex'         : checkParamReturnFile("igIndex"),
    // cosmic VCF with VCF4.1 header
    'cosmic'           : checkParamReturnFile("cosmic"),
    'cosmicIndex'      : checkParamReturnFile("cosmicIndex"),
    // dbNSFP files
    'dbnsfp'           : checkParamReturnFile("dbnsfp"),
    'dbnsfpIndex'      : checkParamReturnFile("dbnsfpIndex")

  ]
}

def minimalInformationMessage() {
  // Minimal information message
  log.info "Command Line: " + workflow.commandLine
  log.info "Profile     : " + workflow.profile
  log.info "Project Dir : " + workflow.projectDir
  log.info "Launch Dir  : " + workflow.launchDir
  log.info "Work Dir    : " + workflow.workDir
  log.info "Out Dir     : " + params.outDir
}

def startMessage() {
  // Display start message
  this.minimalInformationMessage()
}