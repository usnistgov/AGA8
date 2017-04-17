---
layout: default
title: AGA8 Supplemental Material
---

# REPOSITORY FOR THE SUPPLEMENTARY FILES TO AGA 8, 2017 EDITION

A zipped file is available at the below URL containing the supplementary material described in Parts 1 and 2 of AGA 8 Report No. 8, titled Thermodynamic Properties of Natural Gas and Related Gases, 2017.  The description of the contents of each folder contained in the zipped file follows.

**THE FOLLOWING LINK IS NOT YET ACTIVE, WILL BE ACTIVATED WHEN AGA8 IS RELEASED**:

**Official release zip file**: [Link to zip file](https://github.com/usnistgov/AGA8/archive/AGA8release.zip) .  If you have difficulties, right-click on URL, then select ``Save As...`` or equivalent in your browser.

Contents of folder ``TestData``:

* ``NG Compositions.xls`` – Contains 200 compositions collected from industry that represent the full spectrum from nearly 0 to 100 % methane.  
* ``Test Data.xls`` – Contains calculated data points at multiple temperatures and pressures. These data can be used for validation of applications incorporating the AGA 8 source code or for testing modifications of other code. Compositions of the data include both binary mixtures of every component, and the data from the NG Compositions.xls spreadsheet. The data are given along the dew and bubble curves. Many of the data points are outside the range of the AGA 8 equation, and the values should only be used to confirm that a separate application is working correctly. 
* ``Deviation Calculator.xls`` – Calculates the deviation at any temperature and pressure between the DETAIL and GERG-2008 equations of state. The calculations will identify if the point is within the 2-phase or liquid. This file requires that the Refprop program from NIST be installed on the machine performing the calculations (which is used to determine the phase of each point). The spreadsheet also contains the data from the NG Compositions.xls file for comparisons of a large range of gas mixtures. The AGA8.xls file in the AGA8CODE directory can also calculate deviations between the different models, including the GROSS model that is not available here, but it does not locate the phase boundaries. For states known to be single phase, the AGA8.xls file is the best method for calculating deviations, and does not require the Refprop program. 
* ``Tables.xls`` – Contains the calculations used to generate the tables in Appendix B of the main document, plus calculations to verify that the tables in the 1994 version are duplicated correctly in the 2016 revision. 

Contents of folder ``AGA8Code``:

* ``AGA8.xls`` – Contains the VB code in AGA8.bas and allows for calculations within Excel to obtain properties from the AGA 8 Part 1 and 2 equations. 
* ``C`` directory – C code implementing the AGA 8 Part 1 and 2 equations. 
* ``Fortran`` directory – Fortran code implementing the AGA 8 Part 1 and 2 equations. The *.CMN files are ‘include’ files that contain all of the common blocks. 
* ``VB`` directory – VB code implementing the AGA 8 Part 1 and 2 equations. The VB code is identical to that in the AGA8.xls file. 
 
Contents of folder ``1994Code``:

* The original files with the code from the 1994 version of AGA 8 are contained within this directory. These files include ``AGA8PROG.EXE``, ``AGA8PROG.FOR``, ``DETAILXZ.FOR``, ``GROSSXZ.FOR``, ``UNITS.FOR``, and ``CONF.SAV``. The four Fortran files were compiled to make the executable, and the conf.sav file contains the settings specified by the user. 
* ``1994AGA8.doc`` – Contains all documentation concerning the use of these Fortran files from the 1994 edition that is not included in the 2016 revision.

[Go to the source of this file](https://github.com/usnistgov/AGA8/blob/nist-pages/index.md)
