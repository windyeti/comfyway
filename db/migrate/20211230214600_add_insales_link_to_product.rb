class AddInsalesLinkToProduct < ActiveRecord::Migration[5.2]
  def change
    add_column :products, :insales_link, :string
    add_column :products, :insales_images, :string
  end
end
