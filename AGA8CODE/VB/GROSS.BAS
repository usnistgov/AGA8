'Version 2.0 of routines for the calculation of thermodynamic
' properties from the AGA 8 Part 1 GROSS equation of state.
' April, 2017

'Written by Eric W. Lemmon
'Applied Chemicals and Materials Division
'National Institute of Standards and Technology (NIST)
'Boulder, Colorado, USA
'Eric.Lemmon@nist.gov
'303-497-7939

'Other contributors:
'Volker Heinemann, RMG Messtechnik GmbH
'Jason Lu, Thermo Fisher Scientific
'Ian Bell, NIST

'The publication for the AGA 8 equation of state is available from AGA
'  and the Transmission Measurement Committee.

'Subroutines contained here for property calculations:
'***** Subroutine SetupGross must be called once before calling other routines. ******
'Sub MolarMassGross(x, Mm)
'Sub PressureGross(T, D, xGrs, HCH, P, Z, ierr, herr)
'Sub DensityGross(T, P, xGrs, HCH, D, ierr, herr)
'Sub GrossHv(x, xGrs, HN, HCH)
'Sub GrossInputs(T, P, x, xGrs, Gr, HN, HCH, ierr, herr)
'Sub Bmix(T, xGrs, HCH, B, C, ierr, herr)
'Sub GrossMethod1(Th, Td, Pd, xGrs, Gr, Hv, Mm, HCH, HN, ierr, herr)
'Sub GrossMethod2(Th, Td, Pd, xGrs, Gr, Hv, Mm, HCH, HN, ierr, herr)
'Sub SetupGross()

'The compositions in the x() array use the following order and must be sent as mole fractions:
'    1 - Methane
'    2 - Nitrogen
'    3 - Carbon dioxide
'    4 - Ethane
'    5 - Propane
'    6 - Isobutane
'    7 - n-Butane
'    8 - Isopentane
'    9 - n-Pentane
'   10 - n-Hexane
'   11 - n-Heptane
'   12 - n-Octane
'   13 - n-Nonane
'   14 - n-Decane
'   15 - Hydrogen
'   16 - Oxygen
'   17 - Carbon monoxide
'   18 - Water
'   19 - Hydrogen sulfide
'   20 - Helium
'   21 - Argon
'
'For example, a mixture of 94% methane, 5% CO2, and 1% helium would be (in mole fractions):
'x(1)=0.94, x(3)=0.05, x(20)=0.01




'Variables containing the common parameters in the GROSS equations
Option Explicit
Public RGross As Double
Private Const NcGross As Integer = 21, MaxFlds As Integer = 21
Private mN2 As Double, mCO2 As Double, dPdDsave As Double
Private xHN(MaxFlds) As Double, MMiGross(MaxFlds) As Double
Private b0(3, 3) As Double, b1(3, 3) As Double, b2(3, 3) As Double, bCHx(2, 2) As Double, cCHx(2, 2) As Double
Private c0(3, 3, 3) As Double, c1(3, 3, 3) As Double, c2(3, 3, 3) As Double


Sub MolarMassGross(x() As Double, ByRef Mm As Double)
'Sub MolarMassGross(x, Mm)

'Calculate molar mass of the mixture with the compositions contained in the x() input array
'
'Inputs:
'   x() - Composition (mole fraction)
'         Do not send mole percents or mass fractions in the x() array, otherwise the output will be incorrect.
'         The sum of the compositions in the x() array must be equal to one.
'         The order of the fluids in this array is given at the top of this code.
'
'Outputs:
'    Mm - Molar mass (g/mol)

  Dim i As Integer
  Mm = 0
  For i = 1 To NcGross
    Mm = Mm + x(i) * MMiGross(i)
  Next
End Sub

Sub PressureGross(ByVal T As Double, ByVal D As Double, xGrs() As Double, ByVal HCH As Double, ByRef P As Double, ByRef Z As Double, ByRef ierr As Integer, ByRef herr As String)
'Sub PressureGross(T, D, xGrs, HCH, P, Z, ierr, herr)

