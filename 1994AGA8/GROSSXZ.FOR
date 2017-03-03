C=======================================================================
C     COPYRIGHT (C) 1992, 1994 AMERICAN GAS ASSOCIATION
C     ALL RIGHTS RESERVED
C     COPYRIGHT APPLIES TO ALL SUBPROGRAMS
C
C     FOR INFORMATION CONTACT:
C         DR. JEFFREY L. SAVIDGE
C         GAS RESEARCH INSTITUTE
C         8600 W. BRYN MAWR AVE.
C         CHICAGO, IL 60631
C         PHONE (312) 399-8100, FAX (312) 399-8170
C
C     OR: MS. LORI TRAWEEK
C         AMERICAN GAS ASSOCIATION
C         1515 WILSON BOULEVARD
C         ARLINGTON, VA 22209
C         PHONE (703) 841-8400
C
C     PROGRAM WRITTEN BY ERIC LEMMON AND STEVEN BEYERLEIN
C=======================================================================
C     VERSION 1.2
C=======================================================================
      FUNCTION DGROSS(P, T)
C
C     PURPOSE:
C       Calculates density from the GERG model given pressure and
C       temperature.  This function uses Chambers's method and PGROSS
C       to determine the density.
C
C     DESCRIPTION OF ARGUMENTS:
C       P      - Pressure in MPa. (Input)
C       T      - Temperature in kelvins. (Input)
C       DGROSS - Molar density at P and T in mol/dm^3. (Output)
C-----------------------------------------------------------------------
      REAL*8 DHIGH, PLOW, PHIGH, TLOW, THIGH
      COMMON/LIMITS/ DHIGH, PLOW, PHIGH, TLOW, THIGH

      INTEGER IC
      REAL*8 T, P, DGROSS, PGROSS
      REAL*8 TOL, X1, X2, X3, F, F1, F2, F3

C.....Bracket density solution
      TOL = 1.D-6
      X1  = PGROSS(0.D0, T)
      X2  = PGROSS(DHIGH, T)

C.....Check the boundaries
      F1 = PGROSS(X1, T) - P
      IF (DABS(F1).LE.TOL) THEN
        DGROSS = X1
        RETURN
      ENDIF
      F2 = PGROSS(X2, T) - P
      IF (DABS(F2).LE.TOL) THEN
        DGROSS = X2
        RETURN
      ENDIF
      IF (F1*F2.GT.0.0D0) THEN
        WRITE (*,*) ' *** DGROSS:  THE ROOT WAS NOT BOUNDED ***'
        DGROSS = 0
        RETURN
      ENDIF

C.....Begin iterating
      DO 100 IC = 1, 100
        X3 = (X1*F2 - X2*F1)/(F2 - F1)
        F3 = PGROSS(X3, T) - P
        IF (MOD(IC,6).EQ.0) THEN
          DGROSS = (X1 + X2)/2.0D0
        ELSE
          IF (((F1 - F2)*(F1 - F3)*(F2 - F3)).EQ.0.D0) RETURN
          DGROSS = X1*F2*F3/((F1 - F2)*(F1 - F3))
     &           + X2*F1*F3/((F2 - F1)*(F2 - F3))
     &           + X3*F1*F2/((F3 - F1)*(F3 - F2))
          IF ((DGROSS-X1)*(DGROSS-X2).GE.0.D0) DGROSS = (X1 + X2)/2.D0
        ENDIF
        F = PGROSS(DGROSS, T) - P
        IF (DABS(F).LE.TOL) RETURN
        IF (F*F3.LT.0.D0) THEN
          X1 = DGROSS
          F1 = F
          X2 = X3
          F2 = F3
        ELSEIF (F3*F1.GT.0.D0) THEN
          X1 = DGROSS
          F1 = F
         ELSE
          X2 = DGROSS
          F2 = F
        ENDIF
  100 CONTINUE
      WRITE (*,*) ' *** DGROSS:  NO CONVERGENCE ***'
      DGROSS = 0
      RETURN
      END
C=======================================================================
      FUNCTION PGROSS(D, T)
