c  Example program for calling routines for the GROSS equation of state.

      subroutine ExampleGross
      implicit none
      integer ierr
      double precision x(21),Mm,T,P,D,Z,xGrs(3),s,pp
      double precision Gr,Hv,Hv2,HN,HCH
      double precision Th,Td,Pd
      character*255 herr

c  input composition (must be in the same order as below)
      x(1 )=0.77824d0       !Methane
      x(2 )=0.02d0          !Nitrogen
      x(3 )=0.06d0          !CO2
      x(4 )=0.08d0          !Ethane
      x(5 )=0.03d0          !Propane
      x(6 )=0.0015d0        !Isobutane
      x(7 )=0.003d0         !Butane
      x(8 )=0.0005d0        !Isopentane
      x(9 )=0.00165d0       !Pentane
      x(10)=0.00215d0       !Hexane
      x(11)=0.00088d0       !Heptane
      x(12)=0.00024d0       !Octane
      x(13)=0.00015d0       !Nonane
      x(14)=0.00009d0       !Decane
      x(15)=0.004d0         !Hydrogen
      x(16)=0.005d0         !Oxygen
      x(17)=0.002d0         !CO
      x(18)=0.0001d0        !Water
      x(19)=0.0025d0        !H2S
      x(20)=0.007d0         !Helium
      x(21)=0.001d0         !Argon

      s=SUM(x)
      if (ABS(s-1.d0).gt.0.00001d0) pause 'Composition sum<>1'

c  T (K) and P (kPa) inputs
      T=300
      P=10000

      write (*,*) 'Inputs-----'
      write (*,*) 'Temperature [K]:                   ',SNGL(T)
      write (*,*) 'Pressure [kPa]:                    ',SNGL(P)

      write (*,*) 'Outputs-----'

c  Get molar mass.
      Call MolarMassGross(x,Mm)
      write (*,*) 'Molar mass [g/mol]:                ',SNGL(mm)

c  Get molar density at T and P.
c  Subroutine GrossHv must be called first to get xGrs and HCH needed
c  in the DensityGross routine.  Once GrossHv has been called, it does not
c  need to be called again unless the composition changes.
      Call GrossHv(x,xGrs,HN,HCH)
      Call DensityGross(T,P,xGrs,HCH,D,ierr,herr)
      if (ierr.ne.0) write (*,*) '***Error number***: ',ierr
      write (*,*) 'Molar density [mol/l]:             ',SNGL(D)

c  Get pressure from T and D.
c  (Note that GrossHv is not called here since it was called above.)
      Call PressureGross(T,D,xGrs,HCH,pp,Z,ierr,herr)
      write (*,*) 'Pressure [kPa]:                    ',SNGL(pp)
      write (*,*) 'Compressibility factor:            ',SNGL(Z)

c  Set reference states for heat of combustion and density in K and kPa
c     Th = 288.15d0      !(15 C)
      Th = 298.15d0      !(25 C)
      Td = 273.15d0      !(0 C)
      Pd = 101.325d0     !(1 atm)
c     Th = 288.70556d0   !(60 F)
c     Td = 288.70556d0   !(60 F)
c     Pd = 101.55977d0   !(14.73 psia)

c  Get the internal calculations to the Gross routines since Method 0 was used
c  above instead of Methods 1 or 2 (see the AGA 8 publication for details on this).
      Call GrossInputs(Td,Pd,x,xGrs,Gr,HN,HCH,ierr,herr)
      Call GrossHv(x,xGrs,HN,HCH)
      Call DensityGross(Td,Pd,xGrs,HCH,D,ierr,herr)
      Hv=HN*D
      write (*,*) 'Relative density:                  ',SNGL(Gr)
      write (*,*) 'Molar heating value (kJ/mol, 25 C):',SNGL(HN)
      write (*,*) 'HCH (kJ/mol, 25 C):                ',SNGL(HCH)
      write (*,*) 'Equivalent hydrocarbon fraction:   ',SNGL(xGrs(1))
      write (*,*) 'nitrogen mole fraction:            ',SNGL(xGrs(2))
      write (*,*) 'CO2 mole fraction:                 ',SNGL(xGrs(3))
      write (*,*) 'Volumetric heating value at Td,Pd: ',SNGL(Hv)



