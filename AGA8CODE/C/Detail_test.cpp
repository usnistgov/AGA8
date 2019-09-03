#include <cstdio>
#include "Detail.h"

int main()
{
    SetupDetail();
    double _x[] = {0.77824, 0.02, 0.06, 0.08, 0.03, 0.0015, 0.003, 0.0005, 0.00165, 0.00215, 0.00088, 0.00024, 0.00015, 0.00009, 0.004, 0.005, 0.002, 0.0001, 0.0025, 0.007, 0.001};
    const int NcDetail = 21;
    std::vector<double> x(_x, _x+NcDetail), xGrs(4,0);
    x.insert(x.begin(), 0.0);

    double mm = 0;
    MolarMassDetail(x, mm);

    int ierr = 0;
    std::string herr;

    // void Density(const double T, const double P, const std::vector<double> &x, double &D, int &ierr, std::string &herr)
    double T = 400, P = 50000, D = 1e10;
    DensityDetail(T, P, x, D, ierr, herr);

    // Sub PropertiesDetail(T, D, x, P, Z, dPdD, dPdD2, dPdT, U, H, S, Cv, Cp, W, G, JT, Kappa, A)
    double Z, dPdD, dPdD2, d2PdTD, dPdT, U, H, S, Cv, Cp, W, G, JT, Kappa;
    PropertiesDetail(T, D, x, P, Z, dPdD, dPdD2, d2PdTD, dPdT, U, H, S, Cv, Cp, W, G, JT, Kappa);

    printf("Inputs-----\n");
    printf("Temperature [K]:                    400.0000000000000 != %0.16g\n",T);
    printf("Pressure [kPa]:                     50000.00000000000 != %0.16g\n",P);
    printf("Outputs-----\n");
    printf("Molar mass [g/mol]:                 20.54333051000000 != %0.16g\n",mm);
    printf("Molar density [mol/l]:              12.80792403648801 != %0.16g\n",D);
    printf("Pressure [kPa]:                     50000.00000000004 != %0.16g\n",P);
    printf("Compressibility factor:             1.173801364147326 != %0.16g\n",Z);
    printf("d(P)/d(rho) [kPa/(mol/l)]:          6971.387690924090 != %0.16g\n",dPdD);
    printf("d^2(P)/d(rho)^2 [kPa/(mol/l)^2]:    1118.803636639520 != %0.16g\n",dPdD2);
    printf("d(P)/d(T) [kPa/K]:                  235.6641493068212 != %0.16g\n",dPdT);
    printf("Energy [J/mol]:                     -2739.134175817231 != %0.16g\n",U);
    printf("Enthalpy [J/mol]:                   1164.699096269404 != %0.16g\n",H);
    printf("Entropy [J/mol-K]:                  -38.54882684677111 != %0.16g\n",S);
    printf("Isochoric heat capacity [J/mol-K]:  39.12076154430332 != %0.16g\n",Cv);
    printf("Isobaric heat capacity [J/mol-K]:   58.54617672380667 != %0.16g\n",Cp);
    printf("Speed of sound [m/s]:               712.6393684057903 != %0.16g\n",W);
    printf("Gibbs energy [J/mol]:               16584.22983497785 != %0.16g\n",G);
    printf("Joule-Thomson coefficient [K/kPa]:  7.432969304794577E-05 != %0.16g\n",JT);
    printf("Isentropic exponent:                2.672509225184606 != %0.16g\n",Kappa);

}