C
C     PURPOSE:
C       Calculates the pressure from the GERG model as a function of
C       density and temperature.
C
C     DESCRIPTION OF ARGUMENTS:
C       D      - Molar density in mol/dm^3. (Input)
C       T      - Temperature in kelvins. (Input)
C       PGROSS - Pressure in MPa. (Output)
C-----------------------------------------------------------------------
      INTEGER PROG
      REAL*8 RGAS, MWX, MW(5)
      COMMON/CONSTANTS/ PROG, RGAS, MWX, MW

      REAL*8 D, T, ZGROSS, PGROSS

      PGROSS = D*RGAS*T*ZGROSS(D, T)
      END
C=======================================================================
      FUNCTION ZGROSS(D, T)
C
C     PURPOSE:
C       Calculates the compressibility factor from the GERG model as a
C       function of density and temperature.
C
C     DESCRIPTION OF ARGUMENTS:
C       D      - Molar density in mol/dm^3. (Input)
C       T      - Temperature in kelvins. (Input)
C       ZGROSS - Compressibility factor. (Output)
C-----------------------------------------------------------------------
      INTEGER ERRNUM
      REAL*8 BMIX, CMIX, TEMP, D, ZGROSS, T

      REAL*8 X(5)
      COMMON/GROSSCOMP/ X

      ZGROSS = 0
      CALL VIRGS(T, X, BMIX, CMIX, TEMP, 0, ERRNUM)
      IF (ERRNUM.NE.0) RETURN
      ZGROSS = 1.D0 + BMIX*D + CMIX*D*D
      END
C=======================================================================
      SUBROUTINE CHARGS(METHOD,HV,GR,X,TH,TD,PD,TGR,PGR,ZB,DB,ERRNUM)
C
C     PURPOSE:
C       Determines the heating value of the equivalent hydrocarbon and
C       in turn uses this heating value to calculate the parameters in
C       the GERG model for the two input methods.
C
C     DESCRIPTION OF ARGUMENTS:
C       METHOD - Option number for selecting the method: (Input)
C         METHOD 1 -- Use gross caloric value (HV), relative density (Dr)
C                     and the mole fraction of carbon dioxide.
C         METHOD 2 -- Use relative density (Dr) and mole fractions
C                     of nitrogen and carbon dioxide.
C       HV     - Gross calorific heating value for the gas mixture
C                in kJ/dm^3. (Input for Method 1)
C       GR     - Relative density (specific gravity). (Input)
C       X      - An array of 5 elements containing the mole factions of:
C                X(1) - The equivalent hydrocarbon (Output)
C                X(2) - Nitrogen         (Input for Method 2)
C                X(3) - Carbon Dioxide   (Input for Methods 1 and 2)
C                X(4) - Hydrogen         (Input for Methods 1 and 2)
C                X(5) - Carbon Monoxide  (Input for Methods 1 and 2)
C       TH     - Reference temperature for heating value (K). (Input)
C       TD     - Reference temperature for molar density (K). (Input)
C       TGR    - Reference temperature for relative density (K). (Input)
C       PD     - Reference pressure for molar density (MPa). (Input)
C       PGR    - Reference pressure for relative density (MPa). (Input)
C       ZB     - Compressibility factor at 60øF and 14.73 psia. (Output)
C       DB     - Molar density at 60øF and 14.73 psia. (Output)
C       ERRNUM - Error Flag: (Output)
C         ERRNUM = 0       -- No error.
C         ERRNUM = 1 or 2  -- Iteration failed to converge.
C-----------------------------------------------------------------------
      REAL*8 B0(5,5), B1(5,5), B2(5,5), BB(0:2,0:2)
      REAL*8 C0(5,5), C1(5,5), C2(5,5)
      REAL*8 TOLD, BBMIX, CCMIX
      COMMON/VIRIAL2/ BB, B0, B1, B2, C0, C1, C2, TOLD, BBMIX, CCMIX

      REAL*8 XX(5)
      COMMON/GROSSCOMP/ XX

      REAL*8 DHIGH, PLOW, PHIGH, TLOW, THIGH
      COMMON/LIMITS/ DHIGH, PLOW, PHIGH, TLOW, THIGH

      INTEGER PROG
      REAL*8 RGAS, MWX, MW(5)
      COMMON/CONSTANTS/ PROG, RGAS, MWX, MW

      INTEGER ERRNUM, METHOD, FLAG
      REAL*8 DGROSS, ZGROSS
      REAL*8 HCH, HV, GR, X(5)
      REAL*8 BMIX, TEMP, BCH
      REAL*8 D0AIR, Z0, Z0NEW, Z0TDPD, G1, G2, HN0, MR, HTV4, HTV5
      REAL*8 TB, PB, DB, ZB, TH, TD, PD, TGR, PGR, SUM, VIR

      TOLD   = 0
      ERRNUM = 0
      VIR    = -0.12527D0 + 5.91D-4*TGR - 6.62D-7*TGR**2
      D0AIR  = 28.96256D0/(RGAS*TGR/PGR + VIR)

      G1     = -2.709328D0
      G2     = 0.021062199D0
      HTV4   = 285.83D0
      HTV5   = 282.98D0

