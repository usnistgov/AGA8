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
C     PROGRAM WRITTEN BY KENNETH STARLING
C=======================================================================
C     VERSION 1.2
C=======================================================================
      FUNCTION DDETAIL(P, T)
C
C     PURPOSE:
C       Calculates density for the AGA8 model given
C       pressure and temperature.  This function uses Brent's method
C       and PDETAIL to determine the density.
C
C     DESCRIPTION OF ARGUMENTS:
C       P       - Pressure in MPa. (Input)
C       T       - Temperature in kelvins. (Input)
C       DDETAIL - Molar density at P and T in mol/dm^3. (Output)
C-----------------------------------------------------------------------
      REAL*8 DHIGH, PLOW, PHIGH, TLOW, THIGH
      COMMON/LIMITS/ DHIGH, PLOW, PHIGH, TLOW, THIGH

      INTEGER IMAX, I, CODE
      REAL*8 EPSP, EPSR, EPSMIN, T, P, RHO, RHOL, RHOH, PRHOL, PRHOH
      REAL*8 DDETAIL, PDETAIL, X1, X2, X3, Y1, Y2, Y3
      REAL*8 DELX, DELPRV, DELMIN, DELBIS, XNUMER, XDENOM, SGNDEL
      REAL*8 Y2MY3, Y3MY1, Y1MY2, BOUNDN

      IMAX = 150
      EPSP = 1.D-6
      EPSR = 1.D-6
      EPSMIN = 1.D-7
      CODE = 0

C.....CALL SUBROUTINE BRAKET TO BRACKET DENSITY SOLUTION
      CALL BRAKET (CODE,T,P,RHO,RHOL,RHOH,PRHOL,PRHOH)

C.....CHECK VALUE OF "CODE" RETURNED FROM SUBROUTINE BRAKET
      IF (CODE.EQ.1.OR.CODE.EQ.3) THEN
        DDETAIL = RHO
        RETURN
      ENDIF

C.....SET UP TO START BRENT'S METHOD
C     X IS THE INDEPENDENT VARIABLE, Y THE DEPENDENT VARIABLE
C     DELX IS THE CURRENT ITERATION CHANGE IN X
C     DELPRV IS THE PREVIOUS ITERATION CHANGE IN X
      X1 = RHOL
      X2 = RHOH
      Y1 = PRHOL - P
      Y2 = PRHOH - P
      DELX = X1-X2
      DELPRV = DELX

C.....NOTE THAT SOLUTION IS BRACKETED BETWEEN X1 AND X2
C.....A THIRD POINT X3 IS INTRODUCED FOR QUADRATIC INTERPOLATION
      X3 = X1
      Y3 = Y1

C.....NOTE THAT ITERATIVE LOOP STARTS HERE, ENDS AT "10 CONTINUE"

      DO 10 I=1, IMAX
C.......Y3 MUST BE OPPOSITE IN SIGN FROM Y2, SO SOLUTION BETWEEN X2, X3
        IF (Y2*Y3.GT.0.D0) THEN
          X3 = X1
          Y3 = Y1
          DELX = X1-X2
          DELPRV = DELX
        ENDIF

C.......Y2 MUST BE VALUE OF Y CLOSEST TO Y=0.0, THEN X2NEW=X2OLD+DELX
        IF (DABS(Y3).LT.DABS(Y2)) THEN
          X1 = X2
          X2 = X3
          X3 = X1
          Y1 = Y2
          Y2 = Y3
          Y3 = Y1
        ENDIF

C.......DELMIN IS MINIMUM ALLOWED STEP SIZE FOR UNCONVERGED ITERATION
C       SMALLER STEPS THAN DELMIN CAN CAUSE OSCILLATIONS
        DELMIN = EPSMIN*DABS(X2)

C.......IF PROCEDURE IS NOT CONVERGING, I.E., ABS(Y2)>ABS(Y1),
C       OR IF DELPRV IS LESS THAN DELMIN, I.E., INTERPOLATION
C       IS CONVERGING TOO SLOWLY, USE BISECTION
C       DELBIS = 0.5D0*(X3 - X2) IS THE BISECTION DELX
        DELBIS = 0.5D0*(X3 - X2)

C.......TESTS TO DECIDE NUMERICAL METHOD FOR CURRENT ITERATION

        IF (DABS(DELPRV).LT.DELMIN .OR. DABS(Y1).LT.DABS(Y2)) THEN
C.........USE BISECTION
          DELX = DELBIS
          DELPRV = DELBIS

        ELSE

          IF (X3.NE.X1) THEN
C...........USE INVERSE QUADRATIC INTERPOLATION
            Y2MY3 = Y2-Y3
            Y3MY1 = Y3-Y1
            Y1MY2 = Y1-Y2
            XDENOM = -(Y1MY2)*(Y2MY3)*(Y3MY1)
            XNUMER = X1*Y2*Y3*(Y2MY3)+X2*Y3*Y1*(Y3MY1)
     &              +X3*Y1*Y2*(Y1MY2)-X2*XDENOM
          ELSE
C...........USE INVERSE LINEAR INTERPOLATION
            XNUMER = (X2-X1)*Y2
            XDENOM = Y1-Y2
          ENDIF

C.........FOLLOWING BRENT'S PROCEDURE, BEFORE CALCULATING DELX,
C         CHECK THAT DELX=XNUMER/XDENOM DOES NOT STEP OUT OF BOUNDS
          IF (2.D0*DABS(XNUMER).LT.DABS(DELPRV*XDENOM)) THEN
C...........PROCEDURE CONVERGING, USE INTERPOLATION
            DELPRV =DELX
            DELX = XNUMER/XDENOM
          ELSE
C...........PROCEDURE DIVERGING, USE BISECTION
            DELX = DELBIS
            DELPRV = DELBIS
          ENDIF

        ENDIF

C.......CHECK FOR CONVERGENCE
        IF((DABS(Y2).LT.EPSP*P).AND.(DABS(DELX).LT.EPSR*DABS(X2))) THEN
          DDETAIL = X2+DELX
          RETURN
        ENDIF