c  Call Gross Method 2 with inputs of temperature, pressure,
c  mole percent nitrogen, mole percent CO2, and relative density at Td and Pd.
      xGrs(2)=x(2)
      xGrs(3)=x(3)
      Call GrossMethod2(Th,Td,Pd,xGrs,Gr,Hv2,Mm,HCH,HN,ierr,herr)
      Call DensityGross(T,P,xGrs,HCH,D,ierr,herr)
      write (*,*) 'Gross method 2-----'
      if (ierr.ne.0) write (*,*) '***Error number***: ',ierr
      write (*,*) 'Molar density [mol/l]:             ',SNGL(D)
      write (*,*) 'Volumetric heating value at Td,Pd: ',SNGL(Hv2)

c  Call Gross Method 1 with inputs of temperature, pressure,
c  mole percent CO2, relative density, and volumetric heating value (MJ/m^3) at Th.
      xGrs(2)=x(2)
      xGrs(3)=x(3)
      Call GrossMethod1(Th,Td,Pd,xGrs,Gr,Hv,Mm,HCH,HN,ierr,herr)
      Call DensityGross(T,P,xGrs,HCH,D,ierr,herr)
      write (*,*) 'Gross method 1-----'
      if (ierr.ne.0) write (*,*) '***Error number***: ',ierr
      write (*,*) 'Molar density [mol/l]:             ',SNGL(D)


      pause
      end


c-----------------------------------------------------------------------
c
c  Version 2.0 of routines for the calculation of thermodynamic
c   properties from the AGA 8 Part 1 GROSS equation of state.
c   April, 2017
c
c  Written by Eric W. Lemmon
c  Applied Chemicals and Materials Division
c  National Institute of Standards and Technology (NIST)
c  Boulder, Colorado, USA
c  Eric.Lemmon@nist.gov
c  303-497-7939
c
c  Other contributors:
c  Volker Heinemann, RMG Messtechnik GmbH
c  Jason Lu, Thermo Fisher Scientific
c  Ian Bell, NIST
c
c  The publication for the AGA 8 equation of state is available from AGA
c    and the Transmission Measurement Committee.
c
c  Subroutines contained here for property calculations:
c  ***** Subroutine SetupGross must be called once before calling other routines. ******
c  Sub MolarMassGross(x, Mm)
c  Sub PressureGross(T, D, xGrs, HCH, P, Z, ierr, herr)
c  Sub DensityGross(T, P, xGrs, HCH, D, ierr, herr)
c  Sub GrossHv(x, xGrs, HN, HCH)
c  Sub GrossInputs(T, P, x, xGrs, Gr, HN, HCH, ierr, herr)
c  Sub Bmix(T, xGrs, HCH, B, C, ierr, herr)
c  Sub GrossMethod1(Th, Td, Pd, xGrs, Gr, Hv, Mm, HCH, HN, ierr, herr)
c  Sub GrossMethod2(Th, Td, Pd, xGrs, Gr, Hv, Mm, HCH, HN, ierr, herr)
c  Sub SetupGross()
c
c  The compositions in the x() array use the following order and must be sent as mole fractions:
c      1 - Methane
c      2 - Nitrogen
c      3 - Carbon dioxide
c      4 - Ethane
c      5 - Propane
c      6 - Isobutane
c      7 - n-Butane
c      8 - Isopentane
c      9 - n-Pentane
c     10 - n-Hexane
c     11 - n-Heptane
c     12 - n-Octane
c     13 - n-Nonane
c     14 - n-Decane
c     15 - Hydrogen
c     16 - Oxygen
c     17 - Carbon monoxide
c     18 - Water
c     19 - Hydrogen sulfide
c     20 - Helium
c     21 - Argon
c
c  For example, a mixture of 94% methane, 5% CO2, and 1% helium would be (in mole fractions):
c  x(1)=0.94, x(3)=0.05, x(20)=0.01
c-----------------------------------------------------------------------

      SUBROUTINE MolarMassGross(x,Mm)

c  Calculate molar mass of the mixture with the compositions contained in the x() input array
c
c  Inputs:
c   x() - Composition (mole fraction)
c         Do not send mole percents or mass fractions in the x() array, otherwise the output will be incorrect.
c         The sum of the compositions in the x() array must be equal to one.
c         The order of the fluids in this array is given at the top of this code.
c
c  Outputs:
c    Mm - Molar mass (g/mol)

      include 'GROSS.CMN'
      double precision x(MaxFlds),Mm
      Mm=SUM(x(1:NcGross)*MMiGross(1:NcGross))
      END

