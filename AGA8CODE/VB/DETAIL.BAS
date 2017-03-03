'  **********  This code is preliminary, and will be updated.  **********
'  **********  Use only for beta testing.  **********
'  **********  June 7, 2016  **********

'Version 1.7 of routines for the calculation of thermodynamic properties from the
'  AGA 8 Part 1 DETAIL equation of state.

'08/27/2014 - Original version
'01/12/2015 - Reduce calls to stack overhead, check for x(i)=0 before making calculations (Jason Lu, Thermo Fisher Scientific)
'03/10/2015 - Multiple changes to work with Excel, with new fluid order that matches other methods
'03/18/2015 - Reorder fluids from the original 1994 work to that shown below
'10/30/2015 - Addition of comments and further simplification of code
'12/14/2015 - Set bn and kn as integers.  Change subroutine names from Pressure to PressureDetail, etc.
'05/16/2016 - Make minor final changes before publication
'05/25/2016 - Change the ideal gas coefficients so that the GERG and DETAIL use the same values

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
'  and the Transmission Measurement Committee

'Subroutines contained here for property calculations:
'***** Subroutine SetupDetail must be called once before calling other routines. ******
'Sub MolarMassDetail(x, Mm)
'Sub PressureDetail(T, D, x, P, Z)
'Sub DensityDetail(T, P, x, D, ierr, herr)
'Sub PropertiesDetail(T, D, x, P, Z, dPdD, d2PdD2, d2PdTD, dPdT, U, H, S, Cv, Cp, W, G, JT, Kappa)
'Sub SetupDetail()

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




'Variables containing the common parameters in the DETAIL equations
Option Explicit
Public RDetail As Double
Private Const NcDetail As Integer = 21, MaxFlds As Integer = 21, NTerms As Integer = 58
Private fn(NTerms) As Integer, gn(NTerms) As Integer, qn(NTerms) As Integer
Private an(NTerms) As Double, bn(NTerms) As Integer, kn(NTerms) As Integer, un(NTerms) As Double
Private Bsnij2(MaxFlds, MaxFlds, 18) As Double, Bs(18) As Double, Csn(NTerms) As Double
Private Fi(MaxFlds) As Double, Gi(MaxFlds) As Double, Qi(MaxFlds) As Double
Private Ki25(MaxFlds) As Double, Ei25(MaxFlds) As Double
Private Kij5(MaxFlds, MaxFlds) As Double, Uij5(MaxFlds, MaxFlds) As Double, Gij5(MaxFlds, MaxFlds) As Double
Private Tun(NTerms) As Double, Told As Double
Private n0i(MaxFlds, 7) As Double, th0i(MaxFlds, 7)
Private MMiDetail(MaxFlds) As Double, K3 As Double, xold(MaxFlds) As Double
Private dPdDsave As Double 'Calculated in the Pressure subroutine, but not included as an argument since it is only used internally in the density algorithm.


Sub MolarMassDetail(x() As Double, ByRef Mm As Double)

'Calculate molar mass of the mixture with the compositions contained in the x() input array
'
'Inputs:
'   x() - composition (mole fraction)
'         Do not send mole percents or mass fractions in the x() array, otherwise the output will be incorrect.
'         The sum of the compositions in the x() array must be equal to one.
'         The order of the fluids in this array is given at the top of this code.
'
'Outputs:
'    Mm - molar mass (g/mol)

  Dim i As Integer
  Mm = 0
  For i = 1 To NcDetail
    Mm = Mm + x(i) * MMiDetail(i)
  Next
End Sub

Sub PressureDetail(ByVal T As Double, ByVal D As Double, x() As Double, ByRef P As Double, ByRef Z As Double)
'Sub PressureDetail(T, D, x, P, Z)

'Calculate pressure as a function of temperature and density.  The derivative d(P)/d(D) is also calculated
'for use in the iterative DensityDetail subroutine (and is only returned as a common variable).
'
'Inputs:
'     T - temperature (K)
'     D - density (mol/l)
'   x() - composition (mole fraction)
'         Do not send mole percents or mass fractions in the x() array, otherwise the output will be incorrect.
'         The sum of the compositions in the x() array must be equal to one.
'
'Outputs:
'     P - pressure (kPa)
'     Z - compressibility factor
'  dPdDsave - d(P)/d(D) [kPa/(mol/l)]

  Dim ar(3, 3) As Double
  Call xTermsDetail(x)
  Call AlpharDetail(0, 2, T, D, x, ar)
  Z = 1 + ar(0, 1) / RDetail / T         'ar(0,1) is the first derivative of alpha(r) with respect to density
  P = D * RDetail * T * Z
  dPdDsave = RDetail * T + 2 * ar(0, 1) + ar(0, 2)  'd(P)/d(D) for use in density iteration
End Sub

Sub DensityDetail(ByVal T As Double, ByVal P As Double, x() As Double, ByRef D As Double, ByRef ierr As Integer, ByRef herr As String)
'Sub DensityDetail(T, P, x, D, ierr, herr)

'Calculate density as a function of temperature and pressure.  This is an iterative routine that calls PressureDetail
'to find the correct state point.  Generally only 6 iterations at most are required.
'If the iteration fails to converge, the ideal gas density and an error message are returned.
'No checks are made to determine the phase boundary, which would have guaranteed that the output is in the gas phase.
'It is up to the user to locate the phase boundary, and thus identify the phase of the T and P inputs.
'If the state point is 2-phase, the output density will represent a metastable state.
'
'Inputs:
'     T - temperature (K)
'     P - pressure (kPa)
'   x() - composition (mole fraction)
'
'Outputs:
'     D - density (mol/l) (make D negative and send as an input to use as an initial guess)
'  ierr - Error number (0 indicates no error)
'  herr - Error message if ierr is not equal to zero

  Dim it As Integer
  Dim plog As Double, vlog As Double, P2 As Double, Z As Double, dpdlv As Double, vdiff As Double, tolr As Double

  ierr = 0
  herr = ""
  If P = 0 Then D = 0: Exit Sub
  tolr = 0.00000001
  If D >= 0 Then
    D = P / RDetail / T  'Ideal gas estimate
  Else
    D = Abs(D)           'If D<0, then use as initial estimate
  End If
  plog = Log(P)
  vlog = -Log(D)
  For it = 1 To 20
    If vlog < -7 Or vlog > 100 Then GoTo DError:
    D = Exp(-vlog)
    Call PressureDetail(T, D, x, P2, Z)
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
        'NumbItDetail = it   'Used to pass back the number of iterations
        Exit Sub             'Iteration converged
      End If
    End If
  Next

