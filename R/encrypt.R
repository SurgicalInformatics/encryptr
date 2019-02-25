#' Encrypt a character vector using an RSA public/private key
#'
#' Not usually called directly.
#'
#' @param .data A vector, which if not a character vector is coerced to one.
#' @param public_key_path Character. A quoted path to an RSA public key created
#'   using \code{\link{genkeys}}.
#'
#' @return A vector of ciphertexts.
#'
#' @importFrom purrr map
#' @importFrom dplyr mutate_if
#' @importFrom dplyr mutate_at
#' @importFrom dplyr vars
#' @importFrom dplyr select
#' @importFrom dplyr mutate
#' @importFrom dplyr bind_cols
#' @export
#'
#' @examples
#' \dontrun{
#' hospital_number = c("1010761111", "2010761212")
#' encrypt_vec(hospital_number)
#' }
encrypt_vec <- function(.data, public_key_path = "id_rsa.pub"){
  .data %>%
    map(as.character) %>%
    map(charToRaw) %>%
    map(openssl::rsa_encrypt, openssl::read_pubkey(public_key_path)) %>%
    map(raw2hex) %>%
    unlist()
}

#' Encrypt a dataframe or tibble column using an RSA public/private key
#'
#' @param .data A dataframe or tibble.
#' @param ... The unquoted names of columns to encrypt.
#' @param public_key_path Character. A quoted path to an RSA public key created
#'   using \code{\link{genkeys}}.
#' @param lookup Logical. Whether to substitute the encrypted columns for
#'   key-column of integers.
#' @param lookup_name Character. A quoted name to give lookup table and file.
#' @param write_lookup Logical. Write a lookup table as a .csv file.
#'
#' @return The original dataframe or tibble with the specified columns
#'   encrypted.
#' @export
#'
encrypt <- function(.data, ..., public_key_path = "id_rsa.pub",
                    lookup = FALSE, lookup_name = "lookup", write_lookup = TRUE){

  # Capture column names
  .cols <- rlang::enquos(...)

  # Encrypt columns
  df.encrypt <- .data %>%
    mutate_at(vars(!!! .cols), encrypt_vec, public_key_path)

  if(!lookup){
    return(df.encrypt)

  } else if(lookup){
    # Make lookup table
    df.lookup <- df.encrypt %>%
      select(!!! .cols) %>%
      mutate(
        key = 1:dim(df.encrypt)[1]
      )

    # Assign lookup table with lookup_name
    assign(rlang::quo_name(rlang::enquo(lookup_name)), df.lookup, envir=.GlobalEnv)
    cat("Lookup table object created with name '", lookup_name, "'\n", sep = "")

    if(lookup & write_lookup){
      lookup_file_name <- paste0(lookup_name, ".csv")
      if(file.exists(lookup_file_name)) {
        stop("Lookup file with this name already exists. Delete or choose a new name.")
      }
      readr::write_csv(df.lookup, lookup_file_name)
      cat("Lookup table written to file with name '", lookup_file_name, "'\n",
          sep = "")
    }

    # Substitute lookup key in data.frame to return
    df.encrypt %>%
      select(-c(!!! .cols)) %>%
      bind_cols(key = df.lookup$key, .)
  }
}
