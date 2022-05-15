# EMD
material related to empirical mode decomposition
---------------------------------------------------------------------------------------------------------------------------


You will find some basic examples in matlab showing you how to work with the 1D univariate EMD and its extensions
and also how to apply the Hilbert-Huang Transform (Hilbert Transform with preceding EMD).

For a theoretical introduction to these topics, visit my youtube channel @EstherExplains: 
        https://www.youtube.com/channel/UCXxND_50kiHxrUDRW-zqxqQ


---------------------------------------------------------------------------------------------------------------------------
requirements:


univariate EMD: the build-in matlab function is used; you might have to install the Signal Processing Toolbox

multivariate EMD: download the implementation by Rehman & Mandic: https://www.commsp.ee.ic.ac.uk/~mandic/research/emd.htm
                  published in: "Rehman & Mandic, Multivariate Empirical Mode Decomposition, 
                  Proceedings of the Royal Society A, vol. 466, no. 2117, pp. 1291-1302, 2010."
                  and use the function "memd"
