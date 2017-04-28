c  Example program for calling routines for the GERG-2008 equation of state.

      subroutine ExampleGerg
      implicit none
      integer ierr
      double precision x(21),Mm,T,P,D,pp
      double precision Z,dPdD,d2PdD2,d2PdTD,dPdT,U,H,S,Cv,Cp,W,G,JT,K
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
      T=400
      P=50000

      write (*,*) 'Inputs-----'
      write (*,*) 'Temperature [K]:                   ',SNGL(T)
      write (*,*) 'Pressure [kPa]:                    ',SNGL(P)

      write (*,*) 'Outputs-----'

c  Get molar mass.
      Call MolarMassGERG(x,Mm)
      write (*,*) 'Molar mass [g/mol]:                ',SNGL(mm)

c  Get molar density at T and P.
      Call DensityGERG(0,T,P,x,D,ierr,herr)
      write (*,*) 'Error number:                      ',ierr
      write (*,*) 'Molar density [mol/l]:             ',SNGL(D)

c  Get pressure from T and D.
      Call PressureGERG(T,D,x,pp,z)
      write (*,*) 'Pressure [kPa]:                    ',SNGL(pp)

c  Get all other properties at T and D.
c  For T and P inputs, the DensityGERG routine must be called first to get D.
      Call PropertiesGERG(T,D,x,pp,Z,dPdD,d2PdD2,d2PdTD,dPdT,
     &                      U,H,S,Cv,Cp,W,G,JT,K)
      write (*,*) 'Compressibility factor:            ',SNGL(Z)
      write (*,*) 'd(P)/d(rho) [kPa/(mol/l)]:         ',SNGL(dPdD)
      write (*,*) 'd^2(P)/d(rho)^2 [kPa/(mol/l)^2]:   ',SNGL(d2PdD2)
      write (*,*) 'd(P)/d(T) [kPa/K]:                 ',SNGL(dPdT)
      write (*,*) 'Energy [J/mol]:                    ',SNGL(U)
      write (*,*) 'Enthalpy [J/mol]:                  ',SNGL(H)
      write (*,*) 'Entropy [J/mol-K]:                 ',SNGL(S)
      write (*,*) 'Isochoric heat capacity [J/mol-K]: ',SNGL(Cv)
      write (*,*) 'Isobaric heat capacity [J/mol-K]:  ',SNGL(Cp)
      write (*,*) 'Speed of sound [m/s]:              ',SNGL(W)
      write (*,*) 'Gibbs energy [J/mol]:              ',SNGL(G)
      write (*,*) 'Joule-Thomson coefficient [K/kPa]: ',SNGL(JT)
      write (*,*) 'Isentropic exponent:               ',SNGL(K)

      pause
      end

c-----------------------------------------------------------------------
c  Version 2.0 of routines for the calculation of thermodynamic
c   properties from the AGA 8 Part 2 GERG-2008 equation of state.
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
c  The GERG-2008 equation of state was developed by Oliver Kunz and Wolfgang Wagner:
c
c  Kunz, O. and Wagner, W.
c  The GERG-2008 Wide-Range Equation of State for Natural Gases and Other Mixtures:
c  An Expansion of GERG-2004
c  J. Chem. Eng. Data, 57(11):3032-3091, 2012.
c
c  Kunz, O., Klimeck, R., Wagner, W., and Jaeschke, M.
c  The GERG-2004 Wide-Range Equation of State for Natural Gases and Other Mixtures
c  GERG Technical Monograph 15
c  Fortschr.-Ber. VDI, Reihe 6, Nr. 557, VDI Verlag, Düsseldorf, 2007.
c  http://www.gerg.eu/public/uploads/files/publications/technical_monographs/tm15_04.pdf
c
c  Subroutines contained here for property calculations:
c  ***** Subroutine SetupGERG must be called once before calling other routines. ******
c  Sub MolarMassGERG(x, Mm)
c  Sub PressureGERG(T, D, x, P, Z)
c  Sub DensityGERG(iFlag, T, P, x, D, ierr, herr)
c  Sub PropertiesGERG(T, D, x, P, Z, dPdD, d2PdD2, d2PdTD, dPdT, U, H, S, Cv, Cp, W, G, JT, Kappa)
c  Sub SetupGERG()
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

      SUBROUTINE MolarMassGERG(x,Mm)

c  Calculate molar mass of the mixture with the compositions contained in the x() input array
c
c  Inputs:
c     x() - Composition (mole fraction)
c         Do not send mole percents or mass fractions in the x() array, otherwise the output will be incorrect.
c         The sum of the compositions in the x() array must be equal to one.
c         The order of the fluids in this array is given at the top of this code.
c
c  Outputs:
c      Mm - molar mass (g/mol)

      include 'GERG2008.CMN'
      double precision x(MaxFlds),Mm

      If (kpol(1).ne.6) Call SetupGERG
      Mm=SUM(x(1:NcGERG)*MMiGERG(1:NcGERG))
      END

c-----------------------------------------------------------------------

      SUBROUTINE PressureGERG(T,D,x,P,Z)

c  Calculate pressure as a function of temperature and density.  The derivative d(P)/d(D) is also calculated
c  for use in the iterative DensityGERG subroutine (and is only returned as a common variable).
c
c  Inputs:
c       T - Temperature (K)
c       D - Density (mol/l)
c     x() - Composition (mole fraction)
c         Do not send mole percents or mass fractions in the x() array, otherwise the output will be incorrect.
c         The sum of the compositions in the x() array must be equal to one.
c
c  Outputs:
c       P - Pressure (kPa)
c       Z - Compressibility factor
c   dPdDsave - d(P)/d(D) [kPa/(mol/l)] (at constant temperature)

      include 'GERG2008.CMN'
      double precision x(MaxFlds),T,D,P,Z,ar(0:3,0:3)

      If (kpol(1).ne.6) Call SetupGERG

      Call AlpharGERG(0,T,D,x,ar)
      Z=1.d0+ar(0,1)
      P=D*RGERG*T*Z
      dPdDsave=RGERG*T*(1.d0+2.d0*ar(0,1)+ar(0,2))
      END

c-----------------------------------------------------------------------

      SUBROUTINE DensityGERG(iFlag,T,P,x,D,ierr,herr)

c  Calculate density as a function of temperature and pressure.  This is an iterative routine that calls PressureGERG
c  to find the correct state point.  Generally only 6 iterations at most are required.
c  If the iteration fails to converge, the ideal gas density and an error message are returned.
c  No checks are made to determine the phase boundary, which would have guaranteed that the output is in the gas phase (or liquid phase when iFlag=2).
c  It is up to the user to locate the phase boundary, and thus identify the phase of the T and P inputs.
c  If the state point is 2-phase, the output density will represent a metastable state.
c
c  Inputs:
c   iFlag - Set to 0 for strict pressure solver in the gas phase without checks (fastest mode, but output state may not be stable single phase)
c           Set to 1 to make checks for possible 2-phase states (result may still not be stable single phase, but many unstable states will be identified)
c           Set to 2 to search for liquid phase (and make the same checks when iFlag=1)
c       T - Temperature (K)
c       P - Pressure (kPa)
c     x() - Composition (mole fraction)
c  (An initial guess for the density can be sent in D as the negative of the guess for roots that are in the liquid phase instead of using iFlag=2)
c
c  Outputs:
c       D - Density (mol/l)
c    ierr - Error number (0 indicates no error)
c    herr - Error message if ierr is not equal to zero

      include 'GERG2008.CMN'
      integer iFlag,it,ierr,nFail,iFail
      double precision x(MaxFlds)
      double precision plog,vlog,vinc,p2,Z,dpdlv,vdiff,tolr,T,P,D,PP
      double precision Tcx,Dcx
      double precision dPdD,d2PdD2,d2PdTD,dPdT,U,H,S,Cv,Cp,W,G,JT,K
      character*255 herr

      If (kpol(1).ne.6) Call SetupGERG
      ierr=0
      herr=' '
      nFail=0
      iFail=0
      If (P.lt.Epsilon) Then
        D=0.d0
        RETURN
      endif
      tolr=1.d-7
      Call PseudoCriticalPointGERG(x,Tcx,Dcx)
      If (D.gt.-Epsilon) Then
        D=P/RGERG/T                !Ideal gas estimate for vapor phase
        If (iFlag.eq.2) D=Dcx*3.d0 !Initial estimate for liquid phase
      Else
        D=Abs(D)                   !If D<0, then use as initial estimate
      End If
      plog=Log(P)
      vlog=-Log(D)
      Do it=1,50
        If (vlog.lt.-7 .or. vlog.gt.100 .or. it.eq.20 .or. it.eq.30
     &                 .or. it.eq.40 .or. iFail.eq.1) Then
          !Current state is bad or iteration is taking too long.  Restart with completely different initial state
          iFail=0
          If (nFail.gt.2) GoTo 10
          nFail=nFail+1
          If (nFail.eq.1) Then
            D=Dcx*3.d0    !If vapor phase search fails, look for root in liquid region
          ElseIf (nFail.eq.2) Then
            D=Dcx*2.5d0   !If liquid phase search fails, look for root between liquid and critical regions
          ElseIf (nFail.eq.3) Then
            D=Dcx*2.d0    !If search fails,look for root in critical region
          End If
          vlog=-Log(D)
        End If
        D=Exp(-vlog)
        Call PressureGERG(T,D,x,P2,Z)
        If (dPdDsave.lt.Epsilon .or. P2.lt.Epsilon) Then
          !Current state is 2-phase, try locating a different state that is single phase
          vinc=0.1d0
          If (D.gt.Dcx) vinc=-0.1d0
          If (it.gt.5) vinc=vinc/2.d0
          If (it.gt.10 .and. it.lt.20) vinc=vinc/5.d0
          vlog=vlog+vinc
        Else
c  Find the next density with a first order Newton's type iterative scheme, with
c  log(P) as the known variable and log(v) as the unknown property.
c  See AGA 8 publication for further information.
          dpdlv=-D*dPdDsave     !d(p)/d[log(v)]
          vdiff=(Log(P2)-plog)*P2/dpdlv
          vlog=vlog-vdiff
          If (Abs(vdiff).lt.tolr) Then
            !Check to see if state is possibly 2-phase, and if so restart
            If (dPdDsave.lt.0.d0) Then
              iFail=1
            Else
              D=Exp(-vlog)
              Goto 20            !Iteration converged
            End If
          End If
        End If
      Enddo

c  Iteration failed (above loop did not find a solution or checks made below indicate possible 2-phase state)
 10   Continue
      ierr=1
      herr=    'Calculation failed to converge in GERG method, ideal gas
     & density returned.'
      D=P/RGERG/T
      RETURN

c  Iteration converged
 20   Continue
      !If requested, check to see if point is possibly 2-phase
      If (iFlag.gt.0) Then
        Call PropertiesGERG(T,D,x,PP,Z,dPdD,d2PdD2,d2PdTD,dPdT,U,H,S,
     &   Cv,Cp,W,G,JT,K)
        If (PP.le.0.d0 .or. dPdD.le.0.d0 .or. d2PdTD.le.0.d0) goto 10
        If (Cv.le.0.d0 .or. Cp.le.0.d0 .or. W.le.0.d0) goto 10
      End If
      END

c-----------------------------------------------------------------------

      SUBROUTINE PropertiesGERG(T,D,x,P,Z,dPdD,d2PdD2,d2PdTD,dPdT,U,H,S,
     &                          Cv,Cp,W,G,JT,Kappa)

c  Calculate thermodynamic properties as a function of temperature and density.
c  If the density is not known, call subroutine DensityGERG first with the known values of pressure and temperature.
c  Many of the formulas below do not appear in Part 2 of AGA 8, but rather in Part 1, which uses a dimensional Helmholtz equation with more direct formulas for quick calculation.
c
c  Inputs:
c       T - Temperature (K)
c       D - Density (mol/l)
c     x() - Composition (mole fraction)
c
c  Outputs:
c       P - Pressure (kPa)
c       Z - Compressibility factor
c    dPdD - First derivative of pressure with respect to density [kPa/(mol/l)] at constant temperature
c  d2PdD2 - Second derivative of pressure with respect to density [kPa/(mol/l)^2] at constant temperature
c  d2PdTD - Second derivative of pressure with respect to temperature and density [kPa/(mol/l)/K]
c    dPdT - First derivative of pressure with respect to temperature (kPa/K) at constant density
c       U - Internal energy (J/mol)
c       H - Enthalpy (J/mol)
c       S - Entropy [J/(mol-K)]
c      Cv - Isochoric heat capacity [J/(mol-K)]
c      Cp - Isobaric heat capacity [J/(mol-K)]
c       W - Speed of sound (m/s)
c       G - Gibbs energy (J/mol)
c      JT - Joule-Thomson coefficient (K/kPa)
c   Kappa - Isentropic Exponent
c       A - Helmholtz energy (J/mol)

      include 'GERG2008.CMN'
      double precision T,D,P,Z
      double precision dPdD,d2PdD2,d2PdTD,dPdT,A,U,H,S,Cv,Cp,W,G,JT
      double precision x(MaxFlds),a0(0:2),ar(0:3,0:3),Mm,R,RT,Kappa

      If (kpol(1).ne.6) Call SetupGERG

