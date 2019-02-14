#' Decrypt ciphertext using an RSA public/private key
#'
#' Not usually called directly. Password for private key required.
#'
#' @param .data A vector of ciphertexts created using \code{\link{encrypt}}.
#' @param private_key_path Character. A quoted path to an RSA private key
#'   created using \code{\link{write_keys}}.
#'
#' @return A character vector.
#' @importFrom purrr map_chr
#' @importFrom dplyr right_join
#' @export
#'
#' @examples
#' \dontrun{
#' hospital_number = c("1010761111", "2010761212")
#' write_keys()
#' hospital_number_encrypted = encrypt_char(hospital_number)
#' decrypt_char(hospital_number_encrypted)
#' }
decrypt_char <- function(.data, private_key_path = "id_rsa"){
  .data %>%
    map(hex2raw) %>%
    map(openssl::rsa_decrypt, openssl::read_key(private_key_path)) %>%
    map_chr(rawToChar)
}

#' Decrypt a dataframe or tibble column using an RSA public/private key
#'
#' @param .data A dataframe or tibble.
#' @param ... The unquoted names of columns to decrypt.
#' @param private_key_path Character. A quoted path to an RSA private key
#'   created using \code{\link{write_keys}}.
#' @param lookup_object An unquote name of a lookup object in the current
#'   environment created using \code{link{encrypt}}.
#' @param lookup_path Character. A quoted path to an RSA private key
#'   created using \code{\link{write_keys}}.
#'
#' @return The original dataframe or tibble with the specified columns
#'   decrypted.
#' @export
#'
decrypt <- function(.data, ..., private_key_path = "id_rsa",
                    lookup_object = NULL,
                    lookup_path = NULL){
  .cols <- rlang::enquos(...)

  if(is.null(lookup_object) && is.null(lookup_path)){
    .data %>%
      mutate_at(dplyr::vars(!!! .cols), decrypt_char, private_key_path)

  } else if(!is.null(lookup_object)) {
    lookup_object %>%
      right_join(.data, by = "key") %>%
      mutate_at(vars(!!! .cols), decrypt_char, private_key_path) %>%
      select(-key)
  } else if(!is.null(lookup_path)){
    readr::read_csv(lookup_path, col_types = readr::cols()) %>%
      right_join(.data, by = "key") %>%
      mutate_at(vars(!!! .cols), decrypt_char, private_key_path) %>%
      select(-key)
  }
}
