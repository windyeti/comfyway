# class Services::XlsSelected
#   PRODUCT_STRUCTURE = {
#     fid: 'Параметр: fid',
#     sku: 'Артикул',
#     title: 'Название товара',
#     desc: 'Полное описание',
#     sdesc: 'Краткое описание',
#     price: 'Цена продажи',
#     purchase_price: 'Цена закупки',
#     oldprice: 'Старая цена',
#     quantity: 'Остаток',
#     image: 'Изображения',
#     unit: 'Единица измерения',
#     distributor: 'Дополнительное поле: Поставщик',
#     vendor: 'Дополнительное поле: Производитель',
#     manual: 'Дополнительное поле: Инструкция',
#     manuals: 'Дополнительное поле: Инструкции',
#     preview_3d: 'Дополнительное поле: 3D preview',
#     foto: 'Дополнительное поле: Фото',
#     draft: 'Дополнительное поле: Чертёж',
#     model_3d: 'Дополнительное поле: 3D-модель',
#     date_arrival: 'Дополнительное поле: Ожидается',
#     quantity_add: 'Дополнительное поле: Склад',
#     video: 'Ссылка на видео',
#     url: 'Параметр: OLDLINK',
#     barcode: 'Штрих-код',
#     weight: 'Вес',
#     currency: 'Валюта склада',
#     cat: 'Корневая',
#     cat1: 'Подкатегория 1',
#     cat2: 'Подкатегория 2',
#     cat3: 'Подкатегория 3',
#     cat4: 'Подкатегория 4',
#     mtitle: 'Тег title',
#     mdesc: 'Мета-тег description',
#     mkeywords: 'Мета-тег keywords',
#   }.freeze
#
#   def initialize(ids)
#     @file_path_prep = "#{Rails.public_path}/product_selected_prep.csv"
#     @file_path_prep_xls = "#{Rails.public_path}/product_selected_prep_xls.xls"
#     @file_name_output = "#{Rails.public_path}/product_selected_output.xls"
#
#     @tovs = Product.where(id: ids).order(:id)
#   end
#
#   def call
#
#     # прервать если выбрано Ноль товаров
#     return false if @tovs.empty?
#
#     check_previous_files_csv
#
#     create_csv_prep(PRODUCT_STRUCTURE)
#
#     additions_headers = get_additions_headers
#
#     product_hashs = get_product_hashs
#
#     all_column_names = add_column_names(product_hashs, additions_headers)
#
#     xls_with_full_headers(product_hashs, all_column_names)
#
#     create_xls_output
#
#     delete_temple_files_csv
#   end
#
#
#   private
#
#   def check_previous_files_csv
#     FileUtils.rm_rf(Dir.glob(@file_path_prep))
#     FileUtils.rm_rf(Dir.glob(@file_path_prep_xls))
#     FileUtils.rm_rf(Dir.glob(@file_name_output))
#   end
#
#   def delete_temple_files_csv
#     FileUtils.rm_rf(Dir.glob(@file_path_prep))
#     FileUtils.rm_rf(Dir.glob(@file_path_prep_xls))
#   end
#
#   def create_csv_prep(product_hash_structure)
#     CSV.open(@file_path_prep, 'w') do |writer|
#       writer << product_hash_structure.values
#
#       @tovs.each do |tov|
#         product_properties = product_hash_structure.keys
#         product_properties_amount = product_properties.map do |property|
#           tov.send(property)
#         end
#         writer << product_properties_amount
#       end
#     end
#   end
#
#   def get_additions_headers
#     result = []
#     p = @tovs.select(:p1)
#     p.each do |p|
#       if p.p1 != nil
#         p.p1.split(' --- ').each do |pa|
#           result << pa.split(':')[0].strip if pa != nil
#         end
#       end
#     end
#     result.uniq
#   end
#
#   def get_product_hashs
#     CSV.read(@file_path_prep, headers: true).map do |product|
#       product.to_hash
#     end
#   end
#
#   def add_column_names(product_hashs, addHeaders)
#     result = []
#     column_names = product_hashs.first.keys
#     result += column_names
#     addHeaders.each do |addH|
#       additional_column_names = ['Параметр: '+addH]
#       result += additional_column_names
#     end
#     result
#   end
#
#   def xls_with_full_headers(product_hashs, all_column_names)
#     book = Spreadsheet::Workbook.new
#
#     sheet = book.create_worksheet(name: "Prep")
#     sheet.row(0).push(*all_column_names)
#
#     product_hashs.each.with_index(1) do |product_hash, index|
#       sheet.row(index).push(*product_hash.values)
#     end
#     book.write @file_path_prep_xls
#   end
#
#   def create_xls_output
#     book_prep = Spreadsheet.open(@file_path_prep_xls)
#     sheet_prep = book_prep.worksheet("Prep")
#     headers = sheet_prep.row(0)
#
#     rows_hash = []
#     sheet_prep.each_with_index do |row, index|
#       next if index == 0
#       rows_hash << Hash[headers.zip(row)]
#     end
#
#     book_output = Spreadsheet::Workbook.new
#
#     sheet_output = book_output.create_worksheet(name: "Output")
#     sheet_output.row(0).push(*headers)
#
#     rows_hash.each.with_index(1) do |hash, index|
#       fid = hash["Параметр: fid"]
#       product = Product.find_by_fid(fid)
#       if product.p1.present?
#         product.p1.split('---').each do |param|
#           key = 'Параметр: '+param.split(':')[0].strip
#           value = param.split(':')[1] if param.split(':')[1] != nil
#           hash[key] = value
#         end
#       end
#       sheet_output.row(index).push(*hash.values)
#     end
#     book_output.write @file_name_output
#   end
# end
