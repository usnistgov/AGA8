c  Example program for calling routines for the DETAIL equation of state.

      subroutine Example
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
      Call MolarMassDetail(x,Mm)
      write (*,*) 'Molar mass [g/mol]:                ',SNGL(mm)

c  Get molar density at T and P.
      Call DensityDetail(T,P,x,D,ierr,herr)
      write (*,*) 'Molar density [mol/l]:             ',SNGL(D)

c  Get pressure from T and D.
      Call PressureDetail(T,D,x,pp,z)
      write (*,*) 'Pressure [kPa]:                    ',SNGL(pp)

c  Get all other properties at T and D.
c  For T and P inputs, the DensityDetail routine must be called first to get D.
      Call PropertiesDetail(T,D,x,pp,Z,dPdD,d2PdD2,d2PdTD,dPdT,
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
c
c  Version 2.0 of routines for the calculation of thermodynamic
c   properties from the AGA 8 Part 1 DETAIL equation of state.
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
c  ***** Subroutine SetupDetail must be called once before calling other routines. ******
c  Sub MolarMassDetail(x, Mm)
c  Sub PressureDetail(T, D, x, P, Z)
c  Sub DensityDetail(T, P, x, D, ierr, herr)
c  Sub PropertiesDetail(T, D, x, P, Z, dPdD, d2PdD2, d2PdTD, dPdT, U, H, S, Cv, Cp, W, G, JT, Kappa)
c  Sub SetupDetail()
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

      SUBROUTINE MolarMassDetail(x,Mm)

c  Calculate molar mass of the mixture with the compositions contained in the x() input array
c
c  Inputs:
c     x() - Composition (mole fraction)
c         Do not send mole percents or mass fractions in the x() array, otherwise the output will be incorrect.
c         The sum of the compositions in the x() array must be equal to one.
c         The order of the fluids in this array is given at the top of this code.
c
c  Outputs:
c      Mm - Molar mass (g/mol)

      include 'DETAIL.CMN'
      double precision x(MaxFlds),Mm

      if (Kij5(1,1).eq.1) Call SetupDetail
      Mm=SUM(x(1:NcDetail)*MMiDetail(1:NcDetail))
      END

c-----------------------------------------------------------------------

      SUBROUTINE PressureDetail(T,D,x,P,Z)

c  Calculate pressure as a function of temperature and density.  The derivative d(P)/d(D) is also calculated
c  for use in the iterative DensityDetail subroutine (and is only returned as a common variable).
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
c    dPdDsave - d(P)/d(D) [kPa/(mol/l)] (at constant temperature)
c             - This variable is cached in the common variables for use in the iterative density solver, but not returned as an argument

      include 'DETAIL.CMN'
      double precision T,D,x(MaxFlds),ar(0:3,0:3),P,Z

      if (Kij5(1,1).eq.1) Call SetupDetail
      Call xTermsDetail(x)
      Call AlpharDetail(0,2,T,D,ar)
      Z=1.d0+ar(0,1)/RDetail/T         !ar(0,1) is the first derivative of alpha(r) with respect to density
      P=D*RDetail*T*Z
      dPdDsave=RDetail*T+2.d0*ar(0,1)+ar(0,2)  !d(P)/d(D) for use in density iteration
      END

c-----------------------------------------------------------------------

      SUBROUTINE DensityDetail(T,P,x,D,ierr,herr)

c  Calculate density as a function of temperature and pressure.  This is an iterative routine that calls PressureDetail
c  to find the correct state point.  Generally only 6 iterations at most are required.
c  If the iteration fails to converge, the ideal gas density and an error message are returned.
c  No checks are made to determine the phase boundary, which would have guaranteed that the output is in the gas phase.
c  It is up to the user to locate the phase boundary, and thus identify the phase of the T and P inputs.
c  If the state point is 2-phase, the output density will represent a metastable state.
c
c  Inputs:
c       T - Temperature (K)
c       P - Pressure (kPa)
c     x() - Composition (mole fraction)
c
c  Outputs:
c       D - Density (mol/l) (make D negative and send as an input to use as an initial guess)
c    ierr - Error number (0 indicates no error)
c    herr - Error message if ierr is not equal to zero

      include 'DETAIL.CMN'
      integer it,ierr
      double precision T,P,x(MaxFlds),plog,vlog,P2,Z,dpdlv,vdiff,tolr,D
      character*255 herr

      if (Kij5(1,1).eq.1) Call SetupDetail
      ierr=0
      herr=' '
      If (ABS(P).lt.Epsilon) Then
        D=0.d0
        RETURN
      endif
      tolr=1.d-7
      If (D.gt.-Epsilon) Then
        D=P/RDetail/T  !Ideal gas estimate
      Else
        D=Abs(D)           !If D<0 use as initial estimate
      End If
      plog=Log(P)
      vlog=-Log(D)
      Do it=1,20
        If (vlog.lt.-7.d0 .or. vlog.gt.100.d0) GoTo 10
        D=Exp(-vlog)
        Call PressureDetail(T,D,x,P2,Z)
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
            D=Exp(-vlog)
            RETURN         !Iteration converged
          End If
        End If
      Enddo

 10   Continue
      ierr=1
      herr = 'Calculation failed to converge in DETAIL method, ideal gas
     & density returned.'
      D=P/RDetail/T
      END

c-----------------------------------------------------------------------

      SUBROUTINE PropertiesDetail(T,D,x,P,Z,dPdD,d2PdD2,d2PdTD,dPdT,
     &                            U,H,S,Cv,Cp,W,G,JT,Kappa)

c  Calculate thermodynamic properties as a function of temperature and density.  Calls are made to the subroutines
c  MolarmassDetail, Alpha0Detail, and AlpharDetail.  If the density is not known, call subroutine DensityDetail first
c  with the known values of pressure and temperature.
c
c  Inputs:
c       T - Temperature (K)
c       D - Density (mol/l)
c     x() - Composition (mole fraction)
c
c  Outputs:
c       P - Pressure (kPa)
c       Z - Compressibility factor
c    dPdD - First derivative of pressure with respect to density at constant temperature [kPa/(mol/l)]
c  d2PdD2 - Second derivative of pressure with respect to density at constant temperature [kPa/(mol/l)^2]
c  d2PdTD - Second derivative of pressure with respect to temperature and density [kPa/(mol/l)/K] (currently not calculated)
c    dPdT - First derivative of pressure with respect to temperature at constant density (kPa/K)
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

      include 'DETAIL.CMN'
      double precision T,D,P,Z,dPdD,d2PdD2,d2PdTD,dPdT
      double precision U,H,S,Cv,Cp,W,G,JT,Kappa
      double precision x(MaxFlds),a0(0:2),ar(0:3,0:3),A,Mm,R,RT

      if (Kij5(1,1).eq.1) Call SetupDetail
      Call MolarMassDetail(x,Mm)
      Call xTermsDetail(x)

c  Calculate the ideal gas Helmholtz energy, and its first and second derivatives with respect to temperature.
      Call Alpha0Detail(T,D,x,a0)

c  Calculate the real gas Helmholtz energy, and its derivatives with respect to temperature and/or density.
      Call AlpharDetail(2,3,T,D,ar)

      R=RDetail
      RT=R*T
      Z=1.d0+ar(0,1)/RT
      P=D*RT*Z
      dPdD=RT+2.d0*ar(0,1)+ar(0,2)
      dPdT=D*R+D*ar(1,1)
      A=a0(0)+ar(0,0)
      S=-a0(1)-ar(1,0)
      U=A+T*S
      Cv=-(a0(2)+ar(2,0))
      If (D.gt.Epsilon) Then
        H=U+P/D
        G=A+P/D
        Cp=Cv+T*(dPdT/D)**2/dPdD
        d2PdD2=(2.d0*ar(0,1)+4.d0*ar(0,2)+ar(0,3))/D
        JT=(T/D*dPdT/dPdD-1.d0)/Cp/D
      Else
        H=U+RT
        G=A+RT
        Cp=Cv+R
        d2PdD2=0.d0
        JT=1d+20   !=(dB/dT*T-B)/Cp for an ideal gas, but dB/dT is not calculated here
      End If
      W=1000.d0*Cp/Cv*dPdD/Mm
      If (W.lt.0.d0) W=0.d0
      W=Sqrt(W)
      Kappa=W**2*Mm/(RT*1000.d0*Z)
      d2PdTD=0d0
      END


c-----------------------------------------------------------------------
c
c  The following routines are low-level routines that should not be called outside of this code.c
c
c-----------------------------------------------------------------------

      SUBROUTINE xTermsDetail(x)

c  Calculate terms dependent only on composition
c
c  Inputs:
c     x() - Composition (mole fraction)

      include 'DETAIL.CMN'
      integer i,j,n,iCheck
      double precision x(MaxFlds),G,Q,F,U,Q2,xij,xi2

c  Check to see if a component fraction has changed.  If x is the same as the previous call, then exit.
      iCheck=0
      Do i=1,NcDetail
        If (Abs(x(i)-xold(i)).gt.0.00000000001d0) iCheck=1
        xold(i)=x(i)
      Enddo
      If (iCheck.eq.0) RETURN

      K3=0.d0
      U=0.d0
      G=0.d0
      Q=0.d0
      F=0.d0
      Bs=0.d0

c  Calculate pure fluid contributions
      Do i=1,NcDetail
        If (x(i).gt.0) Then
          xi2=x(i)**2
          K3=K3+x(i)*Ki25(i)     !K,U,and G are the sums of a pure fluid contribution and a
          U=U+x(i)*Ei25(i)       !   binary pair contribution
          G=G+x(i)*Gi(i)
          Q=Q+x(i)*Qi(i)         !Q and F depend only on the pure fluid parts
          F=F+xi2*Fi(i)
          Bs(1:18)=Bs(1:18)+xi2*Bsnij2(i,i,1:18)   !Pure fluid contributions to second virial coefficient
        End If
      Enddo
      K3=K3**2
      U=U**2

c  Binary pair contributions
      Do i=1,NcDetail-1
        If (x(i).gt.0.d0) Then
          Do j=i+1,NcDetail
            If (x(j).gt.0.d0) Then
              xij=2.d0*x(i)*x(j)
              K3=K3+xij*Kij5(i,j)
              U=U+xij*Uij5(i,j)
              G=G+xij*Gij5(i,j)
              Bs(1:18)=Bs(1:18)+xij*Bsnij2(i,j,1:18)      !Second virial coefficients of mixture
            End If
          Enddo
        End If
      Enddo
      K3=K3**0.6d0
      U=U**0.2d0

c  Third virial and higher coefficients
      Q2=Q**2
      Do n=13,58
        Csn(n)=an(n)*U**un(n)
        If (gn(n).eq.1) Csn(n)=Csn(n)*G
        If (qn(n).eq.1) Csn(n)=Csn(n)*Q2
        If (fn(n).eq.1) Csn(n)=Csn(n)*F
      Enddo
      END

c-----------------------------------------------------------------------

      SUBROUTINE Alpha0Detail(T,D,x,a0)

c  Calculate the ideal gas Helmholtz energy and its derivatives with respect to T and D.
c  This routine is not needed when only P (or Z) is calculated.
c
c  Inputs:
c       T - Temperature (K)
c       D - Density (mol/l)
c     x() - Composition (mole fraction)
c
c  Outputs:
c   a0(0) - Ideal gas Helmholtz energy (J/mol)
c   a0(1) -   partial  (a0)/partial(T) [J/(mol-K)]
c   a0(2) - T*partial^2(a0)/partial(T)^2 [J/(mol-K)]

      include 'DETAIL.CMN'
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
      Do i=1,NcDetail
        If (x(i).gt.0.d0) Then
          LogxD=LogD+Log(x(i))
          SumHyp0=0.d0
          SumHyp1=0.d0
          SumHyp2=0.d0
          Do j=4,7
            If (th0i(i,j).gt.0.d0) Then
              th0T=th0i(i,j)/T
              ep=Exp(th0T)
              em=1.d0/ep
              hsn=(ep-em)/2.d0
              hcn=(ep+em)/2.d0
              If (j.eq.4 .or. j.eq.6) Then
                LogHyp=Log(Abs(hsn))
                SumHyp0=SumHyp0+n0i(i,j)*LogHyp
                SumHyp1=SumHyp1+n0i(i,j)*(LogHyp-th0T*hcn/hsn)
                SumHyp2=SumHyp2+n0i(i,j)*(th0T/hsn)**2
              Else
                LogHyp=Log(Abs(hcn))
                SumHyp0=SumHyp0-n0i(i,j)*LogHyp
                SumHyp1=SumHyp1-n0i(i,j)*(LogHyp-th0T*hsn/hcn)
                SumHyp2=SumHyp2+n0i(i,j)*(th0T/hcn)**2
              End If
            End If
          Enddo
          a0(0)=a0(0)
     &         +x(i)*(LogxD+n0i(i,1)+n0i(i,2)/T-n0i(i,3)*LogT+SumHyp0)
          a0(1)=a0(1)+x(i)*(LogxD+n0i(i,1)-n0i(i,3)*(1.d0+LogT)+SumHyp1)
          a0(2)=a0(2)-x(i)*(n0i(i,3)+SumHyp2)
        End If
      Enddo
      a0(0)=a0(0)*RDetail*T
      a0(1)=a0(1)*RDetail
      a0(2)=a0(2)*RDetail
      END

c-----------------------------------------------------------------------

      SUBROUTINE AlpharDetail(itau,idel,T,D,ar)

c  Calculate the derivatives of the residual Helmholtz energy with respect to T and D.
c  Outputs are returned in the array ar.
c  Subroutine xTerms must be called before this routine if x has changed

c  Inputs:
c    itau - Set this to 1 to calculate "ar" derivatives with respect to T [i.e., ar(1,0), ar(1,1), and ar(2,0)], otherwise set it to 0.
c    idel - Currently not used, but kept as an input for future use in specifing the highest density derivative needed.
c       T - Temperature (K)
c       D - Density (mol/l)
c
c  Outputs:
c   ar(0,0) - Residual Helmholtz energy (J/mol)
c   ar(0,1) -   D*partial  (ar)/partial(D) (J/mol)
c   ar(0,2) - D^2*partial^2(ar)/partial(D)^2 (J/mol)
c   ar(0,3) - D^3*partial^3(ar)/partial(D)^3 (J/mol)
c   ar(1,0) -     partial  (ar)/partial(T) [J/(mol-K)]
c   ar(1,1) -   D*partial^2(ar)/partial(D)/partial(T) [J/(mol-K)]
c   ar(2,0) -   T*partial^2(ar)/partial(T)^2 [J/(mol-K)]

      include 'DETAIL.CMN'
      integer n,itau,idel
      double precision ar(0:3,0:3),T,D
      double precision ckd,bkd,Dred,Sum,s0,s1,s2,s3,RT
      double precision Sum0(NTerms),SumB(NTerms),Dknn(0:9),Expn(0:4)
      double precision CoefD1(NTerms),CoefD2(NTerms),CoefD3(NTerms)
      double precision CoefT1(NTerms),CoefT2(NTerms)

      ar=0.d0
      If (Abs(T-Told).gt.0.00000000001d0) Then
        Do n=1,58
          Tun(n)=T**(-un(n))
        Enddo
      End If
      Told=T

c  Precalculation of common powers and exponents of density
      Dred=K3*D
      Dknn(0)=1.d0
      Do n=1,9
        Dknn(n)=Dred*Dknn(n-1)
      Enddo
      Expn(0)=1
      Expn(1:4)=Exp(-Dknn(1:4))
      RT=RDetail*T

      Do n=1,58
c  Contributions to the Helmholtz energy and its derivatives with respect to temperature
        CoefT1(n)=RDetail*(un(n)-1.d0)
        CoefT2(n)=CoefT1(n)*un(n)
c  Contributions to the virial coefficients
        SumB(n)=0.d0
        Sum0(n)=0.d0
        If (n.le.18) Then
          Sum=Bs(n)*D
          If (n.ge.13) Sum=Sum-Csn(n)*Dred
          SumB(n)=Sum*Tun(n)
        End If
        If (n.ge.13) Then
c  Contributions to the residual part of the Helmholtz energy
          Sum0(n)=Csn(n)*Dknn(bn(n))*Tun(n)*Expn(kn(n))
c  Contributions to the derivatives of the Helmholtz energy with respect to density
          bkd=dble(bn(n))-dble(kn(n))*Dknn(kn(n))
          ckd=dble(kn(n))**2*Dknn(kn(n))
          CoefD1(n)=bkd
          CoefD2(n)=bkd*(bkd-1.d0)-ckd
          CoefD3(n)=(bkd-2.d0)*CoefD2(n)+ckd*(1.d0-dble(kn(n))-2.d0*bkd)
        Else
          CoefD1(n)=0.d0
          CoefD2(n)=0.d0
          CoefD3(n)=0.d0
        End If
      Enddo

      Do n=1,58
c  Density derivatives
        s0=Sum0(n)+SumB(n)
        s1=Sum0(n)*CoefD1(n)+SumB(n)
        s2=Sum0(n)*CoefD2(n)
        s3=Sum0(n)*CoefD3(n)
        ar(0,0)=ar(0,0)+RT*s0
        ar(0,1)=ar(0,1)+RT*s1
        ar(0,2)=ar(0,2)+RT*s2
        ar(0,3)=ar(0,3)+RT*s3
c  Temperature derivatives
        If (itau.gt.0) Then
          ar(1,0)=ar(1,0)-CoefT1(n)*s0
          ar(1,1)=ar(1,1)-CoefT1(n)*s1
          ar(2,0)=ar(2,0)+CoefT2(n)*s0
c  The following are not used, but fully functional
c         ar(1,2)=ar(1,2)-CoefT1(n)*s2
c         ar(1,3)=ar(1,3)-CoefT1(n)*s3
c         ar(2,1)=ar(2,1)+CoefT2(n)*s1
c         ar(2,2)=ar(2,2)+CoefT2(n)*s2
c         ar(2,3)=ar(2,3)+CoefT2(n)*s3
        End If
      Enddo
      END

c-----------------------------------------------------------------------

c  The following routine must be called once before any other routine.

      SUBROUTINE SetupDetail

c  Initialize all the constants and parameters in the DETAIL model.
c  Some values are modified for calculations that do not depend on T, D, and x in order to speed up the program

      include 'DETAIL.CMN'
      integer i,j,n,sn(NTerms),wn(NTerms)
      double precision Bsnij,T0,d0,n1,n2
      double precision Ei(MaxFlds),Ki(MaxFlds),Si(MaxFlds),Wi(MaxFlds)
      double precision Kij(MaxFlds,MaxFlds),Gij(MaxFlds,MaxFlds),
     & Eij(MaxFlds,MaxFlds),Uij(MaxFlds,MaxFlds)
      common /DETAIL2/ Ei,Ki,Si,Wi,Kij,Gij,Eij,Uij,sn,wn

c  Precalculations of constants
      Told=0.d0
      xold=0.d0
      Do i=1,MaxFlds
        Ki25(i)=Ki(i)**2.5d0
        Ei25(i)=Ei(i)**2.5d0
      Enddo
      Do i=1,MaxFlds
        Do j=i,MaxFlds
          Do n=1,18
            Bsnij=1.d0
            If (gn(n).eq.1) Bsnij=Gij(i,j)*(Gi(i)+Gi(j))/2.d0
            If (qn(n).eq.1) Bsnij=Bsnij*Qi(i)*Qi(j)
            If (fn(n).eq.1) Bsnij=Bsnij*Fi(i)*Fi(j)
            If (sn(n).eq.1) Bsnij=Bsnij*Si(i)*Si(j)
            If (wn(n).eq.1) Bsnij=Bsnij*Wi(i)*Wi(j)
            Bsnij2(i,j,n)=an(n)*(Eij(i,j)*
     &        Sqrt(Ei(i)*Ei(j)))**un(n)*(Ki(i)*Ki(j))**1.5d0*Bsnij
          Enddo
          Kij5(i,j)=(Kij(i,j)**5-1.d0)*Ki25(i)*Ki25(j)
          Uij5(i,j)=(Uij(i,j)**5-1.d0)*Ei25(i)*Ei25(j)
          Gij5(i,j)=(Gij(i,j)-1.d0)*(Gi(i)+Gi(j))/2.d0
        Enddo
      Enddo

c  Ideal gas terms
      T0=298.15d0
      d0=101.325d0/RDetail/T0
      Do i=1,MaxFlds
        n0i(i,3)=n0i(i,3)-1.d0
        n0i(i,1)=n0i(i,1)-Log(d0)
      Enddo
      RETURN

c  Code to produce nearly exact values for n0(1) and n0(2)
c  This is not called in the current code, but included below to show how the values were calculated.  The RETURN above can be removed to call this code.
      T0=298.15d0
      d0=101.325d0/RDetail/T0
      Do i=1,MaxFlds
        n1=0.d0
        n2=0.d0
        If (th0i(i,4).gt.0.d0) Then
          n2=n2-n0i(i,4)*th0i(i,4)/Tanh(th0i(i,4)/T0)
          n1=n1-n0i(i,4)*Log(Sinh(th0i(i,4)/T0))
        End If
        If (th0i(i,5).gt.0.d0) Then
          n2=n2+n0i(i,5)*th0i(i,5)*Tanh(th0i(i,5)/T0)
          n1=n1+n0i(i,5)*Log(Cosh(th0i(i,5)/T0))
        End If
        If (th0i(i,6).gt.0.d0) Then
          n2=n2-n0i(i,6)*th0i(i,6)/Tanh(th0i(i,6)/T0)
          n1=n1-n0i(i,6)*Log(Sinh(th0i(i,6)/T0))
        End If
        If (th0i(i,7).gt.0.d0) Then
          n2=n2+n0i(i,7)*th0i(i,7)*Tanh(th0i(i,7)/T0)
          n1=n1+n0i(i,7)*Log(Cosh(th0i(i,7)/T0))
        End If
        n0i(i,2)=n2-n0i(i,3)*T0
        n0i(i,3)=n0i(i,3)-1.d0
        n0i(i,1)=n1-n2/T0+n0i(i,3)*(1.d0+Log(T0))-Log(d0)
      Enddo
      END

c-----------------------------------------------------------------------

      BLOCK DATA DetailConstants
      include 'DETAIL.CMN'
      integer i,j
      integer sn(NTerms),wn(NTerms)
      double precision Ei(MaxFlds),Ki(MaxFlds),Si(MaxFlds),Wi(MaxFlds)
      double precision Kij(MaxFlds,MaxFlds),Gij(MaxFlds,MaxFlds)
      double precision Eij(MaxFlds,MaxFlds),Uij(MaxFlds,MaxFlds)
      common /DETAIL2/ Ei,Ki,Si,Wi,Kij,Gij,Eij,Uij,sn,wn

c  Ideal gas constant (J/mol-K)
      data RDetail /8.31451d0/

c  Molar masses (g/mol)
      data MMiDetail/
     &  16.043d0,28.0135d0,44.01d0,30.07d0,44.097d0,58.123d0,58.123d0,
     &  72.15d0,72.15d0,86.177d0,100.204d0,114.231d0,128.258d0,
     &  142.285d0,2.0159d0,31.9988d0,28.01d0,18.0153d0,34.082d0,
     &  4.0026d0,39.948d0/

c  Density exponents
      data bn/1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,
     &    2,2,2,2,2,2,2,2,2,3,3,3,3,3,3,3,3,3,3,4,4,4,4,4,4,4,
     &    5,5,5,5,5,6,6,7,7,8,8,8,9,9/

c  Exponents on density in EXP(-cn*D^kn) part
c  The cn part in this term is not included in this program since it is 1 when kn<>1, and 0 otherwise
      data kn/0,0,0,0,0,0,0,0,0,0,0,0,3,2,2,2,4,4,
     &    0,0,2,2,2,4,4,4,4,0,1,1,2,2,3,3,4,4,4,0,0,2,2,2,4,4,
     &    0,2,2,4,4,0,2,0,2,1,2,2,2,2/

c  Temperature exponents
      data un/0.d0,0.5d0,1.d0,3.5d0,-0.5d0,4.5d0,0.5d0,
     &    7.5d0,9.5d0,6.d0,12.d0,12.5d0,-6.d0,2.d0,3.d0,2.d0,2.d0,
     &    11.d0,-0.5d0,0.5d0,0.d0,4.d0,6.d0,21.d0,23.d0,22.d0,-1.d0,
     &    -0.5d0,7.d0,-1.d0,6.d0,4.d0,1.d0,9.d0,-13.d0,21.d0,8.d0,
     &    -0.5d0,0.d0,2.d0,7.d0,9.d0,22.d0,23.d0,1.d0,9.d0,3.d0,8.d0,
     &    23.d0,1.5d0,5.d0,-0.5d0,4.d0,7.d0,3.d0,0.d0,1.d0,0.d0/

c  Coefficients of the equation of state
      data an/
     &  0.1538326d0,1.341953d0,-2.998583d0,-0.04831228d0,0.3757965d0,
     &  -1.589575d0,-0.05358847d0,0.88659463d0,-0.71023704d0,
     &  -1.471722d0,1.32185035d0,-0.78665925d0,0.00000000229129d0,
     &  0.1576724d0,-0.4363864d0,-0.04408159d0,-0.003433888d0,
     &  0.03205905d0,0.02487355d0,0.07332279d0,-0.001600573d0,
     &  0.6424706d0,-0.4162601d0,-0.06689957d0,0.2791795d0,
     &  -0.6966051d0,-0.002860589d0,-0.008098836d0,3.150547d0,
     &  0.007224479d0,-0.7057529d0,0.5349792d0,-0.07931491d0,
     &  -1.418465d0,-5.99905d-17,0.1058402d0,0.03431729d0,
     &  -0.007022847d0,0.02495587d0,0.04296818d0,0.7465453d0,
     &  -0.2919613d0,7.294616d0,-9.936757d0,-0.005399808d0,
     &  -0.2432567d0,0.04987016d0,0.003733797d0,1.874951d0,
     &  0.002168144d0,-0.6587164d0,0.000205518d0,0.009776195d0,
     &  -0.02048708d0,0.01557322d0,0.006862415d0,-0.001226752d0,
     &  0.002850908d0/

c  Energy parameters
      data Ei/
     &  151.3183d0,99.73778d0,241.9606d0,244.1667d0,298.1183d0,
     &  324.0689d0,337.6389d0,365.5999d0,370.6823d0,402.636293d0,
     &  427.72263d0,450.325022d0,470.840891d0,489.558373d0,26.95794d0,
     & 122.7667d0,105.5348d0,514.0156d0,296.355d0,2.610111d0,119.6299d0/

c  Size parameters
      data Ki/
     &  0.4619255d0,0.4479153d0,0.4557489d0,0.5279209d0,0.583749d0,
     &  0.6406937d0,0.6341423d0,0.6738577d0,0.6798307d0,0.7175118d0,
     &  0.7525189d0,0.784955d0,0.8152731d0,0.8437826d0,0.3514916d0,
     &  0.4186954d0,0.4533894d0,0.3825868d0,0.4618263d0,0.3589888d0,
     &  0.4216551d0/

c  Orientation parameters
      data Gi/
     &  0.d0,0.027815d0,0.189065d0,0.0793d0,0.141239d0,0.256692d0,
     &  0.281835d0,0.332267d0,0.366911d0,0.289731d0,0.337542d0,
     &  0.383381d0,0.427354d0,0.469659d0,0.034369d0,0.021d0,0.038953d0,
     &  0.3325d0,0.0885d0,0.d0,0.d0/

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

c  Flags
      data fn/12*0,1,13*0,1,2*0,1,4*0,1,23*0/
      data gn/4*0,2*1,18*0,1,3*0,1,2*0,3*1,16*0,1,2*0,1,0,1,2*0/
      data qn/6*0,1,8*0,1,9*0,1,0,1,8*0,1,4*0,1,4*0,1,0,1,2*0,1,5*0,1/
      data sn/7*0,2*1,49*0/
      data wn/9*0,3*1,46*0/

c  Quadrupole, high temperature, dipole, and association parameters
      data Qi/2*0,0.69d0,14*0,1.06775d0,0.633276d0,2*0/
      data Fi/14*0,1,6*0/
      data Si/17*0,1.5822d0,0.39d0,2*0/
      data Wi/17*0,1,3*0/

c  Orientation parameters
      data ((Gij(i,j),i=4,21),j=1,21)/378*1/
      data  (Gij(1,j),j=1,21)/2*1,0.807653d0,11*1,1.95731d0,6*1/
      data  (Gij(2,j),j=1,21)/2*1,0.982746d0,18*1/
      data  (Gij(3,j),j=1,21)/3*1,0.370296d0,13*1,1.67309d0,3*1/

c  Size parameters
      data ((Kij(i,j),i=5,9)  ,j=1,21)/105*1/
      data ((Kij(i,j),i=15,21),j=1,21)/147*1/
      data  (Kij(10,j),j=1,21)/18*1,0.96813d0,2*1/
      data  (Kij(11,j),j=1,21)/18*1,0.96287d0,2*1/
      data  (Kij(12,j),j=1,21)/18*1,0.957828d0,2*1/
      data  (Kij(13,j),j=1,21)/18*1,0.952441d0,2*1/
      data  (Kij(14,j),j=1,21)/18*1,0.948338d0,2*1/
      data  (Kij(1,j),j=1,21)/1,1.00363d0,0.995933d0,1,1.007619d0,1,
     &  0.997596d0,1,1.002529d0,0.982962d0,0.983565d0,0.982707d0,
     &  0.981849d0,0.980991d0,1.02326d0,3*1,1.00008d0,2*1/
      data  (Kij(2,j),j=1,21)/2*1,0.982361d0,1.00796d0,10*1,1.03227d0,
     &  3*1,0.942596d0,2*1/
      data  (Kij(3,j),j=1,21)/3*1,1.00851d0,5*1,0.910183d0,0.895362d0,
     &  0.881152d0,0.86752d0,0.854406d0,4*1,1.00779d0,2*1/
      data  (Kij(4,j),j=1,21)/4*1,0.986893d0,9*1,1.02034d0,3*1,
     &  0.999969d0,2*1/


c  Energy parameters
      data ((Eij(i,j),i=8,9)  ,j=1,21)/42*1/
      data ((Eij(i,j),i=16,21),j=1,21)/126*1/
      data  (Eij(1,j),j=1,21)/
     &  1,0.97164d0,0.960644d0,1,0.994635d0,1.01953d0,0.989844d0,
     &  1.00235d0,0.999268d0,1.107274d0,0.88088d0,0.880973d0,0.881067d0,
     &  0.881161d0,1.17052d0,1,0.990126d0,0.708218d0,0.931484d0,1,1/
      data  (Eij(2,j),j=1,21)/
     &  1,1,1.02274d0,0.97012d0,0.945939d0,0.946914d0,0.973384d0,
     &  0.95934d0,0.94552d0,1,1,1,1,1,1.08632d0,1.021d0,1.00571d0,
     &  0.746954d0,0.902271d0,1,1/
      data  (Eij(3,j),j=1,21)/
     &  1,1,1,0.925053d0,0.960237d0,0.906849d0,0.897362d0,0.726255d0,
     &  0.859764d0,0.855134d0,0.831229d0,0.80831d0,0.786323d0,
     &  0.765171d0,1.28179d0,1,1.5d0,0.849408d0,0.955052d0,1,1/
      data  (Eij(4,j),j=1,21)/
     &  1,1,1,1,1.02256d0,1,1.01306d0,1,1.00532d0,1,1,1,1,1,
     &  1.16446d0,1,1,0.693168d0,0.946871d0,1,1/
      data  (Eij(5,j),j=1,21)/6*1,1.0049d0,7*1,1.034787d0,6*1/
      data  (Eij(6,j),j=1,21)/14*1,1.3d0,6*1/
      data  (Eij(7,j),j=1,21)/14*1,1.3d0,6*1/
      data  (Eij(10,j),j=1,21)/18*1,1.008692d0,2*1/
      data  (Eij(11,j),j=1,21)/18*1,1.010126d0,2*1/
      data  (Eij(12,j),j=1,21)/18*1,1.011501d0,2*1/
      data  (Eij(13,j),j=1,21)/18*1,1.012821d0,2*1/
      data  (Eij(14,j),j=1,21)/18*1,1.014089d0,2*1/
      data  (Eij(15,j),j=1,21)/16*1,1.1d0,4*1/

c  Conformal energy parameters
      data ((Uij(i,j),i=5,9)  ,j=1,21)/105*1/
      data ((Uij(i,j),i=15,21),j=1,21)/147*1/
      data  (Uij(1,j),j=1,21)/1,0.886106d0,0.963827d0,1,0.990877d0,1,
     &  0.992291d0,1,1.00367d0,1.302576d0,1.191904d0,1.205769d0,
     &  1.219634d0,1.233498d0,1.15639d0,3*1,0.736833d0,2*1/
      data  (Uij(2,j),j=1,21)/2*1,0.835058d0,0.816431d0,0.915502d0,1,
     &  0.993556d0,7*1,0.408838d0,3*1,0.993476d0,2*1/
      data  (Uij(3,j),j=1,21)/3*1,0.96987d0,5*1,1.066638d0,1.077634d0,
     &  1.088178d0,1.098291d0,1.108021d0,2*1,0.9d0,1,1.04529d0,2*1/
      data  (Uij(4,j),j=1,21)/4*1,1.065173d0,1.25d0,1.25d0,1.25d0,
     &  1.25d0,5*1,1.61666d0,3*1,0.971926d0,2*1/
      data  (Uij(10,j),j=1,21)/18*1,1.028973d0,2*1/
      data  (Uij(11,j),j=1,21)/18*1,1.033754d0,2*1/
      data  (Uij(12,j),j=1,21)/18*1,1.038338d0,2*1/
      data  (Uij(13,j),j=1,21)/18*1,1.042735d0,2*1/
      data  (Uij(14,j),j=1,21)/18*1,1.046966d0,2*1/

c  Constants calculated in Setup
      data Kij5/441*1/
      data Uij5/441*1/
      data Gij5/441*1/
      data Bsnij2/7938*1/
      data Ei25/21*0/
      data Ki25/21*0/

      data dPdDsave/0/
      data xold/21*0/
      END
