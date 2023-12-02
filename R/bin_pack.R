#' 1D bin packing "First Fit (Decreasing)" algorithm
#'
#' @param x A numeric vector of values to be fit into bins.
#' @param cap Bin capacity in units of values in `x`. A scalar value.
#' @param sort Determines whether the input vector should be sorted in decreasing
#'             order before applying the "First Fit" algorithm ("First Fit Decreasing").
#' @returns A integer vector of labels of the same length as `x`. The integer
#'          label at position `i` determines the assignment of the `i`th item
#'          with weight `x[i]` to a bin.
#' @export
bin_pack_ffd <- function(x, cap, sort = TRUE) {
  stopifnot(is.numeric(x))
  stopifnot(is.numeric(cap))
  stopifnot(length(cap) == 1)
  stopifnot(is.logical(sort))

  if (sort) {
    ord <- order(x, decreasing = TRUE)

    .Call(`_binpackr_first_fit_decreasing_fast`, x[ord], cap)[order(ord)]
  } else {
    .Call(`_binpackr_first_fit_decreasing_fast`, x, cap)
  }
}
