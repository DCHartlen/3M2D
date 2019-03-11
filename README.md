# 3M2D
**Matlab Material Model Driver Driver**

## Overview
This project contains scripts and functions to run the LS-DYNA Material Model Driver (MMD). The MMD accepts a strain field as inputs and directly executes the constitutive model without the need for elements or other boundary conditions.

## Operation
Load "MainExecutionScript.m" into Matlab. The input strain vector is found on line 21. Currently, only linear, monotonic loading is supported. The strain vector is written to the LS-DYNA Deck specified on line 26. This deck is not overwritten during operation. This script calls three functions: "WriteDynaParams.m" which writes the input strain vector to LS-DYNA using specific parameters, 'WriteDriverCurves.m" which writes all nine strain control curves, and "ParseMMDOutput.m" which reads in the output files exported by the MMD.

In the LS-DYNA Deck, one will find the constitutive model of interest were one can alter material model parameters. This deck only includes the constitutive model, basic outputs and time controls, a single section solid (or shell, depending on your application), a section to enter parameters and nine load curves which convert the strain vector into direct loadings to enter into the constitutive model.

The "Main ExecutionScript" executes the MMD. This is accomplished through the use of two helper files. The first, "MMD_RUN_V2.bat", is a batch script which tells the system command prompt to execute the specific LS-DYNA deck. Supporting this batch script is a plain text file titled "MMD_CMD.txt". This contains all the typed commands which are necessary to run the MMD. This ensures that no user interaction is needed to run the MMD.

To alter what is outputted from the MMD, change the commands found in "MMD_CMD.txt". For reference, please refer to the LS-DYNA User's Manual, Volume 1, Appendix K. For further information, please refer to the L. Schwer article found in the March 2008 FEA Information Newsletter (Available at the following link: <https://www.dynalook.com/fea-newsletters/fea-newsletter-2008/fea-newsletter-march-2008.pdf>)

The MMD outputs individual text files containing simulation time and value of interest (stress, strain, etc.) for each requested component. 3M2D reads in all files sequentially. If there is no output in the requested component (for example, no stress in the xy direction), a file is created but not populated. 3M2D will recognize this and enter a column of zeros in the final data file.

All data generated from the MMD is stored in Matlab table. This table is not saved to disc, so it is the end user's responsibility to do so. This is generally not an issue, as the MMD generally takes only a few seconds to execute, so there is no penalty for forgetting to save one's data. 

## Licensing
3M2D is distributed under the MIT License. Users are free to do anything to the code so long as the originals source is referred and does not hold the developer liable.

LS-DYNA is the product of LSTC. LS-DYNA is not distributed with 3M2D and the developer makes no claims on the development or use of LS-DYNA. The end user is responsible for licensing and use of LS-DYNA.
