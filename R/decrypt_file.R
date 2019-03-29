#' Decrypt a file
#'
#' See \code{\link{encrypt_file}} for details.
#'
#' @param .path Quoted path to file to encrypt.
#' @param file_name Optional new name for unencrypted file.
#' @param private_key_path Quoted path to private key, created with
#'   \code{\link{genkeys}}.
#'
#' @return The decrypted file is saved.
#' @export
#'
#' @examples
#' # This will run:
#' # Create example file to encrypt
#' # write.csv(gp, "gp.csv")
#' # genkeys()
#' # encrypt_file("gp.csv")
#' # decrypt_file("gp.csv.encryptr.bin", file_name = "gp2.csv")
#'
#' # For CRAN and testing:
#' temp_dir = tempdir() # temp directory for testing only
#' genkeys(file.path(temp_dir, "id_rsa4"))
#' write.csv(gp, file.path(temp_dir, "gp.csv"))
#' encrypt_file(file.path(temp_dir, "gp.csv"), public_key_path = file.path(temp_dir, "id_rsa4.pub"))
#' decrypt_file(file.path(temp_dir, "gp.csv.encryptr.bin"),
#'   private_key_path = file.path(temp_dir, "id_rsa4"),
#'   file_name = "file.path(temp_dir, gp2.csv)")
decrypt_file <- function(.path, file_name = NULL, private_key_path = "id_rsa") {
  if (!file.exists(.path)) {
    stop("Encrypted file cannot be found.")
  }

  if(!file.exists(private_key_path)) {
    stop("Private key cannot be found.")
  }

  if (!grepl(".encryptr.bin$", .path)){
    stop("Encrypted file has incorrect name. \n  Should be created with encryptr::encrypt_file and end with '.encryptr.bin'")
  }

  if(is.null(file_name)){
    .file = gsub(".encryptr.bin", "", .path)
  } else {
    .file = file_name
  }
  if (file.exists(.file)) {
    stop("Unencrtyped file with same name exists at this location. \n  Move or choose new name (file_name) to avoid it being overwritten.")
  }

  .crypt = readRDS(.path)
  zz = file(.file, "wb")
  openssl::decrypt_envelope(.crypt$data, .crypt$iv, .crypt$session, key=private_key_path, password = openssl::askpass()) %>%
    writeBin(zz)
  close(zz)

  if (file.exists(.file)){
    cat("Decrypted file written with name '",
        .file, "'\n", sep = "")
  }
}
