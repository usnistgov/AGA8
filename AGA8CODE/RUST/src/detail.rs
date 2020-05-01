//! AGA8 calculations

pub const NC_DETAIL: usize = 21;
const MAXFLDS: usize = 21;
const NTERMS: usize = 58;
const EPSILON: f64 = 1e-15;
const RDETAIL: f64 = 8.31451;

/// Molar masses (g/mol)
const MMI_DETAIL: [f64; 21] = [
    16.043,  // Methane
    28.0135, // Nitrogen
    44.01,   // Carbon dioxide
    30.07,   // Ethane
    44.097,  // Propane
    58.123,  // Isobutane
    58.123,  // n-Butane
    72.15,   // Isopentane
    72.15,   // n-Pentane
    86.177,  // Hexane
    100.204, // Heptane
    114.231, // Octane
    128.258, // Nonane
    142.285, // Decane
    2.0159,  // Hydrogen
    31.9988, // Oxygen
    28.01,   // Carbon monoxide
    18.0153, // Water
    34.082,  // Hydrogen sulfide
    4.0026,  // Helium
    39.948,  // Argon
];

/// Coefficients of the equation of state
const AN: [f64; NTERMS] = [
    0.153_832_6,
    1.341_953_,
    -2.998_583_,
    -0.048_312_28,
    0.375_796_5,
    -1.589_575_,
    -0.053_588_47,
    0.886_594_63,
    -0.710_237_04,
    -1.471_722_,
    1.321_850_35,
    -0.786_659_25,
    0.000_000_002_291_29,
    0.157_672_4,
    -0.436_386_4,
    -0.044_081_59,
    -0.003_433_888,
    0.032_059_05,
    0.024_873_55,
    0.073_322_79,
    -0.001_600_573,
    0.642_470_6,
    -0.416_260_1,
    -0.066_899_57,
    0.279_179_5,
    -0.696_605_1,
    -0.002_860_589,
    -0.008_098_836,
    3.150_547_,
    0.007_224_479,
    -0.705_752_9,
    0.534_979_2,
    -0.079_314_91,
    -1.418_465_,
    -5.99905E-17,
    0.105_840_2,
    0.034_317_29,
    -0.007_022_847,
    0.024_955_87,
    0.042_968_18,
    0.746_545_3,
    -0.291_961_3,
    7.294_616_,
    -9.936_757_,
    -0.005_399_808,
    -0.243_256_7,
    0.049_870_16,
    0.003_733_797,
    1.874_951_,
    0.002_168_144,
    -0.658_716_4,
    0.000_205_518,
    0.009_776_195,
    -0.020_487_08,
    0.015_573_22,
    0.006_862_415,
    -0.001_226_752,
    0.002_850_908,
];

/// Density exponents
const BN: [usize; NTERMS] = [
    1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2, 2, 2, 2, 2, 2, 2, 2, 2, 3, 3, 3, 3, 3,
    3, 3, 3, 3, 3, 4, 4, 4, 4, 4, 4, 4, 5, 5, 5, 5, 5, 6, 6, 7, 7, 8, 8, 8, 9, 9,
];

/// Exponents on density in EXP[-cn*D^kn] part
/// The cn part in this term is not included in this program since it is 1 when kn<>0][and 0 otherwise
const KN: [usize; NTERMS] = [
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3, 2, 2, 2, 4, 4, 0, 0, 2, 2, 2, 4, 4, 4, 4, 0, 1, 1, 2, 2,
    3, 3, 4, 4, 4, 0, 0, 2, 2, 2, 4, 4, 0, 2, 2, 4, 4, 0, 2, 0, 2, 1, 2, 2, 2, 2,
];

/// Temperature exponents
const UN: [f64; NTERMS] = [
    0.0, 0.5, 1.0, 3.5, -0.5, 4.5, 0.5, 7.5, 9.5, 6.0, 12.0, 12.5, -6.0, 2.0, 3.0, 2.0, 2.0, 11.0,
    -0.5, 0.5, 0.0, 4.0, 6.0, 21.0, 23.0, 22.0, -1.0, -0.5, 7.0, -1.0, 6.0, 4.0, 1.0, 9.0, -13.0,
    21.0, 8.0, -0.5, 0.0, 2.0, 7.0, 9.0, 22.0, 23.0, 1.0, 9.0, 3.0, 8.0, 23.0, 1.5, 5.0, -0.5, 4.0,
    7.0, 3.0, 0.0, 1.0, 0.0,
];

/// Flags
// fn[13] = 1; fn[27] = 1; fn[30] = 1; fn[35] = 1;
const FN: [i32; NTERMS] = [
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 1, 0, 0,
    0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
];

// gn[5] = 1; gn[6] = 1; gn[25] = 1; gn[29] = 1; gn[32] = 1;
// gn[33] = 1; gn[34] = 1; gn[51] = 1; gn[54] = 1; gn[56] = 1;
const GN: [i32; NTERMS] = [
    0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 1,
    1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 1, 0, 1, 0, 0,
];

// qn[7] = 1; qn[16] = 1; qn[26] = 1; qn[28] = 1; qn[37] = 1;
// qn[42] = 1; qn[47] = 1; qn[49] = 1; qn[52] = 1; qn[58] = 1;
const QN: [i32; NTERMS] = [
    0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 1, 0, 0, 0, 0,
    0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 1, 0, 0, 1, 0, 0, 0, 0, 0, 1,
];

// sn[8] = 1; sn[9] = 1;
const SN: [i32; NTERMS] = [
    0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
];

// wn[10] = 1; wn[11] = 1; wn[12] = 1;
const WN: [i32; NTERMS] = [
    0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
];