'Calculate pressure as a function of temperature and density.  The derivative d(P)/d(D) is also calculated
'for use in the iterative DensityGross subroutine (and is only returned as a common variable).
'
'Inputs:
'     T - Temperature (K)
'     D - Density (mol/l)
'xGrs() - Compositions of the equivalent hydrocarbon, nitrogen, and CO2 (mole fractions)
'   HCH - Molar ideal gross heating value of the equivalent hydrocarbon (kJ/mol) at 298.15 K
'         ***Call subroutine GrossHv or GrossInputs first to obtain HCH.***
'
'Outputs:
'     P - Pressure (kPa)
'     Z - Compressibility factor
'  dPdDsave - d(P)/d(D) [kPa/(mol/l)] (at constant temperature)
'           - This variable is cached in the common variables for use in the iterative density solver, but not returned as an argument.
'  ierr - Error number (0 indicates no error)
'  herr - Error message if ierr is not equal to zero

  Dim B As Double, C As Double
  Call Bmix(T, xGrs, HCH, B, C, ierr, herr)
  If ierr <> 0 Then Exit Sub
  Z = 1 + B * D + C * D ^ 2
  P = D * RGross * T * Z
  dPdDsave = RGross * T * (1 + 2 * B * D + 3 * C * D ^ 2)
End Sub

Sub DensityGross(ByVal T As Double, ByVal P As Double, xGrs() As Double, ByVal HCH As Double, ByRef D As Double, ByRef ierr As Integer, ByRef herr As String)
'Sub DensityGross(T, P, xGrs, HCH, D, ierr, herr)

'Calculate density as a function of temperature and pressure.  This is an iterative routine that calls PressureGross
'to find the correct state point.  Generally only 6 iterations at most are required.
'If the iteration fails to converge, the ideal gas density and an error message are returned.
'
'Inputs:
'     T - Temperature (K)
'     P - Pressure (kPa)
'xGrs() - Compositions of the equivalent hydrocarbon, nitrogen, and CO2 (mole fractions)
'   HCH - Molar ideal gross heating value of the equivalent hydrocarbon (kJ/mol) at 298.15 K
'         ***Call subroutine GrossHv or GrossInputs first to obtain HCH.***
'
'Outputs:
'     D - Density (mol/l)
'  ierr - Error number (0 indicates no error)
'  herr - Error message if ierr is not equal to zero

  Dim it As Integer
  Dim plog As Double, vlog As Double, P2 As Double, Z As Double, dpdlv As Double, vdiff As Double, tolr As Double

  ierr = 0
  herr = ""
  If P = 0 Then D = 0: Exit Sub
  tolr = 0.00000000001
  D = P / RGross / T       'Ideal gas estimate
  plog = Log(P)
  vlog = -Log(D)
  For it = 1 To 20
    If vlog < -7 Or vlog > 100 Then GoTo DError:
    D = Exp(-vlog)
    Call PressureGross(T, D, xGrs, HCH, P2, Z, ierr, herr)
    If ierr <> 0 Then Exit Sub
    If dPdDsave < 0 Or P2 <= 0 Then
      vlog = vlog + 0.1
    Else
      'Find the next density with a first order Newton's type iterative scheme, with
      'log(P) as the known variable and log(v) as the unknown property.
      'See AGA 8 publication for further information.
      dpdlv = -D * dPdDsave     'd(p)/d[log(v)]
      vdiff = (Log(P2) - plog) * P2 / dpdlv
      vlog = vlog - vdiff
      If Abs(vdiff) < tolr Then
        D = Exp(-vlog)
        Exit Sub         'Iteration converged
      End If
    End If
  Next

DError:
  ierr = 1
  herr = "Calculation failed to converge in GROSS method, ideal gas density returned."
  D = P / RGross / T
End Sub

Sub GrossHv(x() As Double, xGrs() As Double, ByRef HN As Double, ByRef HCH As Double)
'Sub GrossHv(x, xGrs, HN, HCH)