c  Calculate molar mass
      Call MolarMassGERG(x,Mm)

c  Calculate the ideal gas Helmholtz energy, and its first and second derivatives with respect to temperature.
      Call Alpha0GERG(T,D,x,a0)

c  Calculate the real gas Helmholtz energy, and its derivatives with respect to temperature and/or density.
      Call AlpharGERG(1,T,D,x,ar)

      R=RGERG
      RT=R*T
      Z=1.d0+ar(0,1)
      P=D*RT*Z
      dPdD=RT*(1.d0+2.d0*ar(0,1)+ar(0,2))
      dPdT=D*R*(1.d0+ar(0,1)-ar(1,1))
      d2PdTD=R*(1.d0+2.d0*ar(0,1)+ar(0,2)-2.d0*ar(1,1)-ar(1,2))
      A=RT*(a0(0)+ar(0,0))
      G=RT*(1.d0+ar(0,1)+a0(0)+ar(0,0))
      U=RT*(a0(1)+ar(1,0))
      H=RT*(1.d0+ar(0,1)+a0(1)+ar(1,0))
      S=R*(a0(1)+ar(1,0)-a0(0)-ar(0,0))
      Cv=-R*(a0(2)+ar(2,0))
      If (D.gt.Epsilon) Then
        Cp=Cv+T*(dPdT/D)**2/dPdD
        d2PdD2=RT*(2.d0*ar(0,1)+4.d0*ar(0,2)+ar(0,3))/D
        JT=(T/D*dPdT/dPdD-1.d0)/Cp/D    !=(dB/dT*T-B)/Cp for an ideal gas, but dB/dT is not known
      Else
        Cp=Cv+R
        d2PdD2=0.d0
        JT=1d+20
      End If
      W=1000.d0*Cp/Cv*dPdD/Mm
      If (W.lt.0.d0) W=0.d0
      W=Sqrt(W)
      Kappa=W**2*Mm/(RT*1000.d0*Z)
      END

c-----------------------------------------------------------------------

c  The following routines are low-level routines that should not be called outside of this code.

c-----------------------------------------------------------------------

      SUBROUTINE ReducingParametersGERG(x,Tr,Dr)

c  Calculate reducing variables.  Only need to call this if the composition has changed.
c
c  Inputs:
c     x() - Composition (mole fraction)
c
c  Outputs:
c      Tr - Reducing temperature (K)
c      Dr - Reducing density (mol/l)

      include 'GERG2008.CMN'
      integer i,j,iCheck
      double precision x(MaxFlds),Tr,Dr,Vr,xij,F

c  Check to see if a component fraction has changed.  If x is the same as the previous call, then exit.
      iCheck=0
      Do i=1,NcGERG
        If (Abs(x(i)-xold(i)).gt.1.d-7) iCheck=1
        xold(i)=x(i)
      Enddo
      If (iCheck.eq.0) Then
        Dr=Drold
        Tr=Trold
        RETURN
      End If
      Told=0.d0
      Trold2=0.d0

c  Calculate reducing variables for T and D
      Dr=0.d0
      Vr=0.d0
      Tr=0.d0
      Do i=1,NcGERG
        If (x(i).gt.Epsilon) Then
          F=1.d0
          Do j=i,NcGERG
            If (x(j).gt.Epsilon) Then
              xij=F*(x(i)*x(j))*(x(i)+x(j))
              Vr=Vr+xij*gvij(i,j)/(bvij(i,j)*x(i)+x(j))
              Tr=Tr+xij*gtij(i,j)/(btij(i,j)*x(i)+x(j))
              F=2.d0
            End If
          Enddo
        End If
      Enddo
      If (Vr.gt.Epsilon) Dr=1.d0/Vr
      Drold=Dr
      Trold=Tr
      END

c-----------------------------------------------------------------------

      SUBROUTINE Alpha0GERG(T,D,x,a0)

c  Calculate the ideal gas Helmholtz energy and its derivatives with respect to tau and delta.
c  This routine is not needed when only P (or Z) is calculated.
c
c  Inputs:
c       T - Temperature (K)
c       D - Density (mol/l)
c     x() - Composition (mole fraction)
c
c  Outputs:
c   a0(0) - Ideal gas Helmholtz energy (dimensionless [i.e., divided by RT])
c   a0(1) - tau*partial(a0)/partial(tau)
c   a0(2) - tau^2*partial^2(a0)/partial(tau)^2

      include 'GERG2008.CMN'
      integer i,j
      double precision T,D,x(MaxFlds),a0(0:2)
      double precision LogT,LogD,LogHyp,th0T,LogxD
      double precision SumHyp0,SumHyp1,SumHyp2
      double precision em,ep,hcn,hsn

      a0=0.d0
      If (D.gt.Epsilon) Then
        LogD=Log(D)
      Else
        LogD=Log(Epsilon)
      End If
      LogT=Log(T)
      Do i=1,NcGERG
        If (x(i).gt.Epsilon) Then
          LogxD=LogD+Log(x(i))
          SumHyp0=0.d0
          SumHyp1=0.d0
          SumHyp2=0.d0
          Do j=4,7
            If (th0i(i,j).gt.Epsilon) Then
              th0T=th0i(i,j)/T
              ep=Exp(th0T)
              em=1.d0/ep
              hsn=(ep-em)/2.d0
              hcn=(ep+em)/2.d0
              If (j.eq.4 .or. j.eq.6) Then
                LogHyp=Log(Abs(hsn))
                SumHyp0=SumHyp0+n0i(i,j)*LogHyp
                SumHyp1=SumHyp1+n0i(i,j)*th0T*hcn/hsn
                SumHyp2=SumHyp2+n0i(i,j)*(th0T/hsn)**2
              Else
                LogHyp=Log(Abs(hcn))
                SumHyp0=SumHyp0-n0i(i,j)*LogHyp
                SumHyp1=SumHyp1-n0i(i,j)*th0T*hsn/hcn
                SumHyp2=SumHyp2+n0i(i,j)*(th0T/hcn)**2
              End If
            End If
          Enddo
          a0(0)=a0(0)
     &         +x(i)*(LogxD+n0i(i,1)+n0i(i,2)/T-n0i(i,3)*LogT+SumHyp0)
          a0(1)=a0(1)+x(i)*(n0i(i,3)+n0i(i,2)/T+SumHyp1)
          a0(2)=a0(2)-x(i)*(n0i(i,3)+SumHyp2)
        End If
      Enddo
      END

c-----------------------------------------------------------------------

      SUBROUTINE AlpharGERG(iprop,T,D,x,ar)

c  Calculate dimensionless residual Helmholtz energy and its derivatives with respect to tau and delta.
c
c  Inputs:
c   iprop - Set to 1 to return all derivatives or 0 to return only pressure related properties [ar(0,1) and ar(0,2)]
c       T - Temperature (K)
c       D - Density (mol/l)
c     x() - Composition (mole fraction)
c
c  Outputs:
c   ar(0,0) - Residual Helmholtz energy (dimensionless, =a/RT)
c   ar(0,1) -     del*partial  (ar)/partial(del)
c   ar(0,2) -   del^2*partial^2(ar)/partial(del)^2
c   ar(0,3) -   del^3*partial^3(ar)/partial(del)^3
c   ar(1,0) -     tau*partial  (ar)/partial(tau)
c   ar(1,1) - tau*del*partial^2(ar)/partial(tau)/partial(del)
c   ar(2,0) -   tau^2*partial^2(ar)/partial(tau)^2

      include 'GERG2008.CMN'
      integer i,j,k,mn,iprop
      double precision T,d,x(MaxFlds),ar(0:3,0:3),Tr,Dr,del,tau
      double precision lntau,ex,ex2,ex3,cij0,eij0
      double precision delp(7),Expd(7),ndt,ndtd,ndtt,xijf
c  Set up del, tau, log(tau), and the first 7 calculations for del^i
      ar=0.d0
      Call ReducingParametersGERG(x,Tr,Dr)
      del=D/Dr
      tau=Tr/T
      lntau=Log(tau)
      delp(1)=del
      Expd(1)=Exp(-delp(1))
      Do i=2,7
        delp(i)=delp(i-1)*del
        Expd(i)=Exp(-delp(i))
      Enddo

c  If temperature has changed, calculate temperature dependent parts
      If (Abs(T-Told).gt.1.d-7 .or .Abs(Tr-Trold2).gt.1.d-7)
     &    Call tTermsGERG(lntau,x)
      Told=T
      Trold2=Tr

c  Calculate pure fluid contributions
      Do i=1,NcGERG
        If (x(i).gt.Epsilon) Then
          Do k=1,kpol(i)
            ndt=x(i)*delp(int(doik(i,k)))*taup(i,k)
            ndtd=ndt*doik(i,k)
            ar(0,1)=ar(0,1)+ndtd
            ar(0,2)=ar(0,2)+ndtd*(doik(i,k)-1.d0)
            If (iprop.gt.0) Then
              ndtt=ndt*toik(i,k)
              ar(0,0)=ar(0,0)+ndt
              ar(1,0)=ar(1,0)+ndtt
              ar(2,0)=ar(2,0)+ndtt*(toik(i,k)-1.d0)
              ar(1,1)=ar(1,1)+ndtt*doik(i,k)
              ar(1,2)=ar(1,2)+ndtt*doik(i,k)*(doik(i,k)-1.d0)
              ar(0,3)=ar(0,3)+ndtd*(doik(i,k)-1.d0)*(doik(i,k)-2.d0)
            End If
          Enddo
          Do k=1+kpol(i),kpol(i)+kexp(i)
            ndt=x(i)*delp(int(doik(i,k)))*taup(i,k)*Expd(int(coik(i,k)))
            ex=coik(i,k)*delp(int(coik(i,k)))
            ex2=doik(i,k)-ex
            ex3=ex2*(ex2-1.d0)
            ar(0,1)=ar(0,1)+ndt*ex2
            ar(0,2)=ar(0,2)+ndt*(ex3-coik(i,k)*ex)
            If (iprop.gt.0) Then
              ndtt=ndt*toik(i,k)
              ar(0,0)=ar(0,0)+ndt
              ar(1,0)=ar(1,0)+ndtt
              ar(2,0)=ar(2,0)+ndtt*(toik(i,k)-1.d0)
              ar(1,1)=ar(1,1)+ndtt*ex2
              ar(1,2)=ar(1,2)+ndtt*(ex3-coik(i,k)*ex)
              ar(0,3)=ar(0,3)+ndt*(ex3*(ex2-2.d0)-
     &                ex*(3.d0*ex2-3.d0+coik(i,k))*coik(i,k))
            End If
          Enddo
        End If
      Enddo

c  Calculate mixture contributions
      Do i=1,NcGERG-1
        If (x(i).gt.Epsilon) Then
          Do j=i+1,NcGERG
            If (x(j).gt.Epsilon) Then
              mn=mNumb(i,j)
              If (mn.ge.0) Then
                xijf=x(i)*x(j)*fij(i,j)
                Do k=1,kpolij(mn)
                  ndt=xijf*delp(int(dijk(mn,k)))*taupijk(mn,k)
                  ndtd=ndt*dijk(mn,k)
                  ar(0,1)=ar(0,1)+ndtd
                  ar(0,2)=ar(0,2)+ndtd*(dijk(mn,k)-1.d0)
                  If (iprop.gt.0) Then
                    ndtt=ndt*tijk(mn,k)
                    ar(0,0)=ar(0,0)+ndt
                    ar(1,0)=ar(1,0)+ndtt
                    ar(2,0)=ar(2,0)+ndtt*(tijk(mn,k)-1.d0)
                    ar(1,1)=ar(1,1)+ndtt*dijk(mn,k)
                    ar(1,2)=ar(1,2)+ndtt*dijk(mn,k)*(dijk(mn,k)-1.d0)
                    ar(0,3)=ar(0,3)+ndtd*(dijk(mn,k)-1.d0)*
     &                      (dijk(mn,k)-2.d0)
                  End If
                Enddo
                Do k=1+kpolij(mn),kpolij(mn)+kexpij(mn)
                  cij0=cijk(mn,k)*delp(2)
                  eij0=eijk(mn,k)*del
                  ndt=xijf*nijk(mn,k)*delp(int(dijk(mn,k)))*
     &                Exp(cij0+eij0+gijk(mn,k)+tijk(mn,k)*lntau)
                  ex=dijk(mn,k)+2.d0*cij0+eij0
                  ex2=(ex*ex-dijk(mn,k)+2.d0*cij0)
                  ar(0,1)=ar(0,1)+ndt*ex
                  ar(0,2)=ar(0,2)+ndt*ex2
                  If (iprop.gt.0) Then
                    ndtt=ndt*tijk(mn,k)
                    ar(0,0)=ar(0,0)+ndt
                    ar(1,0)=ar(1,0)+ndtt
                    ar(2,0)=ar(2,0)+ndtt*(tijk(mn,k)-1.d0)
                    ar(1,1)=ar(1,1)+ndtt*ex
                    ar(1,2)=ar(1,2)+ndtt*ex2
                    ar(0,3)=ar(0,3)+ndt*(ex*(ex2-2d0*(dijk(mn,k)-
     &                      2.d0*cij0))+2.d0*dijk(mn,k))
                  End If
                Enddo
              End If
            End If
          Enddo
        End If
      Enddo
      END