C-----------------------------------------------------------------------
C     Method 1 - Given the caloric value, specific gravity and
C                the mole fraction of CO2
C-----------------------------------------------------------------------
      IF (METHOD.EQ.1) THEN
        Z0     = 1.D0
        Z0TDPD = 1.D0
 300    HN0   = HV*Z0TDPD*RGAS*TD/PD*(1.D0 + 1.027D-4*(TH - 298.15D0))
        MR    = GR*Z0*RGAS*TGR/PGR*D0AIR
        SUM   = X(3)*(MW(2) - MW(3))
     &        + X(4)*(MW(2) - MW(4) + G2*HTV4)
     &        + X(5)*(MW(2) - MW(5) + G2*HTV5)
        X(1)  = (MR - G2*HN0 - MW(2) + SUM)/(G1 - MW(2))
        X(2)  = 1.D0 - X(1) - X(3) - X(4) - X(5)

        FLAG = 0
        IF (X(2).LT.0) THEN
          FLAG = 1
          X(2) = 0
          X(1) = 1.D0 - X(2) - X(3) - X(4) - X(5)
        ENDIF

        HCH   = (HN0 - X(4)*HTV4 - X(5)*HTV5)/X(1)
        IF (HCH.LT.0) HCH = 0
        MW(1) = G1 + G2*HCH
        BCH   =  BB(0,0) + TD*(BB(0,1) + BB(0,2)*TD)
     &        + (BB(1,0) + TD*(BB(1,1) + BB(1,2)*TD))*HCH
     &        + (BB(2,0) + TD*(BB(2,1) + BB(2,2)*TD))*HCH**2.D0
        CALL VIRGS(TD, X, BMIX, TEMP, BCH, 1, ERRNUM)
        Z0TDPD = 1.D0 + BMIX*PD/RGAS/TD
        BCH   =  BB(0,0) + TGR*(BB(0,1) + BB(0,2)*TGR)
     &        + (BB(1,0) + TGR*(BB(1,1) + BB(1,2)*TGR))*HCH
     &        + (BB(2,0) + TGR*(BB(2,1) + BB(2,2)*TGR))*HCH**2.D0
        CALL VIRGS(TGR, X, BMIX, TEMP, BCH, 1, ERRNUM)
        Z0NEW = 1.D0 + BMIX*PGR/RGAS/TGR
        IF (DABS(Z0/Z0NEW - 1.D0).GT.0.5D-10) THEN
          Z0 = Z0NEW
          GOTO 300
        ENDIF

        X(2) = 1.D0 - X(1) - X(3) - X(4) - X(5)
        IF (X(2).LT.0 .OR. FLAG.EQ.1) THEN
          WRITE (*,*) 'CONFLICTING VALUES OF RELATIVE DENSITY, ',
     &                'HEATING VALUE, AND '
          PAUSE 'CARBON DIOXIDE CONTENT'
          ERRNUM = 3
          RETURN
        ENDIF

