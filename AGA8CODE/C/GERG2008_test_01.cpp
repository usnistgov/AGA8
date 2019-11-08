#include <cmath>
#include <math.h>
#include <cstdio>
#include "GERG2008.h"

int main()
{
    SetupGERG();
    double _x[] = {0.77824, 0.02, 0.06, 0.08, 0.03, 0.0015, 0.003, 0.0005,
        0.00165, 0.00215, 0.00088, 0.00024, 0.00015, 0.00009, 0.004, 0.005,
        0.002, 0.0001, 0.0025, 0.007, 0.001};
    const int NcGERG = 21;
    std::vector<double> x(_x, _x+NcGERG), xGrs(4,0);
    x.insert(x.begin(), 0.0);
    double mm = 0;
    MolarMassGERG(x, mm);

    int ierr = 0;
    std::string herr;
    double T = 400, P = 50000, D = 6.36570, Z = 0;
    double dPdD, d2PdD2, d2PdTD, dPdT, U, H, S, Cv, Cp, W, G, JT, Kappa, A;
    DensityGERG(0, T, P, x, D, ierr, herr);
    PropertiesGERG(T, D, x, P, Z, dPdD, d2PdD2, d2PdTD, dPdT, U, H, S,
        Cv, Cp, W, G, JT, Kappa, A);

    int return_value = EXIT_SUCCESS;
    double mm_reference    = 20.5427445016;
    double D_reference     = 12.79828626082062;
    double P_reference     = 50000.0;
    double Z_reference     = 1.174690666383717;
    double dPdD_reference  = 7000.694030193327;
    double d2PdD2_reference = 1129.526655214841;
    double dPdT_reference  = 235.9832292593096;
    double U_reference     = -2746.492901212530;
    double H_reference     = 1160.280160510973;
    double s_reference     = -38.57590392409089;
    double Cv_reference    = 39.02948218156372;
    double Cp_reference    = 58.45522051000366;
    double W_reference     = 714.4248840596024;
    double G_reference     = 16590.64173014733;
    double JT_reference    = 7.155629581480913E-05;
    double Kappa_reference = 2.683820255058032;

    printf("Inputs-----\n");
    printf("Temperature [K]:                    400.0000000000000 != %0.16g\n", T);
    printf("Pressure [kPa]:                     50000.00000000000 != %0.16g\n", P);
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
    if (std::abs(dPdD_reference - dPdD) > 1.0e-8)
    {
        printf("d(P)/d(rho) [kPa/(mol/l)]:          %0.16g != %0.16g\n",
            dPdD_reference, dPdD);
        return_value = EXIT_FAILURE;
    }
    if (std::abs(d2PdD2_reference - d2PdD2) > 1.0e-8)
    {
        printf("d^2(P)/d(rho)^2 [kPa/(mol/l)^2]:    %0.16g != %0.16g\n",
            d2PdD2_reference, d2PdD2);
        return_value = EXIT_FAILURE;
    }
    if (std::abs(dPdT_reference - dPdT) > 1.0e-8)
    {
        printf("d(P)/d(T) [kPa/K]:                  %0.16g != %0.16g\n",
            dPdT_reference, dPdT);
        return_value = EXIT_FAILURE;
    }
    if (std::abs(s_reference - S) > 1.0e-8)
    {
        printf("Energy [J/mol]:                     %0.16g != %0.16g\n",
            U_reference, U);
        return_value = EXIT_FAILURE;
    }
    if (std::abs(H_reference - H) > 1.0e-8)
    {
        printf("Enthalpy [J/mol]:                   %0.16g != %0.16g\n",
            H_reference, H);
        return_value = EXIT_FAILURE;
    }
    if (std::abs(s_reference - S) > 1.0e-8)
    {
        printf("Entropy [J/mol-K]:                  %0.16g != %0.16g\n",
            s_reference, S);
        return_value = EXIT_FAILURE;
    }
    if (std::abs(Cv_reference - Cv) > 1.0e-8)
    {
        printf("Isochoric heat capacity [J/mol-K]:  %0.16g != %0.16g\n",
            Cv_reference, Cv);
        return_value = EXIT_FAILURE;
    }
    if (std::abs(Cp_reference - Cp) > 1.0e-8)
    {
        printf("Isobaric heat capacity [J/mol-K]:   %0.16g != %0.16g\n",
            Cp_reference, Cp);
        return_value = EXIT_FAILURE;
    }
    if (std::abs(W_reference - W) > 1.0e-8)
    {
        printf("Speed of sound [m/s]:               %0.16g != %0.16g\n",
            W_reference, W);
        return_value = EXIT_FAILURE;
    }
    if (std::abs(G_reference - G) > 1.0e-8)
    {
        printf("Gibbs energy [J/mol]:               %0.16g != %0.16g\n",
            G_reference, G);
        return_value = EXIT_FAILURE;
    }
    if (std::abs(JT_reference - JT) > 1.0e-8)
    {
        printf("Joule-Thomson coefficient [K/kPa]:  %0.16g != %0.16g\n",
            JT_reference, JT);
        return_value = EXIT_FAILURE;
    }
    if (std::abs(Kappa_reference- Kappa) > 1.0e-8)
    {
        printf("Isentropic exponent:                %0.16g != %0.16g\n",
            Kappa_reference, Kappa);
        return_value = EXIT_FAILURE;
    }

    return return_value;
}