'Calculate ideal heating values based on composition.  The mole fractions in the mixture are required in this routine, not
'  just xCH, xN2, and xCO2.
'
'Inputs:
'   x() - Molar compositions of all components in the mixture.  The order in this array is given at the top of this code.
'
'Outputs:
'xGrs() - Compositions of the equivalent hydrocarbon, nitrogen, and CO2 (mole fractions)
'    HN - Molar ideal gross heating value of the mixture (kJ/mol) at 298.15 K
'   HCH - Molar ideal gross heating value of the equivalent hydrocarbon (kJ/mol) at 298.15 K

  Dim i As Integer
  xGrs(1) = 1 - x(2) - x(3)
  xGrs(2) = x(2)
  xGrs(3) = x(3)
  HN = 0
  For i = 1 To NcGross
    HN = HN + x(i) * xHN(i)
  Next
  HCH = 0
  If xGrs(1) > 0 Then HCH = HN / xGrs(1)
End Sub

Sub GrossInputs(ByVal T As Double, ByVal P As Double, x() As Double, xGrs() As Double, ByRef Gr As Double, ByRef HN As Double, ByRef HCH As Double, ByRef ierr As Integer, ByRef herr As String)
'Sub GrossInputs(T, P, x, xGrs, Gr, HN, HCH, ierr, herr)

'Calculate relative density and heating values based on composition.  This routine should only be used to get these
'  two values for use as inputs to Method 1 or Method 2, and not for the relative density for any T and P.
'  All of the mole fractions in the mixture are required in this routine, not just xCH, xN2, and xCO2.
'
'Inputs:
'     T - Temperature (K), generally a reference temperature for relative density
'     P - Pressure (kPa), generally a reference pressure for relative density
'   x() - Molar compositions of all components in the mixture.  The order in this array is given at the top of this code.
'
'Outputs:
'xGrs() - Compositions of the equivalent hydrocarbon, nitrogen, and CO2 (mole fractions)
'    Gr - Relative density at T and P
'    HN - Molar ideal gross heating value of the mixture (kJ/mol) at 298.15 K
'   HCH - Molar ideal gross heating value of the equivalent hydrocarbon (kJ/mol) at 298.15 K
'  ierr - Error number (0 indicates no error)
'  herr - Error message if ierr is not equal to zero

  Dim Bref As Double, Zref As Double, Mref As Double, Z As Double, D As Double, Mm As Double
  ierr = 0
  herr = ""
  Call GrossHv(x, xGrs, HN, HCH)
  Bref = -0.12527 + 0.000591 * T - 0.000000662 * T ^ 2      '2nd virial coefficient of the reference fluid at T
  Zref = 1 + Bref * P / RGross / T                          'Z of the reference fluid at T and P
  Mref = 28.9625
  Call MolarMassGross(x, Mm)
  Call DensityGross(T, P, xGrs, HCH, D, ierr, herr)         'Density of the input fluid at T and D
  Z = P / T / D / RGross                                    'Z of the input fluid at T and D
  Gr = Mm * Zref / Mref / Z
End Sub

Sub Bmix(ByVal T As Double, xGrs() As Double, ByVal HCH As Double, ByRef B As Double, ByRef C As Double, ByRef ierr As Integer, ByRef herr As String)
'Sub Bmix(T, xGrs, HCH, B, C, ierr, herr)

