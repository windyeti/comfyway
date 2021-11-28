class Services::GettingProductDistributer::Swg2

  def self.call
    puts '=====>>>> СТАРТ SWG SCV '+Time.now.to_s

    # Product.where(distributor: "Swg").each {|tov| tov.update(quantity: 0, check: false)}

    uri = "https://swgshop.ru/upload/swgshop_export_full.csv"

    File.open("#{Rails.root.join('public', 'swg.csv')}", 'w') {|f|
      block = proc { |response|
        body = response.body.gsub!("\r", '').force_encoding('UTF-8')
        # body = response.body.gsub!("\r", '').force_encoding('UTF-8').gsub(/\b;/, "##").gsub(/\);/, ")##")
        f.write body
      }
      RestClient::Request.new(method: :get, url: uri, block_response: block).execute
    }

    categories = {}
    rows = CSV.read("#{Rails.root.join('public', 'swg.csv')}", headers: true, col_sep: ';', :quote_char => "\x00").map do |row|
      categories[row[0]] = {
        cat1: row[3],
        cat2: row[4],
        cat3: row[5]
      }
      row.to_hash
    end
    pp rows

    # param_name = Services::CompareParams.new("SWG")
    #
    # arr_exclude = ["﻿\"Внешний код\"", "\"Длинное наименование [OLD_NAME]\"", "\"Краткое наименование [short_title]\"", "\"Наименование элемента\"",
    #                "\"Цена \"\"Розничная цена\"\"\"", "\"Название раздела\"", "\"Валюта для цены \"\"Розничная цена\"\"\"",
    #                "\"URL страницы детального просмотра\"",
    # "\"Количество на складе \"\"Основной склад (с. Дмитровское)\"\"\"", "\"Детальная картинка (путь)\"", "\"Фотографии галереи [MORE_PHOTO]\"",
    #                "\"Заголовок окна браузера [TITLE]\"", "\"Мета-описание [META_DESCRIPTION]\"", "\"Уникальное наименование в детальной карточке товара [H1_DETAIL]\"",
    #                "\"Видео обзор (ссылка на YouTube)\""
    # ]
    # rows.each do |row|
    #   params = []
    #   row.each do |key, value|
    #
    #     if value.present? && !arr_exclude.include?(key)
    #       key = key.gsub(/^"|"$/, "") rescue next
    #       name = param_name.compare(key)
    #       value = value.gsub(/"/, "")
    #
    #       if name == "Вес нетто, кг" && value.present?
    #         value = (value.to_f / 1000).to_s
    #       end
    #       params << "#{name}: #{value}" if name.present? && value.present?
    #     end
    #   end
    #
    #   photos = []
    #   photos << row["\"Детальная картинка (путь)\""] if row["\"Детальная картинка (путь)\""]
    #   photos += row["\"Фотографии галереи [MORE_PHOTO]\""].split("##") if row["\"Фотографии галереи [MORE_PHOTO]\""].present?
    #
    #   if row["﻿\"Внешний код\""] == "\"00-00001319\""
    #   pp data = {
    #     fid: row["﻿\"Внешний код\""].gsub(/"/, "") + "__SWG",
    #     title: row["\"Длинное наименование [OLD_NAME]\""] ? row["\"Длинное наименование [OLD_NAME]\""].gsub(/"/, "") : nil,
    #     sku: row["﻿\"Внешний код\""].gsub(/"/, ""),
    #     url: row["\"URL страницы детального просмотра\""] ? row["\"URL страницы детального просмотра\""].gsub(/"/, "") : nil,
    #     distributor: "SWG",
    #     image: photos.join(" ").gsub(/"| $/, ""),
    #     cat: "SWG",
    #     cat1: categories[row["﻿\"Внешний код\""]][:cat1] ? categories[row["﻿\"Внешний код\""]][:cat1].gsub(/"/, "") : nil,
    #     cat2: categories[row["﻿\"Внешний код\""]][:cat2] ? categories[row["﻿\"Внешний код\""]][:cat2].gsub(/"/, "") : nil,
    #     cat3: categories[row["﻿\"Внешний код\""]][:cat3] ? categories[row["﻿\"Внешний код\""]][:cat3].gsub(/"/, "") : nil,
    #     price: row["\"Цена \"\"Розничная цена\"\"\""].present? ? row["\"Цена \"\"Розничная цена\"\"\""].gsub(/"/, "") : 0,
    #     quantity: row["\"Количество на складе \"\"Основной склад (с. Дмитровское)\"\"\""] ? row["\"Количество на складе \"\"Основной склад (с. Дмитровское)\"\"\""].gsub(/"/, "") : 0,
    #     p1: params.join(" --- "),
    #     video: row["\"Видео обзор (ссылка на YouTube)\""] ? row["\"Видео обзор (ссылка на YouTube)\""].gsub(/"/, "") : nil,
    #     check: true
    #   }
    #   end
    #
    #   # product = Product.find_by(fid: data[:fid])
    #   # product ? product.update(data) : Product.create(data)
    # end
    puts '=====>>>> FINISH SWG CSV '+Time.now.to_s
  end
end
