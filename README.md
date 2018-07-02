# bgcpred

We created 24 BGC class-specific models to predict the abundance of biosynthetic genes cluster classes based on the domain annotation of unassembled metagenomic data. Each model was constructed using the abundance of the BGC class and its corresponding protein domains according to the antiSMASH classification rules (Weber et al., 2015), as the response and predictor variables, respectively.

To construct a BGC class abundance model, we applied a two-step zero-inflated process. First, we predicted the presence or absence of the BGC class using a random forest (RF) binary classifier (Breiman, 2001). Second, we used multiple linear regression (MLR) to predict the BGC class abundance, but only if the class was previously predicted as present (see Figure 1). In the cases where the number of zero values was too low (<10) or non-existent, we directly applied a
MLR. The models were trained using simulated metagenomic data, where we can
accurately compute the real BGC class abundances (i.e., using the complete genome sequences from which the metagenomes were simulated).


bgcpred R package contains the models, functions, and datasets to train and predict the
abundance of biosynthetic gene cluster classes in metagenomic data. This package is the core of the
[BiGMEx](https://github.com/pereiramemo/BiGMEx) BGC class abundance prediction module. 


In [Data simulation](https://github.com/pereiramemo/BiGMEx/wiki/Data-simulation) we have a template code that can be used generate your own training dataset. And in [Traning-your-data](https://rawgit.com/pereiramemo/BiGMEx/master/machine_leaRning/bgcpred_workflow.html) we show the analysis workflow necessary to train and test your models.


![Training workflow](https://github.com/pereiramemo/bgcpred/blob/master/images/Traning_and_prediction_workflow.pdf)


Figure 1. a) and b) BGC class abundance model training and predict workflows, respectively.

### Installation

```
devtools::install_github('pereiramemo/bgcpred')
library(bgcpred)
```

### Bibliography
Breiman, L. (2001). Random forests. Machine Learning, 45(1), 5-32. http://doi.org/10.1023/A:1010933404324

Weber, T., & Kim, H. U. (2016). The secondary metabolite bioinformatics portal: Computational tools to facilitate synthetic biology of secondary metabolite production. Synthetic and Systems Biotechnology, 1, 69–79. http://doi.org/10.1016/j.synbio.2015.12.002