c-----------------------------------------------------------------------

      SUBROUTINE PressureGross(T,D,xGrs,HCH,P,Z,ierr,herr)

c  Calculate pressure as a function of temperature and density.  The derivative d(P)/d(D) is also calculated
c  for use in the iterative DensityGross subroutine (and is only returned as a common variable).
c
c  Inputs:
c     T - Temperature (K)
c     D - Density (mol/l)
c  xGrs - Compositions of the equivalent hydrocarbon, nitrogen, and CO2 (mole fractions)
c   HCH - Molar ideal gross heating value of the equivalent hydrocarbon (kJ/mol) at 298.15 K
c         ***Call subroutine GrossHv or GrossInputs first to obtain HCH.***
c
c  Outputs:
c     P - Pressure (kPa)
c     Z - Compressibility factor
c  dPdDsave - d(P)/d(D) [kPa/(mol/l)] (at constant temperature)
c           - This variable is cached in the common variables for use in the iterative density solver, but not returned as an argument
c  ierr - Error number (0 indicates no error)
c  herr - Error message if ierr is not equal to zero

      include 'GROSS.CMN'
      integer ierr
      double precision xGrs(3),T,D,HCH,P,Z,B,C
      character*255 herr

      Z=1.d0
      P=D*RGross*T
      Call Bmix(T,xGrs,HCH,B,C,ierr,herr)
      If (ierr.gt.0) RETURN
      Z=1.d0+B*D+C*D**2
      P=D*RGross*T*Z
      dPdDsave=RGross*T*(1.d0+2.d0*B*D+3.d0*C*D**2)
      if (P.lt.0.) then
        ierr=-1
        herr='Pressure is negative in the GROSS method.'
      endif
      END

c-----------------------------------------------------------------------

      SUBROUTINE DensityGross(T,P,xGrs,HCH,D,ierr,herr)

c  Calculate density as a function of temperature and pressure.  This is an iterative routine that calls PressureGross
c  to find the correct state point.  Generally only 6 iterations at most are required.
c  If the iteration fails to converge, the ideal gas density and an error message are returned.
c
c  Inputs:
c     T - Temperature (K)
c     P - Pressure (kPa)
c  xGrs - Compositions of the equivalent hydrocarbon, nitrogen, and CO2 (mole fractions)
c   HCH - Molar ideal gross heating value of the equivalent hydrocarbon (kJ/mol) at 298.15 K
c         ***Call subroutine GrossHv or GrossInputs first to obtain HCH.***
c
c  Outputs:
c     D - Density (mol/l)
c  ierr - Error number (0 indicates no error)
c  herr - Error message if ierr is not equal to zero

      include 'GROSS.CMN'
      integer ierr,it
      double precision T,P,xGrs(3),HCH,D
      double precision plog,vlog,P2,Z,dpdlv,vdiff,tolr
      character*255 herr

      ierr=0
      herr=' '
      If (P.lt.Epsilon) Then
        D=0.d0
        RETURN
      endif
      tolr=1.d-7
      D=P/RGross/T       !Ideal gas estimate
      plog=Log(P)
      vlog=-Log(D)
      Do it=1,20
        If (vlog.lt.-7.d0 .or. vlog.gt.100.d0) GoTo 10
        D=Exp(-vlog)
        Call PressureGross(T,D,xGrs,HCH,P2,Z,ierr,herr)
        If (ierr.gt.0) RETURN
        If (dPdDsave.lt.Epsilon .or. P2.lt.Epsilon) Then
          vlog=vlog+0.1d0
        Else
c  Find the next density with a first order Newton's type iterative scheme, with
c  log(P) as the known variable and log(v) as the unknown property.
c  See AGA 8 publication for further information.
          dpdlv=-D*dPdDsave     !d(p)/d[log(v)]
          vdiff=(Log(P2)-plog)*P2/dpdlv
          vlog=vlog-vdiff
          If (Abs(vdiff).lt.tolr) Then
            If (P2.lt.0.) GoTo 10
            D=Exp(-vlog)
            RETURN         !Iteration converged
          End If
        End If
      Enddo

 10   Continue
      ierr=10
      herr = 'Calculation failed to converge in the GROSS method, '//
     &       'ideal gas density returned.'
      D=P/RGross/T
      END

