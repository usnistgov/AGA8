use aga8_2017::Gerg2008;
use aga8_2017::gerg_2008;

#[test]
fn gerg_demo_example() {
    let mut gerg_test: Gerg2008 = Gerg2008::default();

    gerg_test.setup();

    gerg_test.x = [0.0,
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

    gerg_test.density(0);
    gerg_test.properties();

    assert!(f64::abs(gerg_test.d - 12.79828626082062) < 1.0e-10);
    assert!(f64::abs(gerg_test.mm - 20.5427445016) < 1.0e-10);
    assert!(f64::abs(gerg_test.p - 50000.00000000001 ) < 1.0e-10);
    assert!(f64::abs(gerg_test.z - 1.174690666383717 ) < 1.0e-10);
    assert!(f64::abs(gerg_test.dp_dd - 7000.694030193327 ) < 1.0e-10);
    assert!(f64::abs(gerg_test.d2p_dd2 - 1129.526655214841 ) < 1.0e-10);
    assert!(f64::abs(gerg_test.dp_dt - 235.9832292593096 ) < 1.0e-10);
    assert!(f64::abs(gerg_test.u - -2746.492901212530) < 1.0e-10);
    assert!(f64::abs(gerg_test.h - 1160.280160510973 ) < 1.0e-10);
    assert!(f64::abs(gerg_test.s - -38.57590392409089) < 1.0e-10);
    assert!(f64::abs(gerg_test.cv - 39.02948218156372 ) < 1.0e-10);
    assert!(f64::abs(gerg_test.cp - 58.45522051000366 ) < 1.0e-10);
    assert!(f64::abs(gerg_test.w - 714.4248840596024 ) < 1.0e-10);
    assert!(f64::abs(gerg_test.g - 16590.64173014733 ) < 1.0e-10);
    assert!(f64::abs(gerg_test.jt - 7.155629581480913E-5) < 1.0e-10);
    assert!(f64::abs(gerg_test.kappa - 2.683820255058032 ) < 1.0e-10);
}

#[test]
fn gerg_api_call() {
        let composition: [f64; 21] = [
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


    let temperature = 400.0;
    let pressure = 50000.0;

    let density = gerg_2008(composition, pressure, temperature, 0);

    assert!(f64::abs(density - 12.79828626082062) < 1.0e-10);
}