# Specify global variables
globalVariables(c("key", "."))


#' Convert raw to hexadecimal
#'
#' @param .data
#'
#' @keywords internal
raw2hex <- function(.data){
  paste0(.data, collapse = "")
}

#' Convert hexadecimal to raw
#'
#' @param .data
#'
#' @keywords internal
hex2raw <- function(.data){
  .data %>%
    strsplit("(?<=.{2})", perl=TRUE) %>%
    unlist() %>%
    as.hexmode() %>%
    as.raw()
}


#' Pipe operator
#'
#' @name %>%
#' @rdname pipe
#' @keywords internal
#' @importFrom dplyr %>%
#' @usage lhs \%>\% rhs
#' @export
NULL