/// Energy parameters
const EI: [f64; MAXFLDS] = [
    151.318_3,
    99.737_78,
    241.960_6,
    244.166_7,
    298.118_3,
    324.068_9,
    337.638_9,
    365.599_9,
    370.682_3,
    402.636_293,
    427.722_63,
    450.325_022,
    470.840_891,
    489.558_373,
    26.957_94,
    122.766_7,
    105.534_8,
    514.015_6,
    296.355,
    2.610_111,
    119.629_9,
];
/// Size parameters
const KI: [f64; MAXFLDS] = [
    0.461_925_5,
    0.447_915_3,
    0.455_748_9,
    0.527_920_9,
    0.583_749_,
    0.640_693_7,
    0.634_142_3,
    0.673_857_7,
    0.679_830_7,
    0.717_511_8,
    0.752_518_9,
    0.784_955,
    0.815_273_1,
    0.843_782_6,
    0.351_491_6,
    0.418_695_4,
    0.453_389_4,
    0.382_586_8,
    0.461_826_3,
    0.358_988_8,
    0.421_655_1,
];

/// Orientation parameters
const GI: [f64; MAXFLDS] = [
    0.0, 0.027_815, 0.189_065, 0.079_3, 0.141_239, 0.256_692, 0.281_835, 0.332_267, 0.366_911,
    0.289_731, 0.337_542, 0.383_381, 0.427_354, 0.469_659, 0.034_369, 0.021, 0.038_953, 0.332_5,
    0.088_5, 0.0, 0.0,
];

/// Quadrupole parameters
const QI: [f64; MAXFLDS] = [
    0.0, 0.0, 0.69, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.067_75,
    0.633_276, 0.0, 0.0,
];

const FI: [f64; MAXFLDS] = [
    0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
    1.0, // High temperature parameter
    0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
];

const SI: [f64; MAXFLDS] = [
    0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
    1.5822, // Dipole parameter
    0.39,   // Dipole parameter
    0.0, 0.0,
];

const WI: [f64; MAXFLDS] = [
    0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
    1.0, // Association parameter
    0.0, 0.0, 0.0,
];

/// Energy parameters
const EIJ: [[f64; MAXFLDS]; MAXFLDS] = [
    [
        1.0, 0.97164, 0.960_644, 1.0, 0.994_635, 1.019_53, 0.989_844, 1.002_35, 0.999_268,
        1.107_274, 0.880_88, 0.880_973, 0.881_067, 0.881_161, 1.170_52, 1.0, 0.990_126, 0.708_218,
        0.931_484, 1.0, 1.0,
    ],
    [
        1.0, 1.0, 1.02274, 0.97012, 0.945_939, 0.946_914, 0.973_384, 0.95934, 0.94552, 1.0, 1.0,
        1.0, 1.0, 1.0, 1.08632, 1.021, 1.00571, 0.746_954, 0.902_271, 1.0, 1.0,
    ],
    [
        1.0, 1.0, 1.0, 0.925_053, 0.960_237, 0.906_849, 0.897_362, 0.726_255, 0.859_764, 0.855_134,
        0.831_229, 0.80831, 0.786_323, 0.765_171, 1.28179, 1.0, 1.5, 0.849_408, 0.955_052, 1.0,
        1.0,
    ],
    [
        1.0, 1.0, 1.0, 1.0, 1.02256, 1.0, 1.01306, 1.0, 1.00532, 1.0, 1.0, 1.0, 1.0, 1.0, 1.16446,
        1.0, 1.0, 0.693_168, 0.946_871, 1.0, 1.0,
    ],
    [
        1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0049, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.034_787, 1.0,
        1.0, 1.0, 1.0, 1.0, 1.0,
    ],
    [
        1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.3, 1.0, 1.0, 1.0,
        1.0, 1.0, 1.0,
    ],
    [
        1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.3, 1.0, 1.0, 1.0,
        1.0, 1.0, 1.0,
    ],
    [
        1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0,
        1.0, 1.0, 1.0,
    ],
    [
        1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0,
        1.0, 1.0, 1.0,
    ],
    [
        1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0,
        1.008_692, 1.0, 1.0,
    ],
    [
        1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0,
        1.010_126, 1.0, 1.0,
    ],
    [
        1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0,
        1.011_501, 1.0, 1.0,
    ],
    [
        1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0,
        1.012_821, 1.0, 1.0,
    ],
    [
        1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0,
        1.014_089, 1.0, 1.0,
    ],
    [
        1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.1, 1.0,
        1.0, 1.0, 1.0,
    ],
    [
        1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0,
        1.0, 1.0, 1.0,
    ],
    [
        1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0,
        1.0, 1.0, 1.0,
    ],
    [
        1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0,
        1.0, 1.0, 1.0,
    ],
    [
        1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0,
        1.0, 1.0, 1.0,
    ],
    [
        1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0,
        1.0, 1.0, 1.0,
    ],
    [
        1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0,
        1.0, 1.0, 1.0,
    ],
];

