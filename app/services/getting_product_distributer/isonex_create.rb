class Services::GettingProductDistributer::IsonexCreate
  extend Utils

  def self.call(file_path, _extend_file)
    puts '=====>>>> СТАРТ Isonex XLS '+Time.now.to_s

    file = File.open(file_path)
    xlsx = open_spreadsheet(file)

    rows = []
    xlsx.sheets.each do |sheet_name|
      sheet = xlsx.sheet(sheet_name)
      headers = sheet.row(1)
      last_row = sheet.last_row

      (2..last_row).each do |i|
      # p sheet.cell(i, "B")
        rows << headers.zip(sheet.row(i))
      end
    end

    param_name = Services::CompareParams.new("Isonex")
p rows.count
    rows.each do |row|
      hash_arr_params = hash_params(row, param_name)

      params = product_params(hash_arr_params)

      images = []
      images << find_cell(row, "Фото на сайте")
      images << find_cell(row, "Ссылка на схему товара")
      images << find_cell(row, "Ссылка на интерьерное фото")
      images << find_cell(row, "Ссылка на фото на цветном фоне_вкл")
      images << find_cell(row, "Ссылка на интерьерное фото_1")
      images << find_cell(row, "Ссылка на композицию")
      images << find_cell(row, "Ссылка на композицию_1")
      images << find_cell(row, "Ссылка на рендер 3D")
      images << find_cell(row, "Ссылка на фото на белом фоне_вкл")
      images << find_cell(row, "Ссылка на фото на цветном фоне_выкл")
      images << find_cell(row, "Ссылка на фото_доп ракурс")
      images << find_cell(row, "Ссылка на фрагмент")
      images << find_cell(row, "Ссылка на фрагмент_1")
      images << find_cell(row, "Ссылка на фрагмент_2")
      # images << find_cell(row, "Ссылка на 3D модель")

      p sku = remove_zero_end(hash_arr_params["Артикул"].join(", "))
      images = images.compact.join(" ") rescue nil
      p data = {
          fid: "#{sku}___isonex",
          title: hash_arr_params["Наименование"].join(", "),
          url: nil,
          sku: sku,
          desc: hash_arr_params["Краткое описание"] ? hash_arr_params["Краткое описание"].join("<br>") : nil,
          distributor: "Isonex",
          quantity: nil,
          image: images,
          vendor: hash_arr_params["Изготовитель"] ? hash_arr_params["Изготовитель"].join(", ") : nil,
          video: find_cell(row, "Ссылка на видеоконтент"),
          cat: "Isonex",
          cat1: hash_arr_params["Изготовитель"] ? hash_arr_params["Изготовитель"].join(", ") : nil,
          price: nil,
          purchase_price: nil,
          currency: nil,
          mtitle: nil,
          mkeywords: nil,
          mdesc: nil,
          p1: params.compact.join(" --- "),
          weight: hash_arr_params["Вес нетто, кг"] ? hash_arr_params["Вес нетто, кг"].join("") : nil,
      }

      product = Product.find_by(fid: data[:fid])
      product ? product.update(data) : Product.create(data)
      puts "ok"
    end
    puts '=====>>>> FINISH Isonex XLS '+Time.now.to_s
  end

  def self.remove_zero_end(str)
    str.remove(/\.0$/)
  end

  def self.find_cell(row, name)
    row.each do |arr|
      if arr[0] == name
        return arr[1]
      end
    end
  end

  def self.product_params(hash_arr_params)
    arr_exclude_key = ["Артикул", "Наименование", "Изготовитель", "Краткое описание", "Ссылка на видеоконтент", "Цена"]
    result = hash_arr_params.map do |key, value|
      value = value.reject(&:nil?).join(", ")
      next if arr_exclude_key.include?(key) || value == ""
      value = value.gsub(/:/, "&#58;")
      value = replace_semi_to_dot(key, value)
      "#{key.gsub("/","&#47;")}: #{value}" if value.present?
    end.compact
    result << "Поставщик: Isonex"
    result << "Статус у поставщика: true"
    result
  end

  def self.hash_params(row, param_name)
    new_arr_arr_params = []
    row.map do |arr|
      common_name_param = param_name.compare(arr[0])
      new_arr_arr_params << [common_name_param, arr[1]] if common_name_param.present?
    end.compact
    Hash[ new_arr_arr_params.group_by(&:first).map{ |k,a| [k,a.map(&:last).uniq] } ]
  end

  def self.open_spreadsheet(file)
    case File.extname(file)
    when ".csv" then Roo::CSV.new(file.path) #csv_options: {col_sep: ";",encoding: "windows-1251:utf-8"})
    when ".xls" then Roo::Excel.new(file.path)
    when ".xlsx" then Roo::Spreadsheet.open(file.path, extension: :xlsx)
      # when ".xlsx" then Roo::Excelx.new(file.path, extension: :xlsx)
    when ".XLS" then Roo::Excel.new(file.path)
    else raise "Unknown file type: #{File.extname(file)}"
    end
  end
end
