context("encrypt")
library(encryptr)

dir_empty <- function(x){
  unlink(x, recursive = TRUE, force = TRUE)
  dir.create(x)
}

test_with_dir <- function(desc, ...){
  new <- tempfile()
  dir_empty(new)
  withr::with_dir( # or local_dir()
    new = new,
    code = {
      tmp <- capture.output(
        testthat::test_that(desc = desc, ...)
      )
    }
  )
  invisible()
}

test_with_dir("encrypt returns a data frame", {
  genkeys()
  expect_is(encrypt(gp[1,], postcode), "data.frame")
})

test_with_dir("encrypt returns a data frame", {
  genkeys()
  expect_is(encrypt(gp[1,], postcode, lookup = TRUE), "data.frame")
})

test_with_dir("encrypt returns a data frame", {
  genkeys()
  expect_is(encrypt(gp[1,], postcode, lookup = TRUE, write_lookup = TRUE), "data.frame")
})

test_with_dir("encrypt errors when public_key_path wrong", {
  genkeys()
  expect_error(encrypt(gp[1,], postcode, public_key_path = ""))
})


context("encrypt_file")
library(encryptr)

test_with_dir("encrypt_file returns a file", {
  genkeys()
  write.csv(gp[1,], file = "gp.csv")
  expect_null(encrypt_file("gp.csv"))
})

test_with_dir("encrypt_file returns an error if file to encrypt not found", {
  expect_error(encrypt_file("gp.csv"))
})

test_with_dir("encrypt_file returns an error if public key not found", {
  write.csv(gp[1,], file = "gp.csv")
  expect_error(encrypt_file("gp.csv"))
})

test_with_dir("encrypt_file returns an error if crypt file name incorrect format", {
  genkeys()
  write.csv(gp[1,], file = "gp.csv")
  expect_error(encrypt_file("gp.csv", "wrong_name.csv"))
})

test_with_dir("encrypt_file returns an error if crypt file already exists", {
  genkeys()
  write.csv(gp[1,], file = "gp.csv")
  encrypt_file("gp.csv")
  expect_error(encrypt_file("gp.csv"))
})


context("internals")
library(encryptr)

test_that("hextoraw", {
  expect_type(hex2raw("123"), "raw")
})

