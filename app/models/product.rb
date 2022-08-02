class Product < ApplicationRecord
  DISTRIBUTOR = [["", "Поставщик"], ["Maytoni", "Maytoni"], ["Mantra", "Mantra"], ["Lightstar", "Lightstar"], ["Ledron", "Ledron"], ["Swg", "Swg"], ["Elevel", "Elevel"], ["Isonex", "Isonex"], ["Loftit", "Loftit"], ["Favourite", "Favourite"], ["Kinklight", "Kinklight"]]
  DEACTIVATED = [["", "Статус deactivated"], [true, "deactivated"], [false, "activated"]]
  INSALESID = [["", "Статус InSales ID"], [true, "связанные"], [false, "несвязанные"]]
  STATUS_DISTRIBUTOR = [["", "Статус у поставщика"], [true, "true"], [false, "false"]]

  # scope :elevel_for_insales, -> { where(distributor: "Elevel", deactivated: false, insales_var_id: nil).order(:id) }
  scope :distributor_for_insales,
        ->(date) { where(distributor: date[:distributor], deactivated: false, insales_var_id: nil).order(:id) }

  scope :product_all_size, -> { order(:id).size }
  scope :product_qt_not_null, -> { where('quantity > 0') }
  scope :product_qt_not_null_size, -> { where('quantity > 0').size }
  scope :product_cat, -> { order('cat DESC').select(:cat).uniq }
  scope :product_image_nil, -> { where(image: [nil, '']).order(:id) }
end
