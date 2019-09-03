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

#' Encrypt a data frame or tibble column using an RSA public/private key
#'
#' @param .data A data frame or tibble.
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
#' @examples
#' # This will run:
#' # genkeys()
#' # gp_encrypt = gp %>%
#' #   select(-c(name, address1, address2, address3)) %>%
#' #   encrypt(postcode, telephone)
#'
#' # For CRAN and testing:
#' library(dplyr)
#' temp_dir = tempdir()
#' genkeys(file.path(temp_dir, "id_rsa2")) # temp directory for testing only
#' gp_encrypt = gp %>%
#'   select(-c(name, address1, address2, address3)) %>%
#'   encrypt(postcode, telephone, public_key_path = file.path(temp_dir, "id_rsa2.pub"))
encrypt <- function(.data, ..., public_key_path = "id_rsa.pub",
                    lookup = FALSE, lookup_name = "lookup", write_lookup = TRUE){

  if(!file.exists(public_key_path)) {
    stop("Public key cannot be found.")
  }

  if(!lookup & write_lookup){
    message("Lookup file can only be written if 'lookup = TRUE'")
  }

  # Check for .csv file and don't overwrite
  if(lookup & write_lookup){
    lookup_file_name <- paste0(lookup_name, ".csv")
    if(file.exists(lookup_file_name)) {
      stop("Lookup file with this name already exists. Delete or choose a new name.")
    }
  }

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
    do.call(assign_to_global, list(key = rlang::quo_name(rlang::enquo(lookup_name)), val = df.lookup, pos = 1L))
    cat("Lookup table object created with name '", lookup_name, "'\n", sep = "")

    if(lookup & write_lookup){
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