C.......WHEN UNCONVERGED, ABS(DELX) MUST BE GREATER THAN DELMIN
C       MINIMUM ALLOWED MAGNITUDE OF CHANGE IN X2 IS 1.0000009*DELMIN
C       SGNDEL, THE SIGN OF CHANGE IN X2 IS SIGN OF DELBIS
        IF (DABS(DELX).LT.DELMIN) THEN
          SGNDEL = DELBIS/DABS(DELBIS)
          DELX = 1.0000009*SGNDEL*DELMIN
          DELPRV = DELX
        ENDIF

C.....FINAL CHECK TO INSURE THAT NEW X2 IS IN RANGE OF OLD X2 AND X3
C.....BOUNDN IS NEGATIVE IF NEW X2 IS IN RANGE OF OLD X2 AND X3
      BOUNDN = DELX*(X2+DELX-X3)
      IF(BOUNDN.GT.0.D0) THEN
C........PROCEDURE STEPPING OUT OF BOUNDS, USE BISECTION
         DELX = DELBIS
         DELPRV = DELBIS
      ENDIF

C.......RELABEL VARIABLES FOR NEXT ITERATION
C       X1NEW=X2OLD, Y1NEW=Y2OLD
        X1 = X2
        Y1 = Y2
C.......NEXT ITERATION VALUES FOR X2, Y2
        X2 = X2+DELX
        Y2 = PDETAIL(X2, T) - P

C.....RETURN TO START OF LOOP FOR NEXT ITERATION

  10  CONTINUE

      WRITE (*,*) 'DDETAIL: MAXIMUM NUMBER OF ITERATIONS EXCEEDED'

      DDETAIL = X2
      RETURN
      END
C=======================================================================
      FUNCTION PDETAIL(D, T)
C
C     PURPOSE:
C       Calculates the pressure from the AGA8 model as a function of
C       density and temperature.
C
C     DESCRIPTION OF ARGUMENTS:
C       D       - Molar density in mol/dm^3. (Input)
C       T       - Temperature in kelvins. (Input)
C       PDETAIL - Pressure in MPa. (Output)
C-----------------------------------------------------------------------
      INTEGER PROG
      REAL*8 RGAS, MXNUMER, MW(5)
      COMMON/CONSTANTS/ PROG, RGAS, MXNUMER, MW

      REAL*8 D, T, PDETAIL, ZDETAIL

      PDETAIL = ZDETAIL(D, T)*D*RGAS*T
      RETURN
      END
C=======================================================================
      FUNCTION ZDETAIL(D, T)
C
C     PURPOSE:
C       This function calculates the compressibility factor from the
C       AGA8 model as a function of density and temperature.
C
C     DESCRIPTION OF ARGUMENTS:
C       D       - Molar density in mol/dm^3. (Input)
C       T       - Temperature in kelvins. (Input)
C       ZDETAIL - Compressibility factor. (Output)
C-----------------------------------------------------------------------
      REAL*8 FN(58)
      COMMON/AGAEOS/ FN

      REAL*8 UU,RK3P0,WW,Q2P0,HH,BMIX
      COMMON/AGAVARIABLES/ UU,RK3P0,WW,Q2P0,HH,BMIX

      REAL*8 TOLD
      COMMON/TOLDC/ TOLD

      REAL*8 D1, D2, D3, D4, D5, D6, D7, D8, D9, EXP1, EXP2, EXP3, EXP4
      REAL*8 D, T, ZDETAIL

      IF (T.NE.TOLD) CALL TEMP(T)
      TOLD = T
      D1 = RK3P0*D
      D2 = D1*D1
      D3 = D2*D1
      D4 = D3*D1
      D5 = D4*D1
      D6 = D5*D1
      D7 = D6*D1
      D8 = D7*D1
      D9 = D8*D1

      EXP1 = DEXP(-D1)
      EXP2 = DEXP(-D2)
      EXP3 = DEXP(-D3)
      EXP4 = DEXP(-D4)

      ZDETAIL = 1.D0 + BMIX*D
     &  +  FN(13)*D1*(EXP3 - 1.D0 - 3.D0*D3*EXP3)
     &  + (FN(14)  + FN(15) + FN(16))*D1*(EXP2 - 1.D0 - 2.D0*D2*EXP2)
     &  + (FN(17) + FN(18))*D1*(EXP4 - 1.D0 - 4.D0*D4*EXP4)
     &  + (FN(19) + FN(20))*D2*2.D0
     &  + (FN(21) + FN(22) + FN(23))*D2*(2.D0 - 2.D0*D2)*EXP2
     &  + (FN(24) + FN(25) + FN(26))*D2*(2.D0 - 4.D0*D4)*EXP4
     &  +  FN(27)*D2*(2.D0 - 4.D0*D4)*EXP4
     &  +  FN(28)*D3*3.D0
     &  + (FN(29) + FN(30))*D3*(3.D0 - D1)*EXP1
     &  + (FN(31) + FN(32))*D3*(3.D0 - 2.D0*D2)*EXP2
     &  + (FN(33) + FN(34))*D3*(3.D0 - 3.D0*D3)*EXP3
     &  + (FN(35) + FN(36) + FN(37))*D3*(3.D0 - 4.D0*D4)*EXP4
     &  + (FN(38) + FN(39))*D4*4.D0
     &  + (FN(40) + FN(41) + FN(42))*D4*(4.D0 - 2.D0*D2)*EXP2
     &  + (FN(43) + FN(44))*D4*(4.D0 - 4.D0*D4)*EXP4
     &  +  FN(45)*D5*5.D0
     &  + (FN(46) + FN(47))*D5*(5.D0 - 2.D0*D2)*EXP2
     &  + (FN(48) + FN(49))*D5*(5.D0 - 4.D0*D4)*EXP4
     &  +  FN(50)*D6*6.D0
     &  +  FN(51)*D6*(6.D0 - 2.D0*D2)*EXP2
     &  +  FN(52)*D7*7.D0
     &  +  FN(53)*D7*(7.D0 - 2.D0*D2)*EXP2
     &  +  FN(54)*D8*(8.D0 - D1)*EXP1
     &  + (FN(55) + FN(56))*D8*(8.D0 - 2.D0*D2)*EXP2
     &  + (FN(57) + FN(58))*D9*(9.D0 - 2.D0*D2)*EXP2
      END
C=======================================================================
      SUBROUTINE B(T,BMIX)