c-----------------------------------------------------------------------

      SUBROUTINE tTermsGERG(lntau,x)

c  Calculate temperature dependent parts of the GERG-2008 equation of state

      include 'GERG2008.CMN'
      integer i,j,k,mn
      double precision x(MaxFlds),lntau,taup0(12)

      i=5  !Use propane to get exponents for short form of EOS
      Do k=1,kpol(i)+kexp(i)
        taup0(k)=Exp(toik(i,k)*lntau)
      Enddo
      Do i=1,NcGERG
        If (x(i).gt.Epsilon) Then
          If (i.gt.4 .and. i.ne.15. .and. i.ne.18 .and. i.ne.20) then
            Do k=1,kpol(i)+kexp(i)
              taup(i,k)=noik(i,k)*taup0(k)
            Enddo
          Else
            Do k=1,kpol(i)+kexp(i)
              taup(i,k)=noik(i,k)*Exp(toik(i,k)*lntau)
            Enddo
          End If
        End If
      Enddo

      Do i=1,NcGERG-1
        If (x(i).gt.Epsilon) Then
          Do j=i+1,NcGERG
            If (x(j).gt.Epsilon) Then
              mn=mNumb(i,j)
              If (mn.ge.0) Then
                Do k=1,kpolij(mn)
                  taupijk(mn,k)=nijk(mn,k)*Exp(tijk(mn,k)*lntau)
                Enddo
              End If
            End If
          Enddo
        End If
      Enddo
      END

c-----------------------------------------------------------------------

      SUBROUTINE PseudoCriticalPointGERG(x,Tcx,Dcx)

c  Calculate a pseudo critical point as the mole fraction average of the critical temperatures and critical volumes

      include 'GERG2008.CMN'
      integer i
      double precision x(MaxFlds),Tcx,Dcx,Vcx
      Tcx=0.d0
      Vcx=0.d0
      Dcx=0.d0
      Do i=1,NcGERG
        Tcx=Tcx+x(i)*Tc(i)
        Vcx=Vcx+x(i)/Dc(i)
      Enddo
      If (Vcx.gt.Epsilon) Dcx=1.d0/Vcx
      END

c-----------------------------------------------------------------------

c  The following routine must be called once before any other routine.

      SUBROUTINE SetupGERG

c  Initialize all the constants and parameters in the GERG-2008 model.
c  Some values are modified for calculations that do not depend on T, D, and x in order to speed up the program.

      include 'GERG2008.CMN'
      integer i,j
      double precision o13,Rs,Rsr,bijk(MaxMdl,MaxTrmM)
      double precision n1,n2,T0,d0

      RGERG=8.314472d0
      Rs=8.31451d0
      Rsr=Rs/RGERG
      o13=1.d0/3.d0
      xold=0.d0
      Told=0.d0
      bijk=0.d0

c  Molar masses (g/mol)
      MMiGERG(1)=16.04246d0
      MMiGERG(2)=28.0134d0
      MMiGERG(3)=44.0095d0
      MMiGERG(4)=30.06904d0
      MMiGERG(5)=44.09562d0
      MMiGERG(6)=58.1222d0
      MMiGERG(7)=58.1222d0
      MMiGERG(8)=72.14878d0
      MMiGERG(9)=72.14878d0
      MMiGERG(10)=86.17536d0
      MMiGERG(11)=100.20194d0
      MMiGERG(12)=114.22852d0
      MMiGERG(13)=128.2551d0
      MMiGERG(14)=142.28168d0
      MMiGERG(15)=2.01588d0
      MMiGERG(16)=31.9988d0
      MMiGERG(17)=28.0101d0
      MMiGERG(18)=18.01528d0
      MMiGERG(19)=34.08088d0
      MMiGERG(20)=4.002602d0
      MMiGERG(21)=39.948d0

c  Number of polynomial and exponential terms
      Do i=1,MaxFlds
        kpol(i)=6
        kexp(i)=6
      Enddo
      kexp(1)=18
      kexp(2)=18
      kexp(4)=18
      kpol(3)=4
      kexp(3)=18
      kpol(15)=5
      kexp(15)=9
      kpol(18)=7
      kexp(18)=9
      kpol(20)=4
      kexp(20)=8
      kpolij(1)=2
      kexpij(1)=10
      kpolij(2)=5
      kexpij(2)=4
      kpolij(3)=2
      kexpij(3)=7
      kpolij(4)=3
      kexpij(4)=3
      kpolij(5)=2
      kexpij(5)=4
      kpolij(6)=3
      kexpij(6)=3
      kpolij(7)=4
      kexpij(7)=0
      kpolij(10)=10
      kexpij(10)=0

c  Critical densities (mol/l)
      Dc(1)=10.139342719d0
      Dc(2)=11.1839d0
      Dc(3)=10.624978698d0
      Dc(4)=6.87085454d0
      Dc(5)=5.000043088d0
      Dc(6)=3.86014294d0
      Dc(7)=3.920016792d0
      Dc(8)=3.271d0
      Dc(9)=3.215577588d0
      Dc(10)=2.705877875d0
      Dc(11)=2.315324434d0
      Dc(12)=2.056404127d0
      Dc(13)=1.81d0
      Dc(14)=1.64d0
      Dc(15)=14.94d0
      Dc(16)=13.63d0
      Dc(17)=10.85d0
      Dc(18)=17.87371609d0
      Dc(19)=10.19d0
      Dc(20)=17.399d0
      Dc(21)=13.407429659d0

c  Critical temperatures (K)
      Tc(1)=190.564d0
      Tc(2)=126.192d0
      Tc(3)=304.1282d0
      Tc(4)=305.322d0
      Tc(5)=369.825d0
      Tc(6)=407.817d0
      Tc(7)=425.125d0
      Tc(8)=460.35d0
      Tc(9)=469.7d0
      Tc(10)=507.82d0
      Tc(11)=540.13d0
      Tc(12)=569.32d0
      Tc(13)=594.55d0
      Tc(14)=617.7d0
      Tc(15)=33.19d0
      Tc(16)=154.595d0
      Tc(17)=132.86d0
      Tc(18)=647.096d0
      Tc(19)=373.1d0
      Tc(20)=5.1953d0
      Tc(21)=150.687d0


c  Exponents in pure fluid equations
      Do i=1,MaxFlds
        Vc3(i)=1/Dc(i)**o13/2
        Tc2(i)=Sqrt(Tc(i))
        coik(i,1)=0
        doik(i,1)=1
        toik(i,1)=0.25d0
        coik(i,2)=0
        doik(i,2)=1
        toik(i,2)=1.125d0
        coik(i,3)=0
        doik(i,3)=1
        toik(i,3)=1.5d0
        coik(i,4)=0
        doik(i,4)=2
        toik(i,4)=1.375d0
        coik(i,5)=0
        doik(i,5)=3
        toik(i,5)=0.25d0
        coik(i,6)=0
        doik(i,6)=7
        toik(i,6)=0.875d0
        coik(i,7)=1
        doik(i,7)=2
        toik(i,7)=0.625d0
        coik(i,8)=1
        doik(i,8)=5
        toik(i,8)=1.75d0
        coik(i,9)=2
        doik(i,9)=1
        toik(i,9)=3.625d0
        coik(i,10)=2
        doik(i,10)=4
        toik(i,10)=3.625d0
        coik(i,11)=3
        doik(i,11)=3
        toik(i,11)=14.5d0
        coik(i,12)=3
        doik(i,12)=4
        toik(i,12)=12
      Enddo
      Do i=1,4
        If (i.ne.3) Then
          coik(i,1)=0
          doik(i,1)=1
          toik(i,1)=0.125d0
          coik(i,2)=0
          doik(i,2)=1
          toik(i,2)=1.125d0
          coik(i,3)=0
          doik(i,3)=2
          toik(i,3)=0.375d0
          coik(i,4)=0
          doik(i,4)=2
          toik(i,4)=1.125d0
          coik(i,5)=0
          doik(i,5)=4
          toik(i,5)=0.625d0
          coik(i,6)=0
          doik(i,6)=4
          toik(i,6)=1.5d0
          coik(i,7)=1
          doik(i,7)=1
          toik(i,7)=0.625d0
          coik(i,8)=1
          doik(i,8)=1
          toik(i,8)=2.625d0
          coik(i,9)=1
          doik(i,9)=1
          toik(i,9)=2.75d0
          coik(i,10)=1
          doik(i,10)=2
          toik(i,10)=2.125d0
          coik(i,11)=1
          doik(i,11)=3
          toik(i,11)=2
          coik(i,12)=1
          doik(i,12)=6
          toik(i,12)=1.75d0
          coik(i,13)=2
          doik(i,13)=2
          toik(i,13)=4.5d0
          coik(i,14)=2
          doik(i,14)=3
          toik(i,14)=4.75d0
          coik(i,15)=2
          doik(i,15)=3
          toik(i,15)=5
          coik(i,16)=2
          doik(i,16)=4
          toik(i,16)=4
          coik(i,17)=2
          doik(i,17)=4
          toik(i,17)=4.5d0
          coik(i,18)=3
          doik(i,18)=2
          toik(i,18)=7.5d0
          coik(i,19)=3
          doik(i,19)=3
          toik(i,19)=14
          coik(i,20)=3
          doik(i,20)=4
          toik(i,20)=11.5d0
          coik(i,21)=6
          doik(i,21)=5
          toik(i,21)=26
          coik(i,22)=6
          doik(i,22)=6
          toik(i,22)=28
          coik(i,23)=6
          doik(i,23)=6
          toik(i,23)=30
          coik(i,24)=6
          doik(i,24)=7
          toik(i,24)=16
        End If
      Enddo

c  Coefficients of pure fluid equations
c  Methane
      noik(1,1)=0.57335704239162d0
      noik(1,2)=-1.676068752373d0
      noik(1,3)=0.23405291834916d0
      noik(1,4)=-0.21947376343441d0
      noik(1,5)=0.016369201404128d0
      noik(1,6)=0.01500440638928d0
      noik(1,7)=0.098990489492918d0
      noik(1,8)=0.58382770929055d0
      noik(1,9)=-0.7478686756039d0
      noik(1,10)=0.30033302857974d0
      noik(1,11)=0.20985543806568d0
      noik(1,12)=-0.018590151133061d0
      noik(1,13)=-0.15782558339049d0
      noik(1,14)=0.12716735220791d0
      noik(1,15)=-0.032019743894346d0
      noik(1,16)=-0.068049729364536d0
      noik(1,17)=0.024291412853736d0
      noik(1,18)=5.1440451639444d-03
      noik(1,19)=-0.019084949733532d0
      noik(1,20)=5.5229677241291d-03
      noik(1,21)=-4.4197392976085d-03
      noik(1,22)=0.040061416708429d0
      noik(1,23)=-0.033752085907575d0
      noik(1,24)=-2.5127658213357d-03
c  Nitrogen
      noik(2,1)=0.59889711801201d0
      noik(2,2)=-1.6941557480731d0
      noik(2,3)=0.24579736191718d0
      noik(2,4)=-0.23722456755175d0
      noik(2,5)=0.017954918715141d0
      noik(2,6)=0.014592875720215d0
      noik(2,7)=0.10008065936206d0
      noik(2,8)=0.73157115385532d0
      noik(2,9)=-0.88372272336366d0
      noik(2,10)=0.31887660246708d0
      noik(2,11)=0.20766491728799d0
      noik(2,12)=-0.019379315454158d0
      noik(2,13)=-0.16936641554983d0
      noik(2,14)=0.13546846041701d0
      noik(2,15)=-0.033066712095307d0
      noik(2,16)=-0.060690817018557d0
      noik(2,17)=0.012797548292871d0
      noik(2,18)=5.8743664107299d-03
      noik(2,19)=-0.018451951971969d0
      noik(2,20)=4.7226622042472d-03
      noik(2,21)=-5.2024079680599d-03
      noik(2,22)=0.043563505956635d0
      noik(2,23)=-0.036251690750939d0
      noik(2,24)=-2.8974026866543d-03
