class User < ApplicationRecord
  has_secure_password
  def self.from_omniauth(auth)
    where(provider: auth[:provider], uid: auth[:id]).first_or_initialize.tap do |user|
      user.email = auth[:email]
      user.uid = auth[:id]
      user.password = User.friendly_token(20)
      user.provider = auth[:provider]
      user.avatar = auth[:profilePicURL]
      user.username = auth[:name]
      user.oauth_token = auth[:accessToken]
      user.save!
    end
  end

  def self.friendly_token(length = 20)
    rlength = (length * 3) / 4
    SecureRandom.urlsafe_base64(rlength).tr('lIO0', 'sxyz')
  end
end