C
C     PURPOSE:
C       Calculates the second virial coefficient using the AGA8
C       method given temperature.
C
C     DESCRIPTION OF ARGUMENTS:
C       T       - Temperature in kelvins. (Input)
C       BMIX    - Second virial coefficient in mol/dm^3. (Output)
C-----------------------------------------------------------------------
      REAL*8 B1,B2,B3,B4,B5,B6,B7,B8,B9,B10,B11,B12,B13,
     & B14,B15,B16,B17,B18
      COMMON/VIR/ B1,B2,B3,B4,B5,B6,B7,B8,B9,B10,B11,B12,B13,
     & B14,B15,B16,B17,B18

      REAL*8 T0P5, T2P0, T3P0, T3P5, T4P5, T6P0, T11P0, BMIX, T
      REAL*8 T7P5,T9P5,T12P0,T12P5

      T0P5  = DSQRT(T)
      T2P0  = T*T
      T3P0  = T*T2P0
      T3P5  = T3P0*T0P5
      T4P5  = T*T3P5
      T6P0  = T3P0*T3P0
      T11P0 = T4P5*T4P5*T2P0
      T7P5  = T6P0*T*T0P5
      T9P5  = T7P5*T2P0
      T12P0 = T9P5*T0P5*T2P0
      T12P5 = T12P0*T0P5
      BMIX = B1+ B2/T0P5 + B3/T + B4/T3P5 + B5*T0P5 + B6/T4P5
     &          + B7/T0P5+ B8/T7P5 + B9/T9P5 + B10/T6P0 + B11/T12P0
     &          + B12/T12P5 + B13*T6P0 + B14/T2P0 + B15/T3P0 + B16/T2P0
     &          + B17/T2P0 + B18/T11P0
      RETURN
      END
C=======================================================================
      SUBROUTINE BRAKET (CODE, T, P, RHO, RHOL, RHOH, PRHOL, PRHOH)
C
C     PURPOSE:
C       Brackets the density solution.
C-----------------------------------------------------------------------
      INTEGER PROG
      REAL*8 RGAS, MXNUMER, MW(5)
      COMMON/CONSTANTS/ PROG, RGAS, MXNUMER, MW

      REAL*8 UU,RK3P0,WW,Q2P0,HH,BMIX
      COMMON/AGAVARIABLES/ UU,RK3P0,WW,Q2P0,HH,BMIX

      INTEGER IMAX, IT, CODE
      REAL*8 DEL, RHOMAX, T, P, RHO, PDETAIL, VIDEAL
      REAL*8 RHOL, PRHOL, RHOH, PRHOH, RHO1, RHO2, P1, P2

      CODE = 0
      IMAX = 200

      RHO1 = 0.D0
      P1 = 0.D0
      RHOMAX = 1.D0/RK3P0
      IF (T.GT.1.2593D0*UU) RHOMAX = 20.D0*RHOMAX
      VIDEAL = RGAS*T/P
      IF(DABS(BMIX).LT.(0.167D0*VIDEAL)) THEN
         RHO2 = 0.95D0/(VIDEAL+BMIX)
      ELSE
         RHO2 = 1.15D0/VIDEAL
      ENDIF

C.....NOTE: PRESSURE (P2) AT DENSITY RHO2 NOT YET CALCULATED

      DEL = RHO2/20.D0
      IT = 0

C.....START ITERATIVE DENSITY SEARCH LOOP

   10 IT = IT + 1

      IF (IT.GT.IMAX) THEN
C.......MAXIMUM NUMBER OF ITERATIONS EXCEEDED
        CODE = 3
        WRITE (*, 1010)
        RHO = RHO2
        RETURN
      ENDIF

      IF (CODE.NE.2 .AND. RHO2.GT.RHOMAX) THEN
C.......DENSITY IN BRAKET EXCEEDS MAXIMUM ALLOWABLE DENSITY
        CODE = 2
        WRITE (*, 1020)
        DEL = 0.01D0*(RHOMAX - RHO1) + P/(RGAS*T)/20.D0
        RHO2 = RHO1 + DEL
        GOTO 10
      ENDIF

C.....CALCULATE PRESSURE P2 AT DENSITY RHO2
      P2 = PDETAIL(RHO2, T)

C.....TEST VALUE OF P2 RELATIVE TO P AND RELATIVE TO P1

      IF (P2.GT.P) THEN
C.......THE DENSITY ROOT IS BRACKETED (P1<P AND P2>P)
        RHOL = RHO1
        PRHOL = P1
        RHOH = RHO2
        PRHOH = P2
        RETURN

      ELSEIF (P2.GT.P1 .AND. CODE.EQ.2) THEN
C.......RETAIN CONSTANT VALUE FOR DEL (CODE=2)
        RHO1 = RHO2
        P1 = P2
        RHO2 = RHO1 + DEL
        GOTO 10

      ELSEIF (P2.GT.P1. AND. CODE.EQ.0) THEN
C.......INCREASE VALUE FOR DEL (CODE=0)
        DEL = 2.D0*DEL
        RHO1 = RHO2
        P1 = P2
        RHO2 = RHO1 + DEL
        GOTO 10
      ENDIF

C.....ABOVE IF/ELSEIF CONDITIONS UNSATISFIED IMPLIES P2<P1
C     CODE=1 INDICATES THAT PRESSURE HAS A NEGATIVE DENSITY
C     DERIVATIVE, SINCE P2 IS LESS THAN SOME PREVIOUS PRESSURE
      CODE = 1
      WRITE (*, 1030)
      RHO = RHO1
      RETURN

 1010 FORMAT(/' CODE=3: MAXIMUM NUMBER OF ITERATIONS IN',
     &        ' BRAKET EXCEEDED',/' DEFAULT DENSITY USED',/)
 1020 FORMAT(/' CODE=2: DENSITY IN BRAKET EXCEEDS MAXIMUM',
     &        ' ALLOWABLE DENSITY',/' DEFAULT PROCEDURE USED',/)
 1030 FORMAT(/' CODE=1: DERIVATIVE OF PRESSURE WITH RESPECT TO',
     &        ' DENSITY IS NEGATIVE',/' SYSTEM MAY CONTAIN LIQUID,',
     &        ' DEFAULT GAS DENSITY USED',/)
      END
