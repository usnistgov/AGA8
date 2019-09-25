#include <cmath>
#include <math.h>
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

    double T = 300, P = 10000, Td = 273.15, Th = 298.15, Pd = 101.325, D = 6.35826, pp = -1, Hv = -1, Hv2 = -1, Gr, HN, HCH, Z=-1;
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
    printf("Molar mass [g/mol]:                 20.54333051000000 != %0.16g\n",mm);
    printf("Molar density [mol/l]:              5.117641317088482 != %0.16g\n",D);
    printf("Pressure [kPa]:                     9999.999999999998 != %0.16g\n",P);
    printf("Compressibility factor:             0.7833795701012788 != %0.16g\n",Z);

    GrossInputs(Td, Pd, x, xGrs, Gr, HN, HCH, ierr, herr);
    GrossHv(x,xGrs,HN,HCH);
    DensityGross(Td,Pd,xGrs,HCH,D,ierr,herr);
    Hv = HN*D;
    printf("Relative density:                   0.7112387718599272 != %0.16g\n",Gr);
    printf("Molar heating value (kJ/mol, 25 C): 924.3591780000000 != %0.16g\n", HN);
    printf("HCH (kJ/mol, 25 C):                 1004.738236956522 != %0.16g\n",HCH);
    printf("Equivalent hydrocarbon fraction:    0.9199999999999999 != %0.16g\n",xGrs[1]);
    printf("nitrogen mole fraction:             2.000000000000000E-02 != %0.16g\n",xGrs[2]);
    printf("CO2 mole fraction:                  6.000000000000000E-02 != %0.16g\n",xGrs[3]);
    printf("Volumetric heating value at Td,Pd:  41.37676728724603 != %0.16g\n",Hv);

    xGrs[2] = x[2];
    xGrs[3] = x[3];
    GrossMethod2(Th, Td, Pd, xGrs, Gr, Hv2, mm, HCH, HN, ierr, herr);
    DensityGross(T,P,xGrs,HCH,D,ierr,herr);
    printf("Gross method 2-----\n");
    printf("Molar density [mol/l]:              5.197833636353455 != %0.16g\n", D);
    printf("Volumetric heating value at Td,Pd:  42.15440903329388 != %0.16g\n", Hv2);

    xGrs[2] = x[2];
    xGrs[3] = x[3];
    GrossMethod1(Th,Td,Pd,xGrs,Gr,Hv,mm,HCH,HN,ierr,herr);
    DensityGross(T,P,xGrs,HCH,D,ierr,herr);
    printf("Gross method 1-----\n");
    printf("Molar density [mol/l]:              5.144374668159809 != %0.16g\n", D);
}