C-----------------------------------------------------------------------
C     Method 2 - Given the specific gravity and the mole fractions of
C                N2 and CO2
C-----------------------------------------------------------------------
      ELSEIF (METHOD.EQ.2) THEN
        Z0    = 1.D0
        X(1)  = 1.D0 - X(2) - X(3) - X(4) - X(5)
 100    MR    = GR*Z0*RGAS*TGR/PGR*D0AIR
        MW(1) = (MR - X(2)*MW(2) - X(3)*MW(3)
     &        - X(4)*MW(4) - X(5)*MW(5))/X(1)
        HCH   = (MW(1) - G1)/G2
        BCH   =  BB(0,0) + TGR*(BB(0,1) + BB(0,2)*TGR)
     &        + (BB(1,0) + TGR*(BB(1,1) + BB(1,2)*TGR))*HCH
     &        + (BB(2,0) + TGR*(BB(2,1) + BB(2,2)*TGR))*HCH**2.D0
        CALL VIRGS(TGR, X, BMIX, TEMP, BCH, 1, ERRNUM)
        Z0NEW = 1.D0 + BMIX*PGR/RGAS/TGR
        IF (DABS(Z0/Z0NEW - 1.D0).GT.0.5D-10) THEN
          Z0 = Z0NEW
          GOTO 100
        ENDIF
      ENDIF

      IF (ERRNUM.NE.0) RETURN

C.....Find the virial coefficient constants for pure hydrocarbon
C.....using the caloric value.
      B0(1,1) = BB(0,0) + HCH*(BB(1,0) + BB(2,0)*HCH)
      B1(1,1) = BB(0,1) + HCH*(BB(1,1) + BB(2,1)*HCH)
      B2(1,1) = BB(0,2) + HCH*(BB(1,2) + BB(2,2)*HCH)
      C0(1,1) = -0.302488D0  + HCH*( 0.646422D-3 - 0.332805D-06*HCH)
      C1(1,1) =  0.195861D-2 + HCH*(-0.422876D-5 + 0.223160D-08*HCH)
      C2(1,1) = -0.316302D-5 + HCH*( 0.688157D-8 - 0.367713D-11*HCH)

      XX(1) = X(1)
      XX(2) = X(2)
      XX(3) = X(3)
      XX(4) = X(4)
      XX(5) = X(5)
      TLOW  = 263.D0
      THIGH = 338.D0
      PLOW  = 0.5D-9
      PHIGH = 12.D0
      DHIGH = 8.D0

      DB = DGROSS(PGR, TGR)
      MWX = GR*D0AIR/DB

C.....ZB=Compressibility factor at base conditions, TB and PB
C.....Base Conditions: 60.0 Degrees Fahrenheit, 14.73 psia
      TB = (60.D0 + 459.67D0)/1.8D0
      PB = 14.73D0*6894.757D0/1000000.D0
      DB = DGROSS(PB, TB)
      ZB = ZGROSS(DB, TB)
      END
C=======================================================================
      SUBROUTINE PARAMGS
C
C     PURPOSE:
C       Sets up constants used by the GERG model.
C-----------------------------------------------------------------------
      INTEGER PROG
      REAL*8 RGAS, MWX, MW(5)
      COMMON/CONSTANTS/ PROG, RGAS, MWX, MW

      REAL*8 B0(5,5), B1(5,5), B2(5,5), BB(0:2,0:2)
      REAL*8 C0(5,5), C1(5,5), C2(5,5)
      REAL*8 TOLD, BBMIX, CCMIX
      COMMON/VIRIAL2/ BB, B0, B1, B2, C0, C1, C2, TOLD, BBMIX, CCMIX

C.....Store fluid information - Nitrogen is index 2, CO2 is index 3,
C     Hydrogen is index 4, CO is index 5, and the hydrocarbon is index 1.
      RGAS  = 8.31451D-3
      MW(2) = 28.01350D0
      MW(3) = 44.010D0
      MW(4) = 2.0159D0
      MW(5) = 28.01D0
