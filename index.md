---
layout: default
title: AGA8 Supplemental Material
---

# REPOSITORY FOR THE SUPPLEMENTARY FILES TO AGA 8, PARTS 1 & 2, 2017 EDITION

## Property Calculation & Verification

* ``AGA8.xls`` – This Excel spreadsheet can be used to calculate thermodynamic properties of natural gas at any composition, temperature, and pressure, or to determine the differences between calculated values from the DETAIL, GROSS, and GERG-2008 equations of state. 

To access this file, use the link: [Link to Excel spreadsheet]({{ site.url }}/AGA8/downloads/AGA8.XLS) .  If you have difficulties, right-click on the link, then select ``Save As...``, or equivalent in your browser.

## Sample Code

This zipped file contains three subdirectories, each containing identical code originally developed in VB, and then translated to Fortran and C.  Instructions are available at the top of each file that help explain the use of the code.  The Property Calculation & Verification file, AGA8.xls, described above, is also included in this directory. The VBA code in the Excel file is identical to the code given in the VB subdirectory.

* ``AGA8.xls`` – Contains the VB code in ``AGA8.bas`` and allows for calculations within Excel to obtain properties from the AGA 8 Part 1 and 2 equations. 
* ``C`` directory – C code implementing the AGA 8 Part 1 and 2 equations. 
* ``Fortran`` directory – Fortran code implementing the AGA 8 Part 1 and 2 equations. The *.CMN files are ‘include’ files that contain all of the common blocks. 
* ``VB`` directory – VB code implementing the AGA 8 Part 1 and 2 equations. The VB code is identical to that in the AGA8.xls file. 

To access this file, use the link: [Link to AGA8 sample code]({{ site.url }}/AGA8/downloads/AGA8CODE.ZIP) .  If you have difficulties, right-click on the link, then select ``Save As...``, or equivalent in your browser.

## Test data

This zipped file contains test data obtained from evaluation of the models comprising AGA8

* ``NG Compositions.xls`` – Contains 200 compositions collected from industry that represent the full spectrum from nearly 0 to 100 % methane.  
* ``Test Data.xls`` – Contains calculated data points at multiple temperatures and pressures. These data can be used for validation of applications incorporating the AGA 8 source code or for testing modifications of other code. Compositions of the data include both binary mixtures of every component, and the data from the NG Compositions.xls spreadsheet. The data are given along the dew and bubble curves. Many of the data points are outside the range of the AGA 8 equation, and the values should only be used to confirm that a separate application is working correctly. 
* ``Deviation Calculator.xls`` – Calculates the deviation at any temperature and pressure between the DETAIL and GERG-2008 equations of state. The calculations will identify if the point is within the 2-phase or liquid. This file requires that the Refprop program from NIST be installed on the machine performing the calculations (which is used to determine the phase of each point). The spreadsheet also contains the data from the NG Compositions.xls file for comparisons of a large range of gas mixtures. The ``AGA8.xls`` file in the AGA8CODE directory can also calculate deviations between the different models, including the GROSS model that is not available here, but it does not locate the phase boundaries. For states known to be single phase, the ``AGA8.xls`` file is the best method for calculating deviations, and does not require the Refprop program. 
* ``Tables.xls`` – Contains the calculations used to generate the tables in Appendix B of the main document, plus calculations to verify that the tables in the 1994 version are duplicated correctly in the 2016 revision. 

**The following link is not yet active, please watch this space for the updated link in the next few days**

To access this file, use the link: [Link to test data]({{ site.url }}/AGA8/downloads/SampleData.zip) .  If you have difficulties, right-click on the link, then select ``Save As...``, or equivalent in your browser.

Page was last updated on {{ site.time | date_to_string }}

[Go to the source of this file](https://github.com/usnistgov/AGA8/blob/nist-pages/index.md)
