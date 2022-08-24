class Services::GettingProductDistributer::Stluce
  extend Utils

  def self.call
    puts '=====>>>> СТАРТ St Luce Xlsx '+Time.now.to_s

    Product.where(distributor: "Stluce").each {|tov| tov.update(quantity: 0, check: false)}

    uri = "https://stluce.ru/upload/1c/ostatki.xlsx"
    file_path = 'public/stluce/ostatki.xlsx'

    FileUtils.rm_rf(Dir.glob(file_path))

    File.open("#{Rails.root.join(*file_path.split("/"))}", 'w') {|f|
      block = proc { |response|
        f.write response.body.force_encoding('UTF-8')
      }
      RestClient::Request.new(method: :get, url: uri, block_response: block).execute
    }

    file = File.open(file_path)
    xlsx = open_spreadsheet(file)

    rows = []
    xlsx.sheets.each do |sheet_name|
      sheet = xlsx.sheet(sheet_name)

      first_row = sheet.row(1)
      second_row = sheet.row(2)

      first_row_test = ["Бренд", "Артикул", "Товарная группа", "Наименование", "Код ТНВЭД", "МРЦ", "SvetResurs склад", "Основной склад", "Склад Грибки", "Количество в Москве", "Суммарные остатки", "Дата поступления", "Количество поступления", "Ссылка на картинку", "Свойства товара", nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, "Габариты товара (мм)", nil, nil, nil, nil, "Упаковка", nil, nil, nil, nil, nil, nil]
      second_row_test = [nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, "Коллекция", "Стиль", "Тип светильника", "Количество ламп", "Тип ламп", "Мощность ламп, W", "Тип цоколя", "Цвет каркаса", "Цвет плафона", "Поверхность каркаса", "Поверхность плафона", "Материал каркаса", "Материал плафона", "Цветовая температура", "Лампы в комплекте", "Общая мощность", "Площадь освещения", "Наличие пульта", "Тип крепления", "Степень защиты", "Световой поток, Lm", nil, nil, nil, nil, nil, "Длина", "Ширина", "Высота", "Из двух коробок", "Вес (кг)", "Объем (м3)", "Штрихкод"]

      # если изменился файл, ничего не парсим
      raise if first_row != first_row_test || second_row != second_row_test

      headers = ["Бренд", "Артикул", "Товарная группа", "Наименование", "Код ТНВЭД", "МРЦ", "SvetResurs склад", "Основной склад", "Склад Грибки", "Количество в Москве", "Суммарные остатки", "Дата поступления", "Количество поступления", "Ссылка на картинку", "Коллекция", "Стиль", "Тип светильника", "Количество ламп", "Тип ламп", "Мощность ламп, W", "Тип цоколя", "Цвет каркаса", "Цвет плафона", "Поверхность каркаса", "Поверхность плафона", "Материал каркаса", "Материал плафона", "Цветовая температура", "Лампы в комплекте", "Общая мощность", "Площадь освещения", "Наличие пульта", "Тип крепления", "Степень защиты", "Световой поток, Lm", "Длина, мм", "Ширина, мм", "Высота, мм", "Диаметр, мм", "Максимальная высота, мм", "Длина", "Ширина", "Высота", "Из двух коробок", "Вес (кг)", "Объем (м3)", "Штрихкод"]

      last_row = sheet.last_row

      (3..last_row).each do |i|
        next if sheet.cell(i,"D").nil?
        arr_row = headers.zip(sheet.row(i))
        arr_row.each do |arr_prop|
          if ["Длина", "Ширина", "Высота"].include?(arr_prop[0]) && arr_prop[1].present?
            arr_prop[1] = arr_prop[1] * 1000
          end
        end
        rows << arr_row
      end
    end

    param_name = Services::CompareParams.new("Stluce")

    rows.each do |row|
      hash_arr_params = hash_params(row, param_name)

      params = product_params(hash_arr_params)
      sku = hash_arr_params["Артикул"] ? hash_arr_params["Артикул"].join(", ") : nil

      data = {
        fid: "#{sku}___stluce",
        title: hash_arr_params["Наименование"] ? hash_arr_params["Наименование"].join(", ") : nil,
        price: hash_arr_params["Цена"] ? hash_arr_params["Цена"].join(", ") : nil,
        йгфтешен: hash_arr_params["Остаток"] ? hash_arr_params["Остаток"].join(", ") : nil,
        url: nil,
        sku: sku,
        desc: nil,
        distributor: "Stluce",
        image: hash_arr_params["Изображения товаров"] ? hash_arr_params["Изображения товаров"].join(", ") : nil,
        vendor: hash_arr_params["Бренд"] ? hash_arr_params["Бренд"].join(", ") : nil,
        video: nil,
        barcode: hash_arr_params["Штрихкод"] ? hash_arr_params["Штрихкод"].join(", ") : nil,
        cat: "Stluce",
        cat1: hash_arr_params["Бренд"] ? hash_arr_params["Бренд"].join(", ") : nil,
        currency: nil,
        mtitle: nil,
        mkeywords: nil,
        mdesc: nil,
        p1: params.compact.join(" --- "),
        weight: hash_arr_params["Вес нетто, кг"] ? hash_arr_params["Вес нетто, кг"].join(", ") : nil,
      }

      product = Product.find_by(fid: data[:fid])
      product ? product.update(data) : Product.create(data)
      puts "ok"
    end
  end

  def self.product_params(hash_arr_params)
    arr_exclude_key = ["Артикул", "Наименование", "Цена", "Остаток", "Ссылка на картинку", "Штрихкод"]
    result = hash_arr_params.map do |key, value|
      value = value.reject(&:nil?).join(", ")
      next if arr_exclude_key.include?(key) || value == ""
      value = value.gsub(/:/, "&#58;")
      value = replace_semi_to_dot(key, value)
      "#{key.gsub("/","&#47;")}: #{value}" if value.present? && value != "-"
    end.compact
    result << "Поставщик: Stluce"
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
