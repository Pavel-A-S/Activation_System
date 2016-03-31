class CreateTokens < ActiveRecord::Migration
  def change
    create_table :tokens do |t|
      t.string :activation_token
      t.string :activation_status
      t.datetime :activation_request_at
      t.datetime :activated_at
      t.string :name
      t.string :MAC
      t.text :body
      t.integer :user_id
      t.boolean :sended, default: false

      t.timestamps null: false
    end
  end
end
