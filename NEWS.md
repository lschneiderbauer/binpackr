# binpackr (development version)

-   `bin_pack_ffd()` now returns an integer vector, as documented (previously it returned a double vector).
-   `bin_pack_ffd()` is faster and uses less memory: unnecessary copies between R and C++ were removed, and `NA` handling is skipped when the input contains no `NA`s.

# binpackr 0.2.0

-   `bin_pack_ffd()`: fixed wrong item distribution in some cases when item sizes were greater than the bin capacity.
-   `NA`s in `bin_pack_ffd(x = ...)` are now treated consistently.

# binpackr 0.1.1

-   Added references to DESCRIPTION and documentation.

# binpackr 0.1.0

-   Initial CRAN submission.