const UIJ: [[f64; MAXFLDS]; MAXFLDS] = [
    [
        1.0, 0.886_106, 0.963_827, 1.0, 0.990_877, 1.0, 0.992_291, 1.0, 1.003_67, 1.302_576,
        1.191_904, 1.205_769, 1.219_634, 1.233_498, 1.15639, 1.0, 1.0, 1.0, 0.736_833, 1.0, 1.0,
    ],
    [
        1.0, 1.0, 0.835_058, 0.816_431, 0.915_502, 1.0, 0.993_556, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0,
        1.0, 0.408_838, 1.0, 1.0, 1.0, 0.993_476, 1.0, 1.0,
    ],
    [
        1.0, 1.0, 1.0, 0.969_87, 1.0, 1.0, 1.0, 1.0, 1.0, 1.066_638, 1.077_634, 1.088_178,
        1.098_291, 1.108_021, 1.0, 1.0, 0.9, 1.0, 1.045_29, 1.0, 1.0,
    ],
    [
        1.0, 1.0, 1.0, 1.0, 1.065_173, 1.25, 1.25, 1.25, 1.25, 1.0, 1.0, 1.0, 1.0, 1.0, 1.616_66,
        1.0, 1.0, 1.0, 0.971_926, 1.0, 1.0,
    ],
    [
        1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0,
        1.0, 1.0, 1.0,
    ],
    [
        1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0,
        1.0, 1.0, 1.0,
    ],
    [
        1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0,
        1.0, 1.0, 1.0,
    ],
    [
        1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0,
        1.0, 1.0, 1.0,
    ],
    [
        1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0,
        1.0, 1.0, 1.0,
    ],
    [
        1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0,
        1.028_973, 1.0, 1.0,
    ],
    [
        1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0,
        1.033_754, 1.0, 1.0,
    ],
    [
        1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0,
        1.038_338, 1.0, 1.0,
    ],
    [
        1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0,
        1.042_735, 1.0, 1.0,
    ],
    [
        1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0,
        1.046_966, 1.0, 1.0,
    ],
    [
        1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0,
        1.0, 1.0, 1.0,
    ],
    [
        1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0,
        1.0, 1.0, 1.0,
    ],
    [
        1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0,
        1.0, 1.0, 1.0,
    ],
    [
        1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0,
        1.0, 1.0, 1.0,
    ],
    [
        1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0,
        1.0, 1.0, 1.0,
    ],
    [
        1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0,
        1.0, 1.0, 1.0,
    ],
    [
        1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0,
        1.0, 1.0, 1.0,
    ],
];

const KIJ: [[f64; MAXFLDS]; MAXFLDS] = [
    [
        1.0, 1.00363, 0.995_933, 1.0, 1.007_619, 1.0, 0.997_596, 1.0, 1.002_529, 0.982_962,
        0.983_565, 0.982_707, 0.981_849, 0.980_991, 1.023_26, 1.0, 1.0, 1.0, 1.000_08, 1.0, 1.0,
    ],
    [
        1.0, 1.0, 0.982_361, 1.00796, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.03227,
        1.0, 1.0, 1.0, 0.942_596, 1.0, 1.0,
    ],
    [
        1.0, 1.0, 1.0, 1.00851, 1.0, 1.0, 1.0, 1.0, 1.0, 0.910_183, 0.895_362, 0.881_152, 0.86752,
        0.854_406, 1.0, 1.0, 1.0, 1.0, 1.00779, 1.0, 1.0,
    ],
    [
        1.0, 1.0, 1.0, 1.0, 0.986_893, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.02034, 1.0,
        1.0, 1.0, 0.999_969, 1.0, 1.0,
    ],
    [
        1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0,
        1.0, 1.0, 1.0,
    ],
    [
        1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0,
        1.0, 1.0, 1.0,
    ],
    [
        1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0,
        1.0, 1.0, 1.0,
    ],
    [
        1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0,
        1.0, 1.0, 1.0,
    ],
    [
        1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0,
        1.0, 1.0, 1.0,
    ],
    [
        1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0,
        0.96813, 1.0, 1.0,
    ],
    [
        1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0,
        0.96287, 1.0, 1.0,
    ],
    [
        1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0,
        0.957_828, 1.0, 1.0,
    ],
    [
        1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0,
        0.952_441, 1.0, 1.0,
    ],
    [
        1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0,
        0.948_338, 1.0, 1.0,
    ],
    [
        1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0,
        1.0, 1.0, 1.0,
    ],
    [
        1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0,
        1.0, 1.0, 1.0,
    ],
    [
        1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0,
        1.0, 1.0, 1.0,
    ],
    [
        1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0,
        1.0, 1.0, 1.0,
    ],
    [
        1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0,
        1.0, 1.0, 1.0,
    ],
    [
        1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0,
        1.0, 1.0, 1.0,
    ],
    [
        1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0,
        1.0, 1.0, 1.0,
    ],
];

const GIJ: [[f64; MAXFLDS]; MAXFLDS] = [
    [
        1.0, 1.0, 0.807_653, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.957_31, 1.0,
        1.0, 1.0, 1.0, 1.0, 1.0,
    ],
    [
        1.0, 1.0, 0.982_746, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0,
        1.0, 1.0, 1.0, 1.0,
    ],
    [
        1.0, 1.0, 1.0, 0.370_296, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0,
        1.67309, 1.0, 1.0, 1.0,
    ],
    [
        1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0,
        1.0, 1.0, 1.0,
    ],
    [
        1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0,
        1.0, 1.0, 1.0,
    ],
    [
        1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0,
        1.0, 1.0, 1.0,
    ],
    [
        1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0,
        1.0, 1.0, 1.0,
    ],
    [
        1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0,
        1.0, 1.0, 1.0,
    ],
    [
        1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0,
        1.0, 1.0, 1.0,
    ],
    [
        1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0,
        1.0, 1.0, 1.0,
    ],
    [
        1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0,
        1.0, 1.0, 1.0,
    ],
    [
        1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0,
        1.0, 1.0, 1.0,
    ],
    [
        1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0,
        1.0, 1.0, 1.0,
    ],
    [
        1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0,
        1.0, 1.0, 1.0,
    ],
    [
        1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0,
        1.0, 1.0, 1.0,
    ],
    [
        1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0,
        1.0, 1.0, 1.0,
    ],
    [
        1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0,
        1.0, 1.0, 1.0,
    ],
    [
        1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0,
        1.0, 1.0, 1.0,
    ],
    [
        1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0,
        1.0, 1.0, 1.0,
    ],
    [
        1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0,
        1.0, 1.0, 1.0,
    ],
    [
        1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0,
        1.0, 1.0, 1.0,
    ],
];

