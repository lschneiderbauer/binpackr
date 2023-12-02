#include <cpp11.hpp>
#include <vector>
#include "first_fit_fast.h"

using namespace cpp11;

[[cpp11::register]]
integers first_fit_decreasing_fast(doubles x, double cap) {
  return(as_sexp(ffd_fast(cpp11::as_cpp<std::vector<double>>(x), cap)));
}
