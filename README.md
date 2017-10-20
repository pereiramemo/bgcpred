# bgcpred

We created 24 BGC class-specific models to predict the relative counts (RCs) of biosynthetic genes cluster classes based on the domain annotation of unassembled metagenomic data. Each model was constructed using RCs of the BGC class and its corresponding protein domains according to the antiSMASH classification rules (Weber et al., 2015), as
the response and predictor variables, respectively.

To construct a BGC class RC model, we applied a two-step zero-inflated process. First, we predicted the presence or absence of the BGC class using a random forest (RF) binary classifier (Breiman, 2001). Second, we used a multiple linear (ML) regression to predict the BGC class RCs, but only if the class was previously predicted as present (see Figure 1). In the cases where the number of zero values was too low (<10) or non-existent, we directly applied a ML regression (see Figure 1). The models were trained using a simulated metagenomic dataset of 150 samples based on the Ocean Microbial Reference Gene Catalogue (OM-RGC) complete or nearly complete genomes (Sunagawa et al., 2015).

This R package contains the functions and models to train and predict the relative counts of biosynthetic gene cluster classes in metagenomic data. This package is the core of the [ufBGCtoolbox](https://github.com/pereiramemo/ufBGCtoolbox) BGC class RCs prediction module. 

bgcpred contains the BGC class RC models and the functions and datasets to train an test the models.
In [Traning-your-data](https://rawgit.com/pereiramemo/ufBGCtoolbox/master/machine_leaRning/bgcpred_workflow.html) we show the analysis workflow necessay to train and test your models.

### a)
![Training workflow](https://github.com/pereiramemo/bgcpred/blob/master/images/training_models_workflow.png)

### b)
![Predict workflow](https://github.com/pereiramemo/bgcpred/blob/master/images/predict_workflow.png)  

Figure 1. a) and b) BGC class RC model training and predict workflows, respectively.

### Installation

```
devtools::install_github('pereiramemo/bgcpred')
library(bgcpred)
```

### Bibliography
Breiman, L. (2001). Random forests. Machine Learning, 45(1), 5-32. http://doi.org/10.1023/A:1010933404324

Sunagawa, S., Coelho, L. P., Chaffron, S., Kultima, J. R., Labadie, K., Salazar, G., … Velayoudon, D. (2015). Structure and function of the global ocean
microbiome. Science, 348(6237), 1261359–1261359. http://doi.org/10.1126/science.1261359

Weber, T., & Kim, H. U. (2016). The secondary metabolite bioinformatics portal: Computational tools to facilitate synthetic biology of secondary metabolite production. Synthetic and Systems Biotechnology, 1, 69–79. http://doi.org/10.1016/j.synbio.2015.12.002