C=======================================================================
      SUBROUTINE CHARDL (NCC, XI, ZB, DB)
C
C     PURPOSE:
C       Sets up composition dependent terms.  Subroutine PARAMDL should
C       be called before this routine.
C
C     DESCRIPTION OF ARGUMENTS:
C       NCC     - Number of components. (Input)
C       XI      - Array values for mole fraction composition. (Input)
C                 This array corresponds to the CID array used in
C                 subroutine PARAMDL.
C       ZB      - Compressibility at 60øF and 14.73 psia. (Output)
C       DB      - Molar density at 60øF and 14.73 psia. (Output)
C-----------------------------------------------------------------------
      REAL*8 CMW(21), EI(21), RKI(21), WI(21), QI(21), HI(21), MI(21),
     & DI(21)
      REAL*8 BEIJ(21,21), BKIJ(21,21), BWIJ(21,21), BUIJ(21,21)
      COMMON/PARAM/  CMW, EI, RKI, WI, QI, HI, BEIJ, BKIJ, BWIJ, BUIJ,
     & MI,DI

      INTEGER PROG
      REAL*8 RGAS, MWX, MW(5)
      COMMON/CONSTANTS/ PROG, RGAS, MWX, MW

      REAL*8 A(58)
      COMMON/EOSAI/ A

      REAL*8 B1,B2,B3,B4,B5,B6,B7,B8,B9,B10,B11,B12,B13,
     & B14,B15,B16,B17,B18
      COMMON/VIR/ B1,B2,B3,B4,B5,B6,B7,B8,B9,B10,B11,B12,B13,
     & B14,B15,B16,B17,B18

      REAL*8 UU,RK3P0,WW,Q2P0,HH,BMIX
      COMMON/AGAVARIABLES/ UU,RK3P0,WW,Q2P0,HH,BMIX

      REAL*8 TOLD
      COMMON/TOLDC/ TOLD

      INTEGER I, J, NCC
      REAL*8 DDETAIL, ZDETAIL
      REAL*8 TMFRAC, RK5P0, RK2P5, U5P0, U2P5, Q1P0
      REAL*8 XIJ, EIJ, WIJ, E0P5, E2P0, E3P0, E3P5, E4P5, E6P0
      REAL*8 E7P5, E9P5, E12P0, E12P5
      REAL*8 E11P0, S3, TB, PB, ZB, DB, XI(21)

      TOLD = 0
C.....Normalize mole fractions and calculate molar mass
      TMFRAC = 0.D0
      DO 80 J=1, NCC
 80   TMFRAC = TMFRAC + XI(J)
      DO 90 J=1, NCC
 90   XI(J) = XI(J)/TMFRAC

      B1 = 0.D0
      B2 = 0.D0
      B3 = 0.D0
      B4 = 0.D0
      B5 = 0.D0
      B6 = 0.D0
      B7 = 0.D0
      B8 = 0.D0
      B9 = 0.D0
      B10 = 0.D0
      B11 = 0.D0
      B12 = 0.D0
      B13 = 0.D0
      B14 = 0.D0
      B15 = 0.D0
      B16 = 0.D0
      B17 = 0.D0
      B18 = 0.D0

      RK5P0 = 0.D0
      RK2P5 = 0.D0
      U5P0 = 0.D0
      U2P5 = 0.D0
      WW   = 0.D0
      Q1P0 = 0.D0
      HH   = 0.D0

      MWX = 0
      DO 5 J=1,NCC
 5    MWX = MWX + XI(J)*CMW(J)

      DO 20 I=1, NCC
        RK2P5 = RK2P5 + XI(I)*RKI(I)*RKI(I)*DSQRT(RKI(I))
        U2P5  = U2P5  + XI(I)*EI(I)*EI(I)*DSQRT(EI(I))
        WW    = WW    + XI(I)*WI(I)
        Q1P0  = Q1P0  + XI(I)*QI(I)
        HH    = HH    + XI(I)*XI(I)*HI(I)
        DO 10 J=I, NCC
          IF(I.NE.J) THEN
            XIJ = 2.0*XI(I)*XI(J)
          ELSE
            XIJ = XI(I)*XI(J)
          ENDIF
          IF (BKIJ(I,J).NE.1.D0)
     &      RK5P0 = RK5P0 + XIJ*(BKIJ(I,J)**5.D0 - 1.D0)
     &                    * DSQRT((RKI(I)**5)*(RKI(J)**5))
          IF (BUIJ(I,J).NE.1.D0)
     &       U5P0 = U5P0 + XIJ*(BUIJ(I,J)**5.D0 - 1.D0)
     &                   * DSQRT((EI(I)**5.D0)*(EI(J)**5.D0))
          IF (BWIJ(I,J).NE.1.D0)
     &       WW = WW + XIJ*(BWIJ(I,J) - 1.D0)*((WI(I) + WI(J))/2.D0)

C.....Terms in second virial coefficients
          EIJ = BEIJ(I,J)*DSQRT(EI(I)*EI(J))
          WIJ = BWIJ(I,J)*(WI(I) + WI(J))/2.D0
          E0P5 = DSQRT(EIJ)
          E2P0 = EIJ*EIJ
          E3P0 = EIJ*E2P0
          E3P5 = E3P0*E0P5
          E4P5 = EIJ*E3P5
          E6P0 = E3P0*E3P0
          E11P0= E4P5*E4P5*E2P0
          E7P5 = E4P5*EIJ*E2P0
          E9P5 = E7P5*E2P0
          E12P0= E11P0*EIJ
          E12P5= E12P0*E0P5
          S3 = XIJ*DSQRT((RKI(I)**3)*(RKI(J)**3))
          B1 = B1 + S3
          B2 = B2 + S3*E0P5
          B3 = B3 + S3*EIJ
          B4 = B4 + S3*E3P5
          B5 = B5 + S3*WIJ/E0P5
          B6 = B6 + S3*WIJ*E4P5
          B7 = B7 + S3*QI(I)*QI(J)*E0P5
          B8 = B8 + S3*MI(I)*MI(J)*E7P5
          B9 = B9 + S3*MI(I)*MI(J)*E9P5
          B10= B10+ S3*DI(I)*DI(J)*E6P0
          B11= B11+ S3*DI(I)*DI(J)*E12P0
          B12= B12+ S3*DI(I)*DI(J)*E12P5
          B13 = B13 + S3*HI(I)*HI(J)/E6P0
          B14 = B14 + S3*E2P0
          B15 = B15 + S3*E3P0
          B16 = B16 + S3*QI(I)*QI(J)*E2P0
          B17 = B17 + S3*E2P0
          B18 = B18 + S3*E11P0
 10     CONTINUE
 20   CONTINUE

      B1 = B1*A(1)
      B2 = B2*A(2)
      B3 = B3*A(3)
      B4 = B4*A(4)
      B5 = B5*A(5)
      B6 = B6*A(6)
      B7 = B7*A(7)
      B8 = B8*A(8)
      B9 = B9*A(9)
      B10 = B10*A(10)
      B11 = B11*A(11)
      B12 = B12*A(12)
      B13 = B13*A(13)
      B14 = B14*A(14)
      B15 = B15*A(15)
      B16 = B16*A(16)
      B17 = B17*A(17)
      B18 = B18*A(18)

      RK3P0 = (RK5P0 + RK2P5*RK2P5)**0.6D0
      UU    = (U5P0 + U2P5*U2P5)**0.2D0
      Q2P0  = Q1P0*Q1P0