c  Ethane
      noik(4,1)=0.63596780450714d0
      noik(4,2)=-1.7377981785459d0
      noik(4,3)=0.28914060926272d0
      noik(4,4)=-0.33714276845694d0
      noik(4,5)=0.022405964699561d0
      noik(4,6)=0.015715424886913d0
      noik(4,7)=0.11450634253745d0
      noik(4,8)=1.0612049379745d0
      noik(4,9)=-1.2855224439423d0
      noik(4,10)=0.39414630777652d0
      noik(4,11)=0.31390924682041d0
      noik(4,12)=-0.021592277117247d0
      noik(4,13)=-0.21723666564905d0
      noik(4,14)=-0.28999574439489d0
      noik(4,15)=0.42321173025732d0
      noik(4,16)=0.04643410025926d0
      noik(4,17)=-0.13138398329741d0
      noik(4,18)=0.011492850364368d0
      noik(4,19)=-0.033387688429909d0
      noik(4,20)=0.015183171583644d0
      noik(4,21)=-4.7610805647657d-03
      noik(4,22)=0.046917166277885d0
      noik(4,23)=-0.039401755804649d0
      noik(4,24)=-3.2569956247611d-03
c  Propane
      noik(5,1)=1.0403973107358d0
      noik(5,2)=-2.8318404081403d0
      noik(5,3)=0.84393809606294d0
      noik(5,4)=-0.076559591850023d0
      noik(5,5)=0.09469737305728d0
      noik(5,6)=2.4796475497006d-04
      noik(5,7)=0.2774376042287d0
      noik(5,8)=-0.043846000648377d0
      noik(5,9)=-0.2699106478435d0
      noik(5,10)=-0.06931341308986d0
      noik(5,11)=-0.029632145981653d0
      noik(5,12)=0.01404012675138d0
c  Isobutane
      noik(6,1)=1.04293315891d0
      noik(6,2)=-2.8184272548892d0
      noik(6,3)=0.8617623239785d0
      noik(6,4)=-0.10613619452487d0
      noik(6,5)=0.098615749302134d0
      noik(6,6)=2.3948208682322d-04
      noik(6,7)=0.3033000485695d0
      noik(6,8)=-0.041598156135099d0
      noik(6,9)=-0.29991937470058d0
      noik(6,10)=-0.080369342764109d0
      noik(6,11)=-0.029761373251151d0
      noik(6,12)=0.01305963030314d0
c  n-Butane
      noik(7,1)=1.0626277411455d0
      noik(7,2)=-2.862095182835d0
      noik(7,3)=0.88738233403777d0
      noik(7,4)=-0.12570581155345d0
      noik(7,5)=0.10286308708106d0
      noik(7,6)=2.5358040602654d-04
      noik(7,7)=0.32325200233982d0
      noik(7,8)=-0.037950761057432d0
      noik(7,9)=-0.32534802014452d0
      noik(7,10)=-0.079050969051011d0
      noik(7,11)=-0.020636720547775d0
      noik(7,12)=0.005705380933475d0
c  Isopentane
      noik(8,1)=1.0963d0
      noik(8,2)=-3.0402d0
      noik(8,3)=1.0317d0
      noik(8,4)=-0.1541d0
      noik(8,5)=0.11535d0
      noik(8,6)=0.00029809d0
      noik(8,7)=0.39571d0
      noik(8,8)=-0.045881d0
      noik(8,9)=-0.35804d0
      noik(8,10)=-0.10107d0
      noik(8,11)=-0.035484d0
      noik(8,12)=0.018156d0
c  n-Pentane
      noik(9,1)=1.0968643098001d0
      noik(9,2)=-2.9988888298061d0
      noik(9,3)=0.99516886799212d0
      noik(9,4)=-0.16170708558539d0
      noik(9,5)=0.11334460072775d0
      noik(9,6)=2.6760595150748d-04
      noik(9,7)=0.40979881986931d0
      noik(9,8)=-0.040876423083075d0
      noik(9,9)=-0.38169482469447d0
      noik(9,10)=-0.10931956843993d0
      noik(9,11)=-0.03207322332799d0
      noik(9,12)=0.016877016216975d0
c  Hexane
      noik(10,1)=1.0553238013661d0
      noik(10,2)=-2.6120615890629d0
      noik(10,3)=0.7661388296726d0
      noik(10,4)=-0.29770320622459d0
      noik(10,5)=0.11879907733358d0
      noik(10,6)=2.7922861062617d-04
      noik(10,7)=0.46347589844105d0
      noik(10,8)=0.011433196980297d0
      noik(10,9)=-0.48256968738131d0
      noik(10,10)=-0.093750558924659d0
      noik(10,11)=-6.7273247155994d-03
      noik(10,12)=-5.1141583585428d-03
c  Heptane
      noik(11,1)=1.0543747645262d0
      noik(11,2)=-2.6500681506144d0
      noik(11,3)=0.81730047827543d0
      noik(11,4)=-0.30451391253428d0
      noik(11,5)=0.122538687108d0
      noik(11,6)=2.7266472743928d-04
      noik(11,7)=0.4986582568167d0
      noik(11,8)=-7.1432815084176d-04
      noik(11,9)=-0.5423689552545d0
      noik(11,10)=-0.13801821610756d0
      noik(11,11)=-6.1595287380011d-03
      noik(11,12)=4.8602510393022d-04
c  Octane
      noik(12,1)=1.0722544875633d0
      noik(12,2)=-2.4632951172003d0
      noik(12,3)=0.65386674054928d0
      noik(12,4)=-0.36324974085628d0
      noik(12,5)=0.12713269626764d0
      noik(12,6)=3.071357277793d-04
      noik(12,7)=0.5265685698754d0
      noik(12,8)=0.019362862857653d0
      noik(12,9)=-0.58939426849155d0
      noik(12,10)=-0.14069963991934d0
      noik(12,11)=-7.8966330500036d-03
      noik(12,12)=3.3036597968109d-03
c  Nonane
      noik(13,1)=1.1151d0
      noik(13,2)=-2.702d0
      noik(13,3)=0.83416d0
      noik(13,4)=-0.38828d0
      noik(13,5)=0.1376d0
      noik(13,6)=0.00028185d0
      noik(13,7)=0.62037d0
      noik(13,8)=0.015847d0
      noik(13,9)=-0.61726d0
      noik(13,10)=-0.15043d0
      noik(13,11)=-0.012982d0
      noik(13,12)=0.0044325d0
c  Decane
      noik(14,1)=1.0461d0
      noik(14,2)=-2.4807d0
      noik(14,3)=0.74372d0
      noik(14,4)=-0.52579d0
      noik(14,5)=0.15315d0
      noik(14,6)=0.00032865d0
      noik(14,7)=0.84178d0
      noik(14,8)=0.055424d0
      noik(14,9)=-0.73555d0
      noik(14,10)=-0.18507d0
      noik(14,11)=-0.020775d0
      noik(14,12)=0.012335d0
c  Oxygen
      noik(16,1)=0.88878286369701d0
      noik(16,2)=-2.4879433312148d0
      noik(16,3)=0.59750190775886d0
      noik(16,4)=9.6501817061881d-03
      noik(16,5)=0.07197042871277d0
      noik(16,6)=2.2337443000195d-04
      noik(16,7)=0.18558686391474d0
      noik(16,8)=-0.03812936803576d0
      noik(16,9)=-0.15352245383006d0
      noik(16,10)=-0.026726814910919d0
      noik(16,11)=-0.025675298677127d0
      noik(16,12)=9.5714302123668d-03
c  Carbon monoxide
      noik(17,1)=0.90554d0
      noik(17,2)=-2.4515d0
      noik(17,3)=0.53149d0
      noik(17,4)=0.024173d0
      noik(17,5)=0.072156d0
      noik(17,6)=0.00018818d0
      noik(17,7)=0.19405d0
      noik(17,8)=-0.043268d0
      noik(17,9)=-0.12778d0
      noik(17,10)=-0.027896d0
      noik(17,11)=-0.034154d0
      noik(17,12)=0.016329d0
c  Hydrogen sulfide
      noik(19,1)=0.87641d0
      noik(19,2)=-2.0367d0
      noik(19,3)=0.21634d0
      noik(19,4)=-0.050199d0
      noik(19,5)=0.066994d0
      noik(19,6)=0.00019076d0
      noik(19,7)=0.20227d0
      noik(19,8)=-0.0045348d0
      noik(19,9)=-0.2223d0
      noik(19,10)=-0.034714d0
      noik(19,11)=-0.014885d0
      noik(19,12)=0.0074154d0
c  Argon
      noik(21,1)=0.85095714803969d0
      noik(21,2)=-2.400322294348d0
      noik(21,3)=0.54127841476466d0
      noik(21,4)=0.016919770692538d0
      noik(21,5)=0.068825965019035d0
      noik(21,6)=2.1428032815338d-04
      noik(21,7)=0.17429895321992d0
      noik(21,8)=-0.033654495604194d0
      noik(21,9)=-0.13526799857691d0
      noik(21,10)=-0.016387350791552d0
      noik(21,11)=-0.024987666851475d0
      noik(21,12)=8.8769204815709d-03
c  Carbon dioxide
      coik(3,1)=0
      doik(3,1)=1
      toik(3,1)=0
      noik(3,1)=0.52646564804653d0
      coik(3,2)=0
      doik(3,2)=1
      toik(3,2)=1.25d0
      noik(3,2)=-1.4995725042592d0
      coik(3,3)=0
      doik(3,3)=2
      toik(3,3)=1.625d0
      noik(3,3)=0.27329786733782d0
      coik(3,4)=0
      doik(3,4)=3
      toik(3,4)=0.375d0
      noik(3,4)=0.12949500022786d0
      coik(3,5)=1
      doik(3,5)=3
      toik(3,5)=0.375d0
      noik(3,5)=0.15404088341841d0
      coik(3,6)=1
      doik(3,6)=3
      toik(3,6)=1.375d0
      noik(3,6)=-0.58186950946814d0
      coik(3,7)=1
      doik(3,7)=4
      toik(3,7)=1.125d0
      noik(3,7)=-0.18022494838296d0
      coik(3,8)=1
      doik(3,8)=5
      toik(3,8)=1.375d0
      noik(3,8)=-0.095389904072812d0
      coik(3,9)=1
      doik(3,9)=6
      toik(3,9)=0.125d0
      noik(3,9)=-8.0486819317679d-03
      coik(3,10)=1
      doik(3,10)=6
      toik(3,10)=1.625d0
      noik(3,10)=-0.03554775127309d0
      coik(3,11)=2
      doik(3,11)=1
      toik(3,11)=3.75d0
      noik(3,11)=-0.28079014882405d0
      coik(3,12)=2
      doik(3,12)=4
      toik(3,12)=3.5d0
      noik(3,12)=-0.082435890081677d0
      coik(3,13)=3
      doik(3,13)=1
      toik(3,13)=7.5d0
      noik(3,13)=0.010832427979006d0
      coik(3,14)=3
      doik(3,14)=1
      toik(3,14)=8
      noik(3,14)=-6.7073993161097d-03
      coik(3,15)=3
      doik(3,15)=3
      toik(3,15)=6
      noik(3,15)=-4.6827907600524d-03
      coik(3,16)=3
      doik(3,16)=3
      toik(3,16)=16
      noik(3,16)=-0.028359911832177d0
      coik(3,17)=3
      doik(3,17)=4
      toik(3,17)=11
      noik(3,17)=0.019500174744098d0
      coik(3,18)=5
      doik(3,18)=5
      toik(3,18)=24
      noik(3,18)=-0.21609137507166d0
      coik(3,19)=5
      doik(3,19)=5
      toik(3,19)=26
      noik(3,19)=0.43772794926972d0
      coik(3,20)=5
      doik(3,20)=5
      toik(3,20)=28
      noik(3,20)=-0.22130790113593d0
      coik(3,21)=6
      doik(3,21)=5
      toik(3,21)=24
      noik(3,21)=0.015190189957331d0
      coik(3,22)=6
      doik(3,22)=5
      toik(3,22)=26
      noik(3,22)=-0.0153809489533d0
c  Hydrogen
      coik(15,1)=0
      doik(15,1)=1
      toik(15,1)=0.5d0
      noik(15,1)=5.3579928451252d0
      coik(15,2)=0
      doik(15,2)=1
      toik(15,2)=0.625d0
      noik(15,2)=-6.2050252530595d0
      coik(15,3)=0
      doik(15,3)=2
      toik(15,3)=0.375d0
      noik(15,3)=0.13830241327086d0
      coik(15,4)=0
      doik(15,4)=2
      toik(15,4)=0.625d0
      noik(15,4)=-0.071397954896129d0
      coik(15,5)=0
      doik(15,5)=4
      toik(15,5)=1.125d0
      noik(15,5)=0.015474053959733d0
      coik(15,6)=1
      doik(15,6)=1
      toik(15,6)=2.625d0
      noik(15,6)=-0.14976806405771d0
      coik(15,7)=1
      doik(15,7)=5
      toik(15,7)=0
      noik(15,7)=-0.026368723988451d0
      coik(15,8)=1
      doik(15,8)=5
      toik(15,8)=0.25d0
      noik(15,8)=0.056681303156066d0
      coik(15,9)=1
      doik(15,9)=5
      toik(15,9)=1.375d0
      noik(15,9)=-0.060063958030436d0
      coik(15,10)=2
      doik(15,10)=1
      toik(15,10)=4
      noik(15,10)=-0.45043942027132d0
      coik(15,11)=2
      doik(15,11)=1
      toik(15,11)=4.25d0
      noik(15,11)=0.424788402445d0
      coik(15,12)=3
      doik(15,12)=2
      toik(15,12)=5
      noik(15,12)=-0.021997640827139d0
      coik(15,13)=3
      doik(15,13)=5
      toik(15,13)=8
      noik(15,13)=-0.01049952137453d0
      coik(15,14)=5
      doik(15,14)=1
      toik(15,14)=8
      noik(15,14)=-2.8955902866816d-03
