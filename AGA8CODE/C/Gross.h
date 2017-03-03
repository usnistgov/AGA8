#ifndef AGA8Gross_H_
#define AGA8Gross_H_

#include <vector>
#include <string>

void MolarMassGross(const std::vector<double> &x, double &Mm);
void PressureGross(const double T, const double D, const std::vector<double> &xGrs, const double HCH, double &P, double &Z, int &ierr, std::string &herr);
void DensityGross(const double T, const double P, const std::vector<double> &xGrs, const double HCH, double &D, int &ierr, std::string &herr);
void GrossHv(const std::vector<double> &x, std::vector<double> &xGrs, double &HN, double &HCH);
void GrossInputs(const double T, const double P, const std::vector<double> &x, std::vector<double> &xGrs, double &Gr, double &HN, double &HCH, int &ierr, std::string &herr);
void Bmix(const double T, const std::vector<double> &xGrs, const double HCH, double &B, double &C, int &ierr, std::string &herr);
void GrossMethod1(const double Th, const double Td, const double Pd, std::vector<double> &xGrs, const double Gr, const double Hv, double & Mm, double &HCH, double &HN, int &ierr, std::string &herr);
void GrossMethod2(const double Th, const double Td, const double Pd, std::vector<double> &xGrs, const double Gr, double &Hv, double &Mm, double &HCH, double &HN, int &ierr, std::string &herr);
void SetupGross();

#endif
