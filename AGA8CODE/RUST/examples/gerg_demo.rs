use aga8::Gerg2008;

fn main() {
    let mut gerg_test: Gerg2008 = Gerg2008::default();

    gerg_test.x = [
        0.0, 0.77824, 0.02, 0.06, 0.08, 0.03, 0.0015, 0.003, 0.0005, 0.00165, 0.00215, 0.00088,
        0.00024, 0.00015, 0.00009, 0.004, 0.005, 0.002, 0.0001, 0.0025, 0.007, 0.001,
    ];

    gerg_test.setup();

    gerg_test.molarmass();

    gerg_test.t = 400.0;
    gerg_test.p = 50000.0;
    gerg_test.d = 6.36570;
    gerg_test.z = 0.0;

    println!("Inputs-----");
    println!(
        "Temperature [K]:                    400.0000000000000 != {}",
        gerg_test.t
    );
    println!(
        "Pressure [kPa]:                     50000.00000000000 != {}",
        gerg_test.p
    );

    gerg_test.density(0);

    gerg_test.properties();

    println!("Outputs-----");
    println!(
        "Molar mass [g/mol]:                 20.54274450160000 != {}",
        gerg_test.mm
    );
    println!(
        "Molar density [mol/l]:              12.79828626082062 != {}",
        gerg_test.d
    );
    println!(
        "Pressure [kPa]:                     50000.00000000001 != {}",
        gerg_test.p
    );
    println!(
        "Compressibility factor:             1.174690666383717 != {}",
        gerg_test.z
    );
    println!(
        "d(P)/d(rho) [kPa/(mol/l)]:          7000.694030193327 != {}",
        gerg_test.dp_dd
    );
    println!(
        "d^2(P)/d(rho)^2 [kPa/(mol/l)^2]:    1130.481239114938 != {}",
        gerg_test.d2p_dd2
    );
    println!(
        "d(P)/d(T) [kPa/K]:                  235.9832292593096 != {}",
        gerg_test.dp_dt
    );
    println!(
        "Energy [J/mol]:                     -2746.492901212530 != {}",
        gerg_test.u
    );
    println!(
        "Enthalpy [J/mol]:                   1160.280160510973 != {}",
        gerg_test.h
    );
    println!(
        "Entropy [J/mol-K]:                  -38.57590392409089 != {}",
        gerg_test.s
    );
    println!(
        "Isochoric heat capacity [J/mol-K]:  39.02948218156372 != {}",
        gerg_test.cv
    );
    println!(
        "Isobaric heat capacity [J/mol-K]:   58.45522051000366 != {}",
        gerg_test.cp
    );
    println!(
        "Speed of sound [m/s]:               714.4248840596024 != {}",
        gerg_test.w
    );
    println!(
        "Gibbs energy [J/mol]:               16590.64173014733 != {}",
        gerg_test.g
    );
    println!(
        "Joule-Thomson coefficient [K/kPa]:  7.155629581480913E-05 != {}",
        gerg_test.jt
    );
    println!(
        "Isentropic exponent:                2.683820255058032 != {}",
        gerg_test.kappa
    );
}
