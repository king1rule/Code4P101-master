class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
        devise :omniauthable, :omniauth_providers => [:google_oauth2]

  validates :name, presence: true, length: {maximum: 25}

  after_create :send_notification

  def send_notification
  	MyMailer.new_user(self).deliver

  end

  def self.find_for_google_oauth2(access_token, signed_in_resource=nil)
    data = access_token.info
    user = User.where(:provider => access_token.provider, :uid => access_token.uid).first

    if user
      return user
    else
      registered_user = User.where(:email => access_token.email).first
      if registered_user
          return registered_user
      else
          user = User.create(
          name: data["name"],
          provider: access_token.provider,
          email: data["email"],
          uid: access_token.uid,
          image: data["image"],
          password: Devise.friendly_token[0,20]
          )
            end
        end
    end
end
