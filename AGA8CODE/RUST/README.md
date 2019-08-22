# Info
The Rust implementation of AGA8 is based on the C++ implementation.
The main difference from the other implementations is that it puts
the data into a struct `AGA8Detail`, and puts the functions as
methods under that struct.

## Building
Use cargo:

```shell
# Build for debugging
$ cargo build
# Buld for release
$ cargo build --release
```
This will build a number of different types of library files.

To build and run the demo example:
```shell
$ cargo run --example demo
```
This will run an example that uses the `AGA8Detail` struct
and prints the results to the terminal.

## Using
The library files can be used to call the `aga8_2017` function
from other languages. For example from C#:

```c#
...
[DllImport("aga8_2017")]
private static extern double aga8_2017(double[] composition, double pressure,
    double temperature, int result = 0);
...

Console.WriteLine(aga8_2017(comp, 50000.0, 400.0, 0);
```

## Contact
For questions on the Rust impementation, please contact roy.vegard.ovesen@gmail.com

