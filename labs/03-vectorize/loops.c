/*
 * Six loops, each chosen for a different vectorizer behavior.
 * Compile with: clang -O3 -march=native -Rpass=loop-vectorize -c loops.c
 */
#include <stddef.h>
#include <math.h>

/* 1. Trivially vectorizable. */
void vadd(int n, const double *a, const double *b, double *c) {
    for (int i = 0; i < n; i++) c[i] = a[i] + b[i];
}

/* 2. May not vectorize without restrict — possible aliasing. */
void vadd_alias(int n, double *a, double *b, double *c) {
    for (int i = 0; i < n; i++) c[i] = a[i] + b[i];
}

/* 3. Function call inside loop body usually blocks vectorization. */
void vexp(int n, const double *a, double *b) {
    for (int i = 0; i < n; i++) b[i] = exp(a[i]);
}

/* 4. Loop-carried dependency — should NOT vectorize unsoundly. */
void recurrence(int n, double *a) {
    for (int i = 1; i < n; i++) a[i] = a[i-1] * 0.5 + 1.0;
}

/* 5. Reduction — vectorizes only if compiler can reason about associativity. */
double dot(int n, const double *a, const double *b) {
    double s = 0;
    for (int i = 0; i < n; i++) s += a[i] * b[i];
    return s;
}

/* 6. Variable trip count + branches — modern vectorizers handle this with masks. */
void clip(int n, const double *a, double *b, double lo, double hi) {
    for (int i = 0; i < n; i++) {
        double x = a[i];
        if (x < lo) x = lo;
        if (x > hi) x = hi;
        b[i] = x;
    }
}
