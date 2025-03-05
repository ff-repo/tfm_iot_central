# frozen_string_literal: true

module CryptHelper
  # return encoded base64
  def encrypt(plain_msg, key, iv)
    cipher = OpenSSL::Cipher.new('aes-256-gcm')
    cipher.encrypt
    cipher.iv = base64_to_escaped_hex(iv)
    cipher.key = base64_to_escaped_hex(key)

    ciphertext = cipher.update(plain_msg) + cipher.final
    tag = cipher.auth_tag

    { ciphertext: escaped_hex_to_base64(ciphertext), tag: escaped_hex_to_base64(tag) }
  end

  # return string and receive encoded base64
  def decrypt(cipher_msg, tag, key, iv)
    cipher = OpenSSL::Cipher.new('aes-256-gcm')
    cipher.decrypt
    cipher.iv = base64_to_escaped_hex(iv)
    cipher.key = base64_to_escaped_hex(key)
    cipher.auth_tag = base64_to_escaped_hex(tag)

    cipher.update(base64_to_escaped_hex(cipher_msg)) + cipher.final
  end

  def base64_to_escaped_hex(b_64_string)
    Base64.strict_decode64(b_64_string)
  end

  def escaped_hex_to_base64(escaped_hex)
    Base64.strict_encode64(escaped_hex)
  end

  def generate_key_iv
    {
      key: escaped_hex_to_base64(SecureRandom.random_bytes(32)),
      iv: escaped_hex_to_base64(SecureRandom.random_bytes(12))
    }
  end
end