const N0I: [[f64; 7]; MAXFLDS] = [
    [
        33.035_699_694_997_9,
        -15_999.691_51,
        3.000_88,
        0.763_15,
        0.004_6,
        8.744_31,
        -4.469_21,
    ],
    [
        20.764_973_574_995_3,
        -2_801.729_072,
        2.500_31,
        0.137_31,
        -0.146_6,
        0.900_66,
        0.0,
    ],
    [
        23.855_712_684_993,
        -4_902.171_516,
        2.500_02,
        2.044_52,
        -1.060_44,
        2.033_66,
        0.013_93,
    ],
    [
        39.927_325_104_994,
        -23_639.653_01,
        3.002_63,
        4.339_39,
        1.237_22,
        13.1974,
        -6.019_89,
    ],
    [
        47.906_361_914_990_6,
        -31_236.635_51,
        3.029_39,
        6.605_69,
        3.197,
        19.192_1,
        -8.372_67,
    ],
    [
        37.499_069_214_991_3,
        -38_525.502_76,
        3.067_14,
        8.975_75,
        5.251_56,
        25.142_3,
        16.138_8,
    ],
    [
        39.729_643_554_995_3,
        -38_957.809_323,
        3.339_44,
        9.448_93,
        6.894_06,
        24.461_8,
        14.782_4,
    ],
    [
        46.369_451_984_990_4,
        -51_198.309_46,
        3.0,
        11.761_8,
        20.110_1,
        33.168_8,
        0.0,
    ],
    [
        45.875_636_614_990_3,
        -45_215.83,
        3.0,
        8.950_43,
        21.836,
        33.403_2,
        0.0,
    ],
    [
        50.194_437_604_997_2,
        -52_746.833_18,
        3.0,
        11.697_7,
        26.814_2,
        38.616_4,
        0.0,
    ],
    [
        55.273_582_034_996_7,
        -57_104.810_56,
        3.0,
        13.726_6,
        30.470_7,
        43.556_1,
        0.0,
    ],
    [
        60.455_575_064_990_6,
        -60_546.763_85,
        3.0,
        15.686_5,
        33.802_9,
        48.173_1,
        0.0,
    ],
    [
        65.293_734_734_993_7,
        -66_600.128_37,
        3.0,
        18.024_1,
        38.123_5,
        53.341_5,
        0.0,
    ],
    [
        69.136_357_264_007_8,
        -74_131.454_83,
        3.0,
        21.006_9,
        43.493_1,
        58.365_7,
        0.0,
    ],
    [
        16.272_468_604_996_5,
        -5_836.943_696,
        1.479_06,
        0.958_06,
        0.454_44,
        1.560_39,
        -1.375_6,
    ],
    [
        19.998_983_024_993_8,
        -2_318.322_69,
        2.501_46,
        1.07558,
        1.013_34,
        0.0,
        0.0,
    ],
    [
        20.655_134_714_995_3,
        -2_635.244_116,
        2.500_55,
        1.028_65,
        0.004_93,
        0.0,
        0.0,
    ],
    [
        24.776_092_774_994_8,
        -7_766.733_078,
        3.003_92,
        0.010_59,
        0.987_63,
        3.069_04,
        0.0,
    ],
    [
        24.780_360_124_994_1,
        -6_069.035_869,
        3.0,
        3.119_42,
        1.002_43,
        0.0,
        0.0,
    ],
    [13.243_660_794_994_7, -745.375, 1.5, 0.0, 0.0, 0.0, 0.0],
    [13.243_660_794_994_7, -745.375, 1.5, 0.0, 0.0, 0.0, 0.0],
];

const TH0I: [[f64; 7]; MAXFLDS] = [
    [0.0, 0.0, 0.0, 820.659, 178.41, 1_062.82, 1_090.53],
    [0.0, 0.0, 0.0, 662.738, 680.562, 1740.06, 0.0],
    [0.0, 0.0, 0.0, 919.306, 865.07, 483.553, 341.109],
    [0.0, 0.0, 0.0, 559.314, 223.284, 1_031.38, 1_071.29],
    [0.0, 0.0, 0.0, 479.856, 200.893, 955.312, 1027.29],
    [0.0, 0.0, 0.0, 438.27, 198.018, 1_905.02, 893.765],
    [0.0, 0.0, 0.0, 468.27, 183.636, 1_914.1, 903.185],
    [0.0, 0.0, 0.0, 292.503, 910.237, 1_919.37, 0.0],
    [0.0, 0.0, 0.0, 178.67, 840.538, 1_774.25, 0.0],
    [0.0, 0.0, 0.0, 182.326, 859.207, 1_826.59, 0.0],
    [0.0, 0.0, 0.0, 169.789, 836.195, 1_760.46, 0.0],
    [0.0, 0.0, 0.0, 158.922, 815.064, 1_693.07, 0.0],
    [0.0, 0.0, 0.0, 156.854, 814.882, 1_693.79, 0.0],
    [0.0, 0.0, 0.0, 164.947, 836.264, 1_750.24, 0.0],
    [0.0, 0.0, 0.0, 228.734, 326.843, 1_651.71, 1671.69],
    [0.0, 0.0, 0.0, 2_235.71, 1_116.69, 0.0, 0.0],
    [0.0, 0.0, 0.0, 1_550.45, 704.525, 0.0, 0.0],
    [0.0, 0.0, 0.0, 268.795, 1_141.41, 2_507.37, 0.0],
    [0.0, 0.0, 0.0, 1_833.63, 847.181, 0.0, 0.0],
    [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0],
    [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0],
];

/// Implements the DETAIL equation of state described in
/// AGA Report No. 8, Part 1, Third Edition, April 2017.
/// # Example
///
/// ```
/// use aga8::Detail;
///
/// let mut aga8_test: Detail = Detail::new();
///
/// // Run seup() first to set up internal values
/// aga8_test.setup();
/// // Set the gas composition in mol fraction
/// // The sum of all the components must be 1.0
/// aga8_test.x = [
///     0.778_240, // Methane
///     0.020_000, // Nitrogen
///     0.060_000, // Carbon dioxide
///     0.080_000, // Ethane
///     0.030_000, // Propane
///     0.001_500, // Isobutane
///     0.003_000, // n-Butane
///     0.000_500, // Isopentane
///     0.001_650, // n-Pentane
///     0.002_150, // Hexane
///     0.000_880, // Heptane
///     0.000_240, // Octane
///     0.000_150, // Nonane
///     0.000_090, // Decane
///     0.004_000, // Hydrogen
///     0.005_000, // Oxygen
///     0.002_000, // Carbon monoxide
///     0.000_100, // Water
///     0.002_500, // Hydrogen sulfide
///     0.007_000, // Helium
///     0.001_000, // Argon
/// ];
/// // Set pressure in kPA
/// aga8_test.p = 50_000.0;
/// // Set temperature in K
/// aga8_test.t = 400.0;
/// // Run density_detail to calculate the density in mol/l
/// aga8_test.density_detail();
/// // Run properties_detail to calculate all of the
/// // output properties mentioned below
/// aga8_test.properties_detail();
///
/// assert!(f64::abs(12.807_924_036_488_01 - aga8_test.d) < 1.0e-10);
/// ```

