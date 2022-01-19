FROM containers.repo.sciserver.org/bioconductor:3.14

RUN yum install -y \
		gdal-devel \
		proj-devel \
		geos-devel \
	&& yum clean all \
	&& rm -rf /var/cache/yum

USER idies

WORKDIR /home/idies

RUN Rscript -e "BiocManager::install('DESeq2')"

RUN Rscript -e "install.packages('learnr')"

# add cell RNA-seq tools
RUN Rscript -e \
        "pkgs_tools <- c('remotes', 'reticulate', 'swirl'); \
        pkgs_monocle3 <- c('BiocGenerics', 'DelayedArray', 'DelayedMatrixStats', 'limma', 'S4Vectors', 'SingleCellExperiment', 'SummarizedExperiment', 'batchelor', 'Matrix.utils'); \
        pkgs_osca <- c('DropletUtils', 'Rtsne', 'scRNAseq', 'scuttle', 'scran', 'scater', 'velociraptor', 'uwot', 'pheatmap'); \
        pkgs_bioc <- c('DESeq2', 'GenomicRanges', 'rtracklayer', 'GEOquery', 'CoGAPS'); \
        BiocManager::install(c(pkgs_tools, pkgs_monocle3, pkgs_osca, pkgs_bioc)); \
        remotes::install_version('Seurat', version='4.0.1'); \
        remotes::install_github('cole-trapnell-lab/leidenbase@0.1.3'); \
        remotes::install_github('cole-trapnell-lab/monocle3@1.0.0'); \
        remotes::install_github('pcahan1/singleCellNet@v0.4.1');"

USER root