C.....Assign virial coefficient constants for N2 and CO2.
      B0(2,2) = -0.144600D0
      B1(2,2) =  0.740910D-3
      B2(2,2) = -0.911950D-6
      B0(3,3) = -0.868340D0
      B1(3,3) =  0.403760D-2
      B2(3,3) = -0.516570D-5
      B0(4,4) = -0.110596D-2
      B1(4,4) =  0.813385D-4
      B2(4,4) = -0.987220D-7
      B0(5,5) = -0.130820D0
      B1(5,5) =  0.602540D-3
      B2(5,5) = -0.644300D-6
      B0(2,3) = -0.339693D0
      B1(2,3) =  0.161176D-2
      B2(2,3) = -0.204429D-5
      B0(1,4) = -0.521280D-1
      B1(1,4) =  0.271570D-3
      B2(1,4) = -0.250000D-6
      B0(1,5) = -0.687290D-1
      B1(1,5) = -0.239381D-5
      B2(1,5) =  0.518195D-6
      B0(2,4) =  0.012D0
      BB(0,0) = -0.425468D0
      BB(1,0) =  0.877118D-3
      BB(2,0) = -0.824747D-6
      BB(0,1) =  0.286500D-2
      BB(1,1) = -0.556281D-5
      BB(2,1) =  0.431436D-8
      BB(0,2) = -0.462073D-5
      BB(1,2) =  0.881510D-8
      BB(2,2) = -0.608319D-11
      C0(2,2) =  0.784980D-2
      C1(2,2) = -0.398950D-4
      C2(2,2) =  0.611870D-7
      C0(3,3) =  0.205130D-2
      C1(3,3) =  0.348880D-4
      C2(3,3) = -0.837030D-7
      C0(2,3) =  0.552066D-2
      C1(2,3) = -0.168609D-4
      C2(2,3) =  0.157169D-7
      C0(3,2) =  0.358783D-2
      C1(3,2) =  0.806674D-5
      C2(3,2) = -0.325798D-7
      C0(4,4) =  0.104711D-2
      C1(4,4) = -0.364887D-5
      C2(4,4) =  0.467095D-8
      C0(1,5) =  0.736748D-2
      C1(1,5) = -0.276578D-4
      C2(1,5) =  0.343051D-7
      END
C=======================================================================
      SUBROUTINE VIRGS(T, X, BMIX, CMIX, BCH, OPT, ERRNUM)
C
C     PURPOSE:
C       Calculates the second and third virial coefficients in the GERG
C       model at the given temperature.  The coefficient constants are
C       stored in arrays and are mixed using the combining rules.
C
C     DESCRIPTION OF ARGUMENTS:
C       T      - Temperature in kelvins. (Input)
C       BMIX   - Second virial coefficient of the mixture. (Output)
C       CMIX   - Third virial coefficient of the mixture. (Output)
C       BCH    - Binary CH-CH interaction coefficient. (Input/Output)
C       OPT    - Option number: (Input)
C         OPT = 0  -- Calculate BCH.
C         OPT = 1  -- Use BCH from input.
C       ERRNUM - Error Flag: (Output)
C         ERRNUM = 0       -- No error.
C         ERRNUM = 1 or 2  -- Iteration failed to converge.
C-----------------------------------------------------------------------
      REAL*8 B0(5,5), B1(5,5), B2(5,5), BB(0:2,0:2)
      REAL*8 C0(5,5), C1(5,5), C2(5,5)
      REAL*8 TOLD, BBMIX, CCMIX
      COMMON/VIRIAL2/ BB, B0, B1, B2, C0, C1, C2, TOLD, BBMIX, CCMIX

      REAL*8 T, E, F, BMIX, CMIX, X11, X22, X33, X44, X55, X(5)
      REAL*8 C11, C22, C33, C23, C32, C15, C44
      REAL*8 BCH, BN2, BCO2, BH2, BCO
      REAL*8 B12, B13, B14, B15, B23, B24
      INTEGER OPT, ERRNUM
      ERRNUM = 0