pub struct Detail {
    /// Calculated in the Pressure subroutine,
    /// but not included as an argument since it
    /// is only used internally in the density algorithm.
    dp_dd_save: f64,

    /// Temperature (K)
    pub t: f64,
    /// Pressure (kPa)
    pub p: f64,
    /// Molar concentration (mol/l)
    pub d: f64,
    /// Compressibility factor
    pub z: f64,
    /// Molar mass (g/mol)
    pub mm: f64,
    /// First derivative of pressure with respect
    /// to density at constant temperature [kPa/(mol/l)]
    pub dp_dd: f64,
    /// Second derivative of pressure with respect
    /// to density at constant temperature [kPa/(mol/l)^2]
    pub d2p_dd2: f64,
    /// Second derivative of pressure with respect to
    /// temperature and density [kPa/(mol/l)/K] (currently not calculated)
    pub d2p_dtd: f64,
    /// First derivative of pressure with respect to
    /// temperature at constant density (kPa/K)
    pub dp_dt: f64,
    /// Internal energy (J/mol)
    pub u: f64,
    /// Enthalpy (J/mol)
    pub h: f64,
    /// Entropy [J/(mol-K)]
    pub s: f64,
    /// Isochoric heat capacity [J/(mol-K)]
    pub cv: f64,
    /// Isobaric heat capacity [J/(mol-K)]
    pub cp: f64,
    /// Speed of sound (m/s)
    pub w: f64,
    /// Gibbs energy (J/mol)
    pub g: f64,
    /// Joule-Thomson coefficient (K/kPa)
    pub jt: f64,
    /// Isentropic Exponent
    pub kappa: f64,
    /// Composition (mole fraction)
    pub x: [f64; NC_DETAIL],

    xold: [f64; MAXFLDS],
    told: f64,
    ki25: [f64; MAXFLDS],
    ei25: [f64; MAXFLDS],
    bsnij2: [[[f64; 18]; MAXFLDS]; MAXFLDS],
    bs: [f64; 18],
    kij5: [[f64; MAXFLDS]; MAXFLDS],
    uij5: [[f64; MAXFLDS]; MAXFLDS],
    gij5: [[f64; MAXFLDS]; MAXFLDS],
    k3: f64,
    csn: [f64; NTERMS],
    a0: [f64; 3],
    ar: [[f64; 4]; 4],
    tun: [f64; NTERMS],
}

impl Default for Detail {
    fn default() -> Self {
        Detail {
            dp_dd_save: 0.0,
            x: [0.0; NC_DETAIL],
            t: 0.0,
            p: 0.0,
            d: 0.0,
            z: 0.0,
            mm: 0.0,
            dp_dd: 0.0,
            d2p_dd2: 0.0,
            d2p_dtd: 0.0,
            dp_dt: 0.0,
            u: 0.0,
            h: 0.0,
            s: 0.0,
            cv: 0.0,
            cp: 0.0,
            w: 0.0,
            g: 0.0,
            jt: 0.0,
            kappa: 0.0,
            xold: [0.0; MAXFLDS],
            told: 0.0,
            ki25: [0.0; MAXFLDS],
            ei25: [0.0; MAXFLDS],
            bsnij2: [[[0.0; 18]; MAXFLDS]; MAXFLDS],
            bs: [0.0; 18],
            kij5: [[0.0; MAXFLDS]; MAXFLDS],
            uij5: [[0.0; MAXFLDS]; MAXFLDS],
            gij5: [[0.0; MAXFLDS]; MAXFLDS],
            k3: 0.0,
            a0: [0.0; 3],
            ar: [[0.0; 4]; 4],
            csn: [0.0; NTERMS],
            tun: [0.0; NTERMS],
        }
    }
}

impl Detail {
    pub fn new() -> Self {
        Default::default()
    }

    /// Initialize all the constants and parameters in the DETAIL model.
    ///
    /// Some values are modified for calculations that do not depend
    /// on [`t`], D, and x in order to speed up the program.
    pub fn setup(&mut self) {
        for i in 0..MAXFLDS {
            self.ki25[i] = KI[i].powf(2.5);
            self.ei25[i] = EI[i].powf(2.5);
        }

        let mut bsnij: f64;

        for i in 0..MAXFLDS {
            for j in 0..MAXFLDS {
                for n in 0..18 {
                    bsnij = 1.0;
                    if GN[n] == 1 {
                        bsnij = GIJ[i][j] * (GI[i] + GI[j]) / 2.0;
                    }
                    if QN[n] == 1 {
                        bsnij = bsnij * QI[i] * QI[j];
                    }
                    if FN[n] == 1 {
                        bsnij = bsnij * FI[i] * FI[j];
                    }
                    if SN[n] == 1 {
                        bsnij = bsnij * SI[i] * SI[j];
                    }
                    if WN[n] == 1 {
                        bsnij = bsnij * WI[i] * WI[j];
                    }
                    self.bsnij2[i][j][n] = AN[n]
                        * f64::powf(EIJ[i][j] * f64::sqrt(EI[i] * EI[j]), UN[n])
                        * f64::powf(KI[i] * KI[j], 1.5)
                        * bsnij;
                }
                self.kij5[i][j] = (f64::powi(KIJ[i][j], 5) - 1.0) * self.ki25[i] * self.ki25[j];
                self.uij5[i][j] = (f64::powi(UIJ[i][j], 5) - 1.0) * self.ei25[i] * self.ei25[j];
                self.gij5[i][j] = (GIJ[i][j] - 1.0) * (GI[i] + GI[j]) / 2.0;
            }
        }

        // Ideal gas terms
        // const D0: f64 = 101.325/RDETAIL/298.15;

        // for i in 0..MAXFLDS {
        //     self.n0i[i][3] = self.n0i[i][3] - 1.0;
        //     self.n0i[i][1] = self.n0i[i][1] - f64::ln(D0);
        // }
    }

