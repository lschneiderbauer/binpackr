library(purrr)
library(dplyr)
library(tidyr)
library(ggplot2)

# Benchmarks the *installed* version of binpackr: install the current state
# first (e.g. `devtools::install()`), since `devtools::load_all()` compiles
# without optimization and would distort run times.
library(binpackr)

# `bench::mark()` only records R allocations. Compile an instrumented copy of
# the C++ core that counts its heap allocations as well (see count_alloc.cpp).
local({
  src <- readLines("./benchmark/count_alloc.cpp")
  src <- sub(
    "../src/first_fit_fast.cpp", normalizePath("./src/first_fit_fast.cpp"),
    src,
    fixed = TRUE
  )
  cpp11::cpp_source(code = src, quiet = TRUE, env = globalenv())
})

# `fns`: named list of implementations `f(x, cap)`.
# `cpp_mem`: named list of functions `g(x, cap)` returning the bytes allocated
#   outside of R for that implementation (missing names count as 0).
bmark <- function(fns, cpp_mem = list()) {
  reduce(
    map(
      # seq(1, 10000, length.out = 2),
      seq(1, 50000, length.out = 20),
      function(n) {
        x <- sample(100, n, replace = TRUE) / 1000
        cap <- 1

        waste <-
          tibble(x) |>
          mutate(
            id = row_number(),
            across(.cols = x, .fns = map(fns, \(f) \(x) f(x, !!cap)), .names = "res_{.fn}")
          ) |>
          pivot_longer(
            starts_with("res_"),
            names_to = "name",
            values_to = "bin",
            names_prefix = "res_"
          ) |>
          mutate(
            util = sum(x) / cap,
            .by = c(name, bin)
          ) |>
          summarize(
            n_bins = n_distinct(bin),
            space_waste = (n_distinct(bin) * cap - sum(x))/sum(x),
            avg_util = mean(util),
            median_util = median(util),
            min_util = min(util),
            max_util = max(util),
            .by = name
          )

        bres <-
          bench::mark(
            exprs = map(fns, \(f) expr((!!f)(x, cap))),
            check = FALSE
          ) |>
          rowwise() |>
          mutate(
            std = sd(time),
            mean = mean(time)
          ) |>
          ungroup() |>
          mutate(
            name = as.character(expression),
            median, mem_alloc,
            mean, std,
            .keep = "none"
          )

        mem_cpp <-
          tibble(
            name = names(fns),
            mem_alloc_cpp = map_dbl(
              names(fns),
              \(nm) if (is.null(cpp_mem[[nm]])) 0 else cpp_mem[[nm]](x, cap)
            )
          )

        bres |>
          left_join(mem_cpp, by = "name") |>
          mutate(
            mem_alloc_r = mem_alloc,
            mem_alloc = bench::as_bench_bytes(
              as.numeric(mem_alloc_r) + mem_alloc_cpp
            )
          ) |>
          left_join(waste, by = "name") |>
          mutate(n = !!n)
      },
      .progress = TRUE
    ),
    union
  )
}

result <-
  bmark(
    list(
      bbmisc = BBmisc::binPack,
      cpp_ffd = partial(bin_pack_ffd, sort = FALSE),
      cpp_ffd_sort = partial(bin_pack_ffd)
    ),
    cpp_mem = list(
      cpp_ffd = \(x, cap) cpp_alloc_bytes(x, cap),
      cpp_ffd_sort = \(x, cap) cpp_alloc_bytes(sort(x, decreasing = TRUE), cap)
    )
  )

saveRDS(result, "./benchmark/results.rds")

# result |>
#   filter(n > 1) |>
#   ggplot(aes(x = n, y = space_waste, color = name)) +
#   scale_y_continuous(
#     labels = scales::label_percent()
#   ) +
#   geom_point() +
#   geom_line() +
#   facet_wrap(facets = vars(name))
#
# result |>
#   filter(n > 1) |>
#   ggplot(aes(x = n, y = avg_util, color = name, fill = name, linetype = name,
#              ymin = min_util, ymax = max_util)) +
#   scale_y_continuous(
#     labels = scales::label_percent()
#   ) +
#   geom_ribbon(alpha = 0.3, linewidth = 0) +
#   geom_point() +
#   geom_line() +
#   facet_wrap(facets = vars(name))