DError:
  ierr = 1
  herr = "Calculation failed to converge in DETAIL method, ideal gas density returned."
  D = P / RDetail / T
End Sub

Sub PropertiesDetail(ByVal T As Double, ByVal D As Double, x() As Double, ByRef P As Double, ByRef Z As Double, ByRef dPdD As Double, ByRef d2PdD2 As Double, ByRef d2PdTD As Double, ByRef dPdT As Double, ByRef U As Double, ByRef H As Double, ByRef S As Double, ByRef Cv As Double, ByRef Cp As Double, ByRef W As Double, ByRef G As Double, ByRef JT As Double, ByRef Kappa As Double, Optional ByRef A As Double)
'Sub PropertiesDetail(T, D, x, P, Z, dPdD, d2PdD2, d2PdTD, dPdT, U, H, S, Cv, Cp, W, G, JT, Kappa, Optional A)

'Calculate thermodynamic properties as a function of temperature and density.  Calls are made to the subroutines
'Molarmass, Alpha0Detail, and AlpharDetail.  If the density is not known, call subroutine DensityDetail first
'with the known values of pressure and temperature.
'
'Inputs:
'     T - temperature (K)
'     D - density (mol/l)
'   x() - composition (mole fraction)
'
'Outputs:
'     P - pressure (kPa)
'     Z - compressibility factor
'  dPdD - first derivative of pressure with respect to density [kPa/(mol/l)]
'd2PdD2 - second derivative of pressure with respect to density [kPa/(mol/l)^2]
'd2PdTD - second derivative of pressure with respect to temperature and density [kPa/(mol/l)/K]
'  dPdT - first derivative of pressure with respect to temperature (kPa/K)
'     U - internal energy (J/mol)
'     H - enthalpy (J/mol)
'     S - entropy (J/mol-K)
'    Cv - isochoric heat capacity (J/mol-K)
'    Cp - isobaric heat capacity (J/mol-K)
'     W - speed of sound (m/s)
'     G - Gibbs energy (J/mol)
'    JT - Joule-Thomson coefficient (K/kPa)
' Kappa - Isentropic Exponent
'     A - Helmholtz energy (J/mol)

  Dim a0(2) As Double, ar(3, 3) As Double, Mm As Double, R As Double, RT As Double

  Call MolarMassDetail(x, Mm)
  Call xTermsDetail(x)

  'Calculate the ideal gas Helmholtz energy, and its first and second derivatives with respect to temperature.
  Call Alpha0Detail(T, D, x, a0)

  'Calculate the real gas Helmholtz energy, and its derivatives with respect to temperature and/or density.
  Call AlpharDetail(2, 3, T, D, x, ar)

  R = RDetail
  RT = R * T
  Z = 1 + ar(0, 1) / RT
  P = D * RT * Z
  dPdD = RT + 2 * ar(0, 1) + ar(0, 2)
  dPdT = D * R + D * ar(1, 1)
  A = a0(0) + ar(0, 0)
  S = -a0(1) - ar(1, 0)
  U = A + T * S
  Cv = -(a0(2) + ar(2, 0))
  If D > 0 Then
    H = U + P / D
    G = A + P / D
    Cp = Cv + T * (dPdT / D) ^ 2 / dPdD
    d2PdD2 = (2 * ar(0, 1) + 4 * ar(0, 2) + ar(0, 3)) / D
    JT = (T / D * dPdT / dPdD - 1) / Cp / D
  Else
    H = U + RT
    G = A + RT
    Cp = Cv + R
    d2PdD2 = 0
    JT = 1E+20   '=(dB/dT*T-B)/Cp for an ideal gas, but dB/dT is not calculated here
  End If
  W = 1000 * Cp / Cv * dPdD / Mm
  If W < 0 Then W = 0
  W = Sqr(W)
  Kappa = W ^ 2 * Mm / (RT * 1000 * Z)
End Sub


'The following routines are low-level routines that should not be called outside of this code.

Private Sub xTermsDetail(x() As Double)

'Calculate terms dependent only on composition
'
'Inputs:
'   x() - composition (mole fraction)

  Dim G As Double, Q As Double, F As Double, U As Double, Q2 As Double, xij As Double, xi2 As Double
  Dim i As Integer, j As Integer, n As Integer, icheck As Integer

  'Check to see if a component fraction has changed.  If x is the same as the previous call, then exit.
  icheck = 0
  For i = 1 To NcDetail
    If Abs(x(i) - xold(i)) > 0.00000001 Then icheck = 1
    xold(i) = x(i)
  Next
  If icheck = 0 Then Exit Sub

  K3 = 0: U = 0: G = 0: Q = 0: F = 0
  For n = 1 To 18: Bs(n) = 0: Next

  'Calculate pure fluid contributions
  For i = 1 To NcDetail
    If x(i) > 0 Then
      xi2 = x(i) ^ 2
      K3 = K3 + x(i) * Ki25(i)     'K, U, and G are the sums of a pure fluid contribution and a
      U = U + x(i) * Ei25(i)       '   binary pair contribution
      G = G + x(i) * Gi(i)
      Q = Q + x(i) * Qi(i)         'Q and F depend only on the pure fluid parts
      F = F + xi2 * Fi(i)
      For n = 1 To 18
        Bs(n) = Bs(n) + xi2 * Bsnij2(i, i, n)   'Pure fluid contributions to second virial coefficient
      Next
    End If
  Next
  K3 = K3 ^ 2
  U = U ^ 2

  'Binary pair contributions
  For i = 1 To NcDetail - 1
    If x(i) > 0 Then
      For j = i + 1 To NcDetail
        If x(j) > 0 Then
          xij = 2 * x(i) * x(j)
          K3 = K3 + xij * Kij5(i, j)
          U = U + xij * Uij5(i, j)
          G = G + xij * Gij5(i, j)
          For n = 1 To 18
            Bs(n) = Bs(n) + xij * Bsnij2(i, j, n)      'Second virial coefficients of mixture
          Next
        End If
      Next
    End If
  Next
  K3 = K3 ^ 0.6
  U = U ^ 0.2

  'Third virial and higher coefficients
  Q2 = Q ^ 2
  For n = 13 To 58
    Csn(n) = an(n) * U ^ un(n)
    If gn(n) = 1 Then Csn(n) = Csn(n) * G
    If qn(n) = 1 Then Csn(n) = Csn(n) * Q2
    If fn(n) = 1 Then Csn(n) = Csn(n) * F
  Next