    /// Calculate molar mass of the mixture with the compositions
    /// contained in the x() input array
    /// ## Returns:
    /// - mm - Molar mass (g/mol)
    pub fn molar_mass_detail(&mut self) -> f64 {
        let mut mm = 0.0;
        for (i, item) in MMI_DETAIL.iter().enumerate() {
            mm += self.x[i] * item;
        }
        self.mm = mm;
        mm
    }

    /// Calculate terms dependent only on composition
    fn x_terms(&mut self) {
        let mut g: f64;
        let mut q: f64;
        let mut f: f64;
        let mut u: f64;
        let q2: f64;
        let mut xij: f64;
        let mut xi2: f64;
        let mut icheck: i32;

        // Check to see if a component fraction has changed.  If x is the same as the previous call, then exit.
        icheck = 0;

        for i in 0..NC_DETAIL {
            if f64::abs(self.x[i] - self.xold[i]) > 0.000_000_1 {
                icheck = 1;
            }
            self.xold[i] = self.x[i];
        }
        if icheck == 0 {
            return;
        }

        self.k3 = 0.0;
        u = 0.0;
        g = 0.0;
        q = 0.0;
        f = 0.0;
        for n in 0..18 {
            self.bs[n] = 0.0;
        }

        // Calculate pure fluid contributions
        for i in 0..NC_DETAIL {
            if self.x[i] > 0.0 {
                xi2 = f64::powi(self.x[i], 2);
                self.k3 += self.x[i] * self.ki25[i]; // K, U, and G are the sums of a pure fluid contribution and a
                u += self.x[i] * self.ei25[i]; // binary pair contribution
                g += self.x[i] * GI[i];
                q += self.x[i] * QI[i]; // Q and F depend only on the pure fluid parts
                f += xi2 * FI[i];

                for n in 0..18 {
                    self.bs[n] += xi2 * self.bsnij2[i][i][n]; // Pure fluid contributions to second virial coefficient
                }
            }
        }
        self.k3 = f64::powi(self.k3, 2);
        u = f64::powi(u, 2);

        // Binary pair contributions
        for i in 0..NC_DETAIL {
            if self.x[i] > 0.0 {
                for j in i + 1..NC_DETAIL {
                    if self.x[j] > 0.0 {
                        xij = 2.0 * self.x[i] * self.x[j];
                        self.k3 += xij * self.kij5[i][j];
                        u += xij * self.uij5[i][j];
                        g += xij * self.gij5[i][j];

                        for n in 0..18 {
                            self.bs[n] += xij * self.bsnij2[i][j][n]; // Second virial coefficients of mixture
                        }
                    }
                }
            }
        }
        self.k3 = f64::powf(self.k3, 0.6);
        u = f64::powf(u, 0.2);

        // Third virial and higher coefficients
        q2 = f64::powi(q, 2);
        for n in 12..58 {
            self.csn[n] = AN[n] * f64::powf(u, UN[n]);
            if GN[n] == 1 {
                self.csn[n] *= g;
            }
            if QN[n] == 1 {
                self.csn[n] *= q2;
            }
            if FN[n] == 1 {
                self.csn[n] *= f;
            }
        }
    }

    fn alpha0_detail(&mut self) {
        // Calculate the ideal gas Helmholtz energy and its derivatives with respect to T and D.
        // This routine is not needed when only P (or Z) is calculated.

        // Inputs:
        //      T - Temperature (K)
        //      D - Density (mol/l)
        //    x() - Composition (mole fraction)

        // Outputs:
        // a0(0) - Ideal gas Helmholtz energy (J/mol)
        // a0(1) -   partial  (a0)/partial(T) [J/(mol-K)]
        // a0(2) - T*partial^2(a0)/partial(T)^2 [J/(mol-K)]

        let logt: f64;
        let logd: f64;
        let mut loghyp: f64;
        let mut th0t: f64;
        let mut logxd: f64;

        let mut sumhyp0: f64;
        let mut sumhyp1: f64;
        let mut sumhyp2: f64;

        let mut em: f64;
        let mut ep: f64;
        let mut hcn: f64;
        let mut hsn: f64;

        self.a0[0] = 0.0;
        self.a0[1] = 0.0;
        self.a0[2] = 0.0;
        if self.d > EPSILON {
            logd = f64::ln(self.d);
        } else {
            logd = f64::ln(EPSILON);
        }
        logt = f64::ln(self.t);

        for i in 0..NC_DETAIL {
            if self.x[i] > 0.0 {
                logxd = logd + f64::ln(self.x[i]);
                sumhyp0 = 0.0;
                sumhyp1 = 0.0;
                sumhyp2 = 0.0;

                for j in 3..7 {
                    if TH0I[i][j] > 0.0 {
                        th0t = TH0I[i][j] / self.t;
                        ep = f64::exp(th0t);
                        em = 1.0 / ep;
                        hsn = (ep - em) / 2.0;
                        hcn = (ep + em) / 2.0;

                        if j == 3 || j == 5 {
                            loghyp = f64::ln(f64::abs(hsn));
                            sumhyp0 += N0I[i][j] * loghyp;
                            sumhyp1 += N0I[i][j] * (loghyp - th0t * hcn / hsn);
                            sumhyp2 += N0I[i][j] * f64::powi(th0t / hsn, 2);
                        } else {
                            loghyp = f64::ln(f64::abs(hcn));
                            sumhyp0 += -N0I[i][j] * loghyp;
                            sumhyp1 += -N0I[i][j] * (loghyp - th0t * hsn / hcn);
                            sumhyp2 += N0I[i][j] * f64::powi(th0t / hcn, 2);
                        }
                    }
                }
                self.a0[0] += self.x[i]
                    * (logxd + N0I[i][0] + N0I[i][1] / self.t - N0I[i][2] * logt + sumhyp0);
                self.a0[1] += self.x[i] * (logxd + N0I[i][0] - N0I[i][2] * (1.0 + logt) + sumhyp1);
                self.a0[2] += -self.x[i] * (N0I[i][2] + sumhyp2);
            }
        }
        self.a0[0] = self.a0[0] * RDETAIL * self.t;
        self.a0[1] *= RDETAIL;
        self.a0[2] *= RDETAIL;
    }

