class CreateSpreeFuturepayCheckouts < ActiveRecord::Migration
  def self.up
    create_table :spree_futurepay_checkouts do |t|
      t.string  :transaction_id
      t.string  :code
      t.float   :total
      t.timestamps
    end
  end
  
  def self.down
    drop_table :spree_futurepay_checkouts
  end
end