C.....ZB=Compressibility factor at base conditions, TB and PB
C.....Base Conditions: 60.0 Degrees Fahrenheit, 14.73 psia
      TB = (60.D0 + 459.67D0)/1.8D0
      PB = 14.73D0*6894.757D0/1000000.D0
      DB = DDETAIL(PB, TB)
      ZB = ZDETAIL(DB, TB)
      END
C=======================================================================
      SUBROUTINE PARAMDL (NCC, CID)
C
C     PURPOSE:
C       Sets up constants used by the DETAIL model.
C
C     DESCRIPTION OF ARGUMENTS:
C       NCC - Number of Components. (Input)
C       CID - Array containing the Component ID Numbers. (Input)
C             The first NCC elements of the array define the composition
C             of the mixture.  The remaining elements of the array
C             are set to zero.  The ID numbers are:
C       1 - Methane              8 - Hydrogen           15 - n-Hexane
C       2 - Nitrogen             9 - Carbon Monoxide    16 - n-Heptane
C       3 - Carbon Dioxide      10 - Oxygen             17 - n-Octane
C       4 - Ethane              11 - i-Butane           18 - n-Nonane
C       5 - Propane             12 - n-Butane           19 - n-Decane
C       6 - Water               13 - i-Pentane          20 - Helium
C       7 - Hydrogen Sulfide    14 - n-Pentane          21 - Argon
C-----------------------------------------------------------------------
      REAL*8 CMWB(21),EIB(21),RKIB(21),WIB(21),QIB(21),HIB(21),MIB(21),
     & DIB(21)
      REAL*8 BEIJB(21,21),BKIJB(21,21),BWIJB(21,21),BUIJB(21,21)

      COMMON/PARAM91/ CMWB,EIB,RKIB,WIB,QIB,HIB,BEIJB,BKIJB,BWIJB,BUIJB,
     & MIB,DIB

      REAL*8 CMW(21), EI(21), RKI(21), WI(21), QI(21), HI(21), MI(21),
     & DI(21)
      REAL*8 BEIJ(21,21), BKIJ(21,21), BWIJ(21,21), BUIJ(21,21)
      COMMON/PARAM/  CMW, EI, RKI, WI, QI, HI, BEIJ, BKIJ, BWIJ, BUIJ,
     & MI,DI

      INTEGER PROG
      REAL*8 RGAS, MWX, MW(5)
      COMMON/CONSTANTS/ PROG, RGAS, MWX, MW

      REAL*8 DHIGH, PLOW, PHIGH, TLOW, THIGH
      COMMON/LIMITS/ DHIGH, PLOW, PHIGH, TLOW, THIGH

      REAL*8 TOLD
      COMMON/TOLDC/ TOLD

      INTEGER NCC, CID(21), J, K

      TOLD = 0.D0
      RGAS  = 8.31451D-3
      TLOW  = 0.D0
      THIGH = 10000.D0
      PLOW  = 0.5D-9
      PHIGH = 275.D0
      DHIGH = 12.D0

C.....Setup constants from block data
      MWX = 0.D0
      DO 400 J=1,NCC
        CMW(J) = CMWB(CID(J))
        RKI(J) = RKIB(CID(J))
        EI(J) = EIB(CID(J))
        WI(J) = WIB(CID(J))
        QI(J) = QIB(CID(J))
        HI(J) = 0.D0
        IF (CID(J).EQ.8) HI(J) = HIB(8)
        MI(J) = MIB(CID(J))
        DI(J) = DIB(CID(J))
 400  CONTINUE

C.....Interaction parameters from BIP arrays: BEIJ, BKIJ, BWIJ, BUIJ
      DO 420 J=1, NCC
        DO 410 K=J, NCC
          BEIJ(J,K) = BEIJB(CID(J),CID(K))
          BKIJ(J,K) = BKIJB(CID(J),CID(K))
          BWIJ(J,K) = BWIJB(CID(J),CID(K))
          BUIJ(J,K) = BUIJB(CID(J),CID(K))
 410    CONTINUE
 420  CONTINUE
      END
C=======================================================================
      SUBROUTINE TEMP (T)
C
C     PURPOSE:
C       Sets up temperature dependent terms.
C
C     DESCRIPTION OF ARGUMENTS:
C       T       - Temperature in kelvins. (Input)
C-----------------------------------------------------------------------
      REAL*8 A(58)
      COMMON/EOSAI/ A

      REAL*8 UU,RK3P0,WW,Q2P0,HH,BMIX
      COMMON/AGAVARIABLES/ UU,RK3P0,WW,Q2P0,HH,BMIX

      REAL*8 FN(58)
      COMMON/AGAEOS/ FN

      REAL*8 TR0P5, TR1P5, TR2P0, TR3P0, TR4P0, TR5P0, TR6P0
      REAL*8 TR7P0, TR8P0, TR9P0, TR11P0, TR13P0, TR21P0
      REAL*8 TR22P0, TR23P0, TR, T

C.....CALCULATE SECOND VIRIAL COEFFICIENT B
      CALL B(T,BMIX)

