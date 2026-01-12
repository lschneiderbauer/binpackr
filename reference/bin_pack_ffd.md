# 1D bin packing "First Fit (Decreasing)" algorithm

1D bin packing "First Fit (Decreasing)" algorithm

## Usage

``` r
bin_pack_ffd(x, cap, sort = TRUE)
```

## Arguments

- x:

  \[[`numeric()`](https://rdrr.io/r/base/numeric.html)\] A numeric
  vector of item sizes to be fit into bins. Each value represents the
  size of an atomic item. If a value is `NA` it is ignored and the
  corresponding result will also be `NA`.

- cap:

  \[`numeric(1)`\] A scalar value representing the bin capacity in units
  of values in `x`. If an individual item size is above `cap` a single
  bin is reserved for this item.

- sort:

  \[`logical(1)`\] Determines whether the input vector should be sorted
  in decreasing order before applying the "First Fit" algorithm ("First
  Fit Decreasing").

## Value

\[[`integer()`](https://rdrr.io/r/base/integer.html)\] An integer vector
of labels of the same length as `x`. The integer label at position `i`
determines the assignment of the `i`th item with size `x[i]` to a bin.
If the value `x[i]` is `NA` the result label at position `i` will also
be `NA`.

## Details

See [Wikipedia](https://en.wikipedia.org/wiki/First-fit_bin_packing) for
a concise introduction or "The Art of Computer Programming Vol. 1" by
Donald E. Knuth (1997, ISBN: 0201896834) for more details.

## Examples

``` r
# Generate a vector of item sizes
x <- sample(100, 1000, replace = TRUE)

# Pack those items into bins of capacity 130
bins <- bin_pack_ffd(x, cap = 130)

# Number of bins needed to pack the items
print(length(unique(bins)))
#> [1] 383
```
