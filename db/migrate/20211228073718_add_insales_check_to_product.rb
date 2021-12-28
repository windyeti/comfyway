class AddInsalesCheckToProduct < ActiveRecord::Migration[5.2]
  def change
    add_column :products, :insales_check, :boolean, default: false
    add_column :products, :deactivated, :boolean, default: false
  end
end