c-----------------------------------------------------------------------

      SUBROUTINE GrossHv(x,xGrs,HN,HCH)

c  Calculate ideal heating values based on composition.  The mole fractions in the mixture are required in this routine, not
c  just xCH, xN2, and xCO2.
c
c  Inputs:
c   x() - Molar compositions of all components in the mixture.  The order in this array is given at the top of this code.
c
c  Outputs:
c  xGrs - Compositions of the equivalent hydrocarbon, nitrogen, and CO2 (mole fractions)
c    HN - Molar ideal gross heating value of the mixture (kJ/mol) at 298.15 K
c   HCH - Molar ideal gross heating value of the equivalent hydrocarbon (kJ/mol) at 298.15 K

      include 'GROSS.CMN'
      integer i
      double precision x(MaxFlds),xGrs(3),HN,HCH

      xGrs(1)=1.d0-x(2)-x(3)
      xGrs(2)=x(2)
      xGrs(3)=x(3)
      HN=0.d0
      do i=1,NcGross
        HN=HN+x(i)*xHN(i)
      enddo
      HCH=0.d0
      If (xGrs(1).gt.0.d0) HCH=HN/xGrs(1)
      END

c-----------------------------------------------------------------------

      SUBROUTINE GrossInputs(T,P,x,xGrs,Gr,HN,HCH,ierr,herr)

c  Calculate relative density and heating values based on composition.  This routine should only be used to get these
c  two values for use as inputs to Method 1 or Method 2, and not for the relative density for any T and P.
c  All of the mole fractions in the mixture are required in this routine, not just xCH, xN2, and xCO2.
c
c  Inputs:
c     T - Temperature (K), generally a reference temperature for relative density
c     P - Pressure (kPa), generally a reference pressure for relative density
c   x() - Molar compositions of all components in the mixture.  The order in this array is given at the top of this code.
c
c  Outputs:
c  xGrs - Compositions of the equivalent hydrocarbon, nitrogen, and CO2 (mole fractions)
c    Gr - Relative density at T and P
c    HN - Molar ideal gross heating value of the mixture (kJ/mol) at 298.15 K
c   HCH - Molar ideal gross heating value of the equivalent hydrocarbon (kJ/mol) at 298.15 K
c  ierr - Error number (0 indicates no error)
c  herr - Error message if ierr is not equal to zero

      include 'GROSS.CMN'
      integer ierr
      double precision T,P,x(MaxFlds),xGrs(3),Gr,HN,HCH
      double precision Bref,Zref,Mref,Z,D,Mm
      character*255 herr

      ierr=0
      herr=' '
      Call GrossHv(x,xGrs,HN,HCH)
      Bref=-0.12527d0+0.000591d0*T-0.000000662d0*T**2   !2nd virial coefficient of the reference fluid at T
      Zref=1.d0+Bref*P/RGross/T                         !Z of the reference fluid at T and P
      Mref=28.9625d0
      Call MolarMassGross(x,Mm)
      Call DensityGross(T,P,xGrs,HCH,D,ierr,herr)    !Density of the input fluid at T and D
      Z=P/T/D/RGross                                 !Z of the input fluid at T and D
      Gr=Mm*Zref/Mref/Z
      END

c-----------------------------------------------------------------------

      SUBROUTINE Bmix(T,xGrs,HCH,B,C,ierr,herr)

c  Calculate 2nd and 3rd virial coefficients for the mixture at T.
c
c  Inputs:
c     T - Temperature (K)
c  xGrs - Compositions of the equivalent hydrocarbon, nitrogen, and CO2 (mole fractions)
c   HCH - Molar ideal gross heating value of the equivalent hydrocarbon (kJ/mol) at 298.15 K
c
c  Outputs:
c     B - Second virial coefficient (dm^3/mol)
c     C - Third virial coefficient (dm^6/mol^2)
c  ierr - Error number (0 indicates no error)
c  herr - Error message if ierr is not equal to zero

      include 'GROSS.CMN'
      integer i,j,k,ierr
      double precision T,xGrs(3),HCH,B,C
      double precision bCH(0:3),cCH(0:3),BB(3,3),CC(3,3,3),onethrd
      character*255 herr

      ierr=0
      herr=' '
      B=0.d0
      C=0.d0

