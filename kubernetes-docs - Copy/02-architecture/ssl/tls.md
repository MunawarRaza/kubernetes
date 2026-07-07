I create a root CA.
I sign server certificates with it.
I install root CA on user laptops.
nginx presents server certificate.
Browser validates server cert using trusted root.
If valid → secure connection.

👉 Keystore = who I am
👉 Truststore = who I trust