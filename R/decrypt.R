#' Decrypt ciphertext using an RSA public/private key
#'
#' Not usually called directly. Password for private key required.
#'
#' @param .data A vector of ciphertexts created using \code{\link{encrypt}}.
#' @param private_key_path Character. A quoted path to an RSA private key
#'   created using \code{\link{genkeys}}.
#'
#' @return A character vector.
#' @importFrom purrr map_chr
#' @importFrom dplyr right_join
#' @export
#'
#' @examples
#' \dontrun{
#' hospital_number = c("1010761111", "2010761212")
#' genkeys(file.path(tempdir(), "id_rsa") # temp directory for testing only
#' hospital_number_encrypted = encrypt_char(hospital_number)
#' decrypt_vec(hospital_number_encrypted)
#' }
decrypt_vec <- function(.data, private_key_path = "id_rsa"){
  .data %>%
    map(hex2raw) %>%
    map(openssl::rsa_decrypt, openssl::read_key(private_key_path)) %>%
    map_chr(rawToChar)
}

#' Decrypt a data frame or tibble column using an RSA public/private key
#'
#' @param .data A data frame or tibble.
#' @param ... The unquoted names of columns to decrypt.
#' @param private_key_path Character. A quoted path to an RSA private key
#'   created using \code{\link{genkeys}}.
#' @param lookup_object An unquote name of a lookup object in the current
#'   environment created using \code{link{encrypt}}.
#' @param lookup_path Character. A quoted path to an RSA private key
#'   created using \code{\link{encrypt}}.
#'
#' @return The original dataframe or tibble with the specified columns
#'   decrypted.
#' @export
#' @examples
#' #' This will run:
#' # genkeys()
#' # gp_encrypt = gp %>%
#' #   select(-c(name, address1, address2, address3)) %>%
#' #   encrypt(postcode, telephone)
#' # gp_encrypt %>%
#' #   decrypt(postcode, telephone)
#'
#' \dontrun{
#' # For CRAN and testing:
#' library(dplyr)
#' temp_dir = tempdir()
#' genkeys(file.path(temp_dir, "id_rsa")) # temp directory for testing only
#' gp_encrypt = gp %>%
#'   select(-c(name, address1, address2, address3)) %>%
#'   encrypt(postcode, telephone, public_key_path = file.path(temp_dir, "id_rsa.pub"))
#'   gp_encrypt %>%
#'   decrypt(postcode, telephone, private_key_path = file.path(temp_dir, "id_rsa"))
#'   }
decrypt <- function(.data, ..., private_key_path = "id_rsa",
                    lookup_object = NULL,
                    lookup_path = NULL){
  .cols <- rlang::enquos(...)

  if(!file.exists(private_key_path)) {
    stop("Private key cannot be found.")
  }

  if(is.null(lookup_object) && is.null(lookup_path)){
    .data %>%
      mutate_at(dplyr::vars(!!! .cols), decrypt_vec, private_key_path)

  } else if(!is.null(lookup_object)) {
    lookup_object %>%
      right_join(.data, by = "key") %>%
      mutate_at(vars(!!! .cols), decrypt_vec, private_key_path) %>%
      select(-key)
  } else if(!is.null(lookup_path)){
    readr::read_csv(lookup_path, col_types = readr::cols()) %>%
      right_join(.data, by = "key") %>%
      mutate_at(vars(!!! .cols), decrypt_vec, private_key_path) %>%
      select(-key)
  }
}
