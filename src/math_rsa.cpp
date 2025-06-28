#include "math.h"
#include <openssl/pem.h>
#include <openssl/rsa.h>
#include <openssl/err.h>
#include <cstring>

int rsa_encrypt(const char* plaintext, int plaintext_len, const char* pubkey_pem, unsigned char* ciphertext, int ciphertext_bufsize) {
    BIO* bio = BIO_new_mem_buf(pubkey_pem, -1);
    if (!bio) return -1;
    RSA* rsa = PEM_read_bio_RSA_PUBKEY(bio, NULL, NULL, NULL);
    BIO_free(bio);
    if (!rsa) return -1;

    int result = RSA_public_encrypt(plaintext_len, (const unsigned char*)plaintext, ciphertext, rsa, RSA_PKCS1_PADDING);
    RSA_free(rsa);
    if (result > ciphertext_bufsize) return -1;
    return result;
}

int rsa_decrypt(const unsigned char* ciphertext, int ciphertext_len, const char* prikey_pem, char* plaintext, int plaintext_bufsize) {
    BIO* bio = BIO_new_mem_buf(prikey_pem, -1);
    if (!bio) return -1;
    RSA* rsa = PEM_read_bio_RSAPrivateKey(bio, NULL, NULL, NULL);
    BIO_free(bio);
    if (!rsa) return -1;

    int result = RSA_private_decrypt(ciphertext_len, ciphertext, (unsigned char*)plaintext, rsa, RSA_PKCS1_PADDING);
    RSA_free(rsa);
    if (result > plaintext_bufsize) return -1;
    return result;
}