# bgcpred

### Introduction
We created 24 BGC class-specific models to predict the relative counts (RCs) of biosynthetic genes cluster classes based on the domain annotation of unassembled metagenomic data. Each model was constructed using RCs of the BGC class and its corresponding protein domains according to the antiSMASH classification rules (Weber et al., 2015), as
the response and predictor variables, respectively.

This R package contains the functions and models to train and predict the relative counts of biosynthetic gene cluster classes in metagenomic data.

### Installation

```
devtools::install_github('pereiramemo/bgcpred')
library(bgcpred)
```

### Documentation
bgcpred consists of four functions and a training and testing datasets.  
get_domains()  
class_model_train()  
class_model_predict()  
wrap_up_predict()  

In [Traning-your-data](https://rawgit.com/wiki/pereiramemo/ufBGCtoolbox/files/bgcpred_workflow.html) we show the analysis workflow necessay to train and test your models.




