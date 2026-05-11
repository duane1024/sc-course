// Era 6 (alternative): Kokkos, the dominant performance-portable abstraction
// in DOE production codes.
//
// Same SAXPY kernel, but written as a Kokkos parallel_for. The execution
// space (OpenMP / CUDA / HIP / SYCL) is selected at Kokkos build time;
// this source compiles unchanged for any of them.
//
// Build (after installing Kokkos -- see github.com/kokkos/kokkos):
//   g++ -O3 -std=c++17 -fopenmp \
//       -I$KOKKOS_DIR/include -L$KOKKOS_DIR/lib \
//       saxpy_kokkos.cpp -lkokkoscore -o saxpy_kokkos
//   ./saxpy_kokkos
//
// For a CUDA build, rebuild Kokkos with -DKokkos_ENABLE_CUDA=ON and
// compile this file with nvcc_wrapper instead of g++. Same source.

#include <Kokkos_Core.hpp>
#include <chrono>
#include <cstdio>

int main(int argc, char **argv) {
    Kokkos::initialize(argc, argv);
    {
        const long N = 1L << 24;
        Kokkos::View<double*> x("x", N), y("y", N);
        const double a = 3.0;

        Kokkos::parallel_for("init", N, KOKKOS_LAMBDA(const long i) {
            x(i) = 1.0;
            y(i) = 2.0;
        });
        Kokkos::fence();

        auto t0 = std::chrono::steady_clock::now();
        Kokkos::parallel_for("saxpy", N, KOKKOS_LAMBDA(const long i) {
            y(i) = a * x(i) + y(i);
        });
        Kokkos::fence();
        auto t1 = std::chrono::steady_clock::now();

        double sum = 0.0;
        Kokkos::parallel_reduce("sum", N,
            KOKKOS_LAMBDA(const long i, double &s) { s += y(i); },
            sum);

        double ms = std::chrono::duration<double, std::milli>(t1 - t0).count();
        std::printf("Kokkos exec space=%s, N=%ld, time=%.2f ms, sum=%g\n",
                    typeid(Kokkos::DefaultExecutionSpace).name(),
                    N, ms, sum);
    }
    Kokkos::finalize();
    return 0;
}
