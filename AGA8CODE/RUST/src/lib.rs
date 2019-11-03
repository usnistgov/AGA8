
mod aga8;
mod gerg2008;

pub use aga8::AGA8Detail;
pub use gerg2008::Gerg2008;

#[no_mangle]
pub extern "C" fn aga8_2017(composition: [f64; 21], pressure: f64, temperature: f64, result: i32) -> f64 {
    let mut aga8_test: AGA8Detail = AGA8Detail::default();
    aga8_test.setup();
    aga8_test.x = composition;
        // 0.996_953_100, // Methane
        // 0.002_016_000, // Nitrogen
        // 0.000_093_700, // Carbon dioxide
        // 0.000_767_100, // Ethane
        // 0.000_067_900, // Propane
        // 0.000_019_700, // Isobutane
        // 0.000_006_800, // n-Butane
        // 0.000_015_600, // Isopentane
        // 0.000_000_000, // n-Pentane
        // 0.000_000_000, // Hexane
        // 0.000_000_000, // Heptane
        // 0.000_000_000, // Octane
        // 0.000_000_000, // Nonane
        // 0.000_000_000, // Decane
        // 0.000_000_000, // Hydrogen
        // 0.000_000_000, // Oxygen
        // 0.000_000_000, // Carbon monoxide
        // 0.000_000_000, // Water
        // 0.000_000_000, // Hydrogen sulfide
        // 0.000_060_100, // Helium
        // 0.000_000_000, // Argon

    aga8_test.t = temperature;
    aga8_test.p = pressure;
    aga8_test.density_detail();
    aga8_test.properties_detail();

    match result {
        0  => aga8_test.d, // Molar concentration [mol/l]
        1  => aga8_test.mm,
        2  => aga8_test.z,
        3  => aga8_test.dp_dd,
        4  => aga8_test.d2p_dd2,
        5  => aga8_test.dp_dt,
        6  => aga8_test.u,
        7  => aga8_test.h,
        8  => aga8_test.s,
        9  => aga8_test.cv,
        10 => aga8_test.cp,
        11 => aga8_test.w,
        12 => aga8_test.g,
        13 => aga8_test.jt,
        14 => aga8_test.kappa,
        15 => aga8_test.d * aga8_test.mm, // Density [kg/m³]
        _  => aga8_test.d,
    }
}

#[no_mangle]
pub extern "C" fn gerg_2008(composition: [f64; 21], pressure: f64, temperature: f64, result: i32) -> f64 {
    let mut gerg_test: Gerg2008 = Gerg2008::default();
    let mut comp: [f64; 21+1] = [0.0; 21+1];
    //let mut comp: Vec<f64> = Vec::new();
    //comp.push(0.0);
    for i in 1..comp.len() {
        comp[i] = composition[i-1];
    }

    gerg_test.x = comp;
    gerg_test.t = temperature;
    gerg_test.p = pressure;
    gerg_test.density(0);
    gerg_test.properties();

    match result {
        0  => gerg_test.d,
        1  => gerg_test.mm,
        2  => gerg_test.z,
        3  => gerg_test.dp_dd,
        4  => gerg_test.d2p_dd2,
        5  => gerg_test.dp_dt,
        6  => gerg_test.u,
        7  => gerg_test.h,
        8  => gerg_test.s,
        9  => gerg_test.cv,
        10 => gerg_test.cp,
        11 => gerg_test.w,
        12 => gerg_test.g,
        13 => gerg_test.jt,
        14 => gerg_test.kappa,
        15 => gerg_test.d * gerg_test.mm, // Density [kg/m³]
        _  => gerg_test.d,
    }
}