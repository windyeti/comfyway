class Services::GettingProductDistributer::Ledron
  def self.call(path_file, _extend_file)
    puts '=====>>>> СТАРТ Ledron SCV '+Time.now.to_s
    path_middle_csv = "#{Rails.public_path}/ledron/ledron_middle.csv"
    FileUtils.rm_rf(Dir.glob(path_middle_csv))
    Product.where(distributor: "Ledron").each {|tov| tov.update(quantity: nil, check: false)}

    csv_rows = CSV.read(path_file, headers: true, col_sep: ';', encoding: 'windows-1251:utf-8').map do |row|
      row
    end

    headers = CSV.open(path_file, col_sep: ';', encoding: 'windows-1251:utf-8', &:readline)
    product_rows = get_product_rows(csv_rows)

    CSV.open(path_middle_csv, "a+") do |csv|
      csv << headers
      csv_rows.each do |csv_row|
        if csv_row["Тип строки"] == "product_variant"
          csv << csv_row
        elsif csv_row["Тип строки"] == "variant"
          key = csv_row["ID товара"]
          product = product_rows[key]
          (0..csv_row.size).each do |index|
            csv_row[index] = product[index] if csv_row[index].nil?
          end
          csv << csv_row
        else
          next
        end
      end
    end

    rows = CSV.read(path_middle_csv, headers: true).map do |row|
      row.to_a
    end

    param_name = Services::CompareParams.new("Ledron")

    rows.each do |row|
      hash_arr_params = hash_params(row, param_name)

      params = product_params(hash_arr_params)

      images = hash_arr_params["Изображения товаров"].reject(&:nil?)
      images = images.select {|photo| RestClient.get(photo) rescue nil }

      data = {
        fid: hash_arr_params["ID артикула"].join(", ") + "___ledron",
        title: hash_arr_params["Наименование"].join(", "),
        url: "https://ledron.ru/product/" + hash_arr_params["Ссылка на витрину"].join(", "),
        sku: hash_arr_params["Артикул"].join(", ") + " " + "(#{hash_arr_params["ID артикула"].join(", ")})",
        desc: hash_arr_params["Краткое описание"].join("<br>"),
        distributor: "Ledron",
        quantity: nil,
        image: images.join(" "),
        video: hash_arr_params["Адрес видео на YouTube или Vimeo"].join(", "),
        cat: "Ledron",
        cat1: hash_arr_params["Категория"].join(", "),
        price: hash_arr_params["Цена"].join(", ").present? ? hash_arr_params["Цена"].join(", ") : 0,
        purchase_price: hash_arr_params["Закупочная цена"].join(", ").present? ? hash_arr_params["Закупочная цена"].join(", ") : 0,
        currency: hash_arr_params["Валюта"].join(", "),
        mtitle: hash_arr_params["Заголовок"].present? ? hash_arr_params["Заголовок"].join(", ") : nil,
        mkeywords: hash_arr_params["META Keywords"].present? ? hash_arr_params["META Keywords"].join(", ") : nil,
        mdesc: hash_arr_params["META Description"].present? ? hash_arr_params["META Description"].join(", ") : nil,
        p1: params.reject(&:nil?).join(" --- "),
        weight: hash_arr_params["Вес нетто, кг"] ? hash_arr_params["Вес нетто, кг"].join("") : nil,
        check: true
      }

      product = Product.find_by(fid: data[:fid])
      product ? product.update(data) : Product.create(data)
      puts "ok"
    end
    puts '=====>>>> FINISH Ledron CSV '+Time.now.to_s
  end

  def self.product_params(hash_arr_params)
    arr_exclude_key = ["Артикул","Тип строки", "Наименование", "Код артикула", "Валюта", "Цена", "Доступен для заказа",
                       "Изображения товаров", "Доступен для заказа", "ID артикула",
                       "Закупочная цена", "В наличии", "Идентификатор 1С", "status", "ID товара", "Адрес видео на YouTube или Vimeo",
                       "Товар: Идентификатор 1С", "Категория", "META Keywords", "META Description", "Заголовок", "Ссылка на витрину",
                       "Остаток", "Краткое описание"]
    result = hash_arr_params.map do |key, value|
      value = value.reject(&:nil?).join(", ")
      next if arr_exclude_key.include?(key) || value == ""
      value = value
                .gsub(/true/, "Да").gsub(/false/, "Нет")
                .gsub(/:/, "&#58;")
                .gsub(/-{3}/, "&#8722;&#8722;&#8722;")
                .gsub(/\s{2,}/, " ")
                .gsub(/<br \/>|<br>|{|}|<|>/, "")
      value = replace_semi_to_dot(value)
      "#{key.gsub("/","&#47;")}: #{value}"
    end
    result << "Поставщик: Ledron"
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

  def self.get_product_rows(csv_rows)
    result = {}
    csv_rows.each do |csv_row|
      if csv_row["Тип строки"] == "product"
        key = csv_row["ID товара"]
        result[key] = csv_row
      end
    end
    result
  end
end
