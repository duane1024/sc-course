// Era 6: standard-library parallelism. Compile with:
//   g++ -O3 -std=c++20 -ltbb  saxpy_stdpar.cpp -o saxpy_stdpar          (CPU)
//   nvc++ -O3 -std=c++20 -stdpar=gpu saxpy_stdpar.cpp -o saxpy_stdpar    (NVIDIA GPU)

#include <algorithm>
#include <chrono>
#include <execution>
#include <iostream>
#include <numeric>
#include <vector>

int main() {
    constexpr long N = 1L << 24;
    std::vector<double> x(N, 1.0);
    std::vector<double> y(N, 2.0);
    const double a = 3.0;

    auto t0 = std::chrono::steady_clock::now();
    std::transform(std::execution::par_unseq,
                   x.begin(), x.end(), y.begin(), y.begin(),
                   [a](double xi, double yi) { return a*xi + yi; });
    auto t1 = std::chrono::steady_clock::now();

    double sum = std::reduce(std::execution::par_unseq,
                             y.begin(), y.end(), 0.0);

    double ms = std::chrono::duration<double, std::milli>(t1 - t0).count();
    std::cout << "N=" << N << ", time=" << ms << " ms, sum=" << sum << "\n";
    return 0;
}