c  Water
      coik(18,1)=0
      doik(18,1)=1
      toik(18,1)=0.5d0
      noik(18,1)=0.82728408749586d0
      coik(18,2)=0
      doik(18,2)=1
      toik(18,2)=1.25d0
      noik(18,2)=-1.8602220416584d0
      coik(18,3)=0
      doik(18,3)=1
      toik(18,3)=1.875d0
      noik(18,3)=-1.1199009613744d0
      coik(18,4)=0
      doik(18,4)=2
      toik(18,4)=0.125d0
      noik(18,4)=0.15635753976056d0
      coik(18,5)=0
      doik(18,5)=2
      toik(18,5)=1.5d0
      noik(18,5)=0.87375844859025d0
      coik(18,6)=0
      doik(18,6)=3
      toik(18,6)=1
      noik(18,6)=-0.36674403715731d0
      coik(18,7)=0
      doik(18,7)=4
      toik(18,7)=0.75d0
      noik(18,7)=0.053987893432436d0
      coik(18,8)=1
      doik(18,8)=1
      toik(18,8)=1.5d0
      noik(18,8)=1.0957690214499d0
      coik(18,9)=1
      doik(18,9)=5
      toik(18,9)=0.625d0
      noik(18,9)=0.053213037828563d0
      coik(18,10)=1
      doik(18,10)=5
      toik(18,10)=2.625d0
      noik(18,10)=0.013050533930825d0
      coik(18,11)=2
      doik(18,11)=1
      toik(18,11)=5
      noik(18,11)=-0.41079520434476d0
      coik(18,12)=2
      doik(18,12)=2
      toik(18,12)=4
      noik(18,12)=0.1463744334412d0
      coik(18,13)=2
      doik(18,13)=4
      toik(18,13)=4.5d0
      noik(18,13)=-0.055726838623719d0
      coik(18,14)=3
      doik(18,14)=4
      toik(18,14)=3
      noik(18,14)=-0.0112017741438d0
      coik(18,15)=5
      doik(18,15)=1
      toik(18,15)=4
      noik(18,15)=-6.6062758068099d-03
      coik(18,16)=5
      doik(18,16)=1
      toik(18,16)=6
      noik(18,16)=4.6918522004538d-03
c  Helium
      coik(20,1)=0
      doik(20,1)=1
      toik(20,1)=0
      noik(20,1)=-0.45579024006737d0
      coik(20,2)=0
      doik(20,2)=1
      toik(20,2)=0.125d0
      noik(20,2)=1.2516390754925d0
      coik(20,3)=0
      doik(20,3)=1
      toik(20,3)=0.75d0
      noik(20,3)=-1.5438231650621d0
      coik(20,4)=0
      doik(20,4)=4
      toik(20,4)=1
      noik(20,4)=0.020467489707221d0
      coik(20,5)=1
      doik(20,5)=1
      toik(20,5)=0.75d0
      noik(20,5)=-0.34476212380781d0
      coik(20,6)=1
      doik(20,6)=3
      toik(20,6)=2.625d0
      noik(20,6)=-0.020858459512787d0
      coik(20,7)=1
      doik(20,7)=5
      toik(20,7)=0.125d0
      noik(20,7)=0.016227414711778d0
      coik(20,8)=1
      doik(20,8)=5
      toik(20,8)=1.25d0
      noik(20,8)=-0.057471818200892d0
      coik(20,9)=1
      doik(20,9)=5
      toik(20,9)=2
      noik(20,9)=0.019462416430715d0
      coik(20,10)=2
      doik(20,10)=2
      toik(20,10)=1
      noik(20,10)=-0.03329568012302d0
      coik(20,11)=3
      doik(20,11)=1
      toik(20,11)=4.5d0
      noik(20,11)=-0.010863577372367d0
      coik(20,12)=3
      doik(20,12)=2
      toik(20,12)=5
      noik(20,12)=-0.022173365245954d0

c  Exponents in mixture equations
c  Methane-Nitrogen
      dijk(3,1)=1
      nijk(3,1)=-9.8038985517335d-03
      dijk(3,2)=4
      tijk(3,2)=1.85d0
      nijk(3,2)=4.2487270143005d-04
      dijk(3,3)=1
      tijk(3,3)=7.85d0
      cijk(3,3)=1
      eijk(3,3)=0.5d0
      bijk(3,3)=1
      gijk(3,3)=0.5d0
      nijk(3,3)=-0.034800214576142d0
      dijk(3,4)=2
      tijk(3,4)=5.4d0
      cijk(3,4)=1
      eijk(3,4)=0.5d0
      bijk(3,4)=1
      gijk(3,4)=0.5d0
      nijk(3,4)=-0.13333813013896d0
      dijk(3,5)=2
      cijk(3,5)=0.25d0
      eijk(3,5)=0.5d0
      bijk(3,5)=2.5d0
      gijk(3,5)=0.5d0
      nijk(3,5)=-0.011993694974627d0
      dijk(3,6)=2
      tijk(3,6)=0.75d0
      eijk(3,6)=0.5d0
      bijk(3,6)=3
      gijk(3,6)=0.5d0
      nijk(3,6)=0.069243379775168d0
      dijk(3,7)=2
      tijk(3,7)=2.8d0
      eijk(3,7)=0.5d0
      bijk(3,7)=3
      gijk(3,7)=0.5d0
      nijk(3,7)=-0.31022508148249d0
      dijk(3,8)=2
      tijk(3,8)=4.45d0
      eijk(3,8)=0.5d0
      bijk(3,8)=3
      gijk(3,8)=0.5d0
      nijk(3,8)=0.24495491753226d0
      dijk(3,9)=3
      tijk(3,9)=4.25d0
      eijk(3,9)=0.5d0
      bijk(3,9)=3
      gijk(3,9)=0.5d0
      nijk(3,9)=0.22369816716981d0
c  Methane-Carbon dioxide
      dijk(4,1)=1
      tijk(4,1)=2.6d0
      nijk(4,1)=-0.10859387354942d0
      dijk(4,2)=2
      tijk(4,2)=1.95d0
      nijk(4,2)=0.080228576727389d0
      dijk(4,3)=3
      nijk(4,3)=-9.3303985115717d-03
      dijk(4,4)=1
      tijk(4,4)=3.95d0
      cijk(4,4)=1
      eijk(4,4)=0.5d0
      bijk(4,4)=1
      gijk(4,4)=0.5d0
      nijk(4,4)=0.040989274005848d0
      dijk(4,5)=2
      tijk(4,5)=7.95d0
      cijk(4,5)=0.5d0
      eijk(4,5)=0.5d0
      bijk(4,5)=2
      gijk(4,5)=0.5d0
      nijk(4,5)=-0.24338019772494d0
      dijk(4,6)=3
      tijk(4,6)=8
      eijk(4,6)=0.5d0
      bijk(4,6)=3
      gijk(4,6)=0.5d0
      nijk(4,6)=0.23855347281124d0
c  Methane-Ethane
      dijk(1,1)=3
      tijk(1,1)=0.65d0
      nijk(1,1)=-8.0926050298746d-04
      dijk(1,2)=4
      tijk(1,2)=1.55d0
      nijk(1,2)=-7.5381925080059d-04
      dijk(1,3)=1
      tijk(1,3)=3.1d0
      cijk(1,3)=1
      eijk(1,3)=0.5d0
      bijk(1,3)=1
      gijk(1,3)=0.5d0
      nijk(1,3)=-0.041618768891219d0
      dijk(1,4)=2
      tijk(1,4)=5.9d0
      cijk(1,4)=1
      eijk(1,4)=0.5d0
      bijk(1,4)=1
      gijk(1,4)=0.5d0
      nijk(1,4)=-0.23452173681569d0
      dijk(1,5)=2
      tijk(1,5)=7.05d0
      cijk(1,5)=1
      eijk(1,5)=0.5d0
      bijk(1,5)=1
      gijk(1,5)=0.5d0
      nijk(1,5)=0.14003840584586d0
      dijk(1,6)=2
      tijk(1,6)=3.35d0
      cijk(1,6)=0.875d0
      eijk(1,6)=0.5d0
      bijk(1,6)=1.25d0
      gijk(1,6)=0.5d0
      nijk(1,6)=0.063281744807738d0
      dijk(1,7)=2
      tijk(1,7)=1.2d0
      cijk(1,7)=0.75d0
      eijk(1,7)=0.5d0
      bijk(1,7)=1.5d0
      gijk(1,7)=0.5d0
      nijk(1,7)=-0.034660425848809d0
      dijk(1,8)=2
      tijk(1,8)=5.8d0
      cijk(1,8)=0.5d0
      eijk(1,8)=0.5d0
      bijk(1,8)=2
      gijk(1,8)=0.5d0
      nijk(1,8)=-0.23918747334251d0
      dijk(1,9)=2
      tijk(1,9)=2.7d0
      eijk(1,9)=0.5d0
      bijk(1,9)=3
      gijk(1,9)=0.5d0
      nijk(1,9)=1.9855255066891d-03
      dijk(1,10)=3
      tijk(1,10)=0.45d0
      eijk(1,10)=0.5d0
      bijk(1,10)=3
      gijk(1,10)=0.5d0
      nijk(1,10)=6.1777746171555d0
      dijk(1,11)=3
      tijk(1,11)=0.55d0
      eijk(1,11)=0.5d0
      bijk(1,11)=3
      gijk(1,11)=0.5d0
      nijk(1,11)=-6.9575358271105d0
      dijk(1,12)=3
      tijk(1,12)=1.95d0
      eijk(1,12)=0.5d0
      bijk(1,12)=3
      gijk(1,12)=0.5d0
      nijk(1,12)=1.0630185306388d0
c  Methane-Propane
      dijk(2,1)=3
      tijk(2,1)=1.85d0
      nijk(2,1)=0.013746429958576d0
      dijk(2,2)=3
      tijk(2,2)=3.95d0
      nijk(2,2)=-7.4425012129552d-03
      dijk(2,3)=4
      nijk(2,3)=-4.5516600213685d-03
      dijk(2,4)=4
      tijk(2,4)=1.85d0
      nijk(2,4)=-5.4546603350237d-03
      dijk(2,5)=4
      tijk(2,5)=3.85d0
      nijk(2,5)=2.3682016824471d-03
      dijk(2,6)=1
      tijk(2,6)=5.25d0
      cijk(2,6)=0.25d0
      eijk(2,6)=0.5d0
      bijk(2,6)=0.75d0
      gijk(2,6)=0.5d0
      nijk(2,6)=0.18007763721438d0
      dijk(2,7)=1
      tijk(2,7)=3.85d0
      cijk(2,7)=0.25d0
      eijk(2,7)=0.5d0
      bijk(2,7)=1
      gijk(2,7)=0.5d0
      nijk(2,7)=-0.44773942932486d0
      dijk(2,8)=1
      tijk(2,8)=0.2d0
      eijk(2,8)=0.5d0
      bijk(2,8)=2
      gijk(2,8)=0.5d0
      nijk(2,8)=0.0193273748882d0
      dijk(2,9)=2
      tijk(2,9)=6.5d0
      eijk(2,9)=0.5d0
      bijk(2,9)=3
      gijk(2,9)=0.5d0
      nijk(2,9)=-0.30632197804624d0
c  Nitrogen-Carbon dioxide
      dijk(5,1)=2
      tijk(5,1)=1.85d0
      nijk(5,1)=0.28661625028399d0
      dijk(5,2)=3
      tijk(5,2)=1.4d0
      nijk(5,2)=-0.10919833861247d0
      dijk(5,3)=1
      tijk(5,3)=3.2d0
      cijk(5,3)=0.25d0
      eijk(5,3)=0.5d0
      bijk(5,3)=0.75d0
      gijk(5,3)=0.5d0
      nijk(5,3)=-1.137403208227d0
      dijk(5,4)=1
      tijk(5,4)=2.5d0
      cijk(5,4)=0.25d0
      eijk(5,4)=0.5d0
      bijk(5,4)=1
      gijk(5,4)=0.5d0
      nijk(5,4)=0.76580544237358d0
      dijk(5,5)=1
      tijk(5,5)=8
      eijk(5,5)=0.5d0
      bijk(5,5)=2
      gijk(5,5)=0.5d0
      nijk(5,5)=4.2638000926819d-03
      dijk(5,6)=2
      tijk(5,6)=3.75d0
      eijk(5,6)=0.5d0
      bijk(5,6)=3
      gijk(5,6)=0.5d0
      nijk(5,6)=0.17673538204534d0