c  Temperature dependent Bi and Ci values for obtaining B(CH-CH) and C(CH-CH-CH)
      do i=0,2
        bCH(i)=bCHx(0,i)+bCHx(1,i)*T+bCHx(2,i)*T**2
        cCH(i)=cCHx(0,i)+cCHx(1,i)*T+cCHx(2,i)*T**2
      enddo

c  Bij and Cijk values for nitrogen and CO2
      do i=2,3
        do j=i,3
          BB(i,j)=b0(i,j)+b1(i,j)*T+b2(i,j)*T**2
          do k=j,3
            CC(i,j,k)=c0(i,j,k)+c1(i,j,k)*T+c2(i,j,k)*T**2
          enddo
        enddo
      enddo

c  Bij values for use in calculating Bmix
      BB(1,1)=bCH(0)+bCH(1)*HCH+bCH(2)*HCH**2                             !B(CH-CH) for the equivalent hydrocarbon
      BB(1,2)=(0.72d0+0.00001875d0*(320.d0-T)**2)*(BB(1,1)+BB(2,2))/2.d0  !B(CH-N2)
      If (BB(1,1)*BB(3,3).lt.0.d0) Then
        ierr=4
        herr='Invalid input in Bmix routine'
        RETURN
      endif
      BB(1,3)=-0.865d0*Sqrt(BB(1,1)*BB(3,3))                              !B(CH-CO2)

c  Cijk values for use in calculating Cmix
      onethrd=1.d0/3.d0
      CC(1,1,1)=cCH(0)+cCH(1)*HCH+cCH(2)*HCH**2                           !C(CH-CH-CH) for the equivalent hydrocarbon
      If (CC(1,1,1).lt.0.d0 .or. CC(3,3,3).lt.0.d0) Then
        ierr=5
        herr='Invalid input in Bmix routine'
        RETURN
      endif
      CC(1,1,2)=(0.92d0+0.0013d0*(T-270.d0))*(CC(1,1,1)**2*CC(2,2,2))     !C(CH-CH-N2)
     &          **onethrd
      CC(1,2,2)=(0.92d0+0.0013d0*(T-270.d0))*(CC(2,2,2)**2*CC(1,1,1))     !C(CH-N2-N2)
     &          **onethrd
      CC(1,1,3)=0.92d0*(CC(1,1,1)**2*CC(3,3,3))**onethrd                  !C(CH-CH-CO2)
      CC(1,3,3)=0.92d0*(CC(3,3,3)**2*CC(1,1,1))**onethrd                  !C(CH-CO2-CO2)
      CC(1,2,3)=1.1d0*(CC(1,1,1)*CC(2,2,2)*CC(3,3,3))**onethrd            !C(CH-N2-CO2)

c  Calculate Bmix and Cmix
      do i=1,3
        do j=i,3
          If (i.eq.j) Then
            B=B+BB(i,i)*xGrs(i)**2
          Else
            B=B+2.d0*BB(i,j)*xGrs(i)*xGrs(j)
          End If
          do k=j,3
            If (i.eq.j .and. j.eq.k) Then
              C=C+CC(i,i,i)*xGrs(i)**3
            ElseIf (i.ne.j .and. j.ne.k .and. i.ne.k) Then
              C=C+6.d0*CC(i,j,k)*xGrs(i)*xGrs(j)*xGrs(k)
            Else
              C=C+3.d0*CC(i,j,k)*xGrs(i)*xGrs(j)*xGrs(k)
            End If
          enddo
        enddo
      enddo
      END

c-----------------------------------------------------------------------

      SUBROUTINE GrossMethod1(Th,Td,Pd,xGrs,Gr,Hv,Mm,HCH,HN,ierr,herr)

