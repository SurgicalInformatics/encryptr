context("test-genkeys")

# Run tests in temp directory
# https://github.com/r-lib/testthat/issues/664#issuecomment-340809997

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

test_with_dir("genkeys() defaults create id_rsa and id_rsa.pub", {
  genkeys(private_key_name = 'id_rsa')
  expect_true(file.exists("id_rsa"))
  expect_true(file.exists("id_rsa.pub"))
})

test_with_dir("genkeys() errors if files already exist", {
  genkeys(private_key_name = 'id_rsa')
  expect_error(genkeys())
})

test_with_dir("genkeys() creates keys with requested names", {
  genkeys("custom")
  expect_true(file.exists("custom"))
  expect_true(file.exists("custom.pub"))

  genkeys("public", "private")
  expect_true(file.exists("public"))
  expect_true(file.exists("private"))
})