'Calculate 2nd and 3rd virial coefficients for the mixture at T.
'
'Inputs:
'     T - Temperature (K)
'xGrs() - Compositions of the equivalent hydrocarbon, nitrogen, and CO2 (mole fractions)
'   HCH - Molar ideal gross heating value of the equivalent hydrocarbon (kJ/mol) at 298.15 K
'
'Outputs:
'     B - Second virial coefficient (dm^3/mol)
'     C - Third virial coefficient (dm^6/mol^2)
'  ierr - Error number (0 indicates no error)
'  herr - Error message if ierr is not equal to zero

  Dim i As Integer, j As Integer, k As Integer
  Dim bCH(3) As Double, cCH(3) As Double, BB(1 To 3, 1 To 3) As Double, CC(1 To 3, 1 To 3, 1 To 3) As Double, onethrd As Double

  ierr = 0
  herr = ""
  B = 0
  C = 0

  'Temperature dependent Bi and Ci values for obtaining B(CH-CH) and C(CH-CH-CH)
  For i = 0 To 2
    bCH(i) = bCHx(0, i) + bCHx(1, i) * T + bCHx(2, i) * T ^ 2
    cCH(i) = cCHx(0, i) + cCHx(1, i) * T + cCHx(2, i) * T ^ 2
  Next

  'Bij and Cijk values for nitrogen and CO2
  For i = 2 To 3
    For j = i To 3
      BB(i, j) = b0(i, j) + b1(i, j) * T + b2(i, j) * T ^ 2
      For k = j To 3
        CC(i, j, k) = c0(i, j, k) + c1(i, j, k) * T + c2(i, j, k) * T ^ 2
      Next
    Next
  Next

  'Bij values for use in calculating Bmix
  BB(1, 1) = bCH(0) + bCH(1) * HCH + bCH(2) * HCH ^ 2                                          'B(CH-CH) for the equivalent hydrocarbon
  BB(1, 2) = (0.72 + 0.00001875 * (320 - T) ^ 2) * (BB(1, 1) + BB(2, 2)) / 2                   'B(CH-N2)
  If BB(1, 1) * BB(3, 3) < 0 Then ierr = 1: herr = "Invalid input in Bmix routine": Exit Sub
  BB(1, 3) = -0.865 * Sqr(BB(1, 1) * BB(3, 3))                                                 'B(CH-CO2)

  'Cijk values for use in calculating Cmix
  onethrd = 1 / 3
  CC(1, 1, 1) = cCH(0) + cCH(1) * HCH + cCH(2) * HCH ^ 2                                       'C(CH-CH-CH) for the equivalent hydrocarbon
  If CC(1, 1, 1) < 0 Then ierr = 1: herr = "Invalid input in Bmix routine": Exit Sub
  CC(1, 1, 2) = (0.92 + 0.0013 * (T - 270)) * (CC(1, 1, 1) ^ 2 * CC(2, 2, 2)) ^ onethrd        'C(CH-CH-N2)
  CC(1, 2, 2) = (0.92 + 0.0013 * (T - 270)) * (CC(2, 2, 2) ^ 2 * CC(1, 1, 1)) ^ onethrd        'C(CH-N2-N2)
  CC(1, 1, 3) = 0.92 * (CC(1, 1, 1) ^ 2 * CC(3, 3, 3)) ^ onethrd                               'C(CH-CH-CO2)
  CC(1, 3, 3) = 0.92 * (CC(3, 3, 3) ^ 2 * CC(1, 1, 1)) ^ onethrd                               'C(CH-CO2-CO2)
  CC(1, 2, 3) = 1.1 * (CC(1, 1, 1) * CC(2, 2, 2) * CC(3, 3, 3)) ^ onethrd                      'C(CH-N2-CO2)

  'Calculate Bmix and Cmix
  For i = 1 To 3
    For j = i To 3
      If i = j Then
        B = B + BB(i, i) * xGrs(i) ^ 2
      Else
        B = B + 2 * BB(i, j) * xGrs(i) * xGrs(j)
      End If
      For k = j To 3
        If i = j And j = k Then
          C = C + CC(i, i, i) * xGrs(i) ^ 3
        ElseIf i <> j And j <> k And i <> k Then
          C = C + 6 * CC(i, j, k) * xGrs(i) * xGrs(j) * xGrs(k)
        Else
          C = C + 3 * CC(i, j, k) * xGrs(i) * xGrs(j) * xGrs(k)
        End If
      Next
    Next
  Next
End Sub

