#include <iostream>
#include <cstring>

#include "math.h"

// #include "parse_uid.h"
int main() {
    std::cout << "2 + 3 = " << add(2, 3) << std::endl;

    // ===== RSA 加解密测试 =====
    const char* pubkey_pem =R"(-----BEGIN PUBLIC KEY-----
MIGeMA0GCSqGSIb3DQEBAQUAA4GMADCBiAKBgEyJmP/4BJz2wzYShTQkKhFUD3EF
IMjNEWgdYN/wXH0/OrNh8sLEUaS50Zt9FJG9T52BhL6N/4G4qKE+4KMhUNeT0Cw0
Ny+kLX0G7a7t4xJum6eXRZP1de64FM2gT46GMnTpq+WsktfuQMvpOOSIaSoaQ0Q3
cKO939B8BnpKEc6PAgMBAAE=
-----END PUBLIC KEY-----)";
    const char* prikey_pem =R"(-----BEGIN RSA PRIVATE KEY-----
MIICWgIBAAKBgEyJmP/4BJz2wzYShTQkKhFUD3EFIMjNEWgdYN/wXH0/OrNh8sLE
UaS50Zt9FJG9T52BhL6N/4G4qKE+4KMhUNeT0Cw0Ny+kLX0G7a7t4xJum6eXRZP1
de64FM2gT46GMnTpq+WsktfuQMvpOOSIaSoaQ0Q3cKO939B8BnpKEc6PAgMBAAEC
gYA2C7v0lGh9hmqWlkFlblweXGODBYH/CX/PK1+rAontD2ceIH5SNlsInQZ8a7jI
qQu9RyY7gP351jGNm175Ep+ItV1v1LYWcecqEQMD6cMv9u4A3wyKEqM6YPK8MUrS
Dmo/KWl49SHsjn7JbsQU6/7+JdcOHwh8A5BA7sk/zYLbAQJBAI/+b+x9R7tFs1ws
xan9QChFUcRYvRBx1nniP4+LryOqzgHtPtAXdWgIZjeZxX+WCFwWRn/ZeWF+mAqw
TjmyLk8CQQCIEooM/XnOH2eN5M6vrEgAZ5LKGYTc3bLPp7kRxwHXULZt6L8kd78l
bcHbGgGMs/cFlZ6XkbSRFcwf5Yqs6IvBAkBpFSLy7/5wMY6SPu5FftbaTLQ+WRAo
txrxOeZuyF6Y5eaPS2bij6wTrsWB4Atcb85L/cmXNcs6Fhu4+S8tNdZLAkBGlbde
/a3NqqTBCkvc/PVsoE2Y4Jv3Jlm3Nj3eZukhlBDN+soMVMGm3MSOr3LWVhRxpSdb
YI3WJQR6F0xUXV0BAkARvAkWeI8sgeqCg/1M+Q8Hq7QT2vzrR8Ja/HYfQJNNVzVQ
7Y4G7uIMLDsiVPKDNBBRoIwE+sOq5CzwY0t36/j6
-----END RSA PRIVATE KEY-----)";
    const char* plaintext = "hello, rsa!";
    unsigned char ciphertext[256] = {0};
    char decrypted[256] = {0};

    int cipher_len = rsa_encrypt(plaintext, strlen(plaintext), pubkey_pem, ciphertext, sizeof(ciphertext));
    if (cipher_len > 0) {
        std::cout << "rsa_encrypt,ciphertext lenth: " << cipher_len << std::endl;
    } else {
        std::cout << "rsa_encrypt failed" << std::endl;
    }

    int plain_len = rsa_decrypt(ciphertext, cipher_len, prikey_pem, decrypted, sizeof(decrypted));
    if (plain_len > 0) {
        decrypted[plain_len] = '\0';
        std::cout << "rsa_decrypt,decrypted: " << decrypted << std::endl;
    } else {
        std::cout << "rsa_decrypt failed" << std::endl;
    }
    // ===== RSA 加解密测试结束 =====

    // // parse uid test
    // std::string cToken = "R9E5ponWRiYFr2vOQoyRBwZJoxJ-CKoVJFBvs00klmZTezT8phS6AADU0HbUGI74mH_rouzEBIE0wygEkatRiz8S_A23q6ICLbdTs6S953PJaPK-oA47pR8XX78LCUPpBIC5hVbetZf1R8b-tGK5nZhYK1zJd47-4ku1Yta8p74";
    // std::string uid = parse_uid(cToken);
    // std::cout << "uid: " << uid << std::endl;

    return 0;
}
