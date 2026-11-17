#include <cstddef>

// Writes the 0-based bin label of items[i] to out[i]. `out` must hold n_items ints.
void ffd_fast(const double *items, std::size_t n_items, double cap, int *out);
