library(purrr)
library(dplyr)
library(tidyr)
library(ggplot2)

bmark <- function(fns) {
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

        bres |>
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