End Sub

Private Sub Alpha0Detail(ByVal T As Double, ByVal D As Double, x() As Double, a0() As Double)
'Private Sub Alpha0Detail(T, D, x, a0)

'Calculate the ideal gas Helmholtz energy and its derivatives with respect to T and D.
'This routine is not needed when only P (or Z) is calculated.
'
'Inputs:
'     T - temperature (K)
'     D - density (mol/l)
'   x() - composition (mole fraction)
'
'Outputs:
' a0(0) - ideal gas Helmholtz energy (J/mol)
' a0(1) -   partial  (a0)/partial(T)
' a0(2) - T*partial^2(a0)/partial(T)^2

  Dim i As Integer, j As Integer
  Dim LogT As Double, LogD As Double, LogHyp As Double, th0T As Double, LogxD As Double
  Dim Sum0 As Double, Sum1 As Double, Sum2 As Double, SumHyp0 As Double, SumHyp1 As Double, SumHyp2 As Double
  Dim em As Double, ep As Double, hcn As Double, hsn As Double

  a0(0) = 0: a0(1) = 0: a0(2) = 0
  If D > 0 Then LogD = Log(D) Else LogD = Log(1E-20)
  LogT = Log(T)
  For i = 1 To NcDetail
    If x(i) > 0 Then
      LogxD = LogD + Log(x(i))
      SumHyp0 = 0
      SumHyp1 = 0
      SumHyp2 = 0
      For j = 4 To 7
        If th0i(i, j) > 0 Then
          th0T = th0i(i, j) / T
          ep = Exp(th0T)
          em = 1 / ep
          hsn = (ep - em) / 2
          hcn = (ep + em) / 2
          If j = 4 Or j = 6 Then
            LogHyp = Log(Abs(hsn))
            SumHyp0 = SumHyp0 + n0i(i, j) * LogHyp
            SumHyp1 = SumHyp1 + n0i(i, j) * (LogHyp - th0T * hcn / hsn)
            SumHyp2 = SumHyp2 + n0i(i, j) * (th0T / hsn) ^ 2
          Else
            LogHyp = Log(Abs(hcn))
            SumHyp0 = SumHyp0 - n0i(i, j) * LogHyp
            SumHyp1 = SumHyp1 - n0i(i, j) * (LogHyp - th0T * hsn / hcn)
            SumHyp2 = SumHyp2 + n0i(i, j) * (th0T / hcn) ^ 2
          End If
        End If
      Next
      a0(0) = a0(0) + x(i) * (LogxD + n0i(i, 1) + n0i(i, 2) / T - n0i(i, 3) * LogT + SumHyp0)
      a0(1) = a0(1) + x(i) * (LogxD + n0i(i, 1) - n0i(i, 3) * (1 + LogT) + SumHyp1)
      a0(2) = a0(2) - x(i) * (n0i(i, 3) + SumHyp2)
    End If
  Next
  a0(0) = a0(0) * RDetail * T
  a0(1) = a0(1) * RDetail
  a0(2) = a0(2) * RDetail
End Sub

Private Sub AlpharDetail(ByVal itau As Integer, ByVal idel As Integer, ByVal T As Double, ByVal D As Double, x() As Double, ar() As Double)
'Private Sub AlpharDetail(itau, idel, ByVal T, D, x, ar)

'Calculate the derivatives of the residual Helmholtz energy with respect to T and D.
'itau and idel are inputs that contain the highest derivatives needed.
'Outputs are returned in the array ar.
'Subroutine xTerms must be called before this routine if x has changed

'Inputs:
'     T - temperature (K)
'     D - density (mol/l)
'   x() - composition (mole fraction)
'
'Outputs:
' ar(0,0) - residual Helmholtz energy (J/mol)
' ar(0,1) -   D*partial  (ar)/partial(D)
' ar(0,2) - D^2*partial^2(ar)/partial(D)^2
' ar(0,3) - D^3*partial^3(ar)/partial(D)^3
' ar(1,0) -     partial  (ar)/partial(T)
' ar(1,1) -   D*partial^2(ar)/partial(D)/partial(T)
' ar(2,0) -   T*partial^2(ar)/partial(T)^2

  Dim i As Integer, j As Integer, n As Integer, ckd As Double, bkd As Double, Dred As Double
  Dim Sum As Double, s0 As Double, s1 As Double, s2 As Double, s3 As Double, RT As Double
  Dim Sum0(NTerms) As Double, SumB(NTerms) As Double, Dknn(9) As Double, Expn(4) As Double
  Dim CoefD1(NTerms) As Double, CoefD2(NTerms) As Double, CoefD3(NTerms) As Double
  Dim CoefT1(NTerms) As Double, CoefT2(NTerms) As Double

  For i = 0 To 3: For j = 0 To 3: ar(i, j) = 0: Next: Next
  If Abs(T - Told) > 0.0000000001 Then
    For n = 1 To 58
      Tun(n) = T ^ -un(n)
    Next
  End If
  Told = T

  'Precalculation of common powers and exponents of density
  Dred = K3 * D
  Dknn(0) = 1
  For n = 1 To 9
    Dknn(n) = Dred * Dknn(n - 1)
  Next
  Expn(0) = 1
  For n = 1 To 4
    Expn(n) = Exp(-Dknn(n))
  Next
  RT = RDetail * T

  For n = 1 To 58
    'Contributions to the Helmholtz energy and its derivatives with respect to temperature
    CoefT1(n) = RDetail * (un(n) - 1)
    CoefT2(n) = CoefT1(n) * un(n)
    'Contributions to the virial coefficients
    SumB(n) = 0
    Sum0(n) = 0
    If n <= 18 Then
      Sum = Bs(n) * D
      If n >= 13 Then Sum = Sum - Csn(n) * Dred
      SumB(n) = Sum * Tun(n)
    End If
    If n >= 13 Then
      'Contributions to the residual part of the Helmholtz energy
      Sum0(n) = Csn(n) * Dknn(bn(n)) * Tun(n) * Expn(kn(n))
      'Contributions to the derivatives of the Helmholtz energy with respect to density
      bkd = bn(n) - kn(n) * Dknn(kn(n))
      ckd = kn(n) ^ 2 * Dknn(kn(n))
      CoefD1(n) = bkd
      CoefD2(n) = bkd * (bkd - 1) - ckd
      CoefD3(n) = (bkd - 2) * CoefD2(n) + ckd * (1 - kn(n) - 2 * bkd)
    Else
      CoefD1(n) = 0: CoefD2(n) = 0: CoefD3(n) = 0
    End If
  Next

  For n = 1 To 58
    'Density derivatives
    s0 = Sum0(n) + SumB(n)
    s1 = Sum0(n) * CoefD1(n) + SumB(n)
    s2 = Sum0(n) * CoefD2(n)
    s3 = Sum0(n) * CoefD3(n)
    ar(0, 0) = ar(0, 0) + RT * s0
    ar(0, 1) = ar(0, 1) + RT * s1
    ar(0, 2) = ar(0, 2) + RT * s2
    ar(0, 3) = ar(0, 3) + RT * s3
    'Temperature derivatives
    If itau > 0 Then
      ar(1, 0) = ar(1, 0) - CoefT1(n) * s0
      ar(1, 1) = ar(1, 1) - CoefT1(n) * s1
      ar(2, 0) = ar(2, 0) + CoefT2(n) * s0
      'The following are not used
      'ar(1, 2) = ar(1, 2) - CoefT1(n) * s2
      'ar(1, 3) = ar(1, 3) - CoefT1(n) * s3
      'ar(2, 1) = ar(2, 1) + CoefT2(n) * s1
      'ar(2, 2) = ar(2, 2) + CoefT2(n) * s2
      'ar(2, 3) = ar(2, 3) + CoefT2(n) * s3
    End If
  Next
