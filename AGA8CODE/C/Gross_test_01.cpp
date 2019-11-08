#include <cmath>
#include <math.h>
#include <cstdlib>
#include <cstdio>
#include "Gross.h"

int main()
{
    SetupGross();
    double _x[] = {0.77824, 0.02, 0.06, 0.08, 0.03, 0.0015, 0.003, 0.0005,
        0.00165, 0.00215, 0.00088, 0.00024, 0.00015, 0.00009, 0.004, 0.005,
        0.002, 0.0001, 0.0025, 0.007, 0.001};
    const int NcGross = 21;
    std::vector<double> x(_x, _x+NcGross), xGrs(4,0);
    x.insert(x.begin(), 0.0);
    double mm = 0;
    MolarMassGross(x, mm);

    int ierr = 0;
    std::string herr;
    double T = 300, P = 10000, Td = 273.15, Th = 298.15, Pd = 101.325;
    double D = 6.35826, pp = -1, Hv = -1, Hv2 = -1, Gr, HN, HCH, Z=-1;

    int return_value = EXIT_SUCCESS;
    double mm_reference     = 20.54333051;
    double D_reference      = 5.117641317088482;
    double P_reference      = 9999.999999999998;
    double Z_reference      = 0.7833795701012788;
    double Gr_reference     = 0.7112387718599272;
    double HN_reference     = 924.359178;
    double HCH_reference    = 1004.738236956522;
    double xGrs_reference[] = {0.0, 0.9199999999999999, 0.02, 0.06};
    double Hv_reference     = 41.37676728724603;
    double Hv2_reference    = 42.15440903329388;

    printf("Inputs-----\n");
    printf("Temperature [K]:                    300.0000000000000 != %0.16g\n",T);
    printf("Pressure [kPa]:                     10000.00000000000 != %0.16g\n",P);
    printf("Th [K]:                             298.1500000000000 != %0.16g\n",Th);
    printf("Td [K]:                             273.1500000000000 != %0.16g\n",Td);
    printf("Pd [kPa]:                           101.3250000000000 != %0.16g\n",Pd);

    GrossHv(x,xGrs,HN,HCH);
    DensityGross(T,P,xGrs,HCH,D,ierr,herr);
    PressureGross(T,D,xGrs,HCH,pp,Z,ierr,herr);
    printf("Outputs-----\n");
    if (std::abs(mm_reference - mm) > 1.0e-8)
    {
        printf("Molar mass [g/mol]:                 %0.16g != %0.16g\n",
            mm_reference, mm);
        return_value = EXIT_FAILURE;
    }
    if (std::abs(D_reference - D) > 1.0e-8)
    {
        printf("Molar density [mol/l]:              %0.16g != %0.16g\n",
            D_reference, D);
        return_value = EXIT_FAILURE;
    }
    if (std::abs(P_reference - P) > 1.0e-8)
    {
        printf("Pressure [kPa]:                     %0.16g != %0.16g\n",
            P_reference, P);
        return_value = EXIT_FAILURE;
    }
    if (std::abs(Z_reference - Z) > 1.0e-8)
    {
        printf("Compressibility factor:             %0.16g != %0.16g\n",
            Z_reference, Z);
        return_value = EXIT_FAILURE;
    }

    GrossInputs(Td, Pd, x, xGrs, Gr, HN, HCH, ierr, herr);
    GrossHv(x,xGrs,HN,HCH);
    DensityGross(Td,Pd,xGrs,HCH,D,ierr,herr);
    Hv = HN*D;
    if (std::abs(Gr_reference - Gr) > 1.0e-8)
    {
        printf("Relative density:                   %0.16g != %0.16g\n",
            Gr_reference, Gr);
        return_value = EXIT_FAILURE;
    }
    if (std::abs(HN_reference - HN) > 1.0e-8)
    {
        printf("Molar heating value (kJ/mol, 25 C): %0.16g != %0.16g\n",
            HN_reference, HN);
        return_value = EXIT_FAILURE;
    }
    if (std::abs(HCH_reference - HCH) > 1.0e-8)
    {
        printf("HCH (kJ/mol, 25 C):                 %0.16g != %0.16g\n",
            HCH_reference, HCH);
        return_value = EXIT_FAILURE;
    }
    if (std::abs(xGrs_reference[1] - xGrs[1]) > 1.0e-8)
    {
        printf("HCH (kJ/mol, 25 C):                 %0.16g != %0.16g\n",
            xGrs_reference[1], xGrs[1]);
        return_value = EXIT_FAILURE;
    }
    if (std::abs(xGrs_reference[2] - xGrs[2]) > 1.0e-8)
    {
        printf("nitrogen mole fraction:             %0.16g != %0.16g\n",
            xGrs_reference[2], xGrs[2]);
        return_value = EXIT_FAILURE;
    }
    if (std::abs(xGrs_reference[3] - xGrs[3]) > 1.0e-8)
    {
        printf("CO2 mole fraction:                  %0.16g != %0.16g\n",
            xGrs_reference[3], xGrs[3]);
        return_value = EXIT_FAILURE;
    }
    if (std::abs(Hv_reference - Hv) > 1.0e-8)
    {
        printf("Volumetric heating value at Td,Pd:  %0.16g != %0.16g\n",
            Hv_reference, Hv);
        return_value = EXIT_FAILURE;
    }

    xGrs[2] = x[2];
    xGrs[3] = x[3];
    GrossMethod2(Th, Td, Pd, xGrs, Gr, Hv2, mm, HCH, HN, ierr, herr);
    DensityGross(T,P,xGrs,HCH,D,ierr,herr);
    printf("Gross method 2-----\n");
    D_reference = 5.197833636353455;
    if (std::abs(D_reference - D) > 1.0e-8)
    {
        printf("Molar density [mol/l]:              %0.16g != %0.16g\n",
            D_reference, D);
        return_value = EXIT_FAILURE;
    }
    if (std::abs(Hv2_reference - Hv2) > 1.0e-8)
    {
        printf("Volumetric heating value at Td,Pd:  %0.16g != %0.16g\n",
            Hv2_reference, Hv2);
        return_value = EXIT_FAILURE;
    }

    xGrs[2] = x[2];
    xGrs[3] = x[3];
    GrossMethod1(Th,Td,Pd,xGrs,Gr,Hv,mm,HCH,HN,ierr,herr);
    DensityGross(T,P,xGrs,HCH,D,ierr,herr);
    printf("Gross method 1-----\n");
    D = 5.144374668159809;
    if (std::abs(D_reference - D) > 1.0e-8)
    {
        printf("Molar density [mol/l]:              %0.16g != %0.16g\n",
            D_reference, D);
        return_value = EXIT_FAILURE;
    }
}
