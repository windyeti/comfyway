class Services::GettingProductDistributer::IsonexCreate
  extend Utils

  def self.call(file_path, _extend_file)
    puts '=====>>>> СТАРТ Isonex XLS '+Time.now.to_s

    file = File.open(file_path)
    xlsx = open_spreadsheet(file)

    rows = []
    xlsx.sheets.each do |sheet_name|
      sheet = xlsx.sheet(sheet_name)
      p headers = sheet.row(1)

      last_row = sheet.last_row

      (2..last_row).each do |i|
        rows << headers.zip(sheet.row(i))
      end
    end
    p rows
    p "====>>> Isonex все продукты импортировались"

    param_name = Services::CompareParams.new("Isonex")

    rows.each do |row|
      pp hash_arr_params = hash_params(row, param_name)

      # params = product_params(hash_arr_params)
      #
      # images = hash_arr_params["Изображения товаров"].reject(&:nil?)
      # images = images.select {|photo| RestClient.get(photo) rescue nil }

      data = {
    #     fid: hash_arr_params["ID артикула"].join(", ") + "___ledron",
    #     title: hash_arr_params["Наименование"].join(", "),
    #     url: "https://ledron.ru/product/" + hash_arr_params["Ссылка на витрину"].join(", "),
    #     sku: hash_arr_params["Артикул"].join(", ") + " " + "(#{hash_arr_params["ID артикула"].join(", ")})",
    #     desc: hash_arr_params["Краткое описание"].join("<br>"),
    #     distributor: "Ledron",
    #     quantity: nil,
    #     image: images.join(" "),
    #     video: hash_arr_params["Адрес видео на YouTube или Vimeo"].join(", "),
    #     cat: "Ledron",
    #     cat1: hash_arr_params["Категория"].join(", "),
    #     price: hash_arr_params["Цена"].join(", ").present? ? hash_arr_params["Цена"].join(", ") : 0,
    #     purchase_price: hash_arr_params["Закупочная цена"].join(", ").present? ? hash_arr_params["Закупочная цена"].join(", ") : 0,
    #     currency: hash_arr_params["Валюта"].join(", "),
    #     mtitle: hash_arr_params["Заголовок"].present? ? hash_arr_params["Заголовок"].join(", ") : nil,
    #     mkeywords: hash_arr_params["META Keywords"].present? ? hash_arr_params["META Keywords"].join(", ") : nil,
    #     mdesc: hash_arr_params["META Description"].present? ? hash_arr_params["META Description"].join(", ") : nil,
    #     p1: params.reject(&:nil?).join(" --- "),
    #     weight: hash_arr_params["Вес нетто, кг"] ? hash_arr_params["Вес нетто, кг"].join("") : nil,
        check: true
      }

      # product = Product.find_by(fid: data[:fid])
      # product ? product.update(data) : Product.create(data)
      puts "ok"
    end
    # puts '=====>>>> FINISH Isonex XLS '+Time.now.to_s
  end

  # def self.product_params(hash_arr_params)
  #   arr_exclude_key = ["Артикул","Тип строки", "Наименование", "Код артикула", "Валюта", "Цена", "Доступен для заказа",
  #                      "Изображения товаров", "Доступен для заказа", "ID артикула",
  #                      "Закупочная цена", "В наличии", "Идентификатор 1С", "status", "ID товара", "Адрес видео на YouTube или Vimeo",
  #                      "Товар: Идентификатор 1С", "Категория", "META Keywords", "META Description", "Заголовок", "Ссылка на витрину",
  #                      "Остаток", "Краткое описание"]
  #   result = hash_arr_params.map do |key, value|
  #     value = value.reject(&:nil?).join(", ")
  #     next if arr_exclude_key.include?(key) || value == ""
  #     value = value
  #               .gsub(/true/, "Да").gsub(/false/, "Нет")
  #               .gsub(/:/, "&#58;")
  #               .gsub(/-{3}/, "&#8722;&#8722;&#8722;")
  #               .gsub(/\s{2,}/, " ")
  #               .gsub(/<br \/>|<br>|{|}|<|>/, "")
  #     value = replace_semi_to_dot(name, value)
  #     "#{key.gsub("/","&#47;")}: #{value}" if value.present?
  #   end.compact
  #   result << "Поставщик: Ledron"
  #   result
  # end

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