c  Nitrogen-Ethane
      dijk(6,1)=2
      nijk(6,1)=-0.47376518126608d0
      dijk(6,2)=2
      tijk(6,2)=0.05d0
      nijk(6,2)=0.48961193461001d0
      dijk(6,3)=3
      nijk(6,3)=-5.7011062090535d-03
      dijk(6,4)=1
      tijk(6,4)=3.65d0
      cijk(6,4)=1
      eijk(6,4)=0.5d0
      bijk(6,4)=1
      gijk(6,4)=0.5d0
      nijk(6,4)=-0.1996682004132d0
      dijk(6,5)=2
      tijk(6,5)=4.9d0
      cijk(6,5)=1
      eijk(6,5)=0.5d0
      bijk(6,5)=1
      gijk(6,5)=0.5d0
      nijk(6,5)=-0.69411103101723d0
      dijk(6,6)=2
      tijk(6,6)=4.45d0
      cijk(6,6)=0.875d0
      eijk(6,6)=0.5d0
      bijk(6,6)=1.25d0
      gijk(6,6)=0.5d0
      nijk(6,6)=0.69226192739021d0
c  Methane-Hydrogen
      dijk(7,1)=1
      tijk(7,1)=2
      nijk(7,1)=-0.25157134971934d0
      dijk(7,2)=3
      tijk(7,2)=-1
      nijk(7,2)=-6.2203841111983d-03
      dijk(7,3)=3
      tijk(7,3)=1.75d0
      nijk(7,3)=0.088850315184396d0
      dijk(7,4)=4
      tijk(7,4)=1.4d0
      nijk(7,4)=-0.035592212573239d0
c  Methane-n-Butane, Methane-Isobutane, Ethane-Propane, Ethane-n-Butane,
c  Ethane-Isobutane, Propane-n-Butane, Propane-Isobutane, and n-Butane-Isobutane
      dijk(10,1)=1
      tijk(10,1)=1
      nijk(10,1)=2.5574776844118d0
      dijk(10,2)=1
      tijk(10,2)=1.55d0
      nijk(10,2)=-7.9846357136353d0
      dijk(10,3)=1
      tijk(10,3)=1.7d0
      nijk(10,3)=4.7859131465806d0
      dijk(10,4)=2
      tijk(10,4)=0.25d0
      nijk(10,4)=-0.73265392369587d0
      dijk(10,5)=2
      tijk(10,5)=1.35d0
      nijk(10,5)=1.3805471345312d0
      dijk(10,6)=3
      nijk(10,6)=0.28349603476365d0
      dijk(10,7)=3
      tijk(10,7)=1.25d0
      nijk(10,7)=-0.49087385940425d0
      dijk(10,8)=4
      nijk(10,8)=-0.10291888921447d0
      dijk(10,9)=4
      tijk(10,9)=0.7d0
      nijk(10,9)=0.11836314681968d0
      dijk(10,10)=4
      tijk(10,10)=5.4d0
      nijk(10,10)=5.5527385721943d-05

c  Generalized parameters
      fij(1,2)=1                !Methane-Nitrogen
      fij(1,3)=1                !Methane-CO2
      fij(1,4)=1                !Methane-Ethane
      fij(1,5)=1                !Methane-Propane
      fij(2,3)=1                !Nitrogen-CO2
      fij(2,4)=1                !Nitrogen-Ethane
      fij(1,15)=1               !Methane-Hydrogen
      fij(1,6)=0.771035405688d0  !Methane-Isobutane
      fij(1,7)=1                !Methane-n-Butane
      fij(4,5)=0.13042476515d0   !Ethane-Propane
      fij(4,6)=0.260632376098d0  !Ethane-Isobutane
      fij(4,7)=0.281570073085d0  !Ethane-n-Butane
      fij(5,6)=-0.0551609771024d0!Propane-Isobutane
      fij(5,7)=0.0312572600489d0 !Propane-n-Butane
      fij(6,7)=-0.0551240293009d0!Isobutane-n-Butane

c  Model numbers for binary mixtures with no excess functions (mn=-1)
      Do i=1,MaxFlds
        mNumb(i,i)=-1
        Do j=i+1,MaxFlds
          fij(j,i)=fij(i,j)
          mNumb(i,j)=-1
          mNumb(j,i)=-1
        Enddo
      Enddo

c  Model numbers for excess functions, 10 is for generalized equation
      mNumb(1,2)=3
      mNumb(1,3)=4
      mNumb(1,4)=1
      mNumb(1,5)=2
      mNumb(1,6)=10
      mNumb(1,7)=10
      mNumb(1,15)=7
      mNumb(2,3)=5
      mNumb(2,4)=6
      mNumb(4,5)=10
      mNumb(4,6)=10
      mNumb(4,7)=10
      mNumb(5,6)=10
      mNumb(5,7)=10
      mNumb(6,7)=10

c  Mixture parameters for reducing variables
      bvij(1,2)=0.998721377d0
      gvij(1,2)=1.013950311d0
      btij(1,2)=0.99809883d0
      gtij(1,2)=0.979273013d0  !CH4-N2
      bvij(1,3)=0.999518072d0
      gvij(1,3)=1.002806594d0
      btij(1,3)=1.02262449d0
      gtij(1,3)=0.975665369d0  !CH4-CO2
      bvij(1,4)=0.997547866d0
      gvij(1,4)=1.006617867d0
      btij(1,4)=0.996336508d0
      gtij(1,4)=1.049707697d0  !CH4-C2H6
      bvij(1,5)=1.00482707d0
      gvij(1,5)=1.038470657d0
      btij(1,5)=0.989680305d0
      gtij(1,5)=1.098655531d0  !CH4-C3H8
      bvij(1,6)=1.011240388d0
      gvij(1,6)=1.054319053d0
      btij(1,6)=0.980315756d0
      gtij(1,6)=1.161117729d0  !CH4-i-C4H10
      bvij(1,7)=0.979105972d0
      gvij(1,7)=1.045375122d0
      btij(1,7)=0.99417491d0
      gtij(1,7)=1.171607691d0  !CH4-C4H10
      gvij(1,8)=1.343685343d0
      gtij(1,8)=1.188899743d0  !CH4-i-C5H12
      bvij(1,9)=0.94833012d0
      gvij(1,9)=1.124508039d0
      btij(1,9)=0.992127525d0
      gtij(1,9)=1.249173968d0  !CH4-C5H12
      bvij(1,10)=0.958015294d0
      gvij(1,10)=1.052643846d0
      btij(1,10)=0.981844797d0
      gtij(1,10)=1.330570181d0 !CH4-C6H14
      bvij(1,11)=0.962050831d0
      gvij(1,11)=1.156655935d0
      btij(1,11)=0.977431529d0
      gtij(1,11)=1.379850328d0 !CH4-C7H16
      bvij(1,12)=0.994740603d0
      gvij(1,12)=1.116549372d0
      btij(1,12)=0.957473785d0
      gtij(1,12)=1.449245409d0 !CH4-C8H18
      bvij(1,13)=1.002852287d0
      gvij(1,13)=1.141895355d0
      btij(1,13)=0.947716769d0
      gtij(1,13)=1.528532478d0 !CH4-C9H20
      bvij(1,14)=1.033086292d0
      gvij(1,14)=1.146089637d0
      btij(1,14)=0.937777823d0
      gtij(1,14)=1.568231489d0 !CH4-C10H22
      gvij(1,15)=1.018702573d0
      gtij(1,15)=1.352643115d0 !CH4-H2
      gtij(1,16)=0.95d0        !CH4-O2
      bvij(1,17)=0.997340772d0
      gvij(1,17)=1.006102927d0
      btij(1,17)=0.987411732d0
      gtij(1,17)=0.987473033d0 !CH4-CO
      bvij(1,18)=1.012783169d0
      gvij(1,18)=1.585018334d0
      btij(1,18)=1.063333913d0
      gtij(1,18)=0.775810513d0 !CH4-H2O
      bvij(1,19)=1.012599087d0
      gvij(1,19)=1.040161207d0
      btij(1,19)=1.011090031d0
      gtij(1,19)=0.961155729d0 !CH4-H2S
      gvij(1,20)=0.881405683d0
      gtij(1,20)=3.159776855d0 !CH4-He
      bvij(1,21)=1.034630259d0
      gvij(1,21)=1.014678542d0
      btij(1,21)=0.990954281d0
      gtij(1,21)=0.989843388d0 !CH4-Ar
      bvij(2,3)=0.977794634d0
      gvij(2,3)=1.047578256d0
      btij(2,3)=1.005894529d0
      gtij(2,3)=1.107654104d0  !N2-CO2
      bvij(2,4)=0.978880168d0
      gvij(2,4)=1.042352891d0
      btij(2,4)=1.007671428d0
      gtij(2,4)=1.098650964d0  !N2-C2H6
      bvij(2,5)=0.974424681d0
      gvij(2,5)=1.081025408d0
      btij(2,5)=1.002677329d0
      gtij(2,5)=1.201264026d0  !N2-C3H8
      bvij(2,6)=0.98641583d0
      gvij(2,6)=1.100576129d0
      btij(2,6)=0.99286813d0
      gtij(2,6)=1.284462634d0  !N2-i-C4H10
      bvij(2,7)=0.99608261d0
      gvij(2,7)=1.146949309d0
      btij(2,7)=0.994515234d0
      gtij(2,7)=1.304886838d0  !N2-C4H10
      gvij(2,8)=1.154135439d0
      gtij(2,8)=1.38177077d0   !N2-i-C5H12
      gvij(2,9)=1.078877166d0
      gtij(2,9)=1.419029041d0  !N2-C5H12
      gvij(2,10)=1.195952177d0
      gtij(2,10)=1.472607971d0 !N2-C6H14
      gvij(2,11)=1.40455409d0
      gtij(2,11)=1.520975334d0 !N2-C7H16
      gvij(2,12)=1.186067025d0
      gtij(2,12)=1.733280051d0 !N2-C8H18
      gvij(2,13)=1.100405929d0
      btij(2,13)=0.95637945d0
      gtij(2,13)=1.749119996d0 !N2-C9H20
      btij(2,14)=0.957934447d0
      gtij(2,14)=1.822157123d0 !N2-C10H22
      bvij(2,15)=0.972532065d0
      gvij(2,15)=0.970115357d0
      btij(2,15)=0.946134337d0
      gtij(2,15)=1.175696583d0 !N2-H2
      bvij(2,16)=0.99952177d0
      gvij(2,16)=0.997082328d0
      btij(2,16)=0.997190589d0
      gtij(2,16)=0.995157044d0 !N2-O2
      gvij(2,17)=1.008690943d0
      gtij(2,17)=0.993425388d0 !N2-CO
      gvij(2,18)=1.094749685d0
      gtij(2,18)=0.968808467d0 !N2-H2O
      bvij(2,19)=0.910394249d0
      gvij(2,19)=1.256844157d0
      btij(2,19)=1.004692366d0
      gtij(2,19)=0.9601742d0   !N2-H2S
      bvij(2,20)=0.969501055d0
      gvij(2,20)=0.932629867d0
      btij(2,20)=0.692868765d0
      gtij(2,20)=1.47183158d0  !N2-He
      bvij(2,21)=1.004166412d0
      gvij(2,21)=1.002212182d0
      btij(2,21)=0.999069843d0
      gtij(2,21)=0.990034831d0 !N2-Ar
      bvij(3,4)=1.002525718d0
      gvij(3,4)=1.032876701d0
      btij(3,4)=1.013871147d0
      gtij(3,4)=0.90094953d0   !CO2-C2H6
      bvij(3,5)=0.996898004d0
      gvij(3,5)=1.047596298d0
      btij(3,5)=1.033620538d0
      gtij(3,5)=0.908772477d0  !CO2-C3H8
      bvij(3,6)=1.076551882d0
      gvij(3,6)=1.081909003d0
      btij(3,6)=1.023339824d0
      gtij(3,6)=0.929982936d0  !CO2-i-C4H10
      bvij(3,7)=1.174760923d0
      gvij(3,7)=1.222437324d0
      btij(3,7)=1.018171004d0
      gtij(3,7)=0.911498231d0  !CO2-C4H10
      bvij(3,8)=1.060793104d0
      gvij(3,8)=1.116793198d0
      btij(3,8)=1.019180957d0
      gtij(3,8)=0.961218039d0  !CO2-i-C5H12
      bvij(3,9)=1.024311498d0
      gvij(3,9)=1.068406078d0
      btij(3,9)=1.027000795d0
      gtij(3,9)=0.979217302d0  !CO2-C5H12
      gvij(3,10)=0.851343711d0
      gtij(3,10)=1.038675574d0 !CO2-C6H14
      bvij(3,11)=1.205469976d0
      gvij(3,11)=1.164585914d0
      btij(3,11)=1.011806317d0
      gtij(3,11)=1.046169823d0 !CO2-C7H16
      bvij(3,12)=1.026169373d0
      gvij(3,12)=1.104043935d0
      btij(3,12)=1.02969078d0
      gtij(3,12)=1.074455386d0 !CO2-C8H18
      gvij(3,13)=0.973386152d0
      btij(3,13)=1.00768862d0
      gtij(3,13)=1.140671202d0 !CO2-C9H20
      bvij(3,14)=1.000151132d0
      gvij(3,14)=1.183394668d0
      btij(3,14)=1.02002879d0
      gtij(3,14)=1.145512213d0 !CO2-C10H22
      bvij(3,15)=0.904142159d0
      gvij(3,15)=1.15279255d0
      btij(3,15)=0.942320195d0
      gtij(3,15)=1.782924792d0 !CO2-H2
      bvij(3,18)=0.949055959d0
      gvij(3,18)=1.542328793d0
      btij(3,18)=0.997372205d0
      gtij(3,18)=0.775453996d0 !CO2-H2O
      bvij(3,19)=0.906630564d0
      gvij(3,19)=1.024085837d0
      btij(3,19)=1.016034583d0
      gtij(3,19)=0.92601888d0  !CO2-H2S
      bvij(3,20)=0.846647561d0
      gvij(3,20)=0.864141549d0
      btij(3,20)=0.76837763d0
      gtij(3,20)=3.207456948d0 !CO2-He
      bvij(3,21)=1.008392428d0
      gvij(3,21)=1.029205465d0
      btij(3,21)=0.996512863d0
      gtij(3,21)=1.050971635d0 !CO2-Ar
      bvij(4,5)=0.997607277d0
      gvij(4,5)=1.00303472d0
      btij(4,5)=0.996199694d0
      gtij(4,5)=1.01473019d0   !C2H6-C3H8
      gvij(4,6)=1.006616886d0
      gtij(4,6)=1.033283811d0  !C2H6-i-C4H10
      bvij(4,7)=0.999157205d0
      gvij(4,7)=1.006179146d0
      btij(4,7)=0.999130554d0
      gtij(4,7)=1.034832749d0  !C2H6-C4H10
      gvij(4,8)=1.045439935d0
      gtij(4,8)=1.021150247d0  !C2H6-i-C5H12
      bvij(4,9)=0.993851009d0
      gvij(4,9)=1.026085655d0
      btij(4,9)=0.998688946d0
      gtij(4,9)=1.066665676d0  !C2H6-C5H12
      gvij(4,10)=1.169701102d0
      gtij(4,10)=1.092177796d0 !C2H6-C6H14
      gvij(4,11)=1.057666085d0
      gtij(4,11)=1.134532014d0 !C2H6-C7H16
      bvij(4,12)=1.007469726d0
      gvij(4,12)=1.071917985d0
      btij(4,12)=0.984068272d0
      gtij(4,12)=1.168636194d0 !C2H6-C8H18
      gvij(4,13)=1.14353473d0
      gtij(4,13)=1.05603303d0  !C2H6-C9H20
      bvij(4,14)=0.995676258d0
      gvij(4,14)=1.098361281d0
      btij(4,14)=0.970918061d0
      gtij(4,14)=1.237191558d0 !C2H6-C10H22
      bvij(4,15)=0.925367171d0
      gvij(4,15)=1.10607204d0
      btij(4,15)=0.932969831d0
      gtij(4,15)=1.902008495d0 !C2H6-H2
      gvij(4,17)=1.201417898d0
      gtij(4,17)=1.069224728d0 !C2H6-CO
      bvij(4,19)=1.010817909d0
      gvij(4,19)=1.030988277d0
      btij(4,19)=0.990197354d0
      gtij(4,19)=0.90273666d0  !C2H6-H2S
      bvij(5,6)=0.999243146d0
      gvij(5,6)=1.001156119d0
      btij(5,6)=0.998012298d0
      gtij(5,6)=1.005250774d0  !C3H8-i-C4H10
      bvij(5,7)=0.999795868d0
      gvij(5,7)=1.003264179d0
      btij(5,7)=1.000310289d0
      gtij(5,7)=1.007392782d0  !C3H8-C4H10
      bvij(5,8)=1.040459289d0
      gvij(5,8)=0.999432118d0
      btij(5,8)=0.994364425d0
      gtij(5,8)=1.0032695d0    !C3H8-i-C5H12
      bvij(5,9)=1.044919431d0
      gvij(5,9)=1.019921513d0
      btij(5,9)=0.996484021d0
      gtij(5,9)=1.008344412d0  !C3H8-C5H12
      gvij(5,10)=1.057872566d0
      gtij(5,10)=1.025657518d0 !C3H8-C6H14
      gvij(5,11)=1.079648053d0
      gtij(5,11)=1.050044169d0 !C3H8-C7H16
      gvij(5,12)=1.102764612d0
      gtij(5,12)=1.063694129d0 !C3H8-C8H18
      gvij(5,13)=1.199769134d0
      gtij(5,13)=1.109973833d0 !C3H8-C9H20
      bvij(5,14)=0.984104227d0
      gvij(5,14)=1.053040574d0
      btij(5,14)=0.985331233d0
      gtij(5,14)=1.140905252d0 !C3H8-C10H22
      gvij(5,15)=1.07400611d0
      gtij(5,15)=2.308215191d0 !C3H8-H2
      gvij(5,17)=1.108143673d0
      gtij(5,17)=1.197564208d0 !C3H8-CO
      gvij(5,18)=1.011759763d0
      gtij(5,18)=0.600340961d0 !C3H8-H2O
      bvij(5,19)=0.936811219d0
      gvij(5,19)=1.010593999d0
      btij(5,19)=0.992573556d0
      gtij(5,19)=0.905829247d0 !C3H8-H2S
