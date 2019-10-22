use aga8_2017::Gerg2008;


fn main() {
    //SetupGERG();
    let mut gerg_test: Gerg2008 = Gerg2008::default();
    gerg_test.setup();

    gerg_test.x = [
        0.77824,
        0.02,
        0.06,
        0.08,
        0.03,
        0.0015,
        0.003,
        0.0005,
        0.00165,
        0.00215,
        0.00088,
        0.00024,
        0.00015,
        0.00009,
        0.004,
        0.005,
        0.002,
        0.0001,
        0.0025,
        0.007,
        0.001];
    
    gerg_test.molarmass();

    gerg_test.t = 400.0;
    gerg_test.p = 50000.0;
    gerg_test.d = 6.36570;
    gerg_test.z = 0.0;

    println!("Inputs-----\n");
    println!("Temperature [K]:                    400.0000000000000 != {}\n", gerg_test.t);
    println!("Pressure [kPa]:                     50000.00000000000 != {}\n", gerg_test.p);

    gerg_test.density();

    gerg_test.properties();

    println!("Outputs-----\n");
    println!("Molar mass [g/mol]:                 20.54274450160000 != {}\n",gerg_test.mm);
    println!("Molar density [mol/l]:              12.79828626082062 != {}\n",gerg_test.d);
    println!("Pressure [kPa]:                     50000.00000000001 != {}\n",gerg_test.p);
    println!("Compressibility factor:             1.174690666383717 != {}\n",gerg_test.z);
    println!("d(P)/d(rho) [kPa/(mol/l)]:          7000.694030193327 != {}\n",gerg_test.dp_dd);
    println!("d^2(P)/d(rho)^2 [kPa/(mol/l)^2]:    1130.481239114938 != {}\n",gerg_test.d2p_dd2);
    println!("d(P)/d(T) [kPa/K]:                  235.9832292593096 != {}\n",gerg_test.dp_dt);
    println!("Energy [J/mol]:                     -2746.492901212530 != {}\n",gerg_test.u);
    println!("Enthalpy [J/mol]:                   1160.280160510973 != {}\n",gerg_test.h);
    println!("Entropy [J/mol-K]:                  -38.57590392409089 != {}\n",gerg_test.s);
    println!("Isochoric heat capacity [J/mol-K]:  39.02948218156372 != {}\n",gerg_test.cv);
    println!("Isobaric heat capacity [J/mol-K]:   58.45522051000366 != {}\n",gerg_test.cp);
    println!("Speed of sound [m/s]:               714.4248840596024 != {}\n",gerg_test.w);
    println!("Gibbs energy [J/mol]:               16590.64173014733 != {}\n",gerg_test.g);
    println!("Joule-Thomson coefficient [K/kPa]:  7.155629581480913E-05 != {}\n",gerg_test.jt);
    println!("Isentropic exponent:                2.683820255058032 != {}\n",gerg_test.kappa);
    
}