c  Initialize variables required in the GROSS equation with Method 1 of the AGA 8 Part 1 publication.
c  Method 1 requires inputs of volumetric gross heating value, relative density, and mole fraction of CO2.
c
c  Inputs:
c    Th - Reference temperature for heating value (K)
c    Td - Reference temperature for density (K)
c    Pd - Reference pressure for density (kPa)
c  xGrs - Array of size 3 with the molar composition of CO2 in the 3rd position.  xCH and xN2 are returned in this array.
c    Gr - Relative density at Td and Pd
c    Hv - Volumetric ideal gross heating value (MJ/m^3) at Th
c
c  Outputs:
c  xGrs - Compositions of the equivalent hydrocarbon, nitrogen, and CO2 (mole fractions)
c    Mm - Molar mass (g/mol)
c   HCH - Molar ideal gross heating value of the equivalent hydrocarbon (kJ/mol) at 298.15 K
c    HN - Molar ideal gross heating value of the mixture (kJ/mol) at 298.15 K
c  ierr - Error number (0 indicates no error)
c  herr - Error message if ierr is not equal to zero

      include 'GROSS.CMN'
      integer ierr,it
      double precision Th,Td,Pd,xGrs(3),Gr,Hv,Mm,HCH,HN
      double precision xCH,xN2,xCO2,Zd,Zold,G1,G2,Bref,Zref,B,C
      character*255 herr

      ierr=0
      herr=' '
      If (Gr.lt.Epsilon) Then
        ierr=1
        herr='Invalid input for relative density'
        RETURN
      endif
      If (Hv.lt.Epsilon) Then
        ierr=2
        herr='Invalid input for heating value'
        RETURN
      endif

      xCO2=xGrs(3)
      Zd=1.d0
      G1=-2.709328d0
      G2=0.021062199d0
      Bref=-0.12527d0+0.000591d0*Td-0.000000662d0*Td**2         !dm^3/mol
      Zref=(1.d0+Pd/RGross/Td*Bref)
      Do it=1,20
        Zold=Zd
        HN=Zd*RGross*Td/Pd*Hv*(1.d0+0.0001027d0*(Th-298.15d0))  !kJ/mol at 25 C
        Mm=Gr*Zd*28.9625d0/Zref                                 !g/mol
        xCH=(Mm+(xCO2-1.d0)*mN2-xCO2*mCO2-G2*HN)/(G1-mN2)
        xN2=1.d0-xCH-xCO2
        If (xN2.lt.0.d0) Then
          ierr=3
          herr='Negative nitrogen value in GROSS method 1 setup'
          RETURN
        endif
        HCH=HN/xCH
        xGrs(1)=xCH
        xGrs(2)=xN2
        Call Bmix(Td,xGrs,HCH,B,C,ierr,herr)
        If (ierr.gt.0) RETURN
        Zd=1.d0+B*Pd/RGross/Td
        if (Abs(Zold-Zd).lt.0.00000000001d0) Exit
      Enddo
      END

c-----------------------------------------------------------------------

      SUBROUTINE GrossMethod2(Th,Td,Pd,xGrs,Gr,Hv,Mm,HCH,HN,ierr,herr)

c  Initialize variables required in the GROSS equation with Method 2 of the AGA 8 Part 1 publication.
c  Method 2 requires inputs of relative density and mole fractions of nitrogen and CO2.
c
c  Inputs:
c    Th - Reference temperature for heating value (K)
c    Td - Reference temperature for density (K)
c    Pd - Reference pressure for density (kPa)
c  xGrs - Array of size 3 with the molar composition of N2 in the 2nd position and CO2 in the 3rd position.  xCH is returned in this array.
c    Gr - Relative density at Td and Pd
c
c  Outputs:
c  xGrs - Compositions of the equivalent hydrocarbon, nitrogen, and CO2 (mole fractions)
c    Mm - Molar mass (g/mol)
c    Hv - Volumetric ideal gross heating value (MJ/m^3) at Th
c   HCH - Molar ideal gross heating value of the equivalent hydrocarbon (kJ/mol) at 298.15 K
c    HN - Molar ideal gross heating value of the mixture (kJ/mol) at 298.15 K
c  ierr - Error number (0 indicates no error)
c  herr - Error message if ierr is not equal to zero

      include 'GROSS.CMN'
      integer ierr,it
      double precision Th,Td,Pd,xGrs(3),Gr,Hv,Mm,HCH,HN
      double precision xCH,Z,Zold,Bref,Zref,MrCH,G1,G2,B,C,xN2,xCO2
      character*255 herr

      ierr=0
      herr=' '
      If (Gr.lt.Epsilon) Then
        ierr=1
        herr='Invalid input for relative density'
        RETURN
      endif

      xN2=xGrs(2)
      xCO2=xGrs(3)
      xCH=1.d0-xN2-xCO2
      xGrs(1)=xCH
      Z=1.d0
      G1=-2.709328d0
      G2=0.021062199d0
      Bref=-0.12527d0+0.000591d0*Td-0.000000662d0*Td**2
      Zref=(1.d0+Pd/RGross/Td*Bref)
      Do it=1,20
        Zold=Z
        Mm=Gr*Z*28.9625d0/Zref
        MrCH=(Mm-xN2*mN2-xCO2*mCO2)/xCH
        HCH=(MrCH-G1)/G2
        Call Bmix(Td,xGrs,HCH,B,C,ierr,herr)
        If (ierr.gt.0) RETURN
        Z=1.d0+B*Pd/RGross/Td
        if (Abs(Zold-Z).lt.0.00000000001d0) Exit
      Enddo
      HN=HCH*xCH
      Hv=HN/Z/RGross/Td*Pd/(1.d0+0.0001027d0*(Th-298.15d0))
      END

