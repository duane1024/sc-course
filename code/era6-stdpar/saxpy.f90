program saxpy_doconcurrent
  implicit none
  integer, parameter :: N = 2**24
  real(8), allocatable :: x(:), y(:)
  real(8) :: a, t0, t1, sum
  integer :: i

  allocate(x(N), y(N))
  a = 3.0d0
  do concurrent (i = 1:N)
    x(i) = 1.0d0
    y(i) = 2.0d0
  end do

  call cpu_time(t0)
  do concurrent (i = 1:N)
    y(i) = a * x(i) + y(i)
  end do
  call cpu_time(t1)

  sum = sum_array(y, N)
  print *, "N =", N, "time =", (t1-t0)*1000.0d0, "ms, sum =", sum
  deallocate(x, y)

contains
  function sum_array(arr, n) result(s)
    integer, intent(in) :: n
    real(8), intent(in) :: arr(n)
    real(8) :: s
    integer :: j
    s = 0.0d0
    do concurrent (j = 1:n) reduce(+:s)
      s = s + arr(j)
    end do
  end function
end program
