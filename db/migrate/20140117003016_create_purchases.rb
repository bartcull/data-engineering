class CreatePurchases < ActiveRecord::Migration
  def change
    create_table :purchases do |t|
      t.references :item, index: true
      t.references :customer, index: true
      t.decimal :price, scale: 2, precision: 8
      t.integer :item_count

      t.timestamps
    end
  end
end
