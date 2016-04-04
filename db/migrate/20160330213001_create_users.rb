class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :name
      t.string :email
      t.string :password_digest
      t.string :avatar
      t.string :access
      t.string :user_card
      t.string :activation_token
      t.string :activation_status
      t.datetime :activated_at
      t.datetime :last_login
      t.datetime :activation_request_at
      t.string :password_reset_token
      t.datetime :password_reset_requested_at

      t.timestamps null: false
    end
  end
end
