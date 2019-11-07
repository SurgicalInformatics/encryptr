#' Encrypt a file
#'
#' Encryption and decryption with asymmetric keys is computationally expensive.
#' This is how \code{\link{encrypt}} works, in order to allow each piece of data
#' in a data frame to be decrypted without compromise of the whole data frame.
#' This works on the presumption that each cell contains less than 245 bytes of
#' data.
#'
#' File encryption requires a different approach as files are often larger in
#' size. This function encrypts a file using a a symmetric "session" key and the
#' AES-256 cipher. This key is itself then encrypted using a public key
#' generated using \code{\link{genkeys}}. In OpenSSL this combination is
#' referred to as an envelope.
#'
#' @param .path Quoted path to file to encrypt.
#' @param crypt_file_name Optional new name to give encrypted file. Must end with ".encryptr.bin".
#' @param public_key_path Quoted path to public key, created with
#'   \code{\link{genkeys}}.
#'
#' @return The encrypted file is saved.
#' @export
#'
#' @examples
#' # This will run:
#' # Create example file to encrypt
#' # write.csv(gp, "gp.csv")
#' # genkeys()
#' # encrypt_file("gp.csv")
#'
#' # For CRAN and testing:
#' \dontrun{
#' # Run only once in decrypt_file example
#' temp_dir = tempdir() # temp directory for testing only
#' genkeys(file.path(temp_dir, "id_rsa"))
#' write.csv(gp, file.path(temp_dir, "gp.csv"))
#' encrypt_file(file.path(temp_dir, "gp.csv"), public_key_path = file.path(temp_dir, "id_rsa.pub"))
#' }
encrypt_file <- function(.path, crypt_file_name = NULL, public_key_path = "id_rsa.pub") {
  if (!file.exists(.path)) {
    stop("File for encryption cannot be found.")
  }

  # The following doesn't work with URL
  # if (!file.exists(public_key_path)) {
  #   stop("Public key cannot be found. \n  Should be created with encryptr::genkeys")
  # }

  if(is.null(crypt_file_name)){
    .crypt_file = paste0(.path, ".encryptr.bin")
  } else {
    .crypt_file = crypt_file_name
    if (!grepl(".encryptr.bin$", .crypt_file)){
      stop("Encrypted file has incorrect name. \n  Should be created with encryptr::encrypt_file and end with '.encryptr.bin'")
    }
  }

  if (file.exists(.crypt_file)) {
    stop("Encrypted file with this name already exists. Delete or choose a new name.")
  }

  # Encrypt
  openssl::encrypt_envelope(.path, public_key_path) %>%
    saveRDS(file = .crypt_file)

  if (file.exists(.crypt_file)){
    cat("Encrypted file written with name '",
        .crypt_file, "'\n", sep = "")
  }
}


