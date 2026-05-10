program saxpy_scalar
  implicit none
  integer, parameter :: N = 2**24
  real(8), allocatable :: x(:), y(:)
  real(8) :: a, t0, t1, sum
  integer :: i

  allocate(x(N), y(N))
  a = 3.0d0
  do i = 1, N
    x(i) = 1.0d0
    y(i) = 2.0d0
  end do

  call cpu_time(t0)
  do i = 1, N
    y(i) = a * x(i) + y(i)
  end do
  call cpu_time(t1)

  sum = 0.0d0
  do i = 1, N
    sum = sum + y(i)
  end do

  print *, "N =", N, "time =", (t1-t0)*1000.0d0, "ms"
  print *, "sum =", sum, "(expected", 5.0d0*N, ")"
  deallocate(x, y)
end program
