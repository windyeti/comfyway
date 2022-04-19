class Services::GettingProductDistributer::Swg

  def self.call
    puts '=====>>>> СТАРТ SWG SCV '+Time.now.to_s
    FileUtils.rm_rf(Dir.glob('public/swg.csv'))
    Product.where(distributor: "Swg").each {|tov| tov.update(quantity: 0, check: false)}

    uri = "https://swgshop.ru/upload/swgshop_export_full.csv"

    File.open("#{Rails.root.join('public', 'swg.csv')}", 'w') {|f|
      block = proc { |response|
        body = response.body.force_encoding('UTF-8').gsub!(/\r\n?/, "\n").gsub!(/(?!")[\w|\W]\n/, ' ').gsub(/\b;/, "##").gsub(/\);/, ")##")
        # body = response.body.force_encoding('UTF-8').gsub!(/\r\n?|\n\n?/, "\n").gsub(/\b;/, "##").gsub(/\);/, ")##")
        # body = response.body.gsub!("\r", '').force_encoding('UTF-8').gsub(/\b;/, "##").gsub(/\);/, ")##")
        f.write body
      }
      RestClient::Request.new(method: :get, url: uri, block_response: block).execute
    }

    categories = {}
    rows = CSV.read("#{Rails.root.join('public', 'swg.csv')}", headers: true, col_sep: ';', :quote_char => "\x00").map do |row|
      # p row if row["﻿\"Внешний код\""] == "\"00-00003228\""
      categories[row[0]] = {
        cat1: row[3],
        cat2: row[4],
        cat3: row[5]
      }
      row.to_hash
    end

    param_name = Services::CompareParams.new("SWG")

    rows.each do |row|

      cell_sku = row["﻿\"Внешний код\""]
      cell_price = row["\"Цена \"\"Розничная цена\"\"\""]
      cell_quantity = row["\"Количество на складе \"\"Основной склад (с. Дмитровское)\"\"\""]
      # пустое поле Цена или Остаток - не берем товар
      next if cell_sku == "\"\"" ||  cell_sku == "" ||  cell_price == "\"\"" ||  cell_quantity == "\"\"" ||  cell_price == "" ||  cell_quantity == ""

      # if row["﻿\"Внешний код\""] == "\"00-00007050\""
      #   p cell_sku
      #   p cell_price
      #   p cell_quantity
      # end

      sku = cell_sku.gsub(/"/, "")
      price = cell_price.gsub(/"/, "")
      quantity = cell_quantity.gsub(/"/, "")

      hash_arr_params = hash_params(row, param_name)
      params = product_params(hash_arr_params)

      photos = []
      photos << row["\"Детальная картинка (путь)\""] if row["\"Детальная картинка (путь)\""].present? && row["\"Детальная картинка (путь)\""] != " "
      photos += row["\"Фотографии галереи [MORE_PHOTO]\""].split("##") if row["\"Фотографии галереи [MORE_PHOTO]\""].present?
      photos = photos.map do |src|
        if src.match(/https:\/\/swgshop\.ru/)
          src.gsub(/"/, "")
        else
          "https://swgshop.ru#{src.gsub(/"/, "")}"
        end
      end.reject {|src| src == "https://swgshop.ru"}

      photos = photos.select {|photo| RestClient.get(photo) rescue nil }

      long = row["\"Длинное наименование [OLD_NAME]\""] ? row["\"Длинное наименование [OLD_NAME]\""].gsub(/"/, "") : nil
      short = row["\"Наименование элемента\""] ? row["\"Наименование элемента\""].gsub(/"/, "") : nil
      fid = sku + "___swg"
      title = long.present? ? long : (short.present? ? short : fid)

      cat1 =  categories[row["﻿\"Внешний код\""]][:cat1] ? categories[row["﻿\"Внешний код\""]][:cat1].gsub(/"/, "") : nil
      cat2 =  categories[row["﻿\"Внешний код\""]][:cat2] ? categories[row["﻿\"Внешний код\""]][:cat2].gsub(/"/, "") : nil
      cat3 =  categories[row["﻿\"Внешний код\""]][:cat3] ? categories[row["﻿\"Внешний код\""]][:cat3].gsub(/"/, "") : nil

# if row["﻿\"Внешний код\""] == "\"00-00010540\""
      next if guard_exclude(hash_arr_params, [cat1, cat2, cat3])

      data = {
        fid: fid,
        title: title,
        sku: sku,
        url: row["\"URL страницы детального просмотра\""] ? "https://swgshop.ru" + row["\"URL страницы детального просмотра\""].gsub(/"/, "") : nil,
        distributor: "Swg",
        image: photos.join(" "),
        cat: "SWG",
        cat1: cat1,
        cat2: cat2,
        cat3: cat3,
        price: price,
        purchase_price: 0,
        quantity: quantity,
        p1: params.join(" --- "),
        video: row["\"Видео обзор (ссылка на YouTube)\""] ? row["\"Видео обзор (ссылка на YouTube)\""].gsub(/"/, "") : nil,
        currency: row["\"Валюта для цены \"\"Розничная цена\"\"\""] ? row["\"Валюта для цены \"\"Розничная цена\"\"\""].gsub(/"/, "") : nil,
        mtitle: row["\"Заголовок окна браузера [TITLE]\""] ? row["\"Заголовок окна браузера [TITLE]\""].gsub(/"/, "") : nil,
        mdesc: row["\"Мета-описание [META_DESCRIPTION]\""] ? row["\"Мета-описание [META_DESCRIPTION]\""].gsub(/"/, "") : nil,
        weight: hash_arr_params["Вес нетто, кг"] ? hash_arr_params["Вес нетто, кг"].join("") : nil,
        mkeywords: nil,
        check: true
      }
# end
      product = Product.find_by(fid: data[:fid])
      product ? product.update(data) : Product.create(data)
    end
    puts '=====>>>> FINISH SWG CSV '+Time.now.to_s
  end

  def self.hash_params(row, param_name)
    new_arr_arr_params = []
    row.map do |arr|
      new_arr_arr_params << [param_name.compare(arr[0]), arr[1]]
    end
    Hash[ new_arr_arr_params.group_by(&:first).map{ |k,a| [k,a.map(&:last).uniq] } ]
  end

    def self.guard_exclude(hash_arr_params, categories)
      intersection_cat = categories & ["Серия LT360 (3528)", "Серия LT4240 (3014)", "Серия LT560 (5050)", "Демо-кейсы NK", "Демо-кейсы", "Неоновая лента", "Лента 220", "Офисные светильники", "УФ Лампы"]
      intersection_cat.present? ||
      hash_arr_params["Активность"] == "N" ||
      ["более 5000", "6000-6500", "6000", "RGB+6000", "10000", "5100-6100",
       "6500-7000", "10000-13000", "7500", "6500", "5000"].include?(hash_arr_params["Цветовая температура, K [LOW_EMISSION]"])
    end

  def self.product_params(hash_arr_params)
    arr_exclude = ["﻿\"Внешний код\"", "\"Длинное наименование [OLD_NAME]\"", "\"Артикул [ARTNUMBER]\"", "\"Краткое наименование [short_title]\"", "\"Наименование элемента\"",
                   "\"Цена \"\"Розничная цена\"\"\"", "\"Название раздела\"", "\"Валюта для цены \"\"Розничная цена\"\"\"",
                   "\"URL страницы детального просмотра\"",
                   "\"Количество на складе \"\"Основной склад (с. Дмитровское)\"\"\"", "\"Детальная картинка (путь)\"", "\"Фотографии галереи [MORE_PHOTO]\"",
                   "\"Заголовок окна браузера [TITLE]\"", "\"Мета-описание [META_DESCRIPTION]\"", "\"Уникальное наименование в детальной карточке товара [H1_DETAIL]\"",
                   "\"Видео обзор (ссылка на YouTube)\""
    ]
    result = hash_arr_params.map do |key, value|
      next if arr_exclude.include?(key)
      if value.present? && !arr_exclude.include?(key)
        key = key.gsub(/^"|"$/, "") rescue next
        value = value.join(", ").gsub(/"/, "")

        if key == "Вес нетто, кг" && value.present?
          value = (value.to_f / 1000).to_s
        end
        "#{key.gsub("/","&#47;")}: #{value.gsub(/true/, "Да").gsub(/false/, "Нет")}" if key.present? && value.present?
      end
    end.compact
    result << "Поставщик: Swg"
    result
  end
end
