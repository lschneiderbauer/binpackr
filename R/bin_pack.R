#' 1D bin packing "First Fit (Decreasing)" algorithm
#'
#' @param x A numeric vector of item sizes to be fit into bins. Each value
#'          represents the size of an atomic item. If a value is `NA` it is
#'          ignored and the corresponding result will also be `NA`.
#' @param cap Bin capacity in units of values in `x`. A scalar value. If
#'            an individual item size is above `cap` a single bin is reserved
#'            for this item.
#' @param sort Determines whether the input vector should be sorted in
#'             decreasing order before applying the "First Fit" algorithm
#'             ("First Fit Decreasing").
#' @returns An integer vector of labels of the same length as `x`. The integer
#'          label at position `i` determines the assignment of the `i`th item
#'          with size `x[i]` to a bin. If the value `x[i]` is `NA` the result
#'          label at position `i` will also be `NA`.
#' @details See [Wikipedia](https://en.wikipedia.org/wiki/First-fit_bin_packing)
#'          for a concise introduction or
#'          "The Art of Computer Programming Vol. 1" by Donald E. Knuth
#'          (1997, ISBN: 0201896834) for more details.
#' @examples
#' # Generate a vector of item sizes
#' x <- sample(100, 1000, replace = TRUE)
#'
#' # Pack those items into bins of capacity 130
#' bins <- bin_pack_ffd(x, cap = 130)
#'
#' # Number of bins needed to pack the items
#' print(length(unique(bins)))
#'
#' @export
bin_pack_ffd <- function(x, cap, sort = TRUE) {
  stopifnot(is.numeric(x))
  stopifnot(is.numeric(cap))
  stopifnot(length(cap) == 1)
  stopifnot(is.logical(sort))

  x <- as.numeric(x)
  cap <- as.numeric(cap)

  is_na <- is.na(x)
  x2 <- x[!is_na]

  if (sort) {
    ord <- order(x2, decreasing = TRUE)

    y <- .Call(`_binpackr_first_fit_decreasing_fast`, x2[ord], cap)[order(ord)]
  } else {
    y <- .Call(`_binpackr_first_fit_decreasing_fast`, x2, cap)
  }

  x[!is_na] <- y
  return(x)
}