C.....CALCULATE FN(13) THROUGH FN(58)
C.....NOTE: FN(1)-FN(12) DO NOT CONTRIBUTE TO CSM TERMS
      TR     = T/UU
      TR0P5  = DSQRT(TR)
      TR1P5  = TR*TR0P5
      TR2P0  = TR*TR
      TR3P0  = TR*TR2P0
      TR4P0  = TR*TR3P0
      TR5P0  = TR*TR4P0
      TR6P0  = TR*TR5P0
      TR7P0  = TR*TR6P0
      TR8P0  = TR*TR7P0
      TR9P0  = TR*TR8P0
      TR11P0 = TR6P0*TR5P0
      TR13P0 = TR6P0*TR7P0
      TR21P0 = TR9P0*TR9P0*TR3P0
      TR22P0 = TR*TR21P0
      TR23P0 = TR*TR22P0

      FN(13) = A(13)*HH*TR6P0
      FN(14) = A(14)/TR2P0
      FN(15) = A(15)/TR3P0
      FN(16) = A(16)*Q2P0/TR2P0
      FN(17) = A(17)/TR2P0
      FN(18) = A(18)/TR11P0
      FN(19) = A(19)*TR0P5
      FN(20) = A(20)/TR0P5
      FN(21) = A(21)
      FN(22) = A(22)/TR4P0
      FN(23) = A(23)/TR6P0
      FN(24) = A(24)/TR21P0
      FN(25) = A(25)*WW/TR23P0
      FN(26) = A(26)*Q2P0/TR22P0
      FN(27) = A(27)*HH*TR
      FN(28) = A(28)*Q2P0*TR0P5
      FN(29) = A(29)*WW/TR7P0
      FN(30) = A(30)*HH*TR
      FN(31) = A(31)/TR6P0
      FN(32) = A(32)*WW/TR4P0
      FN(33) = A(33)*WW/TR
      FN(34) = A(34)*WW/TR9P0
      FN(35) = A(35)*HH*TR13P0
      FN(36) = A(36)/TR21P0
      FN(37) = A(37)*Q2P0/TR8P0
      FN(38) = A(38)*TR0P5
      FN(39) = A(39)
      FN(40) = A(40)/TR2P0
      FN(41) = A(41)/TR7P0
      FN(42) = A(42)*Q2P0/TR9P0
      FN(43) = A(43)/TR22P0
      FN(44) = A(44)/TR23P0
      FN(45) = A(45)/TR
      FN(46) = A(46)/TR9P0
      FN(47) = A(47)*Q2P0/TR3P0
      FN(48) = A(48)/TR8P0
      FN(49) = A(49)*Q2P0/TR23P0
      FN(50) = A(50)/TR1P5
      FN(51) = A(51)*WW/TR5P0
      FN(52) = A(52)*Q2P0*TR0P5
      FN(53) = A(53)/TR4P0
      FN(54) = A(54)*WW/TR7P0
      FN(55) = A(55)/TR3P0
      FN(56) = A(56)*WW
      FN(57) = A(57)/TR
      FN(58) = A(58)*Q2P0
      RETURN
      END
C=======================================================================
      BLOCK DATA
C-----------------------------------------------------------------------
      REAL*8 A(58)
      COMMON/EOSAI/ A

      REAL*8 CMWB(21),EIB(21),RKIB(21),WIB(21),QIB(21),HIB(21),MIB(21),
     & DIB(21)
      REAL*8 BEIJB(21,21),BKIJB(21,21),BWIJB(21,21),BUIJB(21,21)
      COMMON/PARAM91/ CMWB,EIB,RKIB,WIB,QIB,HIB,BEIJB,BKIJB,BWIJB,BUIJB,
     & MIB,DIB

C     EQUATION OF STATE PARAMETERS, A(1) THROUGH A(53)
C.....A(1)-A(7)
      DATA A/
     &  0.153832600D0,  1.341953000D0, -2.998583000D0, -0.048312280D0,
     &  0.375796500D0, -1.589575000D0, -0.053588470D0,

C.....A(8)-A(12)  FROM GRI1991 A(8)-A(12)
     &  0.886594630D0, -0.710237040D0, -1.471722000D0,  1.321850350D0,
     & -0.786659250D0,

C.....A(13)
     &  0.229129D-08,

C.....A(14)-A(34)
     &  0.157672400D0, -0.436386400D0, -0.044081590D0, -0.003433888D0,
     &  0.032059050D0,  0.024873550D0,  0.073322790D0, -0.001600573D0,
     &  0.642470600D0, -0.416260100D0, -0.066899570D0,  0.279179500D0,
     & -0.696605100D0, -0.002860589D0, -0.008098836D0,  3.150547000D0,
     &  0.007224479D0, -0.705752900D0,  0.534979200D0, -0.079314910D0,
     & -1.418465000D0,

C.....A(35)
     & -0.599905D-16,

C.....A(36)-A(58)
     &  0.105840200D0,  0.034317290D0, -0.007022847D0,  0.024955870D0,
     &  0.042968180D0,  0.746545300D0, -0.291961300D0,  7.294616000D0,
     & -9.936757000D0, -0.005399808D0, -0.243256700D0,  0.049870160D0,
     &  0.003733797D0,  1.874951000D0,  0.002168144D0, -0.658716400D0,
     &  0.000205518D0,  0.009776195D0, -0.020487080D0,  0.015573220D0,
     &  0.006862415D0, -0.001226752D0,  0.002850908D0/

