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
      PROGRAM AGA8PROG
C
C  PURPOSE:
C     Interactive utility program for calculating compressibility factors
C     from the DETAIL and GROSS models.
C-----------------------------------------------------------------------
      REAL*8 X(5), XI(21), ZB, DB
      COMMON/AGA/ X, XI, ZB, DB

      INTEGER PROG
      REAL*8 RGAS, MWX, MW(5)
      COMMON/CONSTANTS/ PROG, RGAS, MWX, MW

      CHARACTER OUTOPT*80, OPTX*2
      INTEGER I, OPTSET, OPT, METSG

      WRITE (*,1020)
      PAUSE
 1020 FORMAT(/,
     &/10X,'ษออออออออออออออออออออออออออออออออออออออออออออออออออออออออป',
     &/10X,'บ                                                        บ',
     &/10X,'บ                                                        บ',
     &/10X,'บ         COMPRESSIBILITY FACTORS OF NATURAL GAS         บ',
     &/10X,'บ           AND OTHER RELATED HYDROCARBON GASES          บ',
     &/10X,'บ                                                        บ',
     &/10X,'บ                                                        บ',
     &/10X,'บ                 Research Sponsored by:                 บ',
     &/10X,'บ                 Gas Research Institute                 บ',
     &/10X,'บ                         and                            บ',
     &/10X,'บ         Groupe Europeen de Recherches Gazieres         บ',
     &/10X,'บ                                                        บ',
     &/10X,'บ                                                        บ',
     &/10X,'บ                For Information Contact:                บ',
     &/10X,'บ                Dr. Jeffrey L. Savidge, GRI             บ',
     &/10X,'บ                    (312) 399-8100                      บ',
     &/10X,'บ                Or: Ms. Lori Traweek, AGA               บ',
     &/10X,'บ                    (703) 841-8400                      บ',
     &/10X,'บ                                                        บ',
     &/10X,'บ Disclaimer:  User assumes all risk and responsibility. บ',
     &/10X,'บ     (C) Copyright 1992, 1994      July 1, 1994         บ',
     &/10X,'ศออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ')

      PROG   = 0
      METSG  = 0
      DO 20 I=1, 21
 20   XI(I)  = 0

      OPTSET = 1
      CALL UNITSG(OPTSET)
      OUTOPT = 'nul'
      OPEN (1, FILE = OUTOPT)

