FROM dockerregistry:443/c-moor_rstudio:latest

USER idies

WORKDIR /home/idies

# add cell Practical_genomics tools
RUN Rscript -e \
        "swhelan_addon <- c('AnnotationHub', 'DropletTestFiles', 'PCAtools' , 'SingleR', 'bluster', 'celldex', 'igraph', 'viridis', 'org.Mm.eg.db'); \
        marchionni_addon <- c('msigdbr', 'corral', 'dendextend', 'dynamicTreeCut', 'clustree', 'GSEABase', 'AUCell','MouseGastrulationData', 'scDblFinder', 'TSCAN', 'slingshot' , 'tradeSeq', 'iSEE'); \
        annotation_packages <- c('org.Hs.eg.db','TxDb.Hsapiens.UCSC.hg38.knownGene', 'TxDb.Mmusculus.UCSC.mm10.knownGene'); \
        other_packages <- c('RTopper','superheat', 'gdata', 'ggplot', 'dplyr', 'reshape', 'reshape2', 'Gviz'); \
        BiocManager::install(c(marchionni_addon, annotation_packages, other_packages, swhelan_addon));"

USER root