C.....INDIVIDUAL COMPONENT PARAMETERS
C.....QIB=Qi,  HIB=Fi,  RKIB=Ki,  EIB=Ei,  WIB=Gi,  CMWB=MWi,  MIB=Mi
C.....DIB=DELTA
      DATA DIB/5*0.D0,1.D0,15*0.D0/
      DATA QIB/2*0.D0,0.69D0,2*0.D0,1.06775D0,0.633276D0,14*0.D0/
      DATA HIB/7*0.D0, 1.D0, 13*0.D0/
      DATA RKIB/0.4619255D0, 0.4479153D0, 0.4557489D0, 0.5279209D0,
     &          0.5837490D0, 0.3825868D0, 0.4618263D0, 0.3514916D0,
     &          0.4533894D0, 0.4186954D0, 0.6406937D0, 0.6341423D0,
     &          0.6738577D0, 0.6798307D0, 0.7175118D0, 0.7525189D0,
     &          0.7849550D0, 0.8152731D0, 0.8437826D0, 0.3589888D0,
     &          0.4216551D0/

      DATA EIB/151.318300D0,  99.737780D0, 241.960600D0, 244.166700D0,
     &         298.118300D0, 514.015600D0, 296.355000D0,  26.957940D0,
     &         105.534800D0, 122.766700D0, 324.068900D0, 337.638900D0,
     &         365.599900D0, 370.682300D0, 402.636293D0, 427.722630D0,
     &         450.325022D0, 470.840891D0, 489.558373D0,   2.610111D0,
     &         119.629900D0/

      DATA WIB/0.000000D0,0.027815D0,0.189065D0,0.079300D0,0.141239D0,
     &         0.332500D0,0.088500D0,0.034369D0,0.038953D0,0.021000D0,
     &         0.256692D0,0.281835D0,0.332267D0,0.366911D0,0.289731D0,
     &         0.337542D0,0.383381D0,0.427354D0,0.469659D0,0.000000D0,
     &         0.000000D0/

      DATA CMWB/16.0430D0, 28.0135D0, 44.0100D0, 30.0700D0, 44.0970D0,
     &          18.0153D0, 34.0820D0,  2.0159D0, 28.0100D0, 31.9988D0,
     &        2*58.1230D0,2*72.1500D0,86.1770D0,100.2040D0,114.2310D0,
     &         128.2580D0,142.2850D0,4.0026D0,39.9480D0/

      DATA MIB/5*0.D0,1.5822D0,0.390D0,14*0.D0/