Sub GrossMethod1(ByVal Th As Double, ByVal Td As Double, ByVal Pd As Double, xGrs() As Double, ByVal Gr As Double, ByVal Hv As Double, ByRef Mm As Double, ByRef HCH As Double, ByRef HN As Double, ByRef ierr As Integer, ByRef herr As String)
'Sub GrossMethod1(Th, Td, Pd, xGrs, Gr, Hv, Mm, HCH, HN, ierr, herr)

'Initialize variables required in the GROSS equation with Method 1 of the AGA 8 Part 1 publication.
'Method 1 requires inputs of volumetric gross heating value, relative density, and mole fraction of CO2.
'
'Inputs:
'    Th - Reference temperature for heating value (K)
'    Td - Reference temperature for density (K)
'    Pd - Reference pressure for density (kPa)
'xGrs() - Array of size 3 with the molar composition of CO2 in the 3rd position.  xCH and xN2 are returned in this array.
'    Gr - Relative density at Td and Pd
'    Hv - Volumetric ideal gross heating value (MJ/m^3) at Th
'
'Outputs:
'xGrs() - Compositions of the equivalent hydrocarbon, nitrogen, and CO2 (mole fractions)
'    Mm - Molar mass (g/mol)
'   HCH - Molar ideal gross heating value of the equivalent hydrocarbon (kJ/mol) at 298.15 K
'    HN - Molar ideal gross heating value of the mixture (kJ/mol) at 298.15 K
'  ierr - Error number (0 indicates no error)
'  herr - Error message if ierr is not equal to zero

  Dim i As Integer
  Dim xCH As Double, xN2 As Double, xCO2 As Double, Zd As Double, Zold As Double
  Dim G1 As Double, G2 As Double, Bref As Double, Zref As Double, B As Double, C As Double
  ierr = 0
  herr = ""
  If Gr <= 0 Then ierr = 1: herr = "Invalid input for relative density": Exit Sub
  If Hv <= 0 Then ierr = 1: herr = "Invalid input for heating value": Exit Sub

  xCO2 = xGrs(3)
  Zd = 1
  G1 = -2.709328
  G2 = 0.021062199
  Bref = -0.12527 + 0.000591 * Td - 0.000000662 * Td ^ 2                   'dm^3/mol
  Zref = (1 + Pd / RGross / Td * Bref)
  For i = 1 To 20
    Zold = Zd
    HN = Zd * RGross * Td / Pd * Hv * (1 + 0.0001027 * (Th - 298.15))      'kJ/mol at 25 C
    Mm = Gr * Zd * 28.9625 / Zref                                          'g/mol
    xCH = (Mm + (xCO2 - 1) * mN2 - xCO2 * mCO2 - G2 * HN) / (G1 - mN2)
    xN2 = 1 - xCH - xCO2
    If xN2 < 0 Then ierr = 1: herr = "Negative nitrogen value in GROSS method 1 setup": Exit Sub
    HCH = HN / xCH
    xGrs(1) = xCH
    xGrs(2) = xN2
    Call Bmix(Td, xGrs, HCH, B, C, ierr, herr)
    If ierr <> 0 Then Exit Sub
    Zd = 1 + B * Pd / RGross / Td
    If Abs(Zold - Zd) < 0.00000000001 Then Exit For
  Next
End Sub

Sub GrossMethod2(ByVal Th As Double, ByVal Td As Double, ByVal Pd As Double, xGrs() As Double, ByVal Gr As Double, ByRef Hv As Double, ByRef Mm As Double, ByRef HCH As Double, ByRef HN As Double, ByRef ierr As Integer, ByRef herr As String)
'Sub GrossMethod2(Th, Td, Pd, xGrs, Gr, Hv, Mm, HCH, HN, ierr, herr)