    fn alphar(&mut self, itau: i32, _idel: i32) {
        // Calculate the derivatives of the residual Helmholtz energy (ar) with respect to T and D.
        // itau and idel are inputs that contain the highest derivatives needed.
        // Outputs are returned in the array ar.
        // Subroutine xTerms must be called before this routine if x has changed

        // Inputs:
        //  itau - Set this to 1 to calculate "ar" derivatives with respect to T [i.e., ar(1,0), ar(1,1), and ar(2,0)], otherwise set it to 0.
        //  idel - Currently not used, but kept as an input for future use in specifing the highest density derivative needed.
        //     T - Temperature (K)
        //     D - Density (mol/l)

        // Outputs:
        // ar(0,0) - Residual Helmholtz energy (J/mol)
        // ar(0,1) -   D*partial  (ar)/partial(D) (J/mol)
        // ar(0,2) - D^2*partial^2(ar)/partial(D)^2 (J/mol)
        // ar(0,3) - D^3*partial^3(ar)/partial(D)^3 (J/mol)
        // ar(1,0) -     partial  (ar)/partial(T) [J/(mol-K)]
        // ar(1,1) -   D*partial^2(ar)/partial(D)/partial(T) [J/(mol-K)]
        // ar(2,0) -   T*partial^2(ar)/partial(T)^2 [J/(mol-K)]

        let mut ckd;
        let mut bkd;
        let dred;

        let mut sum;
        let mut s0;
        let mut s1;
        let mut s2;
        let mut s3;
        let rt;

        let mut sum0: [f64; NTERMS] = [0.0; NTERMS];
        let mut sumb: [f64; NTERMS] = [0.0; NTERMS];
        let mut dknn: [f64; 10] = [0.0; 10];
        let mut expn: [f64; 5] = [0.0; 5];

        let mut coefd1: [f64; NTERMS] = [0.0; NTERMS];
        let mut coefd2: [f64; NTERMS] = [0.0; NTERMS];
        let mut coefd3: [f64; NTERMS] = [0.0; NTERMS];

        let mut coeft1: [f64; NTERMS] = [0.0; NTERMS];
        let mut coeft2: [f64; NTERMS] = [0.0; NTERMS];

        for i in 0..4 {
            for j in 0..4 {
                self.ar[i][j] = 0.0;
            }
        }
        if f64::abs(self.t - self.told) > 0.000_000_1 {
            for (i, item) in UN.iter().enumerate() {
                self.tun[i] = f64::powf(self.t, -item);
            }
        }
        self.told = self.t;

        // Precalculation of common powers and exponents of density
        dred = self.k3 * self.d;
        dknn[0] = 1.0;

        for n in 1..10 {
            dknn[n] = dred * dknn[n - 1];
        }
        expn[0] = 1.0;

        for n in 1..5 {
            expn[n] = f64::exp(-dknn[n]);
        }
        rt = RDETAIL * self.t;

        for n in 0..58 {
            // Contributions to the Helmholtz energy and its derivatives with respect to temperature
            coeft1[n] = RDETAIL * (UN[n] - 1.0);
            coeft2[n] = coeft1[n] * UN[n];
            // Contributions to the virial coefficients
            sumb[n] = 0.0;
            sum0[n] = 0.0;
            if n <= 17 {
                sum = self.bs[n] * self.d;
                if n >= 12 {
                    sum += -self.csn[n] * dred;
                }
                sumb[n] = sum * self.tun[n];
            }
            if n >= 12 {
                // Contributions to the residual part of the Helmholtz energy
                sum0[n] = self.csn[n] * dknn[BN[n]] * self.tun[n] * expn[KN[n]];
                // Contributions to the derivatives of the Helmholtz energy with respect to density
                bkd = BN[n] as f64 - KN[n] as f64 * dknn[KN[n]];
                ckd = KN[n] as f64 * KN[n] as f64 * dknn[KN[n]];
                coefd1[n] = bkd;
                coefd2[n] = bkd * (bkd - 1.0) - ckd;
                coefd3[n] = (bkd - 2.0) * coefd2[n] + ckd * (1.0 - KN[n] as f64 - 2.0 * bkd);
            } else {
                coefd1[n] = 0.0;
                coefd2[n] = 0.0;
                coefd3[n] = 0.0;
            }
        }

        for n in 0..58 {
            // Density derivatives
            s0 = sum0[n] + sumb[n];
            s1 = sum0[n] * coefd1[n] + sumb[n];
            s2 = sum0[n] * coefd2[n];
            s3 = sum0[n] * coefd3[n];
            self.ar[0][0] += rt * s0;
            self.ar[0][1] += rt * s1;
            self.ar[0][2] += rt * s2;
            self.ar[0][3] += rt * s3;
            // Temperature derivatives
            if itau > 0 {
                self.ar[1][1] -= coeft1[n] * s1;
                self.ar[1][0] -= coeft1[n] * s0;
                self.ar[2][0] += coeft2[n] * s0;
                //The following are not used, but fully functional
                //ar(1, 2) = ar(1, 2) - CoefT1(n) * s2;
                //ar(1, 3) = ar(1, 3) - CoefT1(n) * s3;
                //ar(2, 1) = ar(2, 1) + CoefT2(n) * s1;
                //ar(2, 2) = ar(2, 2) + CoefT2(n) * s2;
                //ar(2, 3) = ar(2, 3) + CoefT2(n) * s3;
            }
        }
    }

