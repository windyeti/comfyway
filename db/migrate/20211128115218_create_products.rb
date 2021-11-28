class CreateProducts < ActiveRecord::Migration[5.2]
  def change
    create_table :products do |t|
      t.string :fid
      t.string :title
      t.string :url
      t.string :sku
      t.string :distributor
      t.string :image
      t.string :cat
      t.string :cat1
      t.decimal :price
      t.integer :quantity
      t.string :p1
      t.string :desc
      t.bigint :insales_id
      t.bigint :insales_var_id
      t.boolean :check, default: true
      t.string :barcode
      t.string :cat2
      t.string :cat3
      t.string :cat4
      t.string :cat5
      t.string :video
      t.string :currency
      t.string :mtitle
      t.string :mdesc
      t.string :mkeywords
      t.string :vendor
      t.string :manual
      t.string :preview_3d
      t.string :foto
      t.string :draft
      t.string :model_3d
      t.string :manuals
      t.string :date_arrival
      t.timestamps
    end
  end
end
