#' Create and write RSA private and public keys
#'
#' The first step for the \code{encryptr} workflow is to create a pair of
#' encryption keys. This uses the \code{\link{openssl}} package. The public key
#' is used to encrypt information and can be shared. The private key allows
#' decryption of the encrypted information. It requires a password to be set.
#' This password cannot be recovered if lost. If the file is lost or
#' overwritten, any data encrypted with the public key cannot be decrypted.
#' @param private_key_name Character string. Do not change default unless good
#'   reason.
#' @param public_key_name Character string. Do not change default unless good
#'   reason.
#'
#' @return Two files containing the public key and encrypted private key are
#'   written to the working directory.
#' @export
#'
#' @seealso encrypt decrypt
#'
#' @examples
#' genkeys()
genkeys <- function(private_key_name = "id_rsa",
                    public_key_name = paste0(private_key_name, ".pub")){
  if(file.exists(private_key_name)){
    stop("Private key file with this name already exists. Delete it or change file name.")
  }
  if(file.exists(public_key_name)){
    stop("Public key file with this name already exists. Delete it or change file name.")
  }

  key <- openssl::rsa_keygen()
  pubkey <- as.list(key)$pubkey

  openssl::write_pem(key,
                     private_key_name,
                     password = openssl::askpass(prompt = "Please choose a password for your private key.
                                                 This password CANNOT be recovered if lost.
                                                 Please store the password in a safe location."))
  openssl::write_pem(pubkey, public_key_name)
}