'Initialize variables required in the GROSS equation with Method 2 of the AGA 8 Part 1 publication.
'Method 2 requires inputs of relative density and mole fractions of nitrogen and CO2.
'
'Inputs:
'    Th - Reference temperature for heating value (K)
'    Td - Reference temperature for density (K)
'    Pd - Reference pressure for density (kPa)
'xGrs() - Array of size 3 with the molar composition of N2 in the 2nd position and CO2 in the 3rd position.  xCH is returned in this array.
'    Gr - Relative density at Td and Pd
'
'Outputs:
'xGrs() - Compositions of the equivalent hydrocarbon, nitrogen, and CO2 (mole fractions)
'    Mm - Molar mass (g/mol)
'    Hv - Volumetric ideal gross heating value (MJ/m^3) at Th
'   HCH - Molar ideal gross heating value of the equivalent hydrocarbon (kJ/mol) at 298.15 K
'    HN - Molar ideal gross heating value of the mixture (kJ/mol) at 298.15 K
'  ierr - Error number (0 indicates no error)
'  herr - Error message if ierr is not equal to zero

  Dim i As Integer
  Dim xCH As Double, Z As Double, Zold As Double, Bref As Double, Zref As Double, MrCH As Double
  Dim G1 As Double, G2 As Double, B As Double, C As Double, xN2 As Double, xCO2 As Double
  ierr = 0
  herr = ""
  If Gr <= 0 Then ierr = 1: herr = "Invalid input for relative density": Exit Sub

  xN2 = xGrs(2)
  xCO2 = xGrs(3)
  xCH = 1 - xN2 - xCO2
  xGrs(1) = xCH
  Z = 1
  G1 = -2.709328
  G2 = 0.021062199
  Bref = -0.12527 + 0.000591 * Td - 0.000000662 * Td ^ 2
  Zref = (1 + Pd / RGross / Td * Bref)
  For i = 1 To 20
    Zold = Z
    Mm = Gr * Z * 28.9625 / Zref
    MrCH = (Mm - xN2 * mN2 - xCO2 * mCO2) / xCH
    HCH = (MrCH - G1) / G2
    Call Bmix(Td, xGrs, HCH, B, C, ierr, herr)
    If ierr <> 0 Then Exit Sub
    Z = 1 + B * Pd / RGross / Td
    If Abs(Zold - Z) < 0.00000000001 Then Exit For
  Next
  HN = HCH * xCH
  Hv = HN / Z / RGross / Td * Pd / (1 + 0.0001027 * (Th - 298.15))
End Sub


'The following routine must be called once before any other routine.
Sub SetupGross()

