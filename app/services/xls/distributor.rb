class Services::Xls::Distributor < Services::Xls::Base
  def initialize(data)
    p data
    @file_path_prep = "#{Rails.public_path}/product_#{data[:distributor]}_prep.csv"
    @file_path_prep_xls = "#{Rails.public_path}/product_#{data[:distributor]}_prep_xls.xls"
    @file_name_output = "#{Rails.public_path}/product_#{data[:distributor]}_output.xls"

    @tovs = Product.distributor_for_insales(data)
    p @tovs.count
    @distributor_name = data[:distributor]
  end
end