    /// Calculate density as a function of temperature and pressure.  This is an iterative routine that calls PressureDetail
    /// to find the correct state point.  Generally only 6 iterations at most are required.
    /// If the iteration fails to converge, the ideal gas density and an error message are returned.
    /// No checks are made to determine the phase boundary, which would have guaranteed that the output is in the gas phase.
    /// It is up to the user to locate the phase boundary, and thus identify the phase of the T and P inputs.
    /// If the state point is 2-phase, the output density will represent a metastable state.
    pub fn density_detail(&mut self) -> f64 {
        let plog: f64;
        let mut vlog: f64;
        let mut dpdlv: f64;
        let mut vdiff: f64;
        let tolr: f64;
        let mut p2: f64;

        if f64::abs(self.p) < EPSILON {
            self.d = 0.0;
            return self.d;
        }
        tolr = 0.000_000_1;
        if self.d > -EPSILON {
            self.d = self.p / RDETAIL / self.t; // Ideal gas estimate
        } else {
            self.d = f64::abs(self.d); // If D<0, then use as initial estimate
        }
        plog = f64::ln(self.p);
        vlog = -f64::ln(self.d);
        for _it in 0..20 {
            if vlog < -7.0 || vlog > 100.0 {
                //ierr = 1; herr = "Calculation failed to converge in DETAIL method, ideal gas density returned.";
                self.d = self.p / RDETAIL / self.t;
                return self.d;
            }
            self.d = f64::exp(-vlog);
            p2 = self.pressure_detail();
            if self.dp_dd_save < EPSILON || p2 < EPSILON {
                vlog += 0.1;
            } else {
                // Find the next density with a first order Newton's type iterative scheme, with
                // log(P) as the known variable and log(v) as the unknown property.
                // See AGA 8 publication for further information.
                dpdlv = -self.d * self.dp_dd_save; // d(p)/d[log(v)]
                vdiff = (f64::ln(p2) - plog) * p2 / dpdlv;
                vlog -= vdiff;
                if f64::abs(vdiff) < tolr {
                    self.d = f64::exp(-vlog);
                    return self.d; // Iteration converged
                }
            }
        }
        //ierr = 1; herr = "Calculation failed to converge in DETAIL method, ideal gas density returned.";
        self.d = self.p / RDETAIL / self.t;
        self.d
    }

    /// Calculate pressure as a function of temperature and density.  The derivative d(P)/d(D) is also calculated
    /// for use in the iterative DensityDetail subroutine (and is only returned as a common variable).
    pub fn pressure_detail(&mut self) -> f64 {
        self.x_terms();
        self.alphar(0, 2);
        self.z = 1.0 + self.ar[0][1] / RDETAIL / self.t; // ar(0,1) is the first derivative of alpha(r) with respect to density
        let p = self.d * RDETAIL * self.t * self.z;
        self.dp_dd_save = RDETAIL * self.t + 2.0 * self.ar[0][1] + self.ar[0][2]; // d(P)/d(D) for use in density iteration
        p
    }

    /// Calculate thermodynamic properties as a function of temperature and density.  Calls are made to the subroutines
    /// Molarmass, Alpha0Detail, and AlpharDetail.  If the density is not known, call subroutine DensityDetail first
    /// with the known values of pressure and temperature.
    pub fn properties_detail(&mut self) {
        let mm: f64;
        let a: f64;
        let r: f64;
        let rt: f64;

        mm = self.molar_mass_detail();
        self.x_terms();

        // Calculate the ideal gas Helmholtz energy, and its first and second derivatives with respect to temperature.
        self.alpha0_detail();

        // Calculate the real gas Helmholtz energy, and its derivatives with respect to temperature and/or density.
        self.alphar(2, 3);

        r = RDETAIL;
        rt = r * self.t;
        self.z = 1.0 + self.ar[0][1] / rt;
        self.p = self.d * rt * self.z;
        self.dp_dd = rt + 2.0 * self.ar[0][1] + self.ar[0][2];
        self.dp_dt = self.d * r + self.d * self.ar[1][1];
        a = self.a0[0] + self.ar[0][0];
        self.s = -self.a0[1] - self.ar[1][0];
        self.u = a + self.t * self.s;
        self.cv = -(self.a0[2] + self.ar[2][0]);
        if self.d > EPSILON {
            self.h = self.u + self.p / self.d;
            self.g = a + self.p / self.d;
            self.cp = self.cv + self.t * f64::powi(self.dp_dt / self.d, 2) / self.dp_dd;
            self.d2p_dd2 = (2.0 * self.ar[0][1] + 4.0 * self.ar[0][2] + self.ar[0][3]) / self.d;
            self.jt = (self.t / self.d * self.dp_dt / self.dp_dd - 1.0) / self.cp / self.d;
        } else {
            self.h = self.u + rt;
            self.g = a + rt;
            self.cp = self.cv + r;
            self.d2p_dd2 = 0.0;
            self.jt = 1.0E+20; //=(dB/dT*T-B)/Cp for an ideal gas, but dB/dT is not calculated here
        }
        self.w = 1000.0 * self.cp / self.cv * self.dp_dd / mm;
        if self.w < 0.0 {
            self.w = 0.0;
        }
        self.w = f64::sqrt(self.w);
        self.kappa = self.w * self.w * mm / (rt * 1000.0 * self.z);
        self.d2p_dtd = 0.0;
    }
}
