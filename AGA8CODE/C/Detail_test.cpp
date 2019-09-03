#include <cmath>
#include "Detail.h"

int main()
{
    SetupDetail();
    double _x[] = {0.77824, 0.02, 0.06, 0.08, 0.03, 0.0015, 0.003, 0.0005,
        0.00165, 0.00215, 0.00088, 0.00024, 0.00015, 0.00009, 0.004, 0.005,
        0.002, 0.0001, 0.0025, 0.007, 0.001};
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

    double Z, dPdD, dPdD2, d2PdTD, dPdT, U, H, S, Cv, Cp, W, G, JT, Kappa;
    PropertiesDetail(T, D, x, P, Z, dPdD, dPdD2, d2PdTD, dPdT, U, H, S,
        Cv, Cp, W, G, JT, Kappa);

    int return_value = 0;
    double mm_reference    = 20.54333051;
    double D_reference     = 12.80792403648801;
    double P_reference     = 50000.0;
    double Z_reference     = 1.173801364147326;
    double dPdD_reference  = 6971.387690924090;
    double dPdD2_reference = 1118.803636639520;
    double dPdT_reference  = 235.6641493068212;
    double U_reference     = -2739.134175817231;
    double H_reference     = 1164.699096269404;
    double s_reference     = -38.54882684677111;
    double Cv_reference    = 39.12076154430332;
    double Cp_reference    = 58.54617672380667;
    double W_reference     = 712.6393684057903;
    double G_reference     = 16584.22983497785;
    double JT_reference    = 7.432969304794577E-05;
    double Kappa_reference = 2.672509225184606;

    printf("Inputs-----\n");
    printf("Temperature [K]:                    400.0000000000000 != %0.16g\n",T);
    printf("Pressure [kPa]:                     50000.00000000000 != %0.16g\n",P);
    printf("Outputs-----\n");
    if (fabs(mm_reference - mm) > 0.1)
    {
        printf("Molar mass [g/mol]:                 %0.16g != %0.16g\n",
            mm_reference, mm);
        return_value = 1;
    }
    if (fabs(D_reference - D) > 0.1)
    {
        printf("Molar density [mol/l]:              %0.16g != %0.16g\n",
            D_reference, D);
        return_value = 1;
    }
    if (fabs(P_reference - P) > 0.1)
    {
        printf("Pressure [kPa]:                     %0.16g != %0.16g\n",
            P_reference, P);
        return_value = 1;
    }
    if (fabs(Z_reference - Z) > 0.1)
    {
        printf("Compressibility factor:             %0.16g != %0.16g\n",
            Z_reference, Z);
        return_value = 1;
    }
    if (fabs(dPdD_reference - dPdD) > 0.1)
    {
        printf("d(P)/d(rho) [kPa/(mol/l)]:          %0.16g != %0.16g\n",
            dPdD_reference, dPdD);
        return_value = 1;
    }
    if (fabs(dPdD2_reference - dPdD2) > 0.1)
    {
        printf("d^2(P)/d(rho)^2 [kPa/(mol/l)^2]:    %0.16g != %0.16g\n",
            dPdD2_reference, dPdD2);
        return_value = 1;
    }
    if (fabs(dPdT_reference - dPdT) > 0.1)
    {
        printf("d(P)/d(T) [kPa/K]:                  %0.16g != %0.16g\n",
            dPdT_reference, dPdT);
        return_value = 1;
    }
    if (fabs(s_reference - S) > 0.1)
    {
        printf("Energy [J/mol]:                     %0.16g != %0.16g\n",
            U_reference, U);
        return_value = 1;
    }
    if (fabs(H_reference - H) > 0.1)
    {
        printf("Enthalpy [J/mol]:                   %0.16g != %0.16g\n",
            H_reference, H);
        return_value = 1;
    }
    if (fabs(s_reference - S) > 0.1)
    {
        printf("Entropy [J/mol-K]:                  %0.16g != %0.16g\n",
            s_reference, S);
        return_value = 1;
    }
    if (fabs(Cv_reference - Cv) > 0.1)
    {
        printf("Isochoric heat capacity [J/mol-K]:  %0.16g != %0.16g\n",
            Cv_reference, Cv);
        return_value = 1;
    }
    if (fabs(Cp_reference - Cp) > 0.1)
    {
        printf("Isobaric heat capacity [J/mol-K]:   %0.16g != %0.16g\n",
            Cp_reference, Cp);
        return_value = 1;
    }
    if (fabs(W_reference - W) > 0.1)
    {
        printf("Speed of sound [m/s]:               %0.16g != %0.16g\n",
            W_reference, W);
        return_value = 1;
    }
    if (fabs(G_reference - G) > 0.1)
    {
        printf("Gibbs energy [J/mol]:               %0.16g != %0.16g\n",
            G_reference, G);
        return_value = 1;
    }
    if (fabs(JT_reference - JT) > 0.1E-05)
    {
        printf("Joule-Thomson coefficient [K/kPa]:  %0.16g != %0.16g\n",
            JT_reference, JT);
        return_value = 1;
    }
    if (fabs(Kappa_reference- Kappa) > 0.1)
    {
        printf("Isentropic exponent:                %0.16g != %0.16g\n",
            Kappa_reference, Kappa);
        return_value = 1;
    }

    return return_value;
}