c-----------------------------------------------------------------------

      BLOCK DATA GrossConstants
      include 'GROSS.CMN'

      data RGross /8.31451d0/

c  Molar masses (g/mol).  These are the same as those in the DETAIL method.
      data MMiGross/
     &  16.043d0,28.0135d0,44.01d0,30.07d0,44.097d0,58.123d0,58.123d0,
     &  72.15d0,72.15d0,86.177d0,100.204d0,114.231d0,128.258d0,
     &  142.285d0,2.0159d0,31.9988d0,28.01d0,18.0153d0,34.082d0,
     &  4.0026d0,39.948d0/

c  Initialize constants
      data b0(2,2) /-0.1446d0/
      data b1(2,2) / 0.00074091d0/
      data b2(2,2) /-0.00000091195d0/
      data b0(2,3) /-0.339693d0/
      data b1(2,3) / 0.00161176d0/
      data b2(2,3) /-0.00000204429d0/
      data b0(3,3) /-0.86834d0/
      data b1(3,3) / 0.0040376d0/
      data b2(3,3) /-0.0000051657d0/
      data c0(2,2,2) / 0.0078498d0/
      data c1(2,2,2) /-0.000039895d0/
      data c2(2,2,2) / 0.000000061187d0/
      data c0(2,2,3) / 0.00552066d0/
      data c1(2,2,3) /-0.0000168609d0/
      data c2(2,2,3) / 0.0000000157169d0/
      data c0(2,3,3) / 0.00358783d0/
      data c1(2,3,3) / 0.00000806674d0/
      data c2(2,3,3) /-0.0000000325798d0/
      data c0(3,3,3) / 0.0020513d0/
      data c1(3,3,3) / 0.000034888d0/
      data c2(3,3,3) /-0.000000083703d0/
      data bCHx(0,0) /-0.425468d0/
      data bCHx(1,0) / 0.002865d0/
      data bCHx(2,0) /-0.00000462073d0/
      data bCHx(0,1) / 0.000877118d0/
      data bCHx(1,1) /-0.00000556281d0/
      data bCHx(2,1) / 0.0000000088151d0/
      data bCHx(0,2) /-0.000000824747d0/
      data bCHx(1,2) / 0.00000000431436d0/
      data bCHx(2,2) /-6.08319d-12/
      data cCHx(0,0) /-0.302488d0/
      data cCHx(1,0) / 0.00195861d0/
      data cCHx(2,0) /-0.00000316302d0/
      data cCHx(0,1) / 0.000646422d0/
      data cCHx(1,1) /-0.00000422876d0/
      data cCHx(2,1) / 0.00000000688157d0/
      data cCHx(0,2) /-0.000000332805d0/
      data cCHx(1,2) / 0.0000000022316d0/
      data cCHx(2,2) /-3.67713d-12/

c  Heating values from AGA-5, 2009 at 25 C (kJ/mol)
      data xHN/
     &  890.63d0,0.d0,0.d0,1560.69d0,2219.17d0,2868.2d0,2877.4d0,
     &  3528.83d0,3535.77d0,4194.95d0,4853.43d0,5511.8d0,6171.15d0,
     &  6829.77d0,285.83d0,0.d0,282.98d0,44.016d0,562.01d0,0.d0,0.d0/

      data mN2  /28.0135d0/
      data mCO2 /44.01d0/

      END
