class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :lockable, :timeoutable, :validatable

  has_one :api_token, as: :entity
end
