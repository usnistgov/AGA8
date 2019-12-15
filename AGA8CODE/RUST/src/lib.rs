
mod aga8;
mod gerg2008;

pub use aga8::AGA8Detail;
pub use gerg2008::Gerg2008;

use std::slice;

#[repr(C)]
pub struct Aga8_Result {
    d: f64, // Molar concentration [mol/l]
    mm: f64,
    z: f64,
    dp_dd: f64,
    d2p_dd2: f64,
    dp_dt: f64,
    u: f64,
    h: f64,
    s: f64,
    cv: f64,
    cp: f64,
    w: f64,
    g: f64,
    jt: f64,
    kappa: f64,
}

/// composition must be an array of 21 elements.
#[no_mangle]
pub extern "C" fn aga8_2017(composition: *const f64, pressure: f64, temperature: f64) -> Aga8_Result {
    let array = unsafe {
        assert!(!composition.is_null());
        slice::from_raw_parts(composition, 21)
    };

    let mut aga8_test: AGA8Detail = AGA8Detail::new();
    aga8_test.setup();

    aga8_test.x[0..21].clone_from_slice(&array[..]);

    aga8_test.t = temperature;
    aga8_test.p = pressure;
    aga8_test.density_detail();
    aga8_test.properties_detail();

    Aga8_Result {
        d: aga8_test.d, // Molar concentration [mol/l]
        mm: aga8_test.mm,
        z: aga8_test.z,
        dp_dd: aga8_test.dp_dd,
        d2p_dd2: aga8_test.d2p_dd2,
        dp_dt: aga8_test.dp_dt,
        u: aga8_test.u,
        h: aga8_test.h,
        s: aga8_test.s,
        cv: aga8_test.cv,
        cp: aga8_test.cp,
        w: aga8_test.w,
        g: aga8_test.g,
        jt: aga8_test.jt,
        kappa: aga8_test.kappa,
    }
}

#[no_mangle]
pub extern "C" fn aga8_new() -> *mut AGA8Detail {
    Box::into_raw(Box::new(AGA8Detail::new()))
}

#[no_mangle]
pub extern "C" fn aga8_free(ptr: *mut AGA8Detail) {
    if ptr.is_null() { return }
    unsafe { Box::from_raw(ptr); }
}

#[no_mangle]
pub extern "C" fn aga8_setup(ptr: *mut AGA8Detail) {
    let aga8 = unsafe {
        assert!(!ptr.is_null());
        &mut *ptr
    };
    aga8.setup();
}

#[no_mangle]
pub extern "C" fn aga8_set_composition(ptr: *mut AGA8Detail,
    composition: *const f64) {
    let aga8 = unsafe {
        assert!(!ptr.is_null());
        &mut *ptr
    };
    let array = unsafe {
        assert!(!composition.is_null());
        slice::from_raw_parts(composition, 21)
    };
    aga8.x[0..21].clone_from_slice(&array[..]);
}

#[no_mangle]
pub extern "C" fn aga8_set_pressure(ptr: *mut AGA8Detail, pressure: f64) {
    let aga8 = unsafe {
        assert!(!ptr.is_null());
        &mut *ptr
    };
    aga8.p = pressure;
}

#[no_mangle]
pub extern "C" fn aga8_get_pressure(ptr: *mut AGA8Detail) -> f64 {
    let aga8 = unsafe {
        assert!(!ptr.is_null());
        &mut *ptr
    };
    aga8.p
}

#[no_mangle]
pub extern "C" fn aga8_set_temperature(ptr: *mut AGA8Detail, temperature: f64) {
    let aga8 = unsafe {
        assert!(!ptr.is_null());
        &mut *ptr
    };
    aga8.t = temperature;
}

#[no_mangle]
pub extern "C" fn aga8_get_temperature(ptr: *mut AGA8Detail) -> f64 {
    let aga8 = unsafe {
        assert!(!ptr.is_null());
        &mut *ptr
    };
    aga8.t
}

#[no_mangle]
pub extern "C" fn aga8_set_density(ptr: *mut AGA8Detail, density: f64) {
    let aga8 = unsafe {
        assert!(!ptr.is_null());
        &mut *ptr
    };
    aga8.d = density;
}

#[no_mangle]
pub extern "C" fn aga8_get_density(ptr: *mut AGA8Detail) -> f64 {
    let aga8 = unsafe {
        assert!(!ptr.is_null());
        &mut *ptr
    };
    aga8.d
}

#[no_mangle]
pub extern "C" fn aga8_get_properties(ptr: *const AGA8Detail) -> Aga8_Result {
    let aga8 = unsafe {
        assert!(!ptr.is_null());
        &*ptr
    };
    Aga8_Result {
        d: aga8.d, // Molar concentration [mol/l]
        mm: aga8.mm,
        z: aga8.z,
        dp_dd: aga8.dp_dd,
        d2p_dd2: aga8.d2p_dd2,
        dp_dt: aga8.dp_dt,
        u: aga8.u,
        h: aga8.h,
        s: aga8.s,
        cv: aga8.cv,
        cp: aga8.cp,
        w: aga8.w,
        g: aga8.g,
        jt: aga8.jt,
        kappa: aga8.kappa,
    }
}

#[no_mangle]
pub extern "C" fn aga8_calculate_pressure(ptr: *mut AGA8Detail) {
    let aga8 = unsafe {
        assert!(!ptr.is_null());
        &mut *ptr
    };
    aga8.pressure_detail();
}

#[no_mangle]
pub extern "C" fn aga8_calculate_density(ptr: *mut AGA8Detail) {
    let aga8 = unsafe {
        assert!(!ptr.is_null());
        &mut *ptr
    };
    aga8.density_detail();
}

#[no_mangle]
pub extern "C" fn aga8_calculate_properties(ptr: *mut AGA8Detail) {
    let aga8 = unsafe {
        assert!(!ptr.is_null());
        &mut *ptr
    };
    aga8.properties_detail();
}

pub extern "C" fn gerg_2008(composition: [f64; 21], pressure: f64, temperature: f64, result: i32) -> f64 {
    let mut gerg_test: Gerg2008 = Gerg2008::default();
    gerg_test.setup();
    let mut comp: [f64; 21+1] = [0.0; 21+1];

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
