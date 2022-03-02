class Services::Xls::Selected < Services::Xls::Base
  def initialize(ids)
    @file_path_prep = "#{Rails.public_path}/product_selected_prep.csv"
    @file_path_prep_xls = "#{Rails.public_path}/product_selected_prep_xls.xls"
    @file_name_output = "#{Rails.public_path}/product_selected_output.xls"

    @tovs = Product.where(id: ids).order(:id)
  end
end
