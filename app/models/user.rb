class User < ApplicationRecord
  has_secure_password

  def self.from_omniauth(auth)
    where(provider: auth.provider, uid: auth.uid).first_or_initialize.tap do |user|
      user.email = auth.info.email
      user.uid = auth.uid
      user.password = User.friendly_token(20)
      user.provider = auth.provider
      user.avatar = auth.info.image
      user.username = auth.info.name
      user.oauth_token = auth.credentials.token
      user.save!
    end
  end

  def self.friendly_token(length = 20)
    # To calculate real characters, we must perform this operation.
    # See SecureRandom.urlsafe_base64
    rlength = (length * 3) / 4
    SecureRandom.urlsafe_base64(rlength).tr('lIO0', 'sxyz')
  end
end