c  The beta values for isobutane+butane are the reciprocal values of those in the GERG-2008 publication because the order was reversed in this work.
      bvij(6,7)=0.999120311d0
      gvij(6,7)=1.00041444d0
      btij(6,7)=0.999922459d0
      gtij(6,7)=1.001432824d0  !C4H10-i-C4H10
      gvij(6,8)=1.002284353d0
      gtij(6,8)=1.001835788d0  !i-C4H10-i-
      gvij(6,9)=1.002779804d0
      gtij(6,9)=1.002495889d0  !i-C4H10-C5H12
      gvij(6,10)=1.010493989d0
      gtij(6,10)=1.006018054d0 !i-C4H10-C6H14
      gvij(6,11)=1.021668316d0
      gtij(6,11)=1.00988576d0  !i-C4H10-C7H16
      gvij(6,12)=1.032807063d0
      gtij(6,12)=1.013945424d0 !i-C4H10-C8H18
      gvij(6,13)=1.047298475d0
      gtij(6,13)=1.017817492d0 !i-C4H10-C9H20
      gvij(6,14)=1.060243344d0
      gtij(6,14)=1.021624748d0 !i-C4H10-C10H22
      gvij(6,15)=1.147595688d0
      gtij(6,15)=1.895305393d0 !i-C4H10-H2
      gvij(6,17)=1.087272232d0
      gtij(6,17)=1.161390082d0 !i-C4H10-CO
      bvij(6,19)=1.012994431d0
      gvij(6,19)=0.988591117d0
      btij(6,19)=0.974550548d0
      gtij(6,19)=0.937130844d0 !i-C4H10-H2S
      gvij(7,8)=1.002728434d0
      gtij(7,8)=1.000792201d0  !C4H10-i-C5H12
      gvij(7,9)=1.01815965d0
      gtij(7,9)=1.00214364d0   !C4H10-C5H12
      gvij(7,10)=1.034995284d0
      gtij(7,10)=1.00915706d0  !C4H10-C6H14
      gvij(7,11)=1.019174227d0
      gtij(7,11)=1.021283378d0 !C4H10-C7H16
      gvij(7,12)=1.046905515d0
      gtij(7,12)=1.033180106d0 !C4H10-C8H18
      gvij(7,13)=1.049219137d0
      gtij(7,13)=1.014096448d0 !C4H10-C9H20
      bvij(7,14)=0.976951968d0
      gvij(7,14)=1.027845529d0
      btij(7,14)=0.993688386d0
      gtij(7,14)=1.076466918d0 !C4H10-C10H22
      gvij(7,15)=1.232939523d0
      gtij(7,15)=2.509259945d0 !C4H10-H2
      gvij(7,17)=1.084740904d0
      gtij(7,17)=1.173916162d0 !C4H10-CO
      gvij(7,18)=1.223638763d0
      gtij(7,18)=0.615512682d0 !C4H10-H2O
      bvij(7,19)=0.908113163d0
      gvij(7,19)=1.033366041d0
      btij(7,19)=0.985962886d0
      gtij(7,19)=0.926156602d0 !C4H10-H2S
      gvij(7,21)=1.214638734d0
      gtij(7,21)=1.245039498d0 !C4H10-Ar
      gvij(8,9)=1.000024335d0
      gtij(8,9)=1.000050537d0  !C5H12-i-C5H12
      gvij(8,10)=1.002995876d0
      gtij(8,10)=1.001204174d0 !i-C5H12-C6H14
      gvij(8,11)=1.009928206d0
      gtij(8,11)=1.003194615d0 !i-C5H12-C7H16
      gvij(8,12)=1.017880545d0
      gtij(8,12)=1.00564748d0  !i-C5H12-C8H18
      gvij(8,13)=1.028994325d0
      gtij(8,13)=1.008191499d0 !i-C5H12-C9H20
      gvij(8,14)=1.039372957d0
      gtij(8,14)=1.010825138d0 !i-C5H12-C10H22
      gvij(8,15)=1.184340443d0
      gtij(8,15)=1.996386669d0 !i-C5H12-H2
      gvij(8,17)=1.116694577d0
      gtij(8,17)=1.199326059d0 !i-C5H12-CO
      gvij(8,19)=0.835763343d0
      gtij(8,19)=0.982651529d0 !i-C5H12-H2S
      gvij(9,10)=1.002480637d0
      gtij(9,10)=1.000761237d0 !C5H12-C6H14
      gvij(9,11)=1.008972412d0
      gtij(9,11)=1.002441051d0 !C5H12-C7H16
      gvij(9,12)=1.069223964d0
      gtij(9,12)=1.016422347d0 !C5H12-C8H18
      gvij(9,13)=1.034910633d0
      gtij(9,13)=1.103421755d0 !C5H12-C9H20
      gvij(9,14)=1.016370338d0
      gtij(9,14)=1.049035838d0 !C5H12-C10H22
      gvij(9,15)=1.188334783d0
      gtij(9,15)=2.013859174d0 !C5H12-H2
      gvij(9,17)=1.119954454d0
      gtij(9,17)=1.206043295d0 !C5H12-CO
      gvij(9,18)=0.95667731d0
      gtij(9,18)=0.447666011d0 !C5H12-H2O
      bvij(9,19)=0.984613203d0
      gvij(9,19)=1.076539234d0
      btij(9,19)=0.962006651d0
      gtij(9,19)=0.959065662d0 !C5H12-H2S
      gvij(10,11)=1.001508227d0
      gtij(10,11)=0.999762786d0!C6H14-C7H16
      gvij(10,12)=1.006268954d0
      gtij(10,12)=1.001633952d0!C6H14-C8H18
      gvij(10,13)=1.02076168d0
      gtij(10,13)=1.055369591d0!C6H14-C9H20
      bvij(10,14)=1.001516371d0
      gvij(10,14)=1.013511439d0
      btij(10,14)=0.99764101d0
      gtij(10,14)=1.028939539d0!C6H14-C10H22
      gvij(10,15)=1.243461678d0
      gtij(10,15)=3.021197546d0!C6H14-H2
      gvij(10,17)=1.155145836d0
      gtij(10,17)=1.233272781d0!C6H14-CO
      gvij(10,18)=1.170217596d0
      gtij(10,18)=0.569681333d0!C6H14-H2O
      bvij(10,19)=0.754473958d0
      gvij(10,19)=1.339283552d0
      btij(10,19)=0.985891113d0
      gtij(10,19)=0.956075596d0!C6H14-H2S
      gvij(11,12)=1.006767176d0
      gtij(11,12)=0.998793111d0!C7H16-C8H18
      gvij(11,13)=1.001370076d0
      gtij(11,13)=1.001150096d0!C7H16-C9H20
      gvij(11,14)=1.002972346d0
      gtij(11,14)=1.002229938d0!C7H16-C10H22
      gvij(11,15)=1.159131722d0
      gtij(11,15)=3.169143057d0!C7H16-H2
      gvij(11,17)=1.190354273d0
      gtij(11,17)=1.256123503d0!C7H16-CO
      bvij(11,19)=0.828967164d0
      gvij(11,19)=1.087956749d0
      btij(11,19)=0.988937417d0
      gtij(11,19)=1.013453092d0!C7H16-H2S
      gvij(12,13)=1.001357085d0
      gtij(12,13)=1.000235044d0!C8H18-C9H20
      gvij(12,14)=1.002553544d0
      gtij(12,14)=1.007186267d0!C8H18-C10H22
      gvij(12,15)=1.305249405d0
      gtij(12,15)=2.191555216d0!C8H18-H2
      gvij(12,17)=1.219206702d0
      gtij(12,17)=1.276565536d0!C8H18-CO
      gvij(12,18)=0.599484191d0
      gtij(12,18)=0.662072469d0!C8H18-H2O
      gvij(13,14)=1.00081052d0
      gtij(13,14)=1.000182392d0!C9H20-C10H22
      gvij(13,15)=1.342647661d0
      gtij(13,15)=2.23435404d0 !C9H20-H2
      gvij(13,17)=1.252151449d0
      gtij(13,17)=1.294070556d0!C9H20-CO
      gvij(13,19)=1.082905109d0
      gtij(13,19)=1.086557826d0!C9H20-H2S
      bvij(14,15)=1.695358382d0
      gvij(14,15)=1.120233729d0
      btij(14,15)=1.064818089d0
      gtij(14,15)=3.786003724d0!C10H22-H2
      gvij(14,17)=0.87018496d0
      btij(14,17)=1.049594632d0
      gtij(14,17)=1.803567587d0!C10H22-CO
      gvij(14,18)=0.551405318d0
      btij(14,18)=0.897162268d0
      gtij(14,18)=0.740416402d0!C10H22-H2O
      bvij(14,19)=0.975187766d0
      gvij(14,19)=1.171714677d0
      btij(14,19)=0.973091413d0
      gtij(14,19)=1.103693489d0!C10H22-H2S
      gvij(15,17)=1.121416201d0
      gtij(15,17)=1.377504607d0!H2-CO
      gvij(16,18)=1.143174289d0
      gtij(16,18)=0.964767932d0!O2-H2O
      bvij(16,21)=0.999746847d0
      gvij(16,21)=0.993907223d0
      btij(16,21)=1.000023103d0
      gtij(16,21)=0.990430423d0!O2-Ar
      bvij(17,19)=0.795660392d0
      gvij(17,19)=1.101731308d0
      btij(17,19)=1.025536736d0
      gtij(17,19)=1.022749748d0!CO-H2S
      gvij(17,21)=1.159720623d0
      gtij(17,21)=0.954215746d0!CO-Ar
      gvij(18,19)=1.014832832d0
      gtij(18,19)=0.940587083d0!H2O-H2S
      gvij(18,21)=1.038993495d0
      gtij(18,21)=1.070941866d0!H2O-Ar

      Do i=1,MaxFlds
        bvij(i,i)=1.d0
        btij(i,i)=1.d0
        gvij(i,i)=1.d0/Dc(i)
        gtij(i,i)=Tc(i)
        Do j=i+1,MaxFlds
          gvij(i,j)=gvij(i,j)*bvij(i,j)*(Vc3(i)+Vc3(j))**3
          gtij(i,j)=gtij(i,j)*btij(i,j)*Tc2(i)*Tc2(j)
          bvij(i,j)=bvij(i,j)**2
          btij(i,j)=btij(i,j)**2
        Enddo
      Enddo

      Do i=1,MaxMdl
        Do j=1,MaxTrmM
          gijk(i,j)=-cijk(i,j)*eijk(i,j)**2+bijk(i,j)*gijk(i,j)
          eijk(i,j)=2*cijk(i,j)*eijk(i,j)-bijk(i,j)
          cijk(i,j)=-cijk(i,j)
        Enddo
      Enddo

