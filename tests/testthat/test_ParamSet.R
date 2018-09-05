context("ParamSet")

test_that("methods and active bindings work", {
  ps_list = list(
    th_paramset_empty,
    th_paramset_full,
    th_paramset_repeated,
    th_paramset_restricted,
    th_paramset_untyped,
    th_paramset_numeric,
    th_paramset_trafo,
    th_paramset_trafo_dictionary
    )
  for (ps in ps_list) {
    if (ps$id == "th_paramset_full") {
      expect_equal(ps$ids, c('th_param_int', 'th_param_real', 'th_param_categorical', 'th_param_flag'))
      expect_equal(ps$lower, c(th_param_int=-10, th_param_real=-10, th_param_categorical=NA_real_, th_param_flag=NA_real_))
      expect_equal(ps$upper, c(th_param_int=10, th_param_real=10, th_param_categorical=NA_real_, th_param_flag=NA_real_))
    }
    expect_class(ps, "ParamSet")
    expect_numeric(ps$lower, any.missing = TRUE, names = "strict")
    expect_numeric(ps$upper, any.missing = TRUE, names = "strict")
    expect_character(ps$storage_types, names = "strict")
    expect_character(ps$ids)
    expect_list(ps$values, any.missing = TRUE, names = "strict")
    expect_character(ps$param_classes, names = "strict")
    expect_data_table(ps$range)
    expect_flag(ps$has_finite_bounds)
    expect_int(ps$length, lower = 0L)
    expect_integer(ps$nlevels, any.missing = TRUE)
    expect_list(ps$member_tags, names = "strict", any.missing = TRUE)
  }
})

test_that("advanced methods work", {
  ps_list = list(
    th_paramset_full,
    th_paramset_repeated,
    th_paramset_restricted,
    th_paramset_numeric,
    th_paramset_trafo,
    th_paramset_trafo_dictionary
  )
  
  for (ps in ps_list) {

    x = ps$sample(10)
    expect_data_table(x, nrows = 10, any.missing = FALSE)
    expect_equal(colnames(x), ps$ids)
    expect_true(all(x[, ps$test(as.list(.SD)), by = seq_len(nrow(x))]$V1))
    xt = ps$transform(x)
    expect_data_table(xt, nrows = 10)

    x = lapply(ps$ids, function(x) runif(10))
    names(x) = ps$ids
    xd = ps$denorm(x)
    expect_data_table(xd, nrows = 10, any.missing = FALSE)
    expect_equal(colnames(xd), ps$ids)
    # denorm can produce infeasible settings
    # expect_true(all(x[, ps$test(.SD), by = seq_len(nrow(x))]$V1))
    xdt = ps$transform(xd)
    expect_data_table(xdt, nrows = 10)

    xl = ps$generate_lhs_design(10)
    expect_data_table(xl, nrows = 10, any.missing = FALSE)
    expect_true(all(xl[, ps$test(.SD), by = seq_len(nrow(xl))]$V1))
    xlt = ps$transform(xl)
    expect_data_table(xlt, nrows = 10)
    xltl = design_to_list(xlt)
    expect_list(xltl, len = 10)

    xg = ps$generate_grid_design(5)
    expect_data_table(xg, any.missing = FALSE)
    expect_true(nrow(xg) <= 5^ps$length)
    expect_true(all(xg[, ps$test(.SD), by = seq_len(nrow(xg))]$V1))
    xgt = ps$transform(xg)
    expect_data_table(xgt, nrows = nrow(xg))

    p_res = ps$nlevels
    p_res[is.na(p_res)] = 2
    xgp = ps$generate_grid_design(param_resolutions = p_res)
    expect_data_table(xgp, any.missing = FALSE)
    expect_true(nrow(xgp) <= prod(p_res))

    xgn = ps$generate_grid_design(n = 100)
    expect_data_table(xgn, any.missing = FALSE)
    expect_true(nrow(xgn) <= 100)
  }
})

test_that("repeated params in ParamSet works", {
  ps = th_paramset_repeated
  expect_class(ps, "ParamSet")
  expect_equal(sum(sapply(ps$member_tags, function(z) "th_param_real_na_repeated" %in% z)), 4)
  xs = ps$sample(10)
  expect_true("th_param_categorical" %in% names(xs))
  xs_t = ps$transform(xs)
  expect_false("th_param_nat" %in% names(xs_t))
  expect_list(xs_t$vector_param)
  xs_l = design_to_list(xs_t)
  expect_list(xs_l, len = 10)
})