# frozen_string_literal: true

module OffuscateHelper
  def ofuscate_image_link(content, uri, resource)
    safe_content = URI.encode_www_form_component(content)
    "#{uri}/images/#{resource}/#{safe_content}.jpg"
  end

  def facade_image_link(uri, resource)
    length = 30 + SecureRandom.random_number(41) # Generate a random int from 30 to 70 (inclusive)
    content = Base64.strict_encode64(SecureRandom.random_bytes(length))
    safe_content = URI.encode_www_form_component(content)
    "#{uri}/images/#{resource}/#{safe_content}.png"
  end

  def unofuscate_image_link(offuscated_content, resource)
    safe_content = offuscated_content.split("#{resource}/").last.split('.jpg').first
    URI.decode_www_form_component(safe_content)
  end
end