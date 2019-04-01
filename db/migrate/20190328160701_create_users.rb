
class CreateUsers < ActiveRecord::Migration[5.2]
  def change
    create_table :users do |t|
      t.string :first_name
      t.string :last_name
      t.string :provider
      t.string :uid
      t.string :password_digest
      t.string :bio
      t.string :avatar
      t.string :email
      t.string :username
      t.string :oauth_token

      t.timestamps
    end
  end
end
