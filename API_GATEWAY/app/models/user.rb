class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :lockable, :timeoutable, :validatable, authentication_keys: [:username]

  validates :username, uniqueness: true
end
