#include <mpi.h>
#include <stdio.h>
#include <stdlib.h>

int main(int argc, char **argv) {
    MPI_Init(&argc, &argv);
    int rank, size;
    MPI_Comm_rank(MPI_COMM_WORLD, &rank);
    MPI_Comm_size(MPI_COMM_WORLD, &size);

    long N = 1L << 24;
    if (N % size != 0) {
        if (rank == 0) fprintf(stderr, "N must be divisible by ranks\n");
        MPI_Abort(MPI_COMM_WORLD, 1);
    }
    long local_n = N / size;

    double *x = aligned_alloc(64, local_n * sizeof(double));
    double *y = aligned_alloc(64, local_n * sizeof(double));
    for (long i = 0; i < local_n; i++) { x[i] = 1.0; y[i] = 2.0; }

    MPI_Barrier(MPI_COMM_WORLD);
    double t0 = MPI_Wtime();
    double a = 3.0;
    for (long i = 0; i < local_n; i++) y[i] = a * x[i] + y[i];
    MPI_Barrier(MPI_COMM_WORLD);
    double t1 = MPI_Wtime();

    double local_sum = 0;
    for (long i = 0; i < local_n; i++) local_sum += y[i];
    double global_sum;
    MPI_Reduce(&local_sum, &global_sum, 1, MPI_DOUBLE, MPI_SUM, 0, MPI_COMM_WORLD);

    if (rank == 0)
        printf("ranks=%d, N=%ld, time=%.2f ms, sum=%g\n",
               size, N, (t1-t0)*1e3, global_sum);

    free(x); free(y);
    MPI_Finalize();
    return 0;
}
