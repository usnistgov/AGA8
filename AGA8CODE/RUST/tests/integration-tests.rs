use aga8::Detail;

#[test]
fn test_gas_2() {
    let mut aga8_test: Detail = Detail::default();
    aga8_test.setup();
    aga8_test.x = [
        0.996_953_100, // Methane
        0.002_016_000, // Nitrogen
        0.000_093_700, // Carbon dioxide
        0.000_767_100, // Ethane
        0.000_067_900, // Propane
        0.000_019_700, // Isobutane
        0.000_006_800, // n-Butane
        0.000_015_600, // Isopentane
        0.000_000_000, // n-Pentane
        0.000_000_000, // Hexane
        0.000_000_000, // Heptane
        0.000_000_000, // Octane
        0.000_000_000, // Nonane
        0.000_000_000, // Decane
        0.000_000_000, // Hydrogen
        0.000_000_000, // Oxygen
        0.000_000_000, // Carbon monoxide
        0.000_000_000, // Water
        0.000_000_000, // Hydrogen sulfide
        0.000_060_100, // Helium
        0.000_000_000, // Argon
    ];
    aga8_test.t = 165.933;
    aga8_test.d = 1.0;
    aga8_test.pressure_detail();
    aga8_test.properties_detail();
    assert!(f64::abs(aga8_test.p - 1.179_2e3) < 0.1);
    assert!(f64::abs(aga8_test.cv - 26.484_9) < 0.000_1);
    assert!(f64::abs(aga8_test.cp - 41.491_9) < 0.000_1);
    assert!(f64::abs(aga8_test.w - 309.770_9) < 0.000_1);

    aga8_test.t = 169.184;
    aga8_test.d = 2.0;
    aga8_test.pressure_detail();
    aga8_test.properties_detail();
    assert!(f64::abs(aga8_test.p - 2.050_6e3) < 0.1);
    assert!(f64::abs(aga8_test.cv - 29.617_9) < 0.000_1);
    assert!(f64::abs(aga8_test.cp - 58.791) < 0.000_1);
    assert!(f64::abs(aga8_test.w - 286.869) < 0.000_1);

    aga8_test.t = 176.24;
    aga8_test.d = 3.0;
    aga8_test.pressure_detail();
    aga8_test.properties_detail();
    assert!(f64::abs(aga8_test.p - 2.808_8e3) < 0.1);
    assert!(f64::abs(aga8_test.cv - 32.196) < 0.000_1);
    assert!(f64::abs(aga8_test.cp - 84.340_1) < 0.000_1);
    assert!(f64::abs(aga8_test.w - 275.068_5) < 0.000_1);

    aga8_test.t = 181.681;
    aga8_test.d = 4.0;
    aga8_test.pressure_detail();
    aga8_test.properties_detail();
    assert!(f64::abs(aga8_test.p - 3.422_7e3) < 0.1);
    assert!(f64::abs(aga8_test.cv - 34.397_8) < 0.000_1);
    assert!(f64::abs(aga8_test.cp - 126.207) < 0.000_1);
    assert!(f64::abs(aga8_test.w - 266.393_3) < 0.000_1);
}
