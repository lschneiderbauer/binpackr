#include <cpp11.hpp>
#include <climits>
#include "first_fit_fast.h"

using namespace cpp11;

[[cpp11::register]]
integers first_fit_decreasing_fast(doubles x, double cap) {
  R_xlen_t n = x.size();
  // Labels are < n, so they fit into an R integer as long as n does.
  if (n > INT_MAX) {
    cpp11::stop("`x` has too many elements (more than %d).", INT_MAX);
  }

  writable::integers res(n);
  ffd_fast(REAL(static_cast<SEXP>(x)), static_cast<std::size_t>(n), cap,
           INTEGER(static_cast<SEXP>(res)));
  return res;
}
