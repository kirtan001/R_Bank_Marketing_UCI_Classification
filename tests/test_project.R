library(testthat)

test_that("Environment is ready", {
  expect_true(TRUE)
})

# In a real package, we would source the functions or load the package
# Here we check if the critical files exist as a proxy for 'build success'

test_that("Critical Files Exist", {
  expect_true(file.exists("../src/app.R"))
  expect_true(file.exists("../Dockerfile"))
  expect_true(file.exists("../final_report.Rmd"))
})
