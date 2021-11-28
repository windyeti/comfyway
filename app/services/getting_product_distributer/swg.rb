class Services::GettingProductDistributer::Swg

  def self.call
    puts '=====>>>> СТАРТ SWG SCV '+Time.now.to_s
    FileUtils.rm_rf(Dir.glob('public/swg.csv'))
    FileUtils.rm_rf(Dir.glob('public/swg_youtube.csv'))

    Product.where(distributor: "Swg").each {|tov| tov.update(quantity: 0, check: false)}

    uri = "https://swgshop.ru/upload/swgshop_export_full_price_qty.csv"

    File.open("#{Rails.root.join('public', 'swg.csv')}", 'w') {|f|
      block = proc { |response|
        body = response.body.gsub!("\r", '').force_encoding('UTF-8').gsub(/\b;/, "##").gsub(/\);/, ")##").gsub(/$
/,"\n")
        f.write body
      }
      RestClient::Request.new(method: :get, url: uri, block_response: block).execute
    }

    tmpfile = Tempfile.new("#{Rails.root.join('public', 'swg.csv')}")
    tmpfile.write(File.read("#{Rails.root.join('public', 'swg.csv')}"))
    tmpfile.rewind
    spreadsheet = Roo::CSV.new(tmpfile, csv_options: {col_sep: ";", quote_char: "\x00"})

    categories = {}
    CSV.read("#{Rails.root.join('public', 'swg.csv')}", headers: true, col_sep: ';', :quote_char => "\x00").map do |row|
     categories[row[0]] = {
       cat1: row[7],
       cat2: row[8],
       cat3: row[9]
     }
      row.to_hash
    end

    # START получение ссылки на youtube
    uri_youtube = "https://swgshop.ru/upload/swgshop_export_full.csv"
    File.open("#{Rails.root.join('public', 'swg_youtube.csv')}", 'w') {|f|
      block = proc { |response|
        body = response.body.gsub!("\r", "").force_encoding('UTF-8').gsub(/\b;/, "##").gsub(/\);/, ")##").gsub(/$
/,"\n")
        f.write body
      }
      RestClient::Request.new(method: :get, url: uri_youtube, block_response: block).execute
    }

    spreadsheet.each_with_pagename do |_name, sheet|
      p last_row = sheet.last_row
      p last_column = sheet.last_column

      # (2..5).each do |num|
      #   p num
      #   p sheet.row(num)
      # end
      # (2..3530).each do |num|
      #   p sheet.row(num) if sheet.row(num)[3] == "\"Шнур питания для одноцветной неоновой ленты\""
      # end
      # last_row = sheet.last_row
      # last_column = sheet.last_column
      # (1..last_column).each do |column|
      #   p sheet.cell(2, column)
      # end
      # # sheet.each_with_index do |row, i|
      # #   pp row
      # #   p i
      # # end
    end

    youtube_link = CSV.read("#{Rails.root.join('public', 'swg_youtube.csv')}", headers: true, col_sep: ';', :quote_char => "\x00").map do |row|
      [
        row.to_hash["﻿\"Внешний код\""], row.to_hash["\"Видео обзор (ссылка на YouTube)\""]
      ]
    end
    youtube_link = youtube_link.to_h
    # END получение ссылки на youtube

    param_name = Services::CompareParams.new("SWG")

    arr_exclude = ["﻿\"Внешний код\"", "\"Уникальное наименование в детальной карточке товара [H1_DETAIL]\"", "\"Краткое наименование [short_title]\"", "\"Наименование элемента\"",
                   "\"Цена \"\"Розничная цена\"\"\"", "\"Название раздела\"", "\"Валюта для цены \"\"Розничная цена\"\"\"",
                   "\"URL страницы детального просмотра\"",
    "\"Количество на складе \"\"Основной склад (с. Дмитровское)\"\"\"", "\"Детальная картинка (путь)\"", "\"Фотографии галереи [MORE_PHOTO]\"",
                   "\"Заголовок окна браузера [TITLE]\"", "\"Мета-описание [META_DESCRIPTION]\"", "\"Уникальное наименование в детальной карточке товара [H1_DETAIL]\"",
                   "\"Видео обзор (ссылка на YouTube)\""
    ]

    spreadsheet.each_with_pagename do |_name, sheet|
    sheet.parse(headers: true).each do |row|
      p row if row["﻿\"Внешний код\""] == "\"00000000754\""
      next if row["﻿\"Внешний код\""] == "﻿\"Внешний код\""

      params = []
      row.each do |key, value|

        if value.present? && !arr_exclude.include?(key)
          key = key.gsub(/^"|"$/, "") rescue next
          name = param_name.compare(key)
          value = value.gsub(/"/, "")

          if name == "Вес нетто, кг" && value.present?
            value = (value.to_f / 1000).to_s
          end
          params << "#{name}: #{value}" if name.present? && value.present?
        end
      end

      photos = []
      photos << row["\"Детальная картинка (путь)\""] if row["\"Детальная картинка (путь)\""].present? && row["\"Детальная картинка (путь)\""] != " "
      photos += row["\"Фотографии галереи [MORE_PHOTO]\""].split("##") if row["\"Фотографии галереи [MORE_PHOTO]\""].present?
      photos = photos.map {|src| "https://swgshop.ru#{src}" if src.match(/^\//)}.reject(&:nil?)
if row["﻿\"Внешний код\""] == "\"00000000754\""
      pp data = {
        fid: row["﻿\"Внешний код\""].gsub(/"/, "") + "___swg",
        title: row["\"Уникальное наименование в детальной карточке товара [H1_DETAIL]\""] ? row["\"Уникальное наименование в детальной карточке товара [H1_DETAIL]\""].gsub(/"/, "") : nil,
        sku: row["﻿\"Внешний код\""].gsub(/"/, ""),
        url: row["\"URL страницы детального просмотра\""] ? "https://swgshop.ru" + row["\"URL страницы детального просмотра\""].gsub(/"/, "") : nil,
        distributor: "SWG",
        image: photos.join(" ").gsub(/"/, ""),
        cat: "SWG",
        cat1: categories[row["﻿\"Внешний код\""]][:cat1] ? categories[row["﻿\"Внешний код\""]][:cat1].gsub(/"/, "") : nil,
        cat2: categories[row["﻿\"Внешний код\""]][:cat2] ? categories[row["﻿\"Внешний код\""]][:cat2].gsub(/"/, "") : nil,
        cat3: categories[row["﻿\"Внешний код\""]][:cat3] ? categories[row["﻿\"Внешний код\""]][:cat3].gsub(/"/, "") : nil,
        price: row["\"Цена \"\"Розничная цена\"\"\""].present? ? row["\"Цена \"\"Розничная цена\"\"\""].gsub(/"/, "") : 0,
        quantity: row["\"Количество на складе \"\"Основной склад (с. Дмитровское)\"\"\""] ? row["\"Количество на складе \"\"Основной склад (с. Дмитровское)\"\"\""].gsub(/"/, "") : 0,
        p1: params.join(" --- "),
        video: youtube_link[row["﻿\"Внешний код\""]] ? youtube_link[row["﻿\"Внешний код\""]].gsub(/"/, "") : nil,
        currency: row["\"Валюта для цены \"\"Розничная цена\"\"\""] ? row["\"Валюта для цены \"\"Розничная цена\"\"\""].gsub(/"/, "") : nil,
        mtitle: row["\"Заголовок окна браузера [TITLE]\""] ? row["\"Заголовок окна браузера [TITLE]\""].gsub(/"/, "") : nil,
        mdesc: row["\"Мета-описание [META_DESCRIPTION]\""] ? row["\"Мета-описание [META_DESCRIPTION]\""].gsub(/"/, "") : nil,
        mkeywords: nil,
        check: true
      }
      # product = Product.find_by(fid: data[:fid])
      # product ? product.update(data) : Product.create(data)
    end
    end
end
    puts '=====>>>> FINISH SWG CSV '+Time.now.to_s
  end
end