End Sub


'The following routine must be called once before any other routine.
Sub SetupDetail()

'Initialize all the constants and parameters in the DETAIL model.
'Some values are modified for calculations that do not depend on T, D, and x in order to speed up the program.

  Dim i As Integer, j As Integer, n As Integer, sn(NTerms) As Integer, wn(NTerms) As Integer
  Dim Ei(MaxFlds) As Double, Ki(MaxFlds) As Double, Si(MaxFlds) As Double, Wi(MaxFlds) As Double, Bsnij As Double
  Dim Kij(MaxFlds, MaxFlds) As Double, Gij(MaxFlds, MaxFlds) As Double, Eij(MaxFlds, MaxFlds) As Double, Uij(MaxFlds, MaxFlds) As Double
  Dim n1 As Double, n2 As Double, T0 As Double, d0 As Double

  RDetail = 8.31451

  'Molar masses (g/mol)
  MMiDetail(1) = 16.043    'Methane
  MMiDetail(2) = 28.0135   'Nitrogen
  MMiDetail(3) = 44.01     'Carbon dioxide
  MMiDetail(4) = 30.07     'Ethane
  MMiDetail(5) = 44.097    'Propane
  MMiDetail(6) = 58.123    'Isobutane
  MMiDetail(7) = 58.123    'n-Butane
  MMiDetail(8) = 72.15     'Isopentane
  MMiDetail(9) = 72.15     'n-Pentane
  MMiDetail(10) = 86.177   'Hexane
  MMiDetail(11) = 100.204  'Heptane
  MMiDetail(12) = 114.231  'Octane
  MMiDetail(13) = 128.258  'Nonane
  MMiDetail(14) = 142.285  'Decane
  MMiDetail(15) = 2.0159   'Hydrogen
  MMiDetail(16) = 31.9988  'Oxygen
  MMiDetail(17) = 28.01    'Carbon monoxide
  MMiDetail(18) = 18.0153  'Water
  MMiDetail(19) = 34.082   'Hydrogen sulfide
  MMiDetail(20) = 4.0026   'Helium
  MMiDetail(21) = 39.948   'Argon

  'Initialize constants
  Told = 0
  For i = 1 To NTerms
    an(i) = 0: bn(i) = 0: gn(i) = 0: fn(i) = 0: kn(i) = 0: qn(i) = 0: sn(i) = 0: un(i) = 0: wn(i) = 0
  Next
  For i = 1 To MaxFlds
    Ei(i) = 0: Fi(i) = 0: Gi(i) = 0: Ki(i) = 0: Qi(i) = 0: Si(i) = 0: Wi(i) = 0: xold(i) = 0
    For j = 1 To MaxFlds
      Eij(i, j) = 1: Gij(i, j) = 1: Kij(i, j) = 1: Uij(i, j) = 1
    Next
  Next

  'Coefficients of the equation of state
  an(1) = 0.1538326
  an(2) = 1.341953
  an(3) = -2.998583
  an(4) = -0.04831228
  an(5) = 0.3757965
  an(6) = -1.589575
  an(7) = -0.05358847
  an(8) = 0.88659463
  an(9) = -0.71023704
  an(10) = -1.471722
  an(11) = 1.32185035
  an(12) = -0.78665925
  an(13) = 0.00000000229129
  an(14) = 0.1576724
  an(15) = -0.4363864
  an(16) = -0.04408159
  an(17) = -0.003433888
  an(18) = 0.03205905
  an(19) = 0.02487355
  an(20) = 0.07332279
  an(21) = -0.001600573
  an(22) = 0.6424706
  an(23) = -0.4162601
  an(24) = -0.06689957
  an(25) = 0.2791795
  an(26) = -0.6966051
  an(27) = -0.002860589
  an(28) = -0.008098836
  an(29) = 3.150547
  an(30) = 0.007224479
  an(31) = -0.7057529
  an(32) = 0.5349792
  an(33) = -0.07931491
  an(34) = -1.418465
  an(35) = -5.99905E-17
  an(36) = 0.1058402
  an(37) = 0.03431729
  an(38) = -0.007022847
  an(39) = 0.02495587
  an(40) = 0.04296818
  an(41) = 0.7465453
  an(42) = -0.2919613
  an(43) = 7.294616
  an(44) = -9.936757
  an(45) = -0.005399808
  an(46) = -0.2432567
  an(47) = 0.04987016
  an(48) = 0.003733797
  an(49) = 1.874951
  an(50) = 0.002168144
  an(51) = -0.6587164
  an(52) = 0.000205518
  an(53) = 0.009776195
  an(54) = -0.02048708
  an(55) = 0.01557322
  an(56) = 0.006862415
  an(57) = -0.001226752
  an(58) = 0.002850908

  'Density exponents
  bn(1) = 1: bn(2) = 1: bn(3) = 1: bn(4) = 1: bn(5) = 1
  bn(6) = 1: bn(7) = 1: bn(8) = 1: bn(9) = 1: bn(10) = 1
  bn(11) = 1: bn(12) = 1: bn(13) = 1: bn(14) = 1: bn(15) = 1
  bn(16) = 1: bn(17) = 1: bn(18) = 1: bn(19) = 2: bn(20) = 2
  bn(21) = 2: bn(22) = 2: bn(23) = 2: bn(24) = 2: bn(25) = 2
  bn(26) = 2: bn(27) = 2: bn(28) = 3: bn(29) = 3: bn(30) = 3
  bn(31) = 3: bn(32) = 3: bn(33) = 3: bn(34) = 3: bn(35) = 3
  bn(36) = 3: bn(37) = 3: bn(38) = 4: bn(39) = 4: bn(40) = 4
  bn(41) = 4: bn(42) = 4: bn(43) = 4: bn(44) = 4: bn(45) = 5
  bn(46) = 5: bn(47) = 5: bn(48) = 5: bn(49) = 5: bn(50) = 6
  bn(51) = 6: bn(52) = 7: bn(53) = 7: bn(54) = 8: bn(55) = 8
  bn(56) = 8: bn(57) = 9: bn(58) = 9

  'Exponents on density in EXP(-cn*D^kn) part
  'The cn part in this term is not included in this program since it is 1 when kn<>0, and 0 otherwise
  kn(13) = 3: kn(14) = 2: kn(15) = 2: kn(16) = 2: kn(17) = 4
  kn(18) = 4: kn(21) = 2: kn(22) = 2: kn(23) = 2: kn(24) = 4
  kn(25) = 4: kn(26) = 4: kn(27) = 4: kn(29) = 1: kn(30) = 1
  kn(31) = 2: kn(32) = 2: kn(33) = 3: kn(34) = 3: kn(35) = 4
  kn(36) = 4: kn(37) = 4: kn(40) = 2: kn(41) = 2: kn(42) = 2
  kn(43) = 4: kn(44) = 4: kn(46) = 2: kn(47) = 2: kn(48) = 4
  kn(49) = 4: kn(51) = 2: kn(53) = 2: kn(54) = 1: kn(55) = 2
  kn(56) = 2: kn(57) = 2: kn(58) = 2

  'Temperature exponents
  un(1) = 0: un(2) = 0.5: un(3) = 1: un(4) = 3.5: un(5) = -0.5
  un(6) = 4.5: un(7) = 0.5: un(8) = 7.5: un(9) = 9.5: un(10) = 6
  un(11) = 12: un(12) = 12.5: un(13) = -6: un(14) = 2: un(15) = 3
  un(16) = 2: un(17) = 2: un(18) = 11: un(19) = -0.5: un(20) = 0.5
  un(21) = 0: un(22) = 4: un(23) = 6: un(24) = 21: un(25) = 23
  un(26) = 22: un(27) = -1: un(28) = -0.5: un(29) = 7: un(30) = -1
  un(31) = 6: un(32) = 4: un(33) = 1: un(34) = 9: un(35) = -13
  un(36) = 21: un(37) = 8: un(38) = -0.5: un(39) = 0: un(40) = 2
  un(41) = 7: un(42) = 9: un(43) = 22: un(44) = 23: un(45) = 1
  un(46) = 9: un(47) = 3: un(48) = 8: un(49) = 23: un(50) = 1.5
  un(51) = 5: un(52) = -0.5: un(53) = 4: un(54) = 7: un(55) = 3
  un(56) = 0: un(57) = 1: un(58) = 0

  'Flags
  fn(13) = 1: fn(27) = 1: fn(30) = 1: fn(35) = 1
  gn(5) = 1: gn(6) = 1: gn(25) = 1: gn(29) = 1: gn(32) = 1
  gn(33) = 1: gn(34) = 1: gn(51) = 1: gn(54) = 1: gn(56) = 1
  qn(7) = 1: qn(16) = 1: qn(26) = 1: qn(28) = 1: qn(37) = 1
  qn(42) = 1: qn(47) = 1: qn(49) = 1: qn(52) = 1: qn(58) = 1
  sn(8) = 1: sn(9) = 1
  wn(10) = 1: wn(11) = 1: wn(12) = 1

  'Energy parameters
  Ei(1) = 151.3183
  Ei(2) = 99.73778
  Ei(3) = 241.9606
  Ei(4) = 244.1667
  Ei(5) = 298.1183
  Ei(6) = 324.0689
  Ei(7) = 337.6389
  Ei(8) = 365.5999
  Ei(9) = 370.6823
  Ei(10) = 402.636293
  Ei(11) = 427.72263
  Ei(12) = 450.325022
  Ei(13) = 470.840891
  Ei(14) = 489.558373
  Ei(15) = 26.95794
  Ei(16) = 122.7667
  Ei(17) = 105.5348
  Ei(18) = 514.0156
  Ei(19) = 296.355
  Ei(20) = 2.610111
  Ei(21) = 119.6299

  'Size parameters
  Ki(1) = 0.4619255
  Ki(2) = 0.4479153
  Ki(3) = 0.4557489
  Ki(4) = 0.5279209
  Ki(5) = 0.583749
  Ki(6) = 0.6406937
  Ki(7) = 0.6341423
  Ki(8) = 0.6738577
  Ki(9) = 0.6798307
  Ki(10) = 0.7175118
  Ki(11) = 0.7525189
  Ki(12) = 0.784955
  Ki(13) = 0.8152731
  Ki(14) = 0.8437826
  Ki(15) = 0.3514916
  Ki(16) = 0.4186954
  Ki(17) = 0.4533894
  Ki(18) = 0.3825868
  Ki(19) = 0.4618263
  Ki(20) = 0.3589888
  Ki(21) = 0.4216551

  'Orientation parameters
  Gi(2) = 0.027815
  Gi(3) = 0.189065
  Gi(4) = 0.0793
  Gi(5) = 0.141239
  Gi(6) = 0.256692
  Gi(7) = 0.281835
  Gi(8) = 0.332267
  Gi(9) = 0.366911
  Gi(10) = 0.289731
  Gi(11) = 0.337542
  Gi(12) = 0.383381
  Gi(13) = 0.427354
  Gi(14) = 0.469659
  Gi(15) = 0.034369
  Gi(16) = 0.021
  Gi(17) = 0.038953
  Gi(18) = 0.3325
  Gi(19) = 0.0885

  'Quadrupole parameters
  Qi(3) = 0.69
  Qi(18) = 1.06775
  Qi(19) = 0.633276
  Fi(15) = 1        'High temperature parameter
  Si(18) = 1.5822   'Dipole parameter
  Si(19) = 0.39     'Dipole parameter
  Wi(18) = 1        'Association parameter

  'Energy parameters
  Eij(1, 2) = 0.97164
  Eij(1, 3) = 0.960644
  Eij(1, 5) = 0.994635
  Eij(1, 6) = 1.01953
  Eij(1, 7) = 0.989844
  Eij(1, 8) = 1.00235
  Eij(1, 9) = 0.999268
  Eij(1, 10) = 1.107274
  Eij(1, 11) = 0.88088
  Eij(1, 12) = 0.880973
  Eij(1, 13) = 0.881067
  Eij(1, 14) = 0.881161
  Eij(1, 15) = 1.17052
  Eij(1, 17) = 0.990126
  Eij(1, 18) = 0.708218
  Eij(1, 19) = 0.931484
  Eij(2, 3) = 1.02274
  Eij(2, 4) = 0.97012
  Eij(2, 5) = 0.945939
  Eij(2, 6) = 0.946914
  Eij(2, 7) = 0.973384
  Eij(2, 8) = 0.95934
  Eij(2, 9) = 0.94552
  Eij(2, 15) = 1.08632
  Eij(2, 16) = 1.021
  Eij(2, 17) = 1.00571
  Eij(2, 18) = 0.746954
  Eij(2, 19) = 0.902271
  Eij(3, 4) = 0.925053
  Eij(3, 5) = 0.960237
  Eij(3, 6) = 0.906849
  Eij(3, 7) = 0.897362
  Eij(3, 8) = 0.726255
  Eij(3, 9) = 0.859764
  Eij(3, 10) = 0.855134
  Eij(3, 11) = 0.831229
  Eij(3, 12) = 0.80831
  Eij(3, 13) = 0.786323
  Eij(3, 14) = 0.765171
  Eij(3, 15) = 1.28179
  Eij(3, 17) = 1.5
  Eij(3, 18) = 0.849408
  Eij(3, 19) = 0.955052
  Eij(4, 5) = 1.02256
  Eij(4, 7) = 1.01306
  Eij(4, 9) = 1.00532
  Eij(4, 15) = 1.16446
  Eij(4, 18) = 0.693168
  Eij(4, 19) = 0.946871
  Eij(5, 7) = 1.0049
  Eij(5, 15) = 1.034787
  Eij(6, 15) = 1.3
  Eij(7, 15) = 1.3
  Eij(10, 19) = 1.008692
  Eij(11, 19) = 1.010126
  Eij(12, 19) = 1.011501
  Eij(13, 19) = 1.012821
  Eij(14, 19) = 1.014089
  Eij(15, 17) = 1.1

  'Conformal energy parameters
  Uij(1, 2) = 0.886106
  Uij(1, 3) = 0.963827
  Uij(1, 5) = 0.990877
  Uij(1, 7) = 0.992291
  Uij(1, 9) = 1.00367
  Uij(1, 10) = 1.302576
  Uij(1, 11) = 1.191904
  Uij(1, 12) = 1.205769
  Uij(1, 13) = 1.219634
  Uij(1, 14) = 1.233498
  Uij(1, 15) = 1.15639
  Uij(1, 19) = 0.736833
  Uij(2, 3) = 0.835058
  Uij(2, 4) = 0.816431
  Uij(2, 5) = 0.915502
  Uij(2, 7) = 0.993556
  Uij(2, 15) = 0.408838
  Uij(2, 19) = 0.993476
  Uij(3, 4) = 0.96987
  Uij(3, 10) = 1.066638
  Uij(3, 11) = 1.077634
  Uij(3, 12) = 1.088178
  Uij(3, 13) = 1.098291
  Uij(3, 14) = 1.108021
  Uij(3, 17) = 0.9
  Uij(3, 19) = 1.04529
  Uij(4, 5) = 1.065173
  Uij(4, 6) = 1.25
  Uij(4, 7) = 1.25
  Uij(4, 8) = 1.25
  Uij(4, 9) = 1.25
  Uij(4, 15) = 1.61666
  Uij(4, 19) = 0.971926
  Uij(10, 19) = 1.028973
  Uij(11, 19) = 1.033754
  Uij(12, 19) = 1.038338
  Uij(13, 19) = 1.042735
  Uij(14, 19) = 1.046966

  'Size parameters
  Kij(1, 2) = 1.00363
  Kij(1, 3) = 0.995933
  Kij(1, 5) = 1.007619
  Kij(1, 7) = 0.997596
  Kij(1, 9) = 1.002529
  Kij(1, 10) = 0.982962
  Kij(1, 11) = 0.983565
  Kij(1, 12) = 0.982707
  Kij(1, 13) = 0.981849
  Kij(1, 14) = 0.980991
  Kij(1, 15) = 1.02326
  Kij(1, 19) = 1.00008
  Kij(2, 3) = 0.982361
  Kij(2, 4) = 1.00796
  Kij(2, 15) = 1.03227
  Kij(2, 19) = 0.942596
  Kij(3, 4) = 1.00851
  Kij(3, 10) = 0.910183
  Kij(3, 11) = 0.895362
  Kij(3, 12) = 0.881152
  Kij(3, 13) = 0.86752
  Kij(3, 14) = 0.854406
  Kij(3, 19) = 1.00779
  Kij(4, 5) = 0.986893
  Kij(4, 15) = 1.02034
  Kij(4, 19) = 0.999969
  Kij(10, 19) = 0.96813
  Kij(11, 19) = 0.96287
  Kij(12, 19) = 0.957828
  Kij(13, 19) = 0.952441
  Kij(14, 19) = 0.948338

  'Orientation parameters
  Gij(1, 3) = 0.807653
  Gij(1, 15) = 1.95731
  Gij(2, 3) = 0.982746
  Gij(3, 4) = 0.370296
  Gij(3, 18) = 1.67309

  'Ideal gas parameters
  n0i(1, 3) = 4.00088:  n0i(1, 4) = 0.76315:  n0i(1, 5) = 0.0046:   n0i(1, 6) = 8.74432:  n0i(1, 7) = -4.46921: n0i(1, 1) = 29.83843397:  n0i(1, 2) = -15999.69151
  n0i(2, 3) = 3.50031:  n0i(2, 4) = 0.13732:  n0i(2, 5) = -0.1466:  n0i(2, 6) = 0.90066:  n0i(2, 7) = 0:        n0i(2, 1) = 17.56770785:  n0i(2, 2) = -2801.729072
  n0i(3, 3) = 3.50002:  n0i(3, 4) = 2.04452:  n0i(3, 5) = -1.06044: n0i(3, 6) = 2.03366:  n0i(3, 7) = 0.01393:  n0i(3, 1) = 20.65844696:  n0i(3, 2) = -4902.171516
  n0i(4, 3) = 4.00263:  n0i(4, 4) = 4.33939:  n0i(4, 5) = 1.23722:  n0i(4, 6) = 13.1974:  n0i(4, 7) = -6.01989: n0i(4, 1) = 36.73005938:  n0i(4, 2) = -23639.65301
  n0i(5, 3) = 4.02939:  n0i(5, 4) = 6.60569:  n0i(5, 5) = 3.197:    n0i(5, 6) = 19.1921:  n0i(5, 7) = -8.37267: n0i(5, 1) = 44.70909619:  n0i(5, 2) = -31236.63551
  n0i(6, 3) = 4.06714:  n0i(6, 4) = 8.97575:  n0i(6, 5) = 5.25156:  n0i(6, 6) = 25.1423:  n0i(6, 7) = 16.1388:  n0i(6, 1) = 34.30180349:  n0i(6, 2) = -38525.50276
  n0i(7, 3) = 4.33944:  n0i(7, 4) = 9.44893:  n0i(7, 5) = 6.89406:  n0i(7, 6) = 24.4618:  n0i(7, 7) = 14.7824:  n0i(7, 1) = 36.53237783:  n0i(7, 2) = -38957.80933
  n0i(8, 3) = 4:        n0i(8, 4) = 11.7618:  n0i(8, 5) = 20.1101:  n0i(8, 6) = 33.1688:  n0i(8, 7) = 0:        n0i(8, 1) = 43.17218626:  n0i(8, 2) = -51198.30946
  n0i(9, 3) = 4:        n0i(9, 4) = 8.95043:  n0i(9, 5) = 21.836:   n0i(9, 6) = 33.4032:  n0i(9, 7) = 0:        n0i(9, 1) = 42.67837089:  n0i(9, 2) = -45215.83
  n0i(10, 3) = 4:       n0i(10, 4) = 11.6977: n0i(10, 5) = 26.8142: n0i(10, 6) = 38.6164: n0i(10, 7) = 0:       n0i(10, 1) = 46.99717188: n0i(10, 2) = -52746.83318
  n0i(11, 3) = 4:       n0i(11, 4) = 13.7266: n0i(11, 5) = 30.4707: n0i(11, 6) = 43.5561: n0i(11, 7) = 0:       n0i(11, 1) = 52.07631631: n0i(11, 2) = -57104.81056
  n0i(12, 3) = 4:       n0i(12, 4) = 15.6865: n0i(12, 5) = 33.8029: n0i(12, 6) = 48.1731: n0i(12, 7) = 0:       n0i(12, 1) = 57.25830934: n0i(12, 2) = -60546.76385
  n0i(13, 3) = 4:       n0i(13, 4) = 18.0241: n0i(13, 5) = 38.1235: n0i(13, 6) = 53.3415: n0i(13, 7) = 0:       n0i(13, 1) = 62.09646901: n0i(13, 2) = -66600.12837
  n0i(14, 3) = 4:       n0i(14, 4) = 21.0069: n0i(14, 5) = 43.4931: n0i(14, 6) = 58.3657: n0i(14, 7) = 0:       n0i(14, 1) = 65.93909154: n0i(14, 2) = -74131.45483
  n0i(15, 3) = 2.47906: n0i(15, 4) = 0.95806: n0i(15, 5) = 0.45444: n0i(15, 6) = 1.56039: n0i(15, 7) = -1.3756: n0i(15, 1) = 13.07520288: n0i(15, 2) = -5836.943696
  n0i(16, 3) = 3.50146: n0i(16, 4) = 1.07558: n0i(16, 5) = 1.01334: n0i(16, 6) = 0:       n0i(16, 7) = 0:       n0i(16, 1) = 16.8017173:  n0i(16, 2) = -2318.32269
  n0i(17, 3) = 3.50055: n0i(17, 4) = 1.02865: n0i(17, 5) = 0.00493: n0i(17, 6) = 0:       n0i(17, 7) = 0:       n0i(17, 1) = 17.45786899: n0i(17, 2) = -2635.244116
  n0i(18, 3) = 4.00392: n0i(18, 4) = 0.01059: n0i(18, 5) = 0.98763: n0i(18, 6) = 3.06904: n0i(18, 7) = 0:       n0i(18, 1) = 21.57882705: n0i(18, 2) = -7766.733078
  n0i(19, 3) = 4:       n0i(19, 4) = 3.11942: n0i(19, 5) = 1.00243: n0i(19, 6) = 0:       n0i(19, 7) = 0:       n0i(19, 1) = 21.5830944:  n0i(19, 2) = -6069.035869
  n0i(20, 3) = 2.5:     n0i(20, 4) = 0:       n0i(20, 5) = 0:       n0i(20, 6) = 0:       n0i(20, 7) = 0:       n0i(20, 1) = 10.04639507: n0i(20, 2) = -745.375
  n0i(21, 3) = 2.5:     n0i(21, 4) = 0:       n0i(21, 5) = 0:       n0i(21, 6) = 0:       n0i(21, 7) = 0:       n0i(21, 1) = 10.04639507: n0i(21, 2) = -745.375

  th0i(1, 4) = 820.659:  th0i(1, 5) = 178.41:   th0i(1, 6) = 1062.82:  th0i(1, 7) = 1090.53
  th0i(2, 4) = 662.738:  th0i(2, 5) = 680.562:  th0i(2, 6) = 1740.06:  th0i(2, 7) = 0
  th0i(3, 4) = 919.306:  th0i(3, 5) = 865.07:   th0i(3, 6) = 483.553:  th0i(3, 7) = 341.109
  th0i(4, 4) = 559.314:  th0i(4, 5) = 223.284:  th0i(4, 6) = 1031.38:  th0i(4, 7) = 1071.29
  th0i(5, 4) = 479.856:  th0i(5, 5) = 200.893:  th0i(5, 6) = 955.312:  th0i(5, 7) = 1027.29
  th0i(6, 4) = 438.27:   th0i(6, 5) = 198.018:  th0i(6, 6) = 1905.02:  th0i(6, 7) = 893.765
  th0i(7, 4) = 468.27:   th0i(7, 5) = 183.636:  th0i(7, 6) = 1914.1:   th0i(7, 7) = 903.185
  th0i(8, 4) = 292.503:  th0i(8, 5) = 910.237:  th0i(8, 6) = 1919.37:  th0i(8, 7) = 0
  th0i(9, 4) = 178.67:   th0i(9, 5) = 840.538:  th0i(9, 6) = 1774.25:  th0i(9, 7) = 0
  th0i(10, 4) = 182.326: th0i(10, 5) = 859.207: th0i(10, 6) = 1826.59: th0i(10, 7) = 0
  th0i(11, 4) = 169.789: th0i(11, 5) = 836.195: th0i(11, 6) = 1760.46: th0i(11, 7) = 0
  th0i(12, 4) = 158.922: th0i(12, 5) = 815.064: th0i(12, 6) = 1693.07: th0i(12, 7) = 0
  th0i(13, 4) = 156.854: th0i(13, 5) = 814.882: th0i(13, 6) = 1693.79: th0i(13, 7) = 0
  th0i(14, 4) = 164.947: th0i(14, 5) = 836.264: th0i(14, 6) = 1750.24: th0i(14, 7) = 0
  th0i(15, 4) = 228.734: th0i(15, 5) = 326.843: th0i(15, 6) = 1651.71: th0i(15, 7) = 1671.69
  th0i(16, 4) = 2235.71: th0i(16, 5) = 1116.69: th0i(16, 6) = 0:       th0i(16, 7) = 0
  th0i(17, 4) = 1550.45: th0i(17, 5) = 704.525: th0i(17, 6) = 0:       th0i(17, 7) = 0
  th0i(18, 4) = 268.795: th0i(18, 5) = 1141.41: th0i(18, 6) = 2507.37: th0i(18, 7) = 0
  th0i(19, 4) = 1833.63: th0i(19, 5) = 847.181: th0i(19, 6) = 0:       th0i(19, 7) = 0
  th0i(20, 4) = 0:       th0i(20, 5) = 0:       th0i(20, 6) = 0:       th0i(20, 7) = 0
  th0i(21, 4) = 0:       th0i(21, 5) = 0:       th0i(21, 6) = 0:       th0i(21, 7) = 0

  'Precalculations of constants
  For i = 1 To MaxFlds
    Ki25(i) = Ki(i) ^ 2.5
    Ei25(i) = Ei(i) ^ 2.5
  Next
  For i = 1 To MaxFlds
    For j = i To MaxFlds
      For n = 1 To 18
        Bsnij = 1
        If gn(n) = 1 Then Bsnij = Gij(i, j) * (Gi(i) + Gi(j)) / 2
        If qn(n) = 1 Then Bsnij = Bsnij * Qi(i) * Qi(j)
        If fn(n) = 1 Then Bsnij = Bsnij * Fi(i) * Fi(j)
        If sn(n) = 1 Then Bsnij = Bsnij * Si(i) * Si(j)
        If wn(n) = 1 Then Bsnij = Bsnij * Wi(i) * Wi(j)
        Bsnij2(i, j, n) = an(n) * (Eij(i, j) * Sqr(Ei(i) * Ei(j))) ^ un(n) * (Ki(i) * Ki(j)) ^ 1.5 * Bsnij
      Next
      Kij5(i, j) = (Kij(i, j) ^ 5 - 1) * Ki25(i) * Ki25(j)
      Uij5(i, j) = (Uij(i, j) ^ 5 - 1) * Ei25(i) * Ei25(j)
      Gij5(i, j) = (Gij(i, j) - 1) * (Gi(i) + Gi(j)) / 2
    Next
  Next

  'Ideal gas terms
  T0 = 298.15
  d0 = 101.325 / RDetail / T0
  For i = 1 To MaxFlds
    n0i(i, 3) = n0i(i, 3) - 1
    n0i(i, 1) = n0i(i, 1) - Log(d0)
  Next
  Exit Sub

  'Code to produce nearly exact values for n0(1) and n0(2)
  'This is not called in the current code, but included below to show how the values were calculated.  The Exit Sub above can be removed to call this code.
  T0 = 298.15
  d0 = 101.325 / RDetail / T0
  For i = 1 To MaxFlds
    n1 = 0: n2 = 0
    If th0i(i, 4) > 0 Then n2 = n2 - n0i(i, 4) * th0i(i, 4) / Tanh(th0i(i, 4) / T0): n1 = n1 - n0i(i, 4) * Log(Sinh(th0i(i, 4) / T0))
    If th0i(i, 5) > 0 Then n2 = n2 + n0i(i, 5) * th0i(i, 5) * Tanh(th0i(i, 5) / T0): n1 = n1 + n0i(i, 5) * Log(Cosh(th0i(i, 5) / T0))
    If th0i(i, 6) > 0 Then n2 = n2 - n0i(i, 6) * th0i(i, 6) / Tanh(th0i(i, 6) / T0): n1 = n1 - n0i(i, 6) * Log(Sinh(th0i(i, 6) / T0))
    If th0i(i, 7) > 0 Then n2 = n2 + n0i(i, 7) * th0i(i, 7) * Tanh(th0i(i, 7) / T0): n1 = n1 + n0i(i, 7) * Log(Cosh(th0i(i, 7) / T0))
    n0i(i, 2) = n2 - n0i(i, 3) * T0
    n0i(i, 3) = n0i(i, 3) - 1
    n0i(i, 1) = n1 - n2 / T0 + n0i(i, 3) * (1 + Log(T0)) - Log(d0)
  Next
End Sub

Private Function Tanh(xx As Double) As Double
  Tanh = (Exp(xx) - Exp(-xx)) / (Exp(xx) + Exp(-xx))
End Function

Private Function Sinh(xx)
  Sinh = (Exp(xx) - Exp(-xx)) / 2
End Function

Private Function Cosh(xx)
  Cosh = (Exp(xx) + Exp(-xx)) / 2
End Function
