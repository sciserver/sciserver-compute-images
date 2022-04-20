rm(list = ls())

install_packages <- FALSE

if(!require(devtools)){
  BiocManager::install("devtools", ask=FALSE)
}

if(install_packages){
  Sys.setenv(R_REMOTES_NO_ERRORS_FROM_WARNINGS = TRUE)
  devtools::install_github("VPetukhov/ggrastr")
  devtools::install_github("immunogenomics/harmony")
  BiocManager::install("cydar", ask=FALSE)
  BiocManager::install("scuttle", ask=FALSE)
  BiocManager::install("GenomeInfoDb", ask=FALSE)
  devtools::install_github("casanova-lab/iMUBAC")
  devtools::install_github("masato-ogishi/plotUtility")
  BiocManager::install("flowAI", ask=FALSE)
  remotes::install_github("saeyslab/CytoNorm")
  BiocManager::install("PeacoQC", ask=FALSE)
  BiocManager::install("ggpubr", ask=FALSE)
}

if(install_packages){
  if(!require('rstudioapi')) {
    install.packages('rstudioapi')
  }
  if(!require('devtools')){
    install.packages("devtools")
  }
  if(!require('flowCore')){
    BiocManager::install("flowCore", ask=FALSE)
  }
  if(!require('cytofCore')){
    devtools::install_github("nolanlab/cytofCore")
  }
  if(!require('JinmiaoChenLab/cytofkit')){
  #do not update hexbin
remotes::install_github("JinmiaoChenLab/cytofkit")
}
  if(!require("CytoML")){
 BiocManager::install("CytoML", ask=FALSE)
  }
  if(!require('FlowSOM')){
    BiocManager::install("FlowSOM", ask=FALSE)
  }
  if(!require('cluster')){
    install.packages("cluster")
  }
  if(!require('Rtsne')){
    install.packages("Rtsne")
  }
  if(!require('ggplot2')){
    install.packages("ggplot2")
  }
  if(!require('dplyr')){
    install.packages("dplyr")
  }
  if(!require('ggthemes')){
    install.packages("ggthemes")
  }
  if(!require('RColorBrewer')){
    install.packages('RColorBrewer')
  }
  if(!require("uwot")){
    install.packages("uwot")
  }
  if(!require("CATALYST"))
    BiocManager::install("CATALYST", ask=FALSE)
  if(!require("diffcyt"))
    BiocManager::install("diffcyt", ask=FALSE)
  if(!require("stringr"))
    BiocManager::install("stringr", ask=FALSE)
  
  if(!require("JinmiaoChenLab/Rphenograph")){
    remotes::install_github("JinmiaoChenLab/Rphenograph")
  }
  BiocManager::install("Rphenograph", ask=FALSE)
  if(!require("scran"))
    BiocManager::install("scran", ask=FALSE)
  if(!require("scater"))
    BiocManager::install("scater", ask=FALSE)
  if(!require("ggcyto"))
    BiocManager::install("ggcyto", ask=FALSE)
  if(!require("SingleCellExperiment"))
    BiocManager::install("SingleCellExperiment", ask=FALSE)
  if(!require("Rphenograph"))
    BiocManager::install("Rphenograph", ask=FALSE)
  if(!require("flowWorkspace"))
    BiocManager::install("flowWorkspace", ask=FALSE)
  if(!require("flowVS"))
    install.packages(file.choose(), repos = NULL, type = "source")
  if(!require("flowStats"))
    BiocManager::install("flowStats", ask=FALSE)
}

#add packages that failed from initial script
if (!requireNamespace("BiocManager", quietly = TRUE))
  install.packages("BiocManager")

BiocManager::install("CATALYST", force=TRUE, ask=FALSE)

if (!requireNamespace("BiocManager", quietly = TRUE))
  install.packages("BiocManager")

BiocManager::install("flowVS", ask=FALSE)

if (!requireNamespace("BiocManager", quietly = TRUE))
  install.packages("BiocManager")

BiocManager::install("scMerge", ask=FALSE)

if(!require(devtools)) install.packages("devtools")
devtools::install_github("VPetukhov/ggrastr")
devtools::install_github("immunogenomics/harmony")
devtools::install_github("casanova-lab/iMUBAC")
devtools::install_github("masato-ogishi/plotUtility")

install.packages("remotes")
remotes::install_github("saeyslab/FlowSOM_workshop")

if (!requireNamespace("BiocManager", quietly = TRUE))
  install.packages("BiocManager")

BiocManager::install("destiny", ask=FALSE)

