# Predicting Exporters with Machine Learning

In this contribution, we exploit machine learning techniques to evaluate whether and how close firms are
to become successful exporters. First, we train various algorithms using financial information on both
exporters and non-exporters in France in 2010–2018. Thus, we show that it is possible to predict the distance
non-exporters are from export status. In particular, we find that a Bayesian Additive Regression Tree
with Missingness In Attributes (BART-MIA) performs better than other techniques with an accuracy of
up to 0.90. Predictions are robust to changes in definitions of exporters and in the presence of discontinuous
exporting activity. Eventually, we discuss how our exporting scores can be helpful for trade promotion,
trade credit, and assessing aggregate trade potential. For example, back-of-the-envelope estimates show
that a representative firm with just below-average exporting scores needs up to 44% more cash resources
and up to 2.5 times more capital to get to foreign markets.


## Data
We source firm-level information from ORBIS, compiled by the [Bureau Van Dijk](https://www.bvdinfo.com/en-gb/).

## Code Structure

- All data preparation is performed on Stata, following the ordered codes in the folder *Stata part*.
- The Machine Learning analysis, as well as the Robustness and Sensitivity checks, are performed on R, following the ordered codes in the folder *R part*.

Please note that some of the algorithms are memory intensive, and have been run on an external Server with a RAM of 256G.

## References

Micocci, F., & Rungi, A. (2023). Predicting Exporters with Machine Learning. World Trade Review, 1-24. doi:10.1017/S1474745623000265 [here](https://arxiv.org/abs/2505.03328)