C.....Calculate the second virial coefficient
      IF (T.EQ.TOLD) THEN
        BMIX = BBMIX
        CMIX = CCMIX
        RETURN
      ENDIF
      X11 = X(1)*X(1)
      X22 = X(2)*X(2)
      X33 = X(3)*X(3)
      X44 = X(4)*X(4)
      X55 = X(5)*X(5)
      IF (OPT.EQ.0) BCH = B0(1,1) + T*(B1(1,1) + B2(1,1)*T)
      BN2  = B0(2,2) + T*(B1(2,2) + B2(2,2)*T)
      BCO2 = B0(3,3) + T*(B1(3,3) + B2(3,3)*T)
      BH2  = B0(4,4) + T*(B1(4,4) + B2(4,4)*T)
      BCO  = B0(5,5) + T*(B1(5,5) + B2(5,5)*T)
      IF (BCO2*BCH.LT.0.D0) THEN
        PAUSE 'VIRGS:  SQRT NEGATIVE'
        ERRNUM = 1
        RETURN
      ENDIF
      B12  = (0.72D0 + 1.875D-5*(320.D0-T)*(320.D0-T))*(BN2 + BCH)/2.D0
      B13  = -0.865D0*DSQRT(BCO2*BCH)
      B14  = B0(1,4) + T*(B1(1,4) + B2(1,4)*T)
      B15  = B0(1,5) + T*(B1(1,5) + B2(1,5)*T)
      B23  = B0(2,3) + T*(B1(2,3) + B2(2,3)*T)
      B24  = B0(2,4)
      BMIX = BCH*X11 + BN2*X22 + BCO2*X33 + BH2*X44 + BCO*X55
     &     + 2.D0*B12*X(1)*X(2) + 2.D0*B13*X(1)*X(3)
     &     + 2.D0*B14*X(1)*X(4) + 2.D0*B15*X(1)*X(5)
     &     + 2.D0*B23*X(2)*X(3) + 2.D0*B24*X(2)*X(4)

C.....Since methods 1 and 2 change X(1) and BCH, TOLD must not
C       be initialized until after the two methods have been set up.
C       During their setup, OPT is equal to one.
      IF (OPT.EQ.1) RETURN
      TOLD = T
      BBMIX = BMIX

C.....Calculate the third virial coefficient
      E    = 0.92D0 + 0.0013D0*(T - 270.D0)
      F    = 1.D0/3.D0
      C11  = C0(1,1) + T*(C1(1,1) + C2(1,1)*T)
      C22  = C0(2,2) + T*(C1(2,2) + C2(2,2)*T)
      C33  = C0(3,3) + T*(C1(3,3) + C2(3,3)*T)
      C44  = C0(4,4) + T*(C1(4,4) + C2(4,4)*T)
      IF (C11.LT.0 .OR. C33.LT.0) THEN
        WRITE (*,*) 'INVALID TERM IN VIRGS'
        ERRNUM = 1
        RETURN
      ENDIF
      C15  = 3.D0*(C0(1,5) + T*(C1(1,5) + C2(1,5)*T))
      C23  = 3.D0*(C0(2,3) + T*(C1(2,3) + C2(2,3)*T))
      C32  = 3.D0*(C0(3,2) + T*(C1(3,2) + C2(3,2)*T))
      CMIX = C11*X11*X(1) + C22*X22*X(2) + C33*X33*X(3) + C44*X44*X(4)
     &     + C23*X22*X(3) + C32*X33*X(2) + C15*X11*X(5)
     &     +      E*3.D0*X11* X(2)     *(C11*C11*C22)**F
     &     +      E*3.D0*X22* X(1)     *(C11*C22*C22)**F
     &     + 0.92D0*3.D0*X11* X(3)     *(C11*C11*C33)**F
     &     + 0.92D0*3.D0*X33* X(1)     *(C11*C33*C33)**F
     &     + 1.20D0*3.D0*X11* X(4)     *(C11*C11*C44)**F
     &     + 1.10D0*6.D0*X(1)*X(2)*X(3)*(C11*C22*C33)**F
      CCMIX = CMIX
      END