C.....BINARY INTERACTION PARAMETERS
C.....BEIJB=Eij*,  BUIJB=UIJ,  BKIJB=Kij,  BWIJB=Gij*
      DATA (BUIJB(1,J),J=1,21)/
     &     1.000000D0, 0.886106D0, 0.963827D0, 1.000000D0, 0.990877D0,
     &     1.000000D0, 0.736833D0, 1.156390D0, 1.000000D0, 1.000000D0,
     &     1.000000D0, 0.992291D0, 1.000000D0, 1.003670D0, 1.302576D0,
     &     1.191904D0, 1.205769D0, 1.219634D0, 1.233498D0, 1.000000D0,
     &     1.000000D0/
      DATA (BUIJB(2,J),J=2,21)/
     &     1.000000D0, 0.835058D0, 0.816431D0, 0.915502D0, 1.000000D0,
     &     0.993476D0, 0.408838D0, 3*1.000000D0, 0.993556D0, 9*1.0000D0/
      DATA (BUIJB(3,J),J=3,21)/
     &     1.000000D0, 0.969870D0, 1.000000D0, 1.000000D0, 1.045290D0,
     &     1.000000D0, 0.900000D0, 5*1.0000D0, 1.066638D0, 1.077634D0,
     &     1.088178D0, 1.098291D0, 1.108021D0, 2*1.000000D0/
      DATA (BUIJB(4,J),J=4,21)/
     &     1.000000D0, 1.065173D0, 1.000000D0, 0.971926D0, 1.616660D0,
     &     2*1.0000D0, 4*1.25D0, 7*1.0000D0/
      DATA (BUIJB(5,J),J=5,21)/17*1.D0/
      DATA (BUIJB(6,J),J=6,21)/16*1.D0/
      DATA (BUIJB(7,J),J=7,21)/8*1.D0, 1.028973D0, 1.033754D0,
     &     1.038338D0, 1.042735D0, 1.046966D0, 2*1.0000D0/
      DATA (BUIJB(8,J),J=8,21)/14*1.D0/
      DATA (BUIJB(9,J),J=9,21)/13*1.D0/
      DATA (BUIJB(10,J),J=10,21)/12*1.D0/
      DATA (BUIJB(11,J),J=11,21)/11*1.D0/
      DATA (BUIJB(12,J),J=12,21)/10*1.D0/
      DATA (BUIJB(13,J),J=13,21)/9*1.D0/
      DATA (BUIJB(14,J),J=14,21)/8*1.D0/
      DATA (BUIJB(15,J),J=15,21)/7*1.D0/
      DATA (BUIJB(16,J),J=16,21)/6*1.D0/
      DATA (BUIJB(17,J),J=17,21)/5*1.D0/
      DATA (BUIJB(18,J),J=18,21)/4*1.D0/
      DATA (BUIJB(19,J),J=19,21)/3*1.D0/
      DATA (BUIJB(20,J),J=20,21)/2*1.D0/
      DATA BUIJB(21,21)/1.D0/

      DATA (BKIJB(1,J),J=1,21)/
     &     1.000000D0, 1.003630D0, 0.995933D0, 1.000000D0, 1.007619D0,
     &     1.000000D0, 1.000080D0, 1.023260D0, 1.000000D0, 1.000000D0,
     &     1.000000D0, 0.997596D0, 1.000000D0, 1.002529D0, 0.982962D0,
     &     0.983565D0, 0.982707D0, 0.981849D0, 0.980991D0, 1.000000D0,
     &     1.000000D0/
      DATA (BKIJB(2,J),J=2,21)/
     &     1.0000000D0,0.982361D0,1.007960D0,1.000000D0,1.000000D0,
     &     0.9425960D0,1.032270D0,13*1.000000D0/
      DATA (BKIJB(3,J),J=3,21)/
     &     1.0000000D0, 1.008510D0, 2*1.000000D0,1.00779D0,7*1.0D0,
     &     0.910183D0, 0.895362D0, 0.881152D0, 0.867520D0, 0.854406D0,
     &     2*1.000000D0/
      DATA (BKIJB(4,J),J=4,21)/
     &     1.000000D0, 0.986893D0, 1.000000D0, 0.999969D0, 1.020340D0,
     &     13*1.0000000D0/
      DATA (BKIJB(5,J),J=5,21)/17*1.D0/
      DATA (BKIJB(6,J),J=6,21)/16*1.D0/
      DATA (BKIJB(7,J),J=7,21)/8*1.D0, 0.968130D0, 0.962870D0,
     &     0.957828D0, 0.952441D0, 0.948338D0, 2*1.000000D0/
      DATA (BKIJB(8,J),J=8,21)/14*1.D0/
      DATA (BKIJB(9,J),J=9,21)/13*1.D0/
      DATA (BKIJB(10,J),J=10,21)/12*1.D0/
      DATA (BKIJB(11,J),J=11,21)/11*1.D0/
      DATA (BKIJB(12,J),J=12,21)/10*1.D0/
      DATA (BKIJB(13,J),J=13,21)/9*1.D0/
      DATA (BKIJB(14,J),J=14,21)/8*1.D0/
      DATA (BKIJB(15,J),J=15,21)/7*1.D0/
      DATA (BKIJB(16,J),J=16,21)/6*1.D0/
      DATA (BKIJB(17,J),J=17,21)/5*1.D0/
      DATA (BKIJB(18,J),J=18,21)/4*1.D0/
      DATA (BKIJB(19,J),J=19,21)/3*1.D0/
      DATA (BKIJB(20,J),J=20,21)/2*1.D0/
      DATA BKIJB(21,21)/1.D0/

      DATA (BEIJB(1,J),J=1,21)/
     &     1.000000D0, 0.971640D0, 0.960644D0, 1.000000D0, 0.994635D0,
     &     0.708218D0, 0.931484D0, 1.170520D0, 0.990126D0, 1.000000D0,
     &     1.019530D0, 0.989844D0, 1.002350D0, 0.999268D0, 1.107274D0,
     &     0.880880D0, 0.880973D0, 0.881067D0, 0.881161D0, 1.000000D0,
     &     1.000000D0/
      DATA (BEIJB(2,J),J=2,21)/
     &     1.000000D0, 1.022740D0, 0.970120D0, 0.945939D0, 0.746954D0,
     &     0.902271D0, 1.086320D0, 1.005710D0, 1.021000D0, 0.946914D0,
     &     0.973384D0, 0.959340D0, 0.945520D0, 1.000000D0, 1.000000D0,
     &     1.000000D0, 1.000000D0, 1.000000D0, 1.000000D0, 1.000000D0/
      DATA (BEIJB(3,J),J=3,21)/
     &     1.000000D0, 0.925053D0, 0.960237D0, 0.849408D0, 0.955052D0,
     &     1.281790D0, 1.500000D0, 1.000000D0, 0.906849D0, 0.897362D0,
     &     0.726255D0, 0.859764D0, 0.855134D0, 0.831229D0, 0.808310D0,
     &     0.786323D0, 0.765171D0, 2*1.000000D0/
      DATA (BEIJB(4,J),J=4,21)/
     &     1.000000D0, 1.022560D0, 0.693168D0, 0.946871D0, 1.164460D0,
     &     1.000000D0, 1.000000D0, 1.000000D0, 1.013060D0, 1.000000D0,
     &     1.00532D0, 7*1.000000D0/
      DATA (BEIJB(5,J),J=5,21)/
     &     1.000000D0, 1.000000D0, 1.000000D0, 1.034787D0,
     &     3*1.0000D0, 1.004900D0, 9*1.00000D0/
      DATA (BEIJB(6,J),J=6,21)/16*1.D0/
      DATA (BEIJB(7,J),J=7,21)/8*1.D0, 1.008692D0, 1.010126D0,
     &     1.011501D0, 1.012821D0, 1.014089D0, 2*1.000000D0/
      DATA (BEIJB(8,J),J=8,21)/
     &     1.000000D0, 1.100000D0, 1.000000D0, 1.300000D0,
     &     1.300000D0, 9*1.0000D0/
      DATA (BEIJB(9,J),J=9,21)/13*1.D0/
      DATA (BEIJB(10,J),J=10,21)/12*1.D0/
      DATA (BEIJB(11,J),J=11,21)/11*1.D0/
      DATA (BEIJB(12,J),J=12,21)/10*1.D0/
      DATA (BEIJB(13,J),J=13,21)/9*1.D0/
      DATA (BEIJB(14,J),J=14,21)/8*1.D0/
      DATA (BEIJB(15,J),J=15,21)/7*1.D0/
      DATA (BEIJB(16,J),J=16,21)/6*1.D0/
      DATA (BEIJB(17,J),J=17,21)/5*1.D0/
      DATA (BEIJB(18,J),J=18,21)/4*1.D0/
      DATA (BEIJB(19,J),J=19,21)/3*1.D0/
      DATA (BEIJB(20,J),J=20,21)/2*1.D0/
      DATA BEIJB(21,21)/ 1.D0/

      DATA (BWIJB(1,J),J=1,21)/1.D0,1.D0,0.807653D0,4*1.D0,
     &     1.957310D0,13*1.D0/
      DATA (BWIJB(2,J),J=2,21)/1.D0,0.982746D0,18*1.D0/
      DATA (BWIJB(3,J),J=3,21)/1.D0,0.370296D0,1.D0,1.67309D0,15*1.D0/
      DATA (BWIJB(4,J),J=4,21)/18*1.D0/
      DATA (BWIJB(5,J),J=5,21)/17*1.D0/
      DATA (BWIJB(6,J),J=6,21)/16*1.D0/
      DATA (BWIJB(7,J),J=7,21)/15*1.D0/
      DATA (BWIJB(8,J),J=8,21)/14*1.D0/
      DATA (BWIJB(9,J),J=9,21)/13*1.D0/
      DATA (BWIJB(10,J),J=10,21)/12*1.D0/
      DATA (BWIJB(11,J),J=11,21)/11*1.D0/
      DATA (BWIJB(12,J),J=12,21)/10*1.D0/
      DATA (BWIJB(13,J),J=13,21)/9*1.D0/
      DATA (BWIJB(14,J),J=14,21)/8*1.D0/
      DATA (BWIJB(15,J),J=15,21)/7*1.D0/
      DATA (BWIJB(16,J),J=16,21)/6*1.D0/
      DATA (BWIJB(17,J),J=17,21)/5*1.D0/
      DATA (BWIJB(18,J),J=18,21)/4*1.D0/
      DATA (BWIJB(19,J),J=19,21)/3*1.D0/
      DATA (BWIJB(20,J),J=20,21)/2*1.D0/
      DATA BWIJB(21,21)/1.D0/
      END