c  Ideal gas terms
      T0=298.15d0
      d0=101.325d0/RGERG/T0
      Do i=1,MaxFlds
        n0i(i,3)=n0i(i,3)-1
        n0i(i,2)=n0i(i,2)+T0
        n0i(i,1:7)=Rsr*n0i(i,1:7)
        n0i(i,2)=n0i(i,2)-T0
        n0i(i,1)=n0i(i,1)-Log(d0)
      Enddo
      RETURN

c  Code to produce nearly exact values for n0(1) and n0(2)
c  This is not called in the current code, but included below to show how the values were calculated.  The RETURN above can be removed to call this code.
      T0=298.15d0
      d0=101.325d0/RGERG/T0
      Do i=1,MaxFlds
        n1=0.d0
        n2=0.d0
        If (th0i(i,4).gt.Epsilon) Then
          n2=n2-n0i(i,4)*th0i(i,4)/Tanh(th0i(i,4)/T0)
          n1=n1-n0i(i,4)*Log(Sinh(th0i(i,4)/T0))
        End If
        If (th0i(i,5).gt.Epsilon) Then
          n2=n2+n0i(i,5)*th0i(i,5)*Tanh(th0i(i,5)/T0)
          n1=n1+n0i(i,5)*Log(Cosh(th0i(i,5)/T0))
        End If
        If (th0i(i,6).gt.Epsilon) Then
          n2=n2-n0i(i,6)*th0i(i,6)/Tanh(th0i(i,6)/T0)
          n1=n1-n0i(i,6)*Log(Sinh(th0i(i,6)/T0))
        End If
        If (th0i(i,7).gt.Epsilon) Then
          n2=n2+n0i(i,7)*th0i(i,7)*Tanh(th0i(i,7)/T0)
          n1=n1+n0i(i,7)*Log(Cosh(th0i(i,7)/T0))
        End If
        n0i(i,3)=n0i(i,3)-1.d0
        n0i(i,1)=n1-n2/T0+n0i(i,3)*(1.d0+Log(T0))
        n0i(i,2)=n2-n0i(i,3)*T0
        n0i(i,1:7)=Rsr*n0i(i,1:7)
        n0i(i,2)=n0i(i,2)-T0
        n0i(i,1)=n0i(i,1)-Log(d0)
      Enddo
      END

c-----------------------------------------------------------------------

      BLOCK DATA GERGConstants
      include 'GERG2008.CMN'
      integer i,j
      data gvij/441*1/
      data btij/441*1/
      data gtij/441*1/
      data bvij/441*1/
      data dijk/120*0/
      data tijk/120*0/
      data cijk/120*0/
      data eijk/120*0/
      data gijk/120*0/
      data nijk/120*0/

c  Ideal gas parameters
      data ((n0i(i,j),j=3,7),i=1,21)/
     &  4.00088d0, 0.76315d0, 0.00460d0, 8.74432d0,-4.46921d0,
     &  3.50031d0, 0.13732d0,-0.1466d0,  0.90066d0,      0.d0,
     &  3.50002d0, 2.04452d0,-1.06044d0, 2.03366d0, 0.01393d0,
     &  4.00263d0, 4.33939d0, 1.23722d0, 13.1974d0,-6.01989d0,
     &  4.02939d0, 6.60569d0, 3.19700d0, 19.1921d0,-8.37267d0,
     &  4.06714d0, 8.97575d0, 5.25156d0, 25.1423d0, 16.1388d0,
     &  4.33944d0, 9.44893d0, 6.89406d0, 24.4618d0, 14.7824d0,
     &       4.d0, 11.7618d0, 20.1101d0, 33.1688d0,      0.d0,
     &       4.d0, 8.95043d0, 21.8360d0, 33.4032d0,      0.d0,
     &       4.d0, 11.6977d0, 26.8142d0, 38.6164d0,      0.d0,
     &       4.d0, 13.7266d0, 30.4707d0, 43.5561d0,      0.d0,
     &       4.d0, 15.6865d0, 33.8029d0, 48.1731d0,      0.d0,
     &       4.d0, 18.0241d0, 38.1235d0, 53.3415d0,      0.d0,
     &       4.d0, 21.0069d0, 43.4931d0, 58.3657d0,      0.d0,
     &  2.47906d0, 0.95806d0, 0.45444d0, 1.56039d0,-1.37560d0,
     &  3.50146d0, 1.07558d0, 1.01334d0,      0.d0,      0.d0,
     &  3.50055d0, 1.02865d0, 0.00493d0,      0.d0,      0.d0,
     &  4.00392d0, 0.01059d0, 0.98763d0, 3.06904d0,      0.d0,
     &       4.d0, 3.11942d0, 1.00243d0,      0.d0,      0.d0,
     &      2.5d0,      0.d0,      0.d0,      0.d0,      0.d0,
     &      2.5d0,      0.d0,      0.d0,      0.d0,      0.d0/

      data (n0i( 1,i),i=1,2) /29.83843397d0,-15999.69151d0/
      data (n0i( 2,i),i=1,2) /17.56770785d0,-2801.729072d0/
      data (n0i( 3,i),i=1,2) /20.65844696d0,-4902.171516d0/
      data (n0i( 4,i),i=1,2) /36.73005938d0,-23639.65301d0/
      data (n0i( 5,i),i=1,2) /44.70909619d0,-31236.63551d0/
      data (n0i( 6,i),i=1,2) /34.30180349d0,-38525.50276d0/
      data (n0i( 7,i),i=1,2) /36.53237783d0,-38957.80933d0/
      data (n0i( 8,i),i=1,2) /43.17218626d0,-51198.30946d0/
      data (n0i( 9,i),i=1,2) /42.67837089d0,-45215.83000d0/
      data (n0i(10,i),i=1,2) /46.99717188d0,-52746.83318d0/
      data (n0i(11,i),i=1,2) /52.07631631d0,-57104.81056d0/
      data (n0i(12,i),i=1,2) /57.25830934d0,-60546.76385d0/
      data (n0i(13,i),i=1,2) /62.09646901d0,-66600.12837d0/
      data (n0i(14,i),i=1,2) /65.93909154d0,-74131.45483d0/
      data (n0i(15,i),i=1,2) /13.07520288d0,-5836.943696d0/
      data (n0i(16,i),i=1,2) /16.80171730d0,-2318.322690d0/
      data (n0i(17,i),i=1,2) /17.45786899d0,-2635.244116d0/
      data (n0i(18,i),i=1,2) /21.57882705d0,-7766.733078d0/
      data (n0i(19,i),i=1,2) /21.58309440d0,-6069.035869d0/
      data (n0i(20,i),i=1,2) /10.04639507d0,-745.375d0    /
      data (n0i(21,i),i=1,2) /10.04639507d0,-745.375d0    /

      data (th0i(1,i),i=4,7) /820.659d0,178.410d0,1062.82d0,1090.53d0/
      data (th0i(2,i),i=4,7) /662.738d0,680.562d0,1740.06d0,     0.d0/
      data (th0i(3,i),i=4,7) /919.306d0,865.070d0,483.553d0,341.109d0/
      data (th0i(4,i),i=4,7) /559.314d0,223.284d0,1031.38d0,1071.29d0/
      data (th0i(5,i),i=4,7) /479.856d0,200.893d0,955.312d0,1027.29d0/
      data (th0i(6,i),i=4,7) /438.270d0,198.018d0,1905.02d0,893.765d0/
      data (th0i(7,i),i=4,7) /468.270d0,183.636d0,1914.10d0,903.185d0/
      data (th0i(8,i),i=4,7) /292.503d0,910.237d0,1919.37d0,     0.d0/
      data (th0i(9,i),i=4,7) /178.670d0,840.538d0,1774.25d0,     0.d0/
      data (th0i(10,i),i=4,7)/182.326d0,859.207d0,1826.59d0,     0.d0/
      data (th0i(11,i),i=4,7)/169.789d0,836.195d0,1760.46d0,     0.d0/
      data (th0i(12,i),i=4,7)/158.922d0,815.064d0,1693.07d0,     0.d0/
      data (th0i(13,i),i=4,7)/156.854d0,814.882d0,1693.79d0,     0.d0/
      data (th0i(14,i),i=4,7)/164.947d0,836.264d0,1750.24d0,     0.d0/
      data (th0i(15,i),i=4,7)/228.734d0,326.843d0,1651.71d0,1671.69d0/
      data (th0i(16,i),i=4,7)/2235.71d0,1116.69d0,     0.d0,     0.d0/
      data (th0i(17,i),i=4,7)/1550.45d0,704.525d0,     0.d0,     0.d0/
      data (th0i(18,i),i=4,7)/268.795d0,1141.41d0,2507.37d0,     0.d0/
      data (th0i(19,i),i=4,7)/1833.63d0,847.181d0,     0.d0,     0.d0/
      data (th0i(20,i),i=4,7)/     0.d0,     0.d0,     0.d0,     0.d0/
      data (th0i(21,i),i=4,7)/     0.d0,     0.d0,     0.d0,     0.d0/

      END
