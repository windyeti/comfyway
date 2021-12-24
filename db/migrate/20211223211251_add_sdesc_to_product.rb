class AddSdescToProduct < ActiveRecord::Migration[5.2]
  def change
    add_column :products, :sdesc, :string
    add_column :products, :quantity_add, :integer
  end
end