C.....Enter the main menu.
 100  WRITE (*,1010)
 1010 FORMAT (25(/),'  Compressibility Factor Program',/
     &'  Select option:',//,
     &'  (1)   Select UNITS (SI, Engineering, Custom)',/,
     &'  (2)   Select CALCULATION METHOD',/,
     &'  (3)   VIEW calculation setup',/,
     &'  (4)   Generate a TABLE of properties (Z, d, or Fpv)',/,
     &'  (5)   Calculate Z, d, and Fpv at T and P',/,
     &'  (6)   Calculate Z, d, and Fpv at constant TEMPERATURE',/,
     &'  (7)   Calculate Z, d, and Fpv at constant PRESSURE',/,
     &'  (8)   Select OUTPUT device',/,
     &'  (9)   SAVE setup information to a file',/,
     &'  (10)  LOAD setup information from a file',/,
     &'  (X)   EXIT to operating system',//)
      READ (*,1000,ERR=100) OPTX
      OPT = 0
      READ (OPTX,1001,ERR=110) OPT
1000  FORMAT(A)
1001  FORMAT(I2)
 110  IF (OPT.EQ.1) THEN
        OPTSET = 0
        CALL UNITSG(OPTSET)
      ELSEIF (OPT.EQ.2) THEN
        CALL METHOD(METSG)
      ELSEIF (OPT.EQ.3) THEN
        IF (PROG.EQ.0) THEN
          PAUSE ' Please select a method first'
        ELSE
          CALL STATUS(OUTOPT, METSG)
        ENDIF
      ELSEIF (OPT.GE.4 .AND. OPT.LE.7) THEN
        IF (PROG.EQ.0) THEN
          PAUSE ' Please select a method first'
        ELSE
          IF (OPT.EQ.4) THEN
            CALL TABLES2(METSG)
          ELSE
            CALL TABLES(OPT, METSG)
          ENDIF
        ENDIF
      ELSEIF (OPT.EQ.8) THEN
        CALL OUTPUT(0, OUTOPT)
      ELSEIF (OPT.EQ.9) THEN
        IF (PROG.EQ.0) THEN
          PAUSE ' Please select a method first'
        ELSE
          CALL CONFIG(OPT, OPTSET, OUTOPT, METSG)
        ENDIF
      ELSEIF (OPT.EQ.10) THEN
        CALL CONFIG(OPT, OPTSET, OUTOPT, METSG)
      ELSEIF (OPTX.EQ.'X' .OR. OPTX.EQ.'x') THEN
        STOP
      ENDIF
      GOTO 100
      END
C=======================================================================
      SUBROUTINE COMPST(I)
C
C  PURPOSE:
C     Displays detailed gas composition.
C-----------------------------------------------------------------------
      REAL*8 X(5), XI(21), ZB, DB
      COMMON/AGA/ X, XI, ZB, DB

      INTEGER I

      IF (I.EQ.0) THEN
        WRITE (*,1000) XI
      ELSE
        WRITE (I,1000) XI
      ENDIF

 1000 FORMAT (   '   ID #   COMPONENT         MOLE PERCENT',/,
     &           '   ----   ---------------    ----------',/,
     &           '     1    METHANE            ',F10.6,/,
     &           '     2    ETHANE             ',F10.6,/,
     &           '     3    PROPANE            ',F10.6,/,
     &           '     4    ISOBUTANE          ',F10.6,/,
     &           '     5    N-BUTANE           ',F10.6,/,
     &           '     6    ISOPENTANE         ',F10.6,/,
     &           '     7    N-PENTANE          ',F10.6,/,
     &           '     8    N-HEXANE           ',F10.6,/,
     &           '     9    N-HEPTANE          ',F10.6,/,
     &           '    10    N-OCTANE           ',F10.6,/,
     &           '    11    N-NONANE           ',F10.6,/,
     &           '    12    N-DECANE           ',F10.6,/,
     &           '    13    CARBON DIOXIDE     ',F10.6,/,
     &           '    14    NITROGEN           ',F10.6,/,
     &           '    15    HYDROGEN SULFIDE   ',F10.6,/,
     &           '    16    HELIUM             ',F10.6,/,
     &           '    17    WATER              ',F10.6,/,
     &           '    18    OXYGEN             ',F10.6,/,
     &           '    19    ARGON              ',F10.6,/,
     &           '    20    HYDROGEN           ',F10.6,/,
     &           '    21    CARBON MONOXIDE    ',F10.6)
      END
C=======================================================================
      SUBROUTINE CONFIG(OPT, OPTSET, OUTOPT, METSG)
C
C  PURPOSE:
C     Reads in the CONF.SAV file when OPT = 1.
C     Writes out the CONF.SAV file when OPT = 2.
C-----------------------------------------------------------------------
      CHARACTER*10 ALPHP, ALPHT, ALPHD, ALPHH
      COMMON/LABELS/ ALPHP, ALPHT, ALPHD, ALPHH

      REAL*8 X(5), XI(21), ZB, DB
      COMMON/AGA/ X, XI, ZB, DB

      INTEGER PROG
      REAL*8 RGAS, MWX, MW(5)
      COMMON/CONSTANTS/ PROG, RGAS, MWX, MW

      REAL*8 TBHV, TBDR, PD, HVINPUT, DRINPUT
      COMMON/REFCOND/ TBHV, TBDR, PD, HVINPUT, DRINPUT

      CHARACTER*80 CFNAME, OUTOPT, LINE
      INTEGER OPT, CON, ERRNUM, OPTSET, I, METSG

 10   WRITE (*,'(3(/),A40)')' Configuration Filename <conf.sav> : '
      READ (*, '(A80)') CFNAME
      IF (CFNAME.EQ.'NUL' .OR. CFNAME.EQ.'nul') RETURN
      IF (CFNAME.EQ.' ') CFNAME = 'CONF.SAV'
      IF (OPT.EQ.10) THEN
        OPEN (2, FILE = CFNAME, STATUS='OLD', ERR=10)
        READ (2,*,END=60,ERR=70) PROG
        READ (2,'(A39)',END=60,ERR=70) OUTOPT
        CON = 2
        IF (OUTOPT.EQ.'NUL' .OR. OUTOPT.EQ.'nul') CON = 1
        IF (OUTOPT.EQ.'PRN' .OR. OUTOPT.EQ.'prn') CON = 3
        CALL OUTPUT(CON, OUTOPT)
        READ (2,'(I1)',END=60,ERR=70) OPTSET
        IF (OPTSET.EQ.0) OPTSET = 1
        CALL UNITSG(OPTSET)
        IF (OPTSET.EQ.5) THEN
          READ (2,'(A10)',END=60,ERR=70) ALPHP
          READ (2,'(A10)',END=60,ERR=70) ALPHT
          READ (2,'(A10)',END=60,ERR=70) ALPHD
          READ (2,'(A10)',END=60,ERR=70) ALPHH
        ENDIF
        READ (2,'(A80)',END=60,ERR=70) LINE
        READ (2,'(A80)',END=60,ERR=70) LINE
        READ (2,'(A80)',END=60,ERR=70) LINE
        LINE = LINE
        DO 50 I=1,21
 50     READ (2,'(T30,F10.6)',END=60,ERR=70) XI(I)
        READ (2,'(A80)',END=60,ERR=70) LINE
        READ (2,'(I5)',END=60,ERR=70) METSG
        READ (2,'(F12.6)',END=60,ERR=70) TBHV
        READ (2,'(F12.6)',END=60,ERR=70) TBDR
        READ (2,'(F12.8)',END=60,ERR=70) PD
        READ (2,'(F12.6)',END=60,ERR=70) HVINPUT
        READ (2,'(F12.6)',END=60,ERR=70) DRINPUT
        READ (2,'(F12.8)',END=60,ERR=70) X(2)
        READ (2,'(F12.8)',END=60,ERR=70) X(3)
        READ (2,'(F12.8)',END=60,ERR=70) X(4)
        READ (2,'(F12.8)',END=60,ERR=70) X(5)
        X(2) = X(2)/100.D0
        X(3) = X(3)/100.D0
        X(4) = X(4)/100.D0
        X(5) = X(5)/100.D0
        CLOSE(2)
        CALL SETUP(METSG, ERRNUM)
C-----------------------------------------------------------------------
      ELSEIF (OPT.EQ.9) THEN
        OPEN (2, FILE = CFNAME)
        WRITE (2,'(I1,   T40,A25)') PROG  ,'Program selection        '
        WRITE (2,'(A40,  T40,A25)') OUTOPT,'Output file              '
        WRITE (2,'(I1,   T40,A25)') OPTSET,'Units selection          '
        IF (OPTSET.EQ.5) THEN
          WRITE (2,'(A10,T40,A25)') ALPHP ,'Pressure units           '
          WRITE (2,'(A10,T40,A25)') ALPHT ,'Temperature units        '
          WRITE (2,'(A10,T40,A25)') ALPHD ,'Density units            '
          WRITE (2,'(A10,T40,A25)') ALPHH ,'Heating value units      '
        ENDIF
        WRITE (2,*)
        CALL COMPST(2)
        WRITE (2,*)
        WRITE (2,'(I5,   T40,A25)') METSG  ,'GROSS method             '
        WRITE (2,'(F12.6,T40,A25)') TBHV   ,'Ref. temperature (HV)    '
        WRITE (2,'(F12.6,T40,A25)') TBDR   ,'Ref. temperature (DR)    '
        WRITE (2,'(F12.8,T40,A25)') PD     ,'Ref. pressure            '
        WRITE (2,'(F12.6,T40,A25)') HVINPUT,'Volumetric Heating Value '
        WRITE (2,'(F12.8,T40,A25)') DRINPUT,'Relative Density         '
        IF (METSG.EQ.2 .AND. PROG.EQ.2) THEN
          WRITE (2,'(F12.8,T40,A25)') X(2)*100.D0,
     &                                      'Mole percent of nitrogen '
        ELSE
          WRITE (2,'(F12.8,T40,A25)') 0.D0,
     &                                      'Mole percent of nitrogen '
        ENDIF
        WRITE (2,'(F12.8,T40,A25)') X(3)*100.D0,
     &                                      'Mole percent of CO2      '
        WRITE (2,'(F12.8,T40,A25)') X(4)*100.D0,
     &                                      'Mole percent of hydrogen '
        WRITE (2,'(F12.8,T40,A25)') X(5)*100.D0,
     &                                      'Mole percent of CO       '
        CLOSE(2)
      ENDIF
      RETURN
 60   PAUSE ' Error:  Premature end of file in configuration file'
      STOP
 70   PAUSE ' Error:  Invalid input in configuration file'
      STOP
      END
C=======================================================================
      SUBROUTINE INPUT(PROP1, PROP2, PRINC, ERROR, OPT)
C
C  PURPOSE:
C     Enters the starting point, ending point and increment for
C     temperature and pressure tables.  This routine also prints out
C     the header.
C-----------------------------------------------------------------------
      CHARACTER*10 ALPHP, ALPHT, ALPHD, ALPHH
      COMMON/LABELS/ ALPHP, ALPHT, ALPHD, ALPHH

      INTEGER PROG
      REAL*8 RGAS, MWX, MW(5)
      COMMON/CONSTANTS/ PROG, RGAS, MWX, MW

      INTEGER OPT
      REAL*8 PROP1, PROP2, PRINC, PROP, UNITS
      LOGICAL ERROR

      ERROR = .FALSE.
      READ (*,*,ERR=10) PROP1, PROP2, PRINC
      IF (OPT.EQ.1) THEN
        PROP1 = UNITS(PROP1, 'T', ALPHT, 'K')
        PROP2 = UNITS(PROP2, 'T', ALPHT, 'K')
        IF (ALPHT.EQ.'R' .OR. ALPHT.EQ.'F') PRINC = PRINC*5.D0/9.D0
      ELSE
        PROP1 = UNITS(PROP1, 'P', ALPHP, 'MPa')
        PROP2 = UNITS(PROP2, 'P', ALPHP, 'MPa')
        PRINC = UNITS(PRINC, 'P', ALPHP(1:4), 'MPa')
      ENDIF
      PRINC = DABS(PRINC)
      IF (PRINC.EQ.0.D0) PRINC = 10000.D0
      IF (PROP1.GT.PROP2) THEN
        PROP  = PROP1
        PROP1 = PROP2
        PROP2 = PROP
      ENDIF
      RETURN
 10   ERROR = .TRUE.
      END
C=======================================================================
      SUBROUTINE METHOD(METSG)
C
C  PURPOSE:
C     Selects which model should be used to calculate natural gas
C     properties and inputs the composition, heating value, and
C     relative density (specific gravity) as required by the
C     different models.
C-----------------------------------------------------------------------
      CHARACTER*10 ALPHP, ALPHT, ALPHD, ALPHH
      COMMON/LABELS/ ALPHP, ALPHT, ALPHD, ALPHH

      REAL*8 X(5), XI(21), ZB, DB
      COMMON/AGA/ X, XI, ZB, DB

      INTEGER PROG
      REAL*8 RGAS, MWX, MW(5)
      COMMON/CONSTANTS/ PROG, RGAS, MWX, MW

      REAL*8 TBHV, TBDR, PD, HVINPUT, DRINPUT
      COMMON/REFCOND/ TBHV, TBDR, PD, HVINPUT, DRINPUT

      CHARACTER*1 INPT
      INTEGER IDNMB, I, ERRNUM, METSG, OPT
      REAL*8 SUM, UNITS, TB1, TB2, PD1
      REAL*8 X1, X2, X3, X4, T1, P1, DAIR, VIR
      REAL*8 TEMP1, TEMP2, TEMP3

C.....Select a mixture method.
 10   WRITE (*,1000)
      READ(*,*,ERR=999) OPT
      IF (OPT.EQ.0) RETURN
      PROG = OPT
      IF (PROG.EQ.1) METSG = 0

C-----------------------------------------------------------------------
C  DETAIL METHOD SETUP
C-----------------------------------------------------------------------
      IF (PROG.EQ.1) THEN
 310    SUM = 0
        DO 320 I=1, 21
 320    SUM = SUM + XI(I)
 330    CALL COMPST(0)
        WRITE (*,1210) SUM
        WRITE (*,*) 'ID NUMBER TO CHANGE(0=EXIT): '
        READ (*,*,ERR=330) IDNMB
        IF (IDNMB.LT.0 .OR. IDNMB.GT.21) GOTO 330
        IF (IDNMB.NE.0) THEN
          WRITE (*,'(''+MOLE PERCENT: '')')
          READ (*,*,ERR=330) XI(IDNMB)
          GOTO 310
        ENDIF
        IF (SUM.EQ.0) THEN
          PROG = 0
          RETURN
        ELSEIF (DABS(SUM - 100.D0).GT.0.5D-6) THEN
 350      WRITE (*,1200)
          READ (*,*,ERR=350) OPT
          IF (OPT.EQ.2) GOTO 330
        ENDIF
        CALL SETUP(METSG, ERRNUM)

C-----------------------------------------------------------------------
C  GROSS METHOD SETUP
C-----------------------------------------------------------------------
      ELSEIF (PROG.EQ.2) THEN
        IF (TBHV.EQ.0 .AND. TBDR.EQ.0) THEN
          TBHV = 298.15D0
          TBDR = 273.15D0
          PD   = 0.101325D0
        ENDIF
        TB1 = UNITS(TBHV, 'T', 'K', ALPHT)
        TB2 = UNITS(TBDR, 'T', 'K', ALPHT)
        PD1 = UNITS(PD, 'P', 'MPa', ALPHP)
 100    WRITE (*,1010) TB1, ALPHT, TB2, ALPHT, PD1, ALPHP
        READ(*,*,ERR=999) OPT
        IF (OPT.EQ.0) THEN
          IF (METSG.EQ.0) PROG = 0
          RETURN
        ENDIF
        IF (OPT.EQ.3) THEN
          WRITE (*,1020) ALPHT
          READ (*,*,ERR=100) TEMP1
          WRITE (*,1030) ALPHT
          READ (*,*,ERR=100) TEMP2
          WRITE (*,1040) ALPHP
          READ (*,*,ERR=100) TEMP3
          TB1 = TEMP1
          TB2 = TEMP2
          PD1 = TEMP3
          TBHV = UNITS(TB1, 'T', ALPHT, 'K')
          TBDR = UNITS(TB2, 'T', ALPHT, 'K')
          PD   = UNITS(PD1, 'P', ALPHP, 'MPa')
          IF (METSG.EQ.0) GOTO 100
          CALL SETUP(METSG, ERRNUM)
          IF (ERRNUM.NE.0) GOTO 997
          GOTO 100
        ENDIF
        IF (OPT.LT.1 .OR. OPT.GT.2) GOTO 100
        METSG = OPT

C  .....Relative Density
        DRINPUT = 0
 210    WRITE (*,1060) TB2, ALPHT(1:1)
        READ(*,*,ERR=998) DRINPUT
        IF (DRINPUT.GT.0.87D0 .OR. DRINPUT.LT.0.554D0) THEN
          WRITE (*,1100)
          GOTO 210
        ENDIF

C  .....Heating Value
        HVINPUT = 0
        IF (METSG.EQ.2) GOTO 220
          T1 = UNITS(60.D0, 'T', 'F', 'K')
          P1 = UNITS(14.73D0, 'P', 'psia', 'MPa')
          X1 = UNITS(477.D0, 'H', 'Btu/ft^3', 'MJ/m^3')
          X2 = UNITS(1150.D0, 'H', 'Btu/ft^3', 'MJ/m^3')
          VIR  = -0.12527D0 + 5.91D-4*T1 - 6.62D-7*T1**2
          DAIR = 28.96256D0/(0.00831451D0*T1/P1 + VIR)

          X1 = X1*(1.D0 + 2.1113D-5*(T1 - 273.15D0))/DAIR
     &           *(1.D0 + 1.0270D-4*(T1 - 298.15D0))
          X2 = X2*(1.D0 + 2.1113D-5*(T1 - 273.15D0))/DAIR
     &           *(1.D0 + 1.0270D-4*(T1 - 298.15D0))

          VIR  = -0.12527D0 + 5.91D-4*TBDR - 6.62D-7*TBDR**2
          DAIR = 28.96256D0/(0.00831451D0*TBDR/PD + VIR)
          X3 = X1/(1.D0 + 2.1113D-5*(TBDR - 273.15D0))*DAIR
     &           /(1.D0 + 1.0270D-4*(TBHV - 298.15D0))
          X4 = X2/(1.D0 + 2.1113D-5*(TBDR - 273.15D0))*DAIR
     &           /(1.D0 + 1.0270D-4*(TBHV - 298.15D0))

          X3 = UNITS(X3, 'H', 'MJ/m^3',ALPHH)
          X4 = UNITS(X4, 'H', 'MJ/m^3',ALPHH)
 200      WRITE (*,1050) ALPHH, TB1, TB2, X3, X4, ALPHH
          READ (*,*,ERR=998) HVINPUT
          IF (HVINPUT.GT.X4*1.0005D0 .OR. HVINPUT.LT.X3/1.0005D0) THEN
            WRITE (*,1100)
            GOTO 200
          ENDIF
          HVINPUT = UNITS(HVINPUT, 'H',ALPHH, 'MJ/m^3')

C  .....Nitrogen
        X(2) = 0
        IF (METSG.EQ.1) GOTO 230
 220    WRITE (*,1120)
        READ(*,*,ERR=998) X(2)
        X(2) = X(2)/100.D0
        IF (X(2).GT.0.5D0 .OR. X(2).LT.0.D0) THEN
          WRITE (*,1100)
          GOTO 220
        ENDIF

C  .....Carbon Dioxide
        X(3) = 0
 230    WRITE (*,1130)
        READ(*,*,ERR=998) X(3)
        X(3) = X(3)/100.D0
        IF (X(3).GT.0.3D0 .OR. X(3).LT.0.D0) THEN
          WRITE (*,1100)
          GOTO 230
        ENDIF

C  .....Hydrogen
        X(4) = 0
 240    WRITE (*,1140)
        READ(*,*,ERR=998) X(4)
        X(4) = X(4)/100.D0
        IF (X(4).GT.0.1D0 .OR. X(4).LT.0.D0) THEN
          WRITE (*,1100)
          GOTO 240
        ENDIF

C  .....Carbon Monoxide
        X(5) = 0
 250    INPT = 'N'
        IF (X(4).NE.0) THEN
          X(5) = 0.0964D0*X(4)
          WRITE (*,1145) X(5)*100
          READ (*,'(A1)') INPT
        ENDIF
        IF (INPT.EQ.'N' .OR. INPT.EQ.'n') THEN
 255      WRITE (*,1150)
          READ(*,*,ERR=250) X(5)
          X(5) = X(5)/100.D0
          IF (X(5).GT.0.03D0 .OR. X(5).LT.0.D0) THEN
            WRITE (*,1100)
            GOTO 255
          ENDIF
        ENDIF

        CALL SETUP(OPT, ERRNUM)
 997    IF (ERRNUM.NE.0) THEN
          IF (ERRNUM.EQ.1)
     &     PAUSE '***INVALID PARAMETERS IN SETUP, CHECK GAS COMPOSITION'
          ERRNUM = 0
          METSG = 0
          PROG = 0
          GOTO 100
        ENDIF
      ENDIF
 999  RETURN
 998  METSG = 0
      PROG = 0
      GOTO 10
C-----------------------------------------------------------------------
 1000 FORMAT (20(/),'  SELECT EQUATION OF STATE TO COMPUTE Z, d, OR Fpv'
     &//'  (1)  DETAILED CHARACTERIZATION METHOD',/,
     &  '  (2)  GROSS CHARACTERIZATION METHOD',/,
     &  '  (0)  Return to main menu',//)
 1010 FORMAT (20(/),'  GROSS CHARACTERIZATION MENU',//,
     &'         0 - Return to main menu',/,
     &'  Method 1 - Input volumetric heating value (Hv),',/,
     &'             relative density (specific gravity),',/,
     &'             and the mole percent of CO2.',/,
     &'  Method 2 - Input relative density (specific gravity)',/,
     &'             and the mole percent of N2 and CO2.',/,
     &'         3 - Change Reference conditions',/,
     &'             (for more information, see Appendix C.2 in ',
     &'AGA Report No. 8)',/,
     &'             Current:  T(combustion) =',F10.4,1X,A1,/,
     &'                       T(flow)       =',F10.4,1X,A1,/,
     &'                       P(flow)       =',F12.6,1X,A10,//,
     &'  Select method number ===>  ')
 1020 FORMAT (3(/),' Enter reference temperature for the',
     &             ' combustion basis in ',A10,/)
 1030 FORMAT (3(/),' Enter reference temperature for the',
     &             ' flow basis in ',A10,/)
 1040 FORMAT (3(/),' Enter reference pressure for the',
     &             ' flow basis in ',A10,/)
 1050 FORMAT (3(/),' Enter the volumetric (gross) heating value in ',
     &             A10,' @ ',F6.2,'/',F6.2,':',/,
     &             '   (Range: ',F8.2,' to ',F8.2,' ',A10,')',/)
 1060 FORMAT (3(/),' Enter the relative density (specific gravity)',
     &             ' @ ',F6.2,1X,A1,':',/,
     &             '   (Range:  0.554 to 0.87)',//)
 1100 FORMAT ('  That number is out of range.')
 1120 FORMAT (3(/),' Enter the mole percent of nitrogen:',/,
     &             '   (Range:  0 to 50%)',//)
 1130 FORMAT (3(/),' Enter the mole percent of carbon dioxide:',/,
     &             '   (Range:  0 to 30%)',//)
 1140 FORMAT (3(/),' Enter the mole percent of hydrogen:',/,
     &             '   (Range:  0 to 10%)',//)
 1145 FORMAT (3(/),' The mole percent of carbon monoxide is:',F9.6,/,
     &             '   Do you wish to use this value(Y/N)?  ')
 1150 FORMAT (3(/),' Enter the mole percent of carbon monoxide:',/,
     &             '   (Range:  0 to 3%)',//)
 1200 FORMAT (25(/),
     &    '  THE MOLE PERCENT DOES NOT ADD TO 100%',//,
     &    '  HOW WOULD YOU LIKE TO CORRECT THIS:',/,
     &    '     (1)  NORMALIZE MOLE FRACTIONS',/,
     &    '     (2)  RETURN TO PREVIOUS PAGE',/)
 1210 FORMAT (' SUM = ',F12.6)
       END
C=======================================================================
      SUBROUTINE OUTPUT(CON, OUTOPT)
C
C  PURPOSE:
C     Selects an output device.
C-----------------------------------------------------------------------
      CHARACTER OUTOPT*80
      INTEGER CON, OPT

 100  IF (CON.EQ.0) THEN
        WRITE (*,1000)
        READ (*,*,ERR=100) OPT
      ENDIF

C.....Choose only the display for output.
      IF (OPT.EQ.1 .OR. CON.EQ.1) THEN
        OUTOPT = 'nul'
        OPEN (1, FILE = OUTOPT)

C.....Choose a file and display for output.
      ELSEIF (OPT.EQ.2 .OR. CON.EQ.2) THEN
        IF (CON.NE.2) THEN
          WRITE (*,'('' Enter the filespec for your output file.'',//)')
          READ (*,'(A80)') OUTOPT
          IF (OUTOPT.EQ.' ') OUTOPT = 'nul'
        ENDIF
        OPEN (1, FILE = OUTOPT)

C.....Choose the printer and display for output.
      ELSEIF (OPT.EQ.3 .OR. CON.EQ.3) THEN
        OUTOPT = 'prn'
        OPEN (1, FILE = OUTOPT)

C.....Return to the main menu.
      ELSEIF (OPT.EQ.0) THEN
      ELSE
        CON = 0
        GOTO 100
      ENDIF

 1000 FORMAT (25(/),'  OUTPUT MENU:',//,
     &'  (1)  Display  (Output to the display only)',/,
     &'  (2)  File     (Output to the display and a file)',/,
     &'  (3)  Printer  (Output to the display and the printer)',/,
     &'  (0)  Return to the main menu',//)
        END
C=======================================================================
      SUBROUTINE PROPS(P, D, T, Z)
C
C  PURPOSE:
C     Writes properties to the screen and to a file.
C-----------------------------------------------------------------------
      CHARACTER*10 ALPHP, ALPHT, ALPHD, ALPHH
      COMMON/LABELS/ ALPHP, ALPHT, ALPHD, ALPHH

      REAL*8 X(5), XI(21), ZB, DB
      COMMON/AGA/ X, XI, ZB, DB

      REAL*8 P, D, T, Z, PP, TT, DD, UNITS

C.....Convert properties from the SI units system to the select units.
      PP = UNITS(P, 'P', 'MPa', ALPHP)
      TT = UNITS(T, 'T', 'K', ALPHT)
      DD = UNITS(D, 'D', 'mol/dm^3', ALPHD)
      WRITE (*, 1000) PP, TT, DD, Z, DSQRT(ZB/Z)
      WRITE (1, 1000) PP, TT, DD, Z, DSQRT(ZB/Z)
 1000 FORMAT (1X,G11.6E1,1X,F7.3,3X,3(1X,G10.6E1))
      END
C=======================================================================
      SUBROUTINE SETUP(METSG, ERRNUM)
C
C  PURPOSE:
C     Interfaces with the setup routines for the GROSS or DETAIL models.
C-----------------------------------------------------------------------
      REAL*8 X(5), XI(21), ZB, DB
      COMMON/AGA/ X, XI, ZB, DB

      INTEGER PROG
      REAL*8 RGAS, MWX, MW(5)
      COMMON/CONSTANTS/ PROG, RGAS, MWX, MW

      REAL*8 TBHV, TBDR, PD, HVINPUT, DRINPUT
      COMMON/REFCOND/ TBHV, TBDR, PD, HVINPUT, DRINPUT

      INTEGER METSG, ERRNUM,I, NCC, CID(21)
      REAL*8 SUM, XJ(21), XK(21), XL(21)

      IF (PROG.EQ.1) THEN
        SUM = 0
        DO 10 I=1, 21
 10     SUM = SUM + XI(I)
        IF (SUM.EQ.0) SUM = 1.D0
        DO 20 I=1, 21
 20     XJ(I)  = XI(I)/SUM
        XK( 1) = XJ( 1)
        XK( 4) = XJ( 2)
        XK( 5) = XJ( 3)
        XK(11) = XJ( 4)
        XK(12) = XJ( 5)
        XK(13) = XJ( 6)
        XK(14) = XJ( 7)
        XK(15) = XJ( 8)
        XK(16) = XJ( 9)
        XK(17) = XJ(10)
        XK(18) = XJ(11)
        XK(19) = XJ(12)
        XK( 3) = XJ(13)
        XK( 2) = XJ(14)
        XK( 7) = XJ(15)
        XK(20) = XJ(16)
        XK( 6) = XJ(17)
        XK(10) = XJ(18)
        XK(21) = XJ(19)
        XK( 8) = XJ(20)
        XK( 9) = XJ(21)

        NCC = 0
        DO 30 I=1, 21
          IF (XK(I).NE.0) THEN
            NCC = NCC + 1
            CID(NCC) = I
            XL(NCC) = XK(I)
          ENDIF
 30     CONTINUE
        CALL PARAMDL(NCC, CID)
        CALL CHARDL(NCC, XL, ZB, DB)
      ELSEIF (PROG.EQ.2) THEN
        CALL PARAMGS
        CALL CHARGS(METSG, HVINPUT, DRINPUT, X, TBHV, TBDR, PD,
     &              TBDR, PD, ZB, DB, ERRNUM)
      ENDIF
      END
C=======================================================================
      SUBROUTINE STATUS(OUTOPT, METSG)
C
C  PURPOSE:
C     Displays the current program settings and fixed points.
C-----------------------------------------------------------------------
      CHARACTER*10 ALPHP, ALPHT, ALPHD, ALPHH
      COMMON/LABELS/ ALPHP, ALPHT, ALPHD, ALPHH

      REAL*8 X(5), XI(21), ZB, DB
      COMMON/AGA/ X, XI, ZB, DB

      REAL*8 DHIGH, PLOW, PHIGH, TLOW, THIGH
      COMMON/LIMITS/ DHIGH, PLOW, PHIGH, TLOW, THIGH

      INTEGER PROG
      REAL*8 RGAS, MWX, MW(5)
      COMMON/CONSTANTS/ PROG, RGAS, MWX, MW

      REAL*8 TBHV, TBDR, PD, HVINPUT, DRINPUT
      COMMON/REFCOND/ TBHV, TBDR, PD, HVINPUT, DRINPUT

      CHARACTER*80 UNITOPT, OUTOPT
      INTEGER METSG, I
      REAL*8 P1, T1, T2
      REAL*8 UNITS, HV1, SUM, TB1, TB2, PD1

C.....Display program settings.
      WRITE (*,'(25(/))')
      IF (PROG.EQ.1) WRITE (*,1040)
      IF (PROG.EQ.2) WRITE (*,1050) METSG
      UNITOPT = ALPHP//'  '//ALPHT//'  '//ALPHD//'  '//ALPHH
      WRITE (*,1000) OUTOPT, UNITOPT
      T1 = UNITS(TLOW, 'T', 'K', ALPHT)
      T2 = UNITS(THIGH, 'T', 'K', ALPHT)
      P1 = UNITS(PHIGH, 'P', 'MPa', ALPHP)
      IF (PROG.EQ.1) THEN
        WRITE (*,1010)
      ELSEIF (PROG.EQ.2) THEN
        WRITE (*,1020) T1, T2, ALPHT, P1, ALPHP
      ENDIF
      WRITE (*,1030)

      SUM = 0
      DO 10 I=1, 21
 10   SUM = SUM + XI(I)
      WRITE (*,*)
      IF (DABS(SUM-100.D0).GT.0.5D-9 .AND. SUM.NE.0.D0 .AND. PROG.EQ.1)
     &    WRITE (*,*) 'COMPONENTS WILL BE NORMALIZED'

      PAUSE
      WRITE (*,'(25(/))')
      IF (PROG.EQ.1) THEN
        CALL COMPST(0)
        PAUSE
      ELSEIF (PROG.EQ.2) THEN
        HV1 = UNITS(HVINPUT, 'H', 'MJ/m^3', ALPHH)
        TB1 = UNITS(TBHV, 'T', 'K',ALPHT)
        TB2 = UNITS(TBDR, 'T', 'K',ALPHT)
        PD1 = UNITS(PD, 'P', 'MPa',ALPHP)
        WRITE (*,1100) TB1, ALPHT, TB2, ALPHT, PD1, ALPHP
        IF (METSG.EQ.1) WRITE (*,1110) HV1, ALPHH
                        WRITE (*,1120) DRINPUT
        IF (METSG.EQ.2) WRITE (*,1130) X(2)*100.D0
                        WRITE (*,1140) X(3)*100.D0
        IF (X(4).NE.0 .OR. X(5).NE.0)
     &                  WRITE (*,1150) X(4)*100.D0, X(5)*100.D0
        WRITE (*,*)
        PAUSE
      ENDIF
C-----------------------------------------------------------------------
 1000 FORMAT(' CURRENT OPTION SETTINGS:',/,
     &       '    OUTPUT DEVICE:  ',A60,/,
     &       '    UNITS SYSTEM :  ',A60,/)
 1010 FORMAT(' RANGE OF VALIDITY:',/,
     &   '    GAS PHASE ONLY (User should identify phase boundaries)'//)
 1020 FORMAT(' RANGE OF VALIDITY:',/,
     &       '    TEMPERATURE:',F7.2,' TO ', F8.2,1X, A10,/,
     &       '    PRESSURE:      0.00 TO ', F8.2,1X, A10,/)
 1030 FORMAT(' BASE CONDITIONS FOR CALCULATION OF SUPERCOMPRESSIBILITY:'
     &     ,/'    60๘F, 14.73 psia   OR   15.56๘C, 101.56 kPa',/)
 1040 FORMAT(' CURRENT SELECTED METHOD:',
     &       '  DETAILED CHARACTERIZATION METHOD ',//)
 1050 FORMAT(' CURRENT SELECTED METHOD:',
     &       '  GROSS CHARACTERIZATION METHOD ',I1,//)
 1100 FORMAT(
     &'  REF. TEMPERATURE FOR COMBUSTION BASIS:        ',F9.3,4X,A10,/,
     &'  REF. TEMPERATURE FOR FLOW BASIS:              ',F9.3,4X,A10,/,
     &'  REF. PRESSURE FOR FLOW BASIS:               ',F14.6,1X,A10,/)
 1110 FORMAT(
     &'  VOLUMETRIC (GROSS) HEATING VALUE @ REF. T,P:',F14.6,1X,A10)
 1120 FORMAT(
     &'  RELATIVE DENSITY (SPECIFIC GRAVITY):        ',F14.6)
 1130 FORMAT(
     &'  MOLE PERCENT N2:                            ',F14.6)
 1140 FORMAT(
     &'  MOLE PERCENT CO2:                           ',F14.6)
 1150 FORMAT(
     &'  MOLE PERCENT H2:                            ',F14.6,/,
     &'  MOLE PERCENT CO:                            ',F14.6)
      END
C=======================================================================
      SUBROUTINE TABLES(OPT, METSG)
C
C  PURPOSE:
C     Constructs a table of properties.
C-----------------------------------------------------------------------
      CHARACTER*10 ALPHP, ALPHT, ALPHD, ALPHH
      COMMON/LABELS/ ALPHP, ALPHT, ALPHD, ALPHH

      INTEGER PROG
      REAL*8 RGAS, MWX, MW(5)
      COMMON/CONSTANTS/ PROG, RGAS, MWX, MW

      REAL*8 DHIGH, PLOW, PHIGH, TLOW, THIGH
      COMMON/LIMITS/ DHIGH, PLOW, PHIGH, TLOW, THIGH

      REAL*8 DCALC, UNITS, T, T2, TINC, D, P, P2, PINC, Z
      INTEGER OPT, METSG, FLAG
      LOGICAL ERROR

      FLAG = 0
      CALL STATUS2(METSG)

C.....Calculate properties given T and P.
 500  WRITE (*,*)
      WRITE (*,*)
      IF (OPT.EQ.5) THEN
        WRITE (*,1010) ALPHT
        READ (*,*,ERR=9999) T
        T = UNITS(T, 'T', ALPHT, 'K')
        IF (T.LT.TLOW .OR. T.GT.THIGH) THEN
          WRITE (*,*) ' *** TEMPERATURE OUT OF BOUNDS ***'
          GOTO 500
        ENDIF

 510    WRITE (*,1000) ALPHP
        READ (*,*,ERR=9999) P
        P = UNITS(P, 'P', ALPHP, 'MPa')
        IF (P.LT.PLOW .OR. P.GT.PHIGH) THEN
          WRITE (*,*) ' *** PRESSURE OUT OF BOUNDS ***'
          WRITE (*,*)
          GOTO 510
        ENDIF

C.....Calculate isothermal properties.
      ELSEIF (OPT.EQ.6) THEN
        WRITE (*,1010) ALPHT
        READ (*,*,ERR=9999) T
        T = UNITS(T, 'T', ALPHT, 'K')
        IF (T.LT.TLOW .OR. T.GT.THIGH) THEN
          WRITE (*,*) ' *** TEMPERATURE OUT OF BOUNDS ***'
          GOTO 500
        ENDIF

        WRITE (*,1030) ALPHP
        CALL INPUT(P, P2, PINC, ERROR, 2)
        IF (ERROR) GOTO 500
        IF (P2.LT.PLOW .OR. P.GT.PHIGH) THEN
          WRITE (*,*) ' *** PRESSURE OUT OF BOUNDS ***'
          GOTO 500
        ENDIF

C.....Calculate isobaric properties.
      ELSEIF (OPT.EQ.7) THEN
        WRITE (*,1000) ALPHP
        READ (*,*,ERR=9999) P
        P = UNITS(P, 'P', ALPHP, 'MPa')
        IF (P.LT.PLOW .OR. P.GT.PHIGH) THEN
          WRITE (*,*) ' *** PRESSURE OUT OF BOUNDS ***'
          GOTO 500
        ENDIF

        WRITE (*,1020) ALPHT
        CALL INPUT(T, T2, TINC, ERROR, 1)
        IF (ERROR) GOTO 500
        IF (T2.LT.TLOW .OR. T.GT.THIGH) THEN
          WRITE (*,*) ' *** TEMPERATURE OUT OF BOUNDS ***'
          GOTO 500
        ENDIF
      ENDIF

C.....Write header.
      WRITE (*,'(25(/))')
      IF (PROG.EQ.1) THEN
        WRITE (*,*) ' PROPERTIES FROM DETAILED CHARACTERIZATION MODEL'
      ELSEIF (PROG.EQ.2) THEN
        WRITE (*,*) '  PROPERTIES FROM GROSS CHARACTERIZATION MODEL'
      ENDIF
      WRITE (*,'(54(''=''))')
      WRITE (*,*) '    P          T          D          Z         Fpv'
      WRITE (*,*) '   '//ALPHP(1:9)//'   '//ALPHT(1:5)//'   '//ALPHD
      WRITE (*,'(54(''=''))')

      IF (OPT.NE.5 .OR. FLAG.EQ.0) THEN
        FLAG = 1
        WRITE (1,*)
        IF (PROG.EQ.1) THEN
          WRITE (1,*) ' PROPERTIES FROM DETAILED CHARACTERIZATION MODEL'
        ELSEIF (PROG.EQ.2) THEN
          WRITE (1,*) '  PROPERTIES FROM GROSS CHARACTERIZATION MODEL'
        ENDIF
        WRITE (1,'(54(''=''))')
        WRITE (1,*) '    P          T          D          Z         Fpv'
        WRITE (1,*) '   '//ALPHP(1:9)//'   '//ALPHT(1:5)//'   '//ALPHD
        WRITE (1,'(54(''=''))')
      ENDIF

C.....Property calculation.
      IF (OPT.EQ.5) THEN
        D = DCALC(P, T)
        Z = P/(D*RGAS*T)
        CALL PROPS(P, D, T, Z)
      ELSEIF (OPT.EQ.6) THEN
 600    IF (P.LT.PLOW) THEN
          P = P + PINC
          GOTO 600
        ENDIF
 610    IF (P-P2.GT.-0.5D-9) P = P2
        IF (P-PHIGH.GT.-0.5D-9) P = PHIGH
        D = DCALC(P, T)
        Z = P/(D*RGAS*T)
        CALL PROPS(P, D, T, Z)
        IF (P.NE.P2 .AND. P.LT.PHIGH) THEN
          P = P + PINC
          GOTO 610
        ENDIF
      ELSEIF (OPT.EQ.7) THEN
        IF (T.LT.TLOW) THEN
          D = DCALC(P, TLOW)
          Z = P/(D*RGAS*TLOW)
          CALL PROPS(P, D, TLOW, Z)
        ENDIF
 700    IF (T.LT.TLOW) THEN
          T = T + TINC
          GOTO 700
        ENDIF
 710    IF (T-T2.GT.-0.5D-9) T = T2
        IF (T-THIGH.GT.-0.5D-9) T = THIGH
        D = DCALC(P, T)
        Z = P/(D*RGAS*T)
        CALL PROPS(P, D, T, Z)
        IF (T.NE.T2 .AND. T.LT.THIGH) THEN
          T = T + TINC
          GOTO 710
        ENDIF
      ENDIF
      GOTO 500
 9999 RETURN

C-----------------------------------------------------------------------
 1000 FORMAT ('  Input Pressure in ',A10,'    (X to exit) ----> ')
 1010 FORMAT ('  Input Temperature in ',A10,' (X to exit) ----> ')
 1020 FORMAT ('  Enter the following in ', A10,/,
     &'  (1)  Starting Temperature',/,
     &'  (2)  Ending Temperature',/,
     &'  (3)  Temperature Increment',//)
 1030 FORMAT ('  Input the following in ', A10,/,
     &'  (1)  Starting Pressure',/,
     &'  (2)  Ending Pressure',/,
     &'  (3)  Pressure Increment',//)
      END
C=======================================================================
      SUBROUTINE TABLES2(METSG)
C
C  PURPOSE:
C     Constructs a table of properties.
C-----------------------------------------------------------------------
      REAL*8 X(5), XI(21), ZB, DB
      COMMON/AGA/ X, XI, ZB, DB

      CHARACTER*10 ALPHP, ALPHT, ALPHD, ALPHH
      COMMON/LABELS/ ALPHP, ALPHT, ALPHD, ALPHH

      INTEGER PROG
      REAL*8 RGAS, MWX, MW(5)
      COMMON/CONSTANTS/ PROG, RGAS, MWX, MW

      REAL*8 DHIGH, PLOW, PHIGH, TLOW, THIGH
      COMMON/LIMITS/ DHIGH, PLOW, PHIGH, TLOW, THIGH

      CHARACTER A*11, LINE*240
      LOGICAL ERROR
      INTEGER OPT, I, J, CELL, METSG
      REAL*8 T, T1, T2, TINC, P, P2, PINC, TT, PP, DD, UNITS
      REAL*8 D, Z, FPV, DCALC

      CELL = 11
 100  WRITE (*,1000)
      READ (*,*,ERR=100) OPT
      IF (OPT.LE.0 .OR. OPT.GE.4) RETURN

      WRITE (*,1010) ALPHT
      CALL INPUT(T1, T2, TINC, ERROR, 1)
      IF (ERROR) RETURN
      IF (T2.LT.TLOW .OR. T1.GT.THIGH) THEN
        PAUSE ' *** TEMPERATURE OUT OF BOUNDS ***'
        RETURN
      ENDIF

      WRITE (*,1020) ALPHP
      IF (ERROR) RETURN
      CALL INPUT(P, P2, PINC, ERROR, 2)
      IF (P2.LT.PLOW .OR. P.GT.PHIGH) THEN
        PAUSE ' *** PRESSURE OUT OF BOUNDS ***'
        RETURN
      ENDIF

C.....Write header.
      IF (OPT.EQ.1) THEN
        WRITE (*,1060)
        WRITE (1,1060)
      ELSEIF (OPT.EQ.2) THEN
        WRITE (*,1070)
        WRITE (1,1070)
      ELSE
        WRITE (*,1080)
        WRITE (1,1080)
      ENDIF
      CALL STATUS2(METSG)
      PAUSE

C.....Write temperature and pressure header.
      IF (ALPHT.EQ.'C' .OR. ALPHT.EQ.'F') THEN
        WRITE (*,1040) ALPHT
        WRITE (1,1040) ALPHT
      ELSE
        WRITE (*,1050) ALPHT
        WRITE (1,1050) ALPHT
      ENDIF
      WRITE (LINE,'(1X,A10)') ALPHP
      T = T1
      I = 1
 10   IF (T.LT.TLOW) THEN
        T = T + TINC
        GOTO 10
      ENDIF
 15   IF (T-T2.GT.-0.5D-9) T = T2
      IF (T-THIGH.GT.-0.5D-9) T = THIGH
      TT = UNITS(T, 'T', 'K', ALPHT)
      WRITE (A, 1031) TT
      LINE(I*CELL+2:I*CELL+CELL+1) = A
      I = I + 1
      IF (T.NE.T2 .AND. T.LT.THIGH .AND. (I+1)*CELL.LT.240) THEN
        T = T + TINC
        GOTO 15
      ENDIF
      WRITE (*,*) LINE(1:78)
      WRITE (1,*) LINE(1:I*CELL+CELL+1)
      WRITE (LINE,'(240(''_''))')
      IF (I.LE.7) THEN
        WRITE (*,*) LINE(1:I*CELL)
      ELSE
        WRITE (*,*) LINE(1:78)
      ENDIF
      WRITE (1,*) LINE(1:I*CELL)

C.....Pressure loop.
      J = 0
 30   IF (P.LT.PLOW) THEN
        P = P + PINC
        GOTO 30
      ENDIF
 35   IF (P-P2.GT.-0.5D-9) P = P2
      IF (P-PHIGH.GT.-0.5D-9) P = PHIGH
      I = 1
      PP = UNITS(P, 'P', 'MPa', ALPHP)
      IF (DABS(PP).LT.0.5D-9) PP = 0
      WRITE (LINE, 1035) PP

C  .....Temperature loop.
        T = T1
 20     IF (T.LT.TLOW) THEN
          T = T + TINC
          GOTO 20
        ENDIF
 25     IF (T-T2.GT.-0.5D-9) T = T2
        IF (T-THIGH.GT.-0.5D-9) T = THIGH
        D  = DCALC(P, T)
        Z  = P/(D*RGAS*T)
        DD = UNITS(D, 'D', 'mol/dm^3', ALPHD)
        IF (OPT.EQ.1) THEN
          WRITE (A, 1030) Z
        ELSEIF (OPT.EQ.2) THEN
          FPV = DSQRT(ZB/Z)
          WRITE (A, 1030) FPV
        ELSEIF (OPT.EQ.3) THEN
          WRITE (A, 1030) DD
        ENDIF
        LINE(I*CELL+1:I*CELL+CELL) = A
        I = I + 1
        IF (T.NE.T2 .AND. T.LT.THIGH .AND. (I+1)*CELL.LT.240) THEN
          T = T + TINC
          GOTO 25
        ENDIF

C  .....End temperature loop.
      LINE(CELL+1:CELL+1)='|'
      WRITE (*,*) LINE(1:78)
      WRITE (1,*) LINE(1:I*CELL+CELL)
      IF (P.NE.P2 .AND. P.LT.PHIGH) THEN
        J = J + 1
        IF (J.EQ.5) THEN
          WRITE (*,*) '           |'
          WRITE (1,*) '           |'
          J = 0
        ENDIF
        P = P + PINC
        GOTO 35
      ENDIF
      WRITE (1,*)
      WRITE (1,*)
      PAUSE

C-----------------------------------------------------------------------
 1000 FORMAT (25(/),'  Table options:',//,
     &'  (1)  Compressibility Factor, Z',/,
     &'  (2)  Supercompressibility, Fpv',/,
     &'  (3)  Density',/,
     &'  (0)  Return to main menu',//)
 1010 FORMAT ('  Enter the following in ', A10,/,
     &'  (1)  Starting Temperature',/,
     &'  (2)  Ending Temperature',/,
     &'  (3)  Temperature Increment',//)
 1020 FORMAT ('  Input the following in ', A10,/,
     &'  (1)  Starting Pressure',/,
     &'  (2)  Ending Pressure',/,
     &'  (3)  Pressure Increment',//)
 1030 FORMAT (1X,G10.6E1)
 1031 FORMAT (F7.3,4X)
 1035 FORMAT (G11.6E1)
 1040 FORMAT (' Pressure                        Temperature, ๘',A1)
 1050 FORMAT (' Pressure                        Temperature, ',A1)
 1060 FORMAT ('                            Compressibility Factors',/)
 1070 FORMAT ('                          Supercompressibility Factors'/)
 1080 FORMAT ('                               Densities',/)
      END
C=======================================================================
      SUBROUTINE STATUS2(METSG)
C
C  PURPOSE:
C     Prints the method and composition of the selected natural gas.
C-----------------------------------------------------------------------
      REAL*8 X(5), XI(21), ZB, DB
      COMMON/AGA/ X, XI, ZB, DB

      INTEGER PROG
      REAL*8 RGAS, MWX, MW(5)
      COMMON/CONSTANTS/ PROG, RGAS, MWX, MW

      CHARACTER*10 ALPHP, ALPHT, ALPHD, ALPHH
      COMMON/LABELS/ ALPHP, ALPHT, ALPHD, ALPHH

      REAL*8 TBHV, TBDR, PD, HVINPUT, DRINPUT
      COMMON/REFCOND/ TBHV, TBDR, PD, HVINPUT, DRINPUT

      INTEGER METSG, I
      REAL*8 HV1, SUM, UNITS, XJ(21)

      SUM = 0
      DO 40 I=1, 21
 40   SUM = SUM + XI(I)
      IF (SUM.EQ.0) SUM = 100
      DO 50 I=1, 21
 50   XJ(I) = XI(I)/SUM*100.D0

      WRITE (*,*)
      WRITE (1,*)
      WRITE (1,*)
      IF (PROG.EQ.1) THEN
        WRITE (*,1090)
        WRITE (1,1090)
      ELSEIF (PROG.EQ.2) THEN
        WRITE (*,1100) METSG
        WRITE (1,1100) METSG
      ENDIF
      IF (PROG.EQ.1) THEN
        WRITE (*,1200) XJ(1), XJ(5), XJ(9), XJ(2), XJ(6), XJ(10),
     &                 XJ(3), XJ(7), XJ(11),XJ(4), XJ(8), XJ(12),
     &                 XJ(13),XJ(16),XJ(19),XJ(14),XJ(17),XJ(20),
     &                 XJ(15),XJ(18),XJ(21)
        WRITE (1,1200) XJ(1), XJ(5), XJ(9), XJ(2), XJ(6), XJ(10),
     &                 XJ(3), XJ(7), XJ(11),XJ(4), XJ(8), XJ(12),
     &                 XJ(13),XJ(16),XJ(19),XJ(14),XJ(17),XJ(20),
     &                 XJ(15),XJ(18),XJ(21)
        IF (DABS(SUM-100.D0).GT.0.5D-9 .AND. SUM.NE.0.D0) THEN
          WRITE (*,1210)
          WRITE (1,1210)
        ENDIF
      ELSEIF (PROG.EQ.2) THEN
        IF (METSG.EQ.1) THEN
          HV1 = UNITS(HVINPUT, 'H', 'MJ/m^3', ALPHH)
          WRITE (*,1120) HV1, ALPHH
          WRITE (1,1120) HV1, ALPHH
        ENDIF
        WRITE (*,1130) DRINPUT
        WRITE (1,1130) DRINPUT
        IF (METSG.EQ.2) THEN
          WRITE (*,1140) X(2)*100.D0
          WRITE (1,1140) X(2)*100.D0
        ENDIF
        WRITE (*,1150) X(3)*100.D0
        WRITE (1,1150) X(3)*100.D0
        IF (X(4).NE.0 .OR. X(5).NE.0) THEN
          WRITE (*,1160) X(4)*100.D0, X(5)*100.D0
          WRITE (1,1160) X(4)*100.D0, X(5)*100.D0
        ENDIF
        WRITE (*,*)
        WRITE (1,*)
      ENDIF

 1090 FORMAT(' DETAILED CHARACTERIZATION METHOD')
 1100 FORMAT(' GROSS CHARACTERIZATION METHOD ',I1)
 1120 FORMAT(' Volumetric (gross) heating value:',F14.4,1X,A10)
 1130 FORMAT(' Relative density:                ',F16.6)
 1140 FORMAT(' Mole percent N2:                 ',F14.4)
 1150 FORMAT(' Mole percent CO2:                ',F14.4)
 1160 FORMAT(' Mole percent H2:                 ',F14.4,/,
     &       ' Mole percent CO:                 ',F14.4)
 1200 FORMAT(
     &' CH4     ',F8.4,8X,'n-C4H10 ',F8.4,8X,'n-C7H16 ',F8.4,/
     &' C2H6    ',F8.4,8X,'i-C5H12 ',F8.4,8X,'n-C8H18 ',F8.4,/
     &' C3H8    ',F8.4,8X,'n-C5H12 ',F8.4,8X,'n-C9H20 ',F8.4,/
     &' i-C4H10 ',F8.4,8X,'n-C6H14 ',F8.4,8X,'n-C10H22',F8.4,//
     &' CO2     ',F8.4,8X,'He      ',F8.4,8X,'Ar      ',F8.4,/
     &' N2      ',F8.4,8X,'H2O     ',F8.4,8X,'H2      ',F8.4,/
     &' H2S     ',F8.4,8X,'O2      ',F8.4,8X,'CO      ',F8.4,/)
 1210 FORMAT(' Components have been normalized'/)
      END
C=======================================================================
      SUBROUTINE UNITSG(OPTSET)
C
C  PURPOSE:
C     Sets up unit conversion factors and labels for headings.
C-----------------------------------------------------------------------
      CHARACTER*10 ALPHP, ALPHT, ALPHD, ALPHH
      COMMON/LABELS/ ALPHP, ALPHT, ALPHD, ALPHH

      INTEGER UNIT, OPTSET, OPT
      CHARACTER*12 ALPHA(5,5)

      DATA ALPHA/'K','C','R','F',' ',
     &     'MPa','psia','bar','mmHg','atm',
     &     'MPa gage','psig','bar gage','mmHg gage','atm gage',
     &     'mol/dm^3','kmol/m^3','kg/m^3','lbm/ft^3','lbmol/ft^3',
     &     'MJ/m^3','kJ/dm^3','kJ/m^3','kcal/m^3','Btu/ft^3'/

C.....Display the units menu.
      IF (OPTSET.EQ.5) RETURN

  100 IF (OPTSET.EQ.0) THEN
        WRITE (*,1000)
        READ (*,*,ERR=100) OPT
        IF (OPT.EQ.0) RETURN
        OPTSET = OPT
      ENDIF

C.....SI units with molar density and Megapascals for pressure.
      IF (OPTSET.EQ.1) THEN
        ALPHT = 'K'
        ALPHP = 'MPa'
        ALPHD = 'mol/dm^3'
        ALPHH = 'MJ/m^3'

C.....SI units with mass density and Megapascals for pressure.
      ELSEIF (OPTSET.EQ.2) THEN
        ALPHT = 'C'
        ALPHP = 'MPa'
        ALPHD = 'kg/m^3'
        ALPHH = 'MJ/m^3'

C.....Engineering Units with mass density and PSIA for pressure.
      ELSEIF (OPTSET.EQ.3 .OR. OPTSET.EQ.4) THEN
        ALPHT = 'F'
        ALPHP = 'psia'
        ALPHD = 'lbmol/ft^3'
        ALPHH = 'Btu/ft^3'
        IF (OPTSET.EQ.4) ALPHD = 'lbm/ft^3'

C.....Customize Units.
      ELSEIF (OPTSET.EQ.5) THEN
  110   WRITE (*,2000) ALPHT, ALPHP, ALPHD, ALPHH
        READ(*,*,ERR=110) OPT
        IF (OPT.EQ.1) THEN
          WRITE (*,2001) ALPHT
          READ(*,*,ERR=110) UNIT
          IF (UNIT.GE.1 .AND. UNIT.LE.4) ALPHT = ALPHA(UNIT, 1)
        ELSEIF (OPT.EQ.2) THEN
          WRITE (*,2002) ALPHP
          READ(*,*,ERR=110) UNIT
          IF (UNIT.GE.1 .AND. UNIT.LE.5) ALPHP = ALPHA(UNIT, 2)
          IF (UNIT.GE.6 .AND. UNIT.LE.10) ALPHP = ALPHA((UNIT-5), 3)
        ELSEIF (OPT.EQ.3) THEN
          WRITE (*,2003) ALPHD
          READ(*,*,ERR=110) UNIT
          IF (UNIT.GE.1 .AND. UNIT.LE.5) ALPHD = ALPHA(UNIT, 4)
        ELSEIF (OPT.EQ.4) THEN
          WRITE (*,2004) ALPHH
          READ(*,*,ERR=110) UNIT
          IF (UNIT.GE.1 .AND. UNIT.LE.5) THEN
            ALPHH = ALPHA(UNIT, 5)
          ENDIF
        ELSEIF (OPT.EQ.0) THEN
          RETURN
        ENDIF
        GOTO 110
      ENDIF
C-----------------------------------------------------------------------
 1000   FORMAT (24(/),'  UNITS MENU:',//,
     &  '  (1)  SI (molar)           (MPa, mol/dm^3, K, MJ/m^3)',/,
     &  '  (2)  SI (mass)            (MPa, kg/m^3, ๘C, MJ/m^3)',/,
     &  '  (3)  Engineering (molar)  (psia, lbmol/ft^3, ๘F, Btu/ft^3)',/,
     &  '  (4)  Engineering (mass)   (psia, lbm/ft^3, ๘F, Btu/ft^3)',/,
     &  '  (5)  Custom               (Choose your own units)',/,
     &  '  (0)  Return to the main menu',//)
 2000   FORMAT (25(/),'  CUSTOM MENU:',
     &  //,'  (1)  Temperature   ',A10,' (K, ๘C, R, ๘F)',/,
     &  '  (2)  Pressure      ',A10,
     &  ' (MPa, psia, bar, mmHg, atm, gage)',/,
     &  '  (3)  Density       ',A10,
     &  ' (mol/dm^3, kg/m^3, lbm/ft^3, lbmol/ft^3)',/,
     &  '  (4)  Heating Value ',A10,
     &  ' (MJ/m^3, kJ/dm^3, kcal/m^3, Btu/ft^3)',/,
     &  '  (0)  Return to main menu',/)
 2001   FORMAT (2(/),'  TEMPERATURE UNITS:',//,
     &  '  (1)   Kelvin',/,
     &  '  (2)   Celsius',/,
     &  '  (3)   Rankine',/,
     &  '  (4)   Fahrenheit',//,
     &  ' The current units are ',A10,//)
 2002   FORMAT (2(/),'  PRESSURE UNITS:',//,
     &  '  (1)   MPa        (6)    MPa, gage',/,
     &  '  (2)   psia       (7)    psig, gage',/,
     &  '  (3)   bar        (8)    bar, gage',/,
     &  '  (4)   mmHg       (9)    mmHg, gage ',/,
     &  '  (5)   atm        (10)   atm, gage',//,
     &  ' The current units are ',A10,//)
 2003   FORMAT (2(/),'  DENSITY UNITS:',//,
     &  '  (1)   mol/dm^3',/,
     &  '  (2)   kgmol/m^3',/,
     &  '  (3)   kg/m^3',/,
     &  '  (4)   lbm/ft^3',/,
     &  '  (5)   lbmol/ft^3',//,
     &  ' The current units are ',A10,//)
 2004   FORMAT (2(/),'  HEATING VALUE UNITS:',//,
     &  '  (1)   MJ/m^3',/,
     &  '  (2)   kJ/dm^3',/,
     &  '  (3)   kJ/m^3',/,
     &  '  (4)   kcal/m^3',/,
     &  '  (5)   Btu/ft^3',/,
     &  ' The current units are ',A10,//)
      END
C=======================================================================
      FUNCTION DCALC(P, T)
C
C  PURPOSE:
C     Calculates the molar density from the GROSS or DETAIL model.
C-----------------------------------------------------------------------

      INTEGER PROG
      REAL*8 RGAS, MWX, MW(5)
      COMMON/CONSTANTS/ PROG, RGAS, MWX, MW

      REAL*8 P, T, DCALC, DDETAIL, DGROSS

      IF (PROG.EQ.1) THEN
        DCALC = DDETAIL(P, T)
      ELSEIF (PROG.EQ.2) THEN
        DCALC = DGROSS(P, T)
      ENDIF
      RETURN
      END
C=======================================================================
      FUNCTION PCALC(D, T)
C
C  PURPOSE:
C     Calculates the pressure from the GROSS or DETAIL model.
C-----------------------------------------------------------------------

      INTEGER PROG
      REAL*8 RGAS, MWX, MW(5)
      COMMON/CONSTANTS/ PROG, RGAS, MWX, MW

      REAL*8 D, T, PCALC, PDETAIL, PGROSS

      IF (PROG.EQ.1) THEN
        PCALC = PDETAIL(D, T)
      ELSEIF (PROG.EQ.2) THEN
        PCALC = PGROSS(D, T)
      ENDIF
      RETURN
      END
C=======================================================================
      FUNCTION ZCALC(D, T)
C
C  PURPOSE:
C     Calculates the compressibility factor from the GROSS or DETAIL model.
C-----------------------------------------------------------------------

      INTEGER PROG
      REAL*8 RGAS, MWX, MW(5)
      COMMON/CONSTANTS/ PROG, RGAS, MWX, MW

      REAL*8 D, T, ZCALC, ZDETAIL, ZGROSS

      IF (PROG.EQ.1) THEN
        ZCALC = ZDETAIL(D, T)
      ELSEIF (PROG.EQ.2) THEN
        ZCALC = ZGROSS(D, T)
      ENDIF
      RETURN
      END
