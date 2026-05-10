/*
 * 1D heat equation with halo exchange.
 *   u_t = alpha u_xx,  central differences
 *   stable for dt/dx^2 <= 1/2.
 *
 * Domain partitioned into contiguous chunks across ranks.
 * Periodic boundaries (left/right neighbors wrap).
 *
 * Build:   make
 * Run:     mpirun -n 4 ./heat1d 1000000 1000
 */
#include <mpi.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>

int main(int argc, char **argv) {
    MPI_Init(&argc, &argv);
    int rank, size;
    MPI_Comm_rank(MPI_COMM_WORLD, &rank);
    MPI_Comm_size(MPI_COMM_WORLD, &size);

    long N = (argc > 1) ? atol(argv[1]) : 1000000;
    int  T = (argc > 2) ? atoi(argv[2]) : 1000;
    if (N % size != 0) {
        if (rank == 0) fprintf(stderr, "N must be divisible by ranks\n");
        MPI_Abort(MPI_COMM_WORLD, 1);
    }
    long local_n = N / size;

    /* +2 for halo cells. u[0] is left halo, u[local_n+1] is right halo. */
    double *u  = calloc(local_n + 2, sizeof(double));
    double *un = calloc(local_n + 2, sizeof(double));

    /* Initial condition: a Gaussian bump centered in the global domain. */
    double cx = N / 2.0;
    double sig = N / 50.0;
    for (long i = 1; i <= local_n; i++) {
        long g = rank * local_n + (i - 1);
        u[i] = exp(-((g - cx)*(g - cx)) / (2.0*sig*sig));
    }

    int left  = (rank - 1 + size) % size;
    int right = (rank + 1) % size;
    double dt_over_dx2 = 0.4;  /* under stability bound 0.5 */

    double t0 = MPI_Wtime();
    for (int t = 0; t < T; t++) {
        /* Halo exchange: send my edges, receive into halos. */
        MPI_Sendrecv(&u[1],          1, MPI_DOUBLE, left,  0,
                     &u[local_n+1],  1, MPI_DOUBLE, right, 0,
                     MPI_COMM_WORLD, MPI_STATUS_IGNORE);
        MPI_Sendrecv(&u[local_n],    1, MPI_DOUBLE, right, 1,
                     &u[0],          1, MPI_DOUBLE, left,  1,
                     MPI_COMM_WORLD, MPI_STATUS_IGNORE);

        /* Update interior */
        for (long i = 1; i <= local_n; i++)
            un[i] = u[i] + dt_over_dx2 * (u[i-1] - 2.0*u[i] + u[i+1]);

        double *tmp = u; u = un; un = tmp;
    }
    double t1 = MPI_Wtime();

    /* L2 norm verification */
    double local_sumsq = 0;
    for (long i = 1; i <= local_n; i++) local_sumsq += u[i]*u[i];
    double global_sumsq;
    MPI_Reduce(&local_sumsq, &global_sumsq, 1, MPI_DOUBLE, MPI_SUM, 0, MPI_COMM_WORLD);

    if (rank == 0) {
        printf("N=%ld, T=%d, ranks=%d, walltime=%.4f s, L2=%.10f\n",
               N, T, size, t1 - t0, sqrt(global_sumsq));
    }

    free(u); free(un);
    MPI_Finalize();
    return 0;
}
