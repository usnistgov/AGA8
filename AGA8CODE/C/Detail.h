#ifndef AGA8DETAIL_H_
#define AGA8DETAIL_H_

#include <vector>
#include <string>

void MolarMassDetail(const std::vector<double> &x, double &Mm);
void PressureDetail(const double T, const double D, const std::vector<double> &x, double &P, double &Z);
void DensityDetail(const double T, const double P, const std::vector<double> &x, double &D, int &ierr, std::string &herr);
void PropertiesDetail(const double T, const double D, const std::vector<double> &x, double &P, double &Z, double &dPdD, double &dPdD2, double &d2PdTD, double &dPdT, double &U, double &H, double &S, double &Cv, double &Cp, double &W, double &G, double &JT, double &Kappa);
void SetupDetail();

#endif
