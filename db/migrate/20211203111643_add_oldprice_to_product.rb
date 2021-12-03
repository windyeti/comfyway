class AddOldpriceToProduct < ActiveRecord::Migration[5.2]
  def change
    add_column :products, :purchase_price, :decimal
    add_column :products, :oldprice, :decimal
  end
end
