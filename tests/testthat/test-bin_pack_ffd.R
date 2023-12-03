test_that("Number of bins are always smaller or equal than the number of constituents.", {
  hedgehog::forall(
    hedgehog::gen.sample.int(100, 1000, replace = TRUE),
    function(x) {
      expect_lte(length(unique((bin_pack_ffd(x / 100, 1)))), 1000)
    }
  )
})

test_that("Particular examples are correct.", {
  x <-
    c(0.3, 0.4, 0.4, 0.3, 0.2)

  expect_equal(
    bin_pack_ffd(x, cap = 1, sort = TRUE),
    c(1, 0, 0, 1, 0)
  )

  expect_equal(
    bin_pack_ffd(x, cap = 1, sort = FALSE),
    c(0, 0, 1, 0, 1)
  )
})

test_that("Equal sized items get distributed correctly.", {
  hedgehog::forall(
    list(
      size = hedgehog::gen.int(100),
      length = hedgehog::gen.int(1000),
      cap_factor = hedgehog::gen.int(10)
    ),
    function(size, length, cap_factor) {
      x <- rep(size, length)
      cap <- size * cap_factor

      expect_equal(
        length(unique((bin_pack_ffd(x, cap)))),
        ceiling(length * size / cap)
      )

      expect_equal(
        length(unique((bin_pack_ffd(x, cap, sort = FALSE)))),
        ceiling(length * size / cap)
      )
    }
  )
})

test_that("Size bigger then cap simply yield one bin.", {
  x <- c(1.1, 1.22, 0.3, 0.2)

  expect_equal(
    bin_pack_ffd(x, cap = 1, sort = TRUE),
    c(1, 0, 2, 2)
  )

  expect_equal(
    bin_pack_ffd(x, cap = 1, sort = FALSE),
    c(0, 1, 2, 2)
  )
})
