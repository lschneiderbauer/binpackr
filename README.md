
<!-- README.md is generated from README.Rmd. Please edit that file -->

# binpackr

<!-- badges: start -->

[![R-CMD-check](https://github.com/lschneiderbauer/binpackr/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/lschneiderbauer/binpackr/actions/workflows/R-CMD-check.yaml)
[![Codecov test
coverage](https://codecov.io/gh/lschneiderbauer/binpackr/graph/badge.svg)](https://app.codecov.io/gh/lschneiderbauer/binpackr)
[![Lifecycle:
stable](https://img.shields.io/badge/lifecycle-stable-brightgreen.svg)](https://lifecycle.r-lib.org/articles/stages.html#stable)
[![CRAN
status](https://www.r-pkg.org/badges/version/binpackr)](https://CRAN.R-project.org/package=binpackr)

<!-- badges: end -->

This package implements the First Fit Decreasing algorithm to achieve
one dimensional heuristic bin packing. Its run time is of order
$\mathcal{O}(n\,log(n))$ where $n$ is the number of items to pack.

## Installation

You can install the latest CRAN release of binpackr with:

``` r
install.packages("binpackr")
```

Alternatively, you can install the development version of binpackr from
[GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("lschneiderbauer/binpackr")
```

## Example

This is a basic example which shows to retrieve the solution for the bin
packing problem.

``` r
library(binpackr)

# Generate a vector of item sizes
set.seed(42)
x <- sample(100, 1000, replace = TRUE)

# Pack those items into bins of capacity 130
bins <- bin_pack_ffd(x, cap = 130)

# Number of bins needed to pack the items
print(length(unique(bins)))
#> [1] 389
```

## Benchmarks

The implementation in this package is compared to an implementation of
the same algorithm in the
[BBmisc](https://github.com/berndbischl/BBmisc) package. The authors
made it clear that speed was none of their concern. BBmisc’s
implementation is written in R while this package uses a C++
implementation.

### Run time

    #> Warning: Removed 3 rows containing missing values or values outside the scale range
    #> (`geom_ribbon()`).

<img src="man/figures/README-benchmark_runtime-1.png" alt="" width="100%" />

### Memory allocation

    #> Ignoring unknown labels:
    #> • fill : "Implementation"

<img src="man/figures/README-benchmark_memory-1.png" alt="" width="100%" />