'Initialize all the constants and parameters in the GROSS model.

  RGross = 8.31451

  'Molar masses (g/mol).  These are the same as those in the DETAIL method.
  MMiGross(1) = 16.043    'Methane
  MMiGross(2) = 28.0135   'Nitrogen
  MMiGross(3) = 44.01     'Carbon dioxide
  MMiGross(4) = 30.07     'Ethane
  MMiGross(5) = 44.097    'Propane
  MMiGross(6) = 58.123    'Isobutane
  MMiGross(7) = 58.123    'n-Butane
  MMiGross(8) = 72.15     'Isopentane
  MMiGross(9) = 72.15     'n-Pentane
  MMiGross(10) = 86.177   'Hexane
  MMiGross(11) = 100.204  'Heptane
  MMiGross(12) = 114.231  'Octane
  MMiGross(13) = 128.258  'Nonane
  MMiGross(14) = 142.285  'Decane
  MMiGross(15) = 2.0159   'Hydrogen
  MMiGross(16) = 31.9988  'Oxygen
  MMiGross(17) = 28.01    'Carbon monoxide
  MMiGross(18) = 18.0153  'Water
  MMiGross(19) = 34.082   'Hydrogen sulfide
  MMiGross(20) = 4.0026   'Helium
  MMiGross(21) = 39.948   'Argon

  'Initialize constants
  b0(2, 2) = -0.1446:           b1(2, 2) = 0.00074091:         b2(2, 2) = -0.00000091195
  b0(2, 3) = -0.339693:         b1(2, 3) = 0.00161176:         b2(2, 3) = -0.00000204429
  b0(3, 3) = -0.86834:          b1(3, 3) = 0.0040376:          b2(3, 3) = -0.0000051657
  c0(2, 2, 2) = 0.0078498:      c1(2, 2, 2) = -0.000039895:    c2(2, 2, 2) = 0.000000061187
  c0(2, 2, 3) = 0.00552066:     c1(2, 2, 3) = -0.0000168609:   c2(2, 2, 3) = 0.0000000157169
  c0(2, 3, 3) = 0.00358783:     c1(2, 3, 3) = 0.00000806674:   c2(2, 3, 3) = -0.0000000325798
  c0(3, 3, 3) = 0.0020513:      c1(3, 3, 3) = 0.000034888:     c2(3, 3, 3) = -0.000000083703
  bCHx(0, 0) = -0.425468:       bCHx(1, 0) = 0.002865:         bCHx(2, 0) = -0.00000462073
  bCHx(0, 1) = 0.000877118:     bCHx(1, 1) = -0.00000556281:   bCHx(2, 1) = 0.0000000088151
  bCHx(0, 2) = -0.000000824747: bCHx(1, 2) = 0.00000000431436: bCHx(2, 2) = -6.08319E-12
  cCHx(0, 0) = -0.302488:       cCHx(1, 0) = 0.00195861:       cCHx(2, 0) = -0.00000316302
  cCHx(0, 1) = 0.000646422:     cCHx(1, 1) = -0.00000422876:   cCHx(2, 1) = 0.00000000688157
  cCHx(0, 2) = -0.000000332805: cCHx(1, 2) = 0.0000000022316:  cCHx(2, 2) = -3.67713E-12

  'Heating values from ISO 6976 at 25 C (kJ/mol)
  'xHN(1) = 890.58    'Methane
  'xHN(2) = 0         'Nitrogen
  'xHN(3) = 0         'Carbon dioxide
  'xHN(4) = 1560.69   'Ethane
  'xHN(5) = 2219.17   'Propane
  'xHN(6) = 2868.2    'Isobutane
  'xHN(7) = 2877.4    'n-Butane
  'xHN(8) = 3528.83   'Isopentane
  'xHN(9) = 3535.77   'n-Pentane
  'xHN(10) = 4194.95  'Hexane
  'xHN(11) = 4853.43  'Heptane
  'xHN(12) = 5511.8   'Octane
  'xHN(13) = 6171.15  'Nonane
  'xHN(14) = 6829.77  'Decane
  'xHN(15) = 285.83   'Hydrogen
  'xHN(16) = 0        'Oxygen
  'xHN(17) = 282.98   'Carbon monoxide
  'xHN(18) = 44.013   'Water
  'xHN(19) = 562.01   'Hydrogen sulfide
  'xHN(20) = 0        'Helium
  'xHN(21) = 0        'Argon

  'Heating values from AGA-5, 2009 at 25 C (kJ/mol)
  xHN(1) = 890.63     'Methane
  xHN(2) = 0          'Nitrogen
  xHN(3) = 0          'Carbon dioxide
  xHN(4) = 1560.69    'Ethane
  xHN(5) = 2219.17    'Propane
  xHN(6) = 2868.2     'Isobutane
  xHN(7) = 2877.4     'n-Butane
  xHN(8) = 3528.83    'Isopentane
  xHN(9) = 3535.77    'n-Pentane
  xHN(10) = 4194.95   'Hexane
  xHN(11) = 4853.43   'Heptane
  xHN(12) = 5511.8    'Octane
  xHN(13) = 6171.15   'Nonane
  xHN(14) = 6829.77   'Decane
  xHN(15) = 285.83    'Hydrogen
  xHN(16) = 0         'Oxygen
  xHN(17) = 282.98    'Carbon monoxide
  xHN(18) = 44.016    'Water
  xHN(19) = 562.01    'Hydrogen sulfide
  xHN(20) = 0         'Helium
  xHN(21) = 0         'Argon

  mN2 = MMiGross(2)
  mCO2 = MMiGross(3)
End Sub


