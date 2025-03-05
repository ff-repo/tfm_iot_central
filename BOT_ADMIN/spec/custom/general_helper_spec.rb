require 'rails_helper'

RSpec.describe "General Test", type: :helper do
  include OsHelper
  include CryptHelper
  include OfuscateHelper

  it "tests any helper method dynamically" do
    information = host_info.to_s
    result = encrypt(information)
    image = result[:ciphertext]
    url = ofuscate_image_link(result[:tag])

    payload = {
      name: 'hello_encrypted',
      image: image,
      url: url
    }

    expect(decrypt(payload[:image], unofuscate_image_link(payload[:url]))).to eq(information)
  end
end
