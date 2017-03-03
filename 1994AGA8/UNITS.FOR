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
      FUNCTION UNITS(VALUEIN, TYPE, ALPH1, ALPH2)
C
C  PURPOSE:
C     Converts temperatures, pressures, densities, volumes and gross
C     calorific values between different units systems.  All input
C     units are first converted to SI, then to the specified unit.
C
C  DESCRIPTION OF ARGUMENTS:
C     VALUEIN   Input value to be converted. (Input, Real*8)
C     TYPE      The type of variable to be converted: (Input)
C                 Type = 'T'   for temperature,
C                 Type = 'P'   for pressure,
C                 Type = 'D'   for density, and
C                 Type = 'H'   for gross calorific value.
C     ALPH1     Unit string that identifies the input unit. (Input)
C     ALPH2     Unit string that identifies the output unit. (Input)
C     UNITS     Converted output value. (Output)
C-----------------------------------------------------------------------
      INTEGER PROG
      REAL*8 RGAS, MWX, MW(5)
      COMMON/CONSTANTS/ PROG, RGAS, MWX, MW

      REAL*8 VALUE, UNITS, VALUEIN
      CHARACTER Type*(*), ALPH1*(*), ALPH2*(*)

      REAL*8 C_TO_K, F_TO_R, R_TO_K
      REAL*8 ATM_TO_MPA, PSIA_TO_MPA, MMHG_TO_MPA, BAR_TO_MPA
      REAL*8 IN3_TO_M3, FT3_TO_M3, LB_TO_KG, CAL_TO_J, BTU_TO_KJ

      C_TO_K      = 273.15D0
      F_TO_R      = 459.67D0
      R_TO_K      = 5.D0/9.D0
      ATM_TO_MPA  = 0.101325D0
      PSIA_TO_MPA = 6.894757D-3
      MMHG_TO_MPA = 1.33322D-4
      BAR_TO_MPA  = 0.1D0
      IN3_TO_M3   = 1.6387064D-5
      FT3_TO_M3   = 0.02831684659D0
      LB_TO_KG    = 0.4535924D0
      CAL_TO_J    = 4.184D0
      BTU_TO_KJ   = 1.055056D0

      VALUE = VALUEIN
      IF (TYPE.EQ.'T' .OR. TYPE.EQ.'t') THEN
        IF (ALPH1.EQ.'K') THEN
        ELSEIF (ALPH1.EQ.'C') THEN
          VALUE = VALUE + C_TO_K
        ELSEIF (ALPH1.EQ.'R') THEN
          VALUE = VALUE * R_TO_K
        ELSEIF (ALPH1.EQ.'F') THEN
          VALUE = R_TO_K * (VALUE + F_TO_R)
        ELSE
          PAUSE 'Temperature units do not exist.'
        ENDIF

        IF (ALPH2.EQ.'K') THEN
        ELSEIF (ALPH2.EQ.'C') THEN
          VALUE = VALUE - C_TO_K
        ELSEIF (ALPH2.EQ.'R') THEN
          VALUE = VALUE / R_TO_K
        ELSEIF (ALPH2.EQ.'F') THEN
          VALUE = VALUE / R_TO_K - F_TO_R
        ELSE
          PAUSE 'Temperature units do not exist.'
        ENDIF

      ELSEIF (TYPE.EQ.'P' .OR. TYPE.EQ.'p') THEN
        IF (ALPH1.EQ.'MPa') THEN
        ELSEIF (ALPH1.EQ.'bar') THEN
          VALUE = BAR_TO_MPA * VALUE
        ELSEIF (ALPH1.EQ.'atm') THEN
          VALUE = ATM_TO_MPA * VALUE
        ELSEIF (ALPH1.EQ.'mmHg') THEN
          VALUE = MMHG_TO_MPA * VALUE
        ELSEIF (ALPH1.EQ.'psia') THEN
          VALUE = PSIA_TO_MPA * VALUE
        ELSEIF (ALPH1.EQ.'MPa gage') THEN
          VALUE = VALUE + ATM_TO_MPA
        ELSEIF (ALPH1.EQ.'bar gage') THEN
          VALUE = BAR_TO_MPA * VALUE + ATM_TO_MPA
        ELSEIF (ALPH1.EQ.'atm gage') THEN
          VALUE = ATM_TO_MPA * VALUE + ATM_TO_MPA
        ELSEIF (ALPH1.EQ.'mmHg gage') THEN
          VALUE = MMHG_TO_MPA * VALUE + ATM_TO_MPA
        ELSEIF (ALPH1.EQ.'psig') THEN
          VALUE = PSIA_TO_MPA * VALUE + ATM_TO_MPA
        ELSE
          PAUSE 'Pressure units do not exist.'
        ENDIF

        IF (ALPH2.EQ.'MPa') THEN
        ELSEIF (ALPH2.EQ.'bar') THEN
          VALUE = VALUE / BAR_TO_MPA
        ELSEIF (ALPH2.EQ.'atm') THEN
          VALUE = VALUE / ATM_TO_MPA
        ELSEIF (ALPH2.EQ.'mmHg') THEN
          VALUE = VALUE / MMHG_TO_MPA
        ELSEIF (ALPH2.EQ.'psia') THEN
          VALUE = VALUE / PSIA_TO_MPA
        ELSEIF (ALPH2.EQ.'MPa gage') THEN
          VALUE = VALUE - ATM_TO_MPA
        ELSEIF (ALPH2.EQ.'bar gage') THEN
          VALUE = (VALUE - ATM_TO_MPA) / BAR_TO_MPA
        ELSEIF (ALPH2.EQ.'atm gage') THEN
          VALUE = (VALUE - ATM_TO_MPA) / ATM_TO_MPA
        ELSEIF (ALPH2.EQ.'mmHg gage') THEN
          VALUE = (VALUE - ATM_TO_MPA) / MMHG_TO_MPA
        ELSEIF (ALPH2.EQ.'psig') THEN
          VALUE = (VALUE - ATM_TO_MPA) / PSIA_TO_MPA
        ELSE
          PAUSE 'Pressure units do not exist.'
        ENDIF

      ELSEIF (TYPE.EQ.'D' .OR. TYPE.EQ.'d') THEN
        IF (ALPH1.EQ.'mol/dm^3' .OR. ALPH1.EQ.'kmol/m^3') THEN
        ELSEIF (ALPH1.EQ.'dm^3/mol') THEN
          VALUE = 1.D0 / VALUE
        ELSEIF (ALPH1.EQ.'kg/m^3') THEN
          VALUE = VALUE / MWX
        ELSEIF (ALPH1.EQ.'m^3/kg') THEN
          VALUE = 1.D0 / (VALUE * MWX)
        ELSEIF (ALPH1.EQ.'lbm/ft^3') THEN
          VALUE = LB_TO_KG / FT3_TO_M3 * VALUE / MWX
        ELSEIF (ALPH1.EQ.'ft^3/lbm') THEN
          VALUE = LB_TO_KG / FT3_TO_M3 / (VALUE * MWX)
        ELSEIF (ALPH1.EQ.'lbmol/ft^3') THEN
          VALUE = LB_TO_KG / FT3_TO_M3 * VALUE
        ELSEIF (ALPH1.EQ.'ft^3/lbmol') THEN
          VALUE = LB_TO_KG / FT3_TO_M3 / VALUE
        ELSE
          PAUSE 'Density units do not exist.'
        ENDIF

        IF (ALPH2.EQ.'mol/dm^3' .OR. ALPH2.EQ.'kmol/m^3') THEN
        ELSEIF (ALPH2.EQ.'dm^3/mol') THEN
          VALUE = 1.D0 / VALUE
        ELSEIF (ALPH2.EQ.'kg/m^3') THEN
          VALUE = MWX * VALUE
        ELSEIF (ALPH2.EQ.'m^3/kg') THEN
          VALUE = 1.D0 / (MWX * VALUE)
        ELSEIF (ALPH2.EQ.'lbm/ft^3') THEN
          VALUE = VALUE * MWX / (LB_TO_KG / FT3_TO_M3)
        ELSEIF (ALPH2.EQ.'ft^3/lbm') THEN
          VALUE = LB_TO_KG / FT3_TO_M3 / (VALUE * MWX)
        ELSEIF (ALPH2.EQ.'lbmol/ft^3') THEN
          VALUE = VALUE / (LB_TO_KG / FT3_TO_M3)
        ELSEIF (ALPH2.EQ.'ft^3/lbmol') THEN
          VALUE = LB_TO_KG / FT3_TO_M3 / VALUE
        ELSE
          PAUSE 'Density units do not exist.'
        ENDIF

      ELSEIF (TYPE.EQ.'H' .OR. TYPE.EQ.'h') THEN
        IF (ALPH1.EQ.'kJ/dm^3' .OR. ALPH1.EQ.'MJ/m^3') THEN
        ELSEIF (ALPH1.EQ.'kJ/m^3') THEN
          VALUE = VALUE * 1.D-3
        ELSEIF (ALPH1.EQ.'kcal/m^3') THEN
          VALUE = VALUE * CAL_TO_J / 1.D3
        ELSEIF (ALPH1.EQ.'Btu/ft^3') THEN
          VALUE = VALUE * BTU_TO_KJ / (FT3_TO_M3 * 1.D3)
        ELSEIF (ALPH1.EQ.'Btu/in^3') THEN
          VALUE = VALUE * BTU_TO_KJ / (IN3_TO_M3 * 1.D3)
        ELSE
          PAUSE 'Heating value units do not exist.'
        ENDIF

        IF (ALPH2.EQ.'kJ/dm^3' .OR. ALPH2.EQ.'MJ/m^3') THEN
        ELSEIF (ALPH2.EQ.'kJ/m^3') THEN
          VALUE = VALUE * 1.D3
        ELSEIF (ALPH2.EQ.'kcal/m^3') THEN
          VALUE = VALUE / CAL_TO_J * 1.D3
        ELSEIF (ALPH2.EQ.'Btu/ft^3') THEN
          VALUE = VALUE / BTU_TO_KJ * (FT3_TO_M3 * 1.D3)
        ELSEIF (ALPH2.EQ.'Btu/in^3') THEN
          VALUE = VALUE / BTU_TO_KJ * (IN3_TO_M3 * 1.D3)
        ELSE
          PAUSE 'Heating value units do not exist.'
        ENDIF

      ELSE
        PAUSE 'VARIABLE NOT AVAILABLE'
      ENDIF
      UNITS = VALUE
      RETURN
      END
