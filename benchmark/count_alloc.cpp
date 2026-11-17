// Counts the heap memory allocated by the C++ core of binpackr.
//
// `bench::mark()` only sees R allocations (via `Rprofmem`), so memory
// allocated by `std::vector`s inside the C++ code goes unnoticed. This file
// compiles the package's own `src/first_fit_fast.cpp` a second time, inside a
// namespace where `vector` is a `std::vector` with a byte-counting allocator.
// Unqualified `vector` in that file resolves to `counted::vector` (it is found
// before the names pulled in by `using namespace std;`), so no change to the
// package source is needed.
//
// Usage from R (see benchmark.R):
//   cpp11::cpp_source("benchmark/count_alloc.cpp")
//   cpp_alloc_bytes(x, cap)  # total bytes allocated by one call to ffd_fast()

#include <cmath>
#include <cstddef>
#include <memory>
#include <vector>
#include <cpp11.hpp>

namespace counted {

static double bytes_allocated = 0;

template <class T>
struct counting_allocator {
  using value_type = T;

  counting_allocator() = default;
  template <class U>
  counting_allocator(const counting_allocator<U>&) {}

  T* allocate(std::size_t n) {
    bytes_allocated += static_cast<double>(n) * sizeof(T);
    return std::allocator<T>{}.allocate(n);
  }
  void deallocate(T* p, std::size_t n) { std::allocator<T>{}.deallocate(p, n); }
};

template <class T, class U>
bool operator==(const counting_allocator<T>&, const counting_allocator<U>&) { return true; }
template <class T, class U>
bool operator!=(const counting_allocator<T>&, const counting_allocator<U>&) { return false; }

template <class T>
using vector = std::vector<T, counting_allocator<T>>;

#include "../src/first_fit_fast.cpp"

}  // namespace counted

[[cpp11::register]]
double cpp_alloc_bytes(cpp11::doubles x, double cap) {
  // The output vector is allocated by R in the package (and therefore already
  // counted by bench), so it is not counted here.
  std::vector<int> out(x.size());

  counted::bytes_allocated = 0;
  counted::ffd_fast(REAL(static_cast<SEXP>(x)), x.size(), cap, out.data());
  return counted::bytes_allocated;
}
