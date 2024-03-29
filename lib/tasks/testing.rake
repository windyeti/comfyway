namespace :p do

  task maytoni: :environment do
    uri = "https://mais-upload.maytoni.de/YML/all.csv"

    FileUtils.rm_rf(Dir.glob('public/maytoni.csv'))
    FileUtils.rm_rf(Dir.glob('public/aws/*.*'))

    File.open("#{Rails.root.join('public', 'maytoni.csv')}", 'w') { |f|
      block = proc { |response|
        f.write response.body
      }
      RestClient::Request.new(method: :get, url: uri, block_response: block).execute
    }

    # download_link = "https://mais-upload.maytoni.de/YML/all.csv"
    # download_path = "#{Rails.public_path}"+'maytoni.csv'
    # download_response = open(download_link).read()
    # IO.copy_stream(download_response, download_path)

    # CSV.foreach("#{Rails.root.join('public', 'maytoni.csv')}", headers: :first_row, col_sep: ';', quote_char: "\x00") do |line|
    #   p line
    #   sleep 2
    # end

    # rows = CSV.read("#{Rails.root.join('public', 'maytoni.csv')}", headers: true, col_sep: ';', quote_char: "\x00").map do |row|
    #   p row.to_a
    #   sleep 2
    # end

    # rows.each do |row|
    #   p row
    # end
  end

  task get: :environment do
    @agent = Mechanize.new
    @agent.post('https://assets.transistor.ru/', {:loginUser => 'svet.online.store@yandex.ru', :loginPass => 'QAZwsx123&', :multipart => true}) #вошли

    url = 'https://assets.transistor.ru/price/v3/sites/price.json'
    response = @agent.get(url)
    File.open("#{Rails.public_path}/argliht_json.txt", "a+") do |f|
      f.write JSON.parse(response.body)
    end
    # p JSON.parse(response.body)

    puts 'finish'
  end

  task get: :environment do
    @agent = Mechanize.new
    @agent.post('https://assets.transistor.ru/', {:loginUser => 'svet.online.store@yandex.ru', :loginPass => 'QAZwsx123&', :multipart => true}) #вошли

    url = 'https://assets.transistor.ru/price/v3/sites/price.json'
    response = @agent.get(url)
    p JSON.parse(response.body)
  end

  task arli: :environment do
    response = RestClient.get("https://assets.transistor.ru")
    p response.code
    # p response.body
    p response.cookies
    p response.cookie_jar
    payload = {
      loginUser: "svet.online.store@yandex.ru",
      loginPass: "QAZwsx123&",
    }
    response2 = RestClient.post("https://assets.transistor.ru", payload.to_json, {cookies: {:PHPSESSID => response.cookies["PHPSESSID"]}})
    p response2.code
    p response2.body
    p response2.cookies
  end

  task t: :environment do
    auth = 'Basic ' + Base64.strict_encode64("#{Rails.application.credentials.krokus[:user]}:#{Rails.application.credentials.krokus[:password]}").chomp
    url = 'http://swop.krokus.ru/ExchangeBase/hs/catalog/getidbyarticles'
    request_payload = {
      "articles": [
        "Светильник подвесной"
      ],
      "typeOfSearch": "Категория"
    }

    @resource = RestClient::Resource.new( url )
    @response = @resource.post( request_payload.to_json, :Authorization => auth )
    p @response.code
    p JSON.parse(@response.body)
    p JSON.parse(@response.body)["result"].count
  end

  task tt: :environment do
    auth = 'Basic ' + Base64.strict_encode64("#{Rails.application.credentials.krokus[:user]}:#{Rails.application.credentials.krokus[:password]}").chomp
    url = 'http://swop.krokus.ru/ExchangeBase/hs/catalog/allcategory'
    request_payload = {

    }
    @resource = RestClient::Resource.new( url )
    @response = @resource.post( request_payload, :Authorization => auth )
    p @response.code
    # m = JSON.parse(@response.body).map {|c| c["name"]}
    f = JSON.parse(@response.body).find {|c| c["name"] == "Шнуровой выключатель / светорегулятор (диммер)"}
    p f
  end

  task qqq: :environment do
    download_link = "https://assets.transistor.ru/catalog/v3/sites/products.json?brandID=4&categoryID=668"
    p download_path = "#{Rails.public_path}/test.json"
    download_response = open(download_link).read()
    IO.copy_stream(download_response, download_path)
  end

  task gauss: :environment do
    url = 'http://swop.krokus.ru/ExchangeBase/hs/catalog/getidbyarticles'
    payload = {
      "articles": [
        "gauss"
      ],
      "typeOfSearch": "Бренд"
    }
    products = api_elevel(url, payload)["result"]
    p products.count
  end

  task sss: :environment do
    insales_rows = CSV.read("#{Rails.public_path}/shop.csv", headers: true).map {|row| row["Параметр: fid"]}
    app_rows = CSV.read("#{Rails.public_path}/app.csv", headers: true).map {|row| row["fid"]}
    p insales_rows.count
    p app_rows.count
    # p app_rows - insales_rows
    # p insales_rows - app_rows
  end

  task nil_id: :environment do
    Product.all.each do |product|
      product.update(insales_id: nil, insales_var_id: nil)
    end
  end



  # task quantity: :environment do
  #   products = [{"id"=> "2480216"}]
  #   p quantities = get_quantities(products)
  #   p hash_id_quantity = get_id_quantity(quantities)
  #   products.each do |product|
  #     id = product['id']
  #     p hash_id_quantity[id][:stockamount].to_i + hash_id_quantity[id][:stockamount_add].to_i
  #   end
  #
  # end
  #
  # def get_quantities(products_for_create)
  #   url = 'http://swop.krokus.ru/ExchangeBase/hs/catalog/stockOfGoodsOffline'
  #   p products_for_create.pluck("id")
  #   payload = {
  #     "ids": products_for_create.pluck("id")
  #   }
  #   result = api_elevel(url, payload)["stockOfGoods"]
  #   result.present? ? result : []
  # end
  #
  # def get_id_quantity(quantities)
  #   result = {}
  #   quantities.each do |quantity|
  #     key = quantity["id"]
  #     result[key] = {
  #       stockamount: quantity["stockamount"],
  #       stockamount_add: quantity["stockamountAdd"]
  #     }
  #   end
  #   result
  # end
  #
  # def api_elevel(url, payload)
  #   p @auth = 'Basic ' + Base64.strict_encode64("#{Rails.application.credentials.krokus[:user]}:#{Rails.application.credentials.krokus[:password]}").chomp
  #   RestClient.post( url, payload.to_json, timeout: 120, :accept => :json, :content_type => "application/json", :Authorization => @auth) do |response, request, result, &block|
  #     case response.code
  #     when 200
  #       # puts 'Okey'
  #       # pp response.body
  #       response.body.present? ? JSON.parse(response.body) : {}
  #     when 422
  #       puts "error 422 - не добавили категорию"
  #       puts response
  #     when 404
  #       puts 'error 404'
  #       puts response
  #     when 503
  #       puts 'error 503'
  #     else
  #       p response.code
  #       puts 'UNKNOWN ERROR'
  #     end
  #   end
  # end

  task compare: :environment do
    param_name = Services::CompareParams.new("Elevel")
    p param_name.compare("Цветовая температура")
    p param_name.compare("Цветовая температура, K")
  end

  task readlog: :environment do
    File.readlines("#{Rails.public_path}/import 86.log").each do |row|
      next if row.match(/уже существует у данного товара/)
      p row
    end
  end

  task temper: :environment do
    count = 0
    Product.where(distributor: "Elevel").each do |product|
      count += 1 if product.p1.match(/Кратность заказа поставщику:/)
    end
    p count
  end

  task roz: :environment do
    uri = "https://loftit.ru/catalog.xml"

    response = RestClient.get uri, :accept => :xml, :content_type => "application/xml"
    doc_data = Nokogiri::XML(response)
    doc_offers = doc_data.xpath("//offer")

    doc_offers.each do |doc_offer|
      doc_params = doc_offer.xpath("param")
      p doc_params.search('[name="Категория"]').text
    end
  end

  task uniq_params_count: :environment do
   p Product.where(distributor: "Mantra")
       .map {|tov| tov.p1.split(" --- ")}
       .flatten
       .uniq
       .count
  end

  task params_csv: :environment do
      params = CSV.read("#{Rails.public_path}/map_params.csv", headers: true).map { |row| row["Название"].gsub("/", "&#47;") if row["Название"].present? }.uniq.compact
      exclude = ["Наименование", "Артикул", "Цена", "Валюта", "Остаток", "Краткое описание", "url", "ID артикула",
                 "Ссылка на витрину", "Адрес видео на YouTube или Vimeo", "Закупочная цена", "Изображения товаров",  "Штрихкод"]
      result = params - exclude
      p result
  end





  task uniq: :environment do
    # names = CSV.read("#{Rails.public_path}/map_params.csv") do |row|
    #   row
    # end
    # a = names.map {|row| row[1]}
    # a = Product.where(distributor: "Elevel").map(&:sku)
    a = Product.where(distributor: "Stluce").map(&:title)
    p a.uniq.
      map { | e | [a.count(e), e] }.
      select { | c, _ | c > 1 }.
      sort.reverse.
      map { | c, e | "#{e}:#{c}" }
  end

  task s: :environment do
    book = Spreadsheet::Workbook.new

    sheet = book.create_worksheet(name: "TEST")

    (0..670).each.with_index do |product_hash, index|
      sheet.row(0).push(index)
    end

    book.write "#{Rails.public_path}/test.xls"
  end

  task a: :environment do
    FileUtils.rm_rf(Dir.glob('public/swg.csv'))
    FileUtils.rm_rf(Dir.glob('public/swg_sherlock.csv'))

    url = "https://swgshop.ru/upload/swgshop_export_full_price_qty.csv"
    download = RestClient::Request.execute(method: :get, url: url, raw_response: true, verify_ssl: false )
    # download_path = Rails.public_path.to_s + '/swg.csv'
    # IO.copy_stream(download.file.path, download_path)

    # content = File.read(download.body.gsub!("\r", '').force_encoding('UTF-8'))
    # detection = CharlockHolmes::EncodingDetector.detect(content)
    # utf8_encoded_content = CharlockHolmes::Converter.convert(content, detection[:encoding], 'UTF-8')

    File.open(Rails.public_path.to_s + '/swg_sherlock.csv', "a+") do |f|
      f.write download.body.gsub!("\r", '').force_encoding('UTF-8')
    end

    CSV.open(Rails.public_path.to_s + '/swg_sherlock.csv', :row_sep => :auto, :col_sep => ";", quote_char: "\x00") do |csv|
      csv.each do |c|
        p c
      end
    end
    # file_path = File.read(Rails.public_path.to_s + '/swg_sherlock.csv')

    # spreadsheet = Roo::CSV.new(Rails.public_path.to_s + '/swg_sherlock.csv', csv_options: {col_sep: ";", quote_char: "\x00"})
    #
    # spreadsheet.each_with_pagename do |_name, sheet|
    #   sheet.parse(headers: true).each do |row|
    #     pp row if row[0] == "\"00-00007381\""
    #   end
    #   p sheet.parse(headers: true).count
    # end
    # url = "https://swgshop.ru/upload/swgshop_export_full.csv"
    # url = "https://swgshop.ru/upload/swgshop_export_full_price_qty.csv"

    # File.open("#{Rails.root.join('public', 'swg.csv')}", 'w') {|f|
    #   block = proc { |response|
    #     body = response.body
    #     # body = response.body.gsub!("\r", '').force_encoding('UTF-8').gsub(/\b;/, "##").gsub(/\);/, ")##")
    #     f.write body
    #   }
    #   RestClient::Request.new(method: :get, url: uri, block_response: block).execute
    # }

    # tmpfile = Tempfile.new("#{Rails.root.join('public', 'swg.csv')}", encoding: 'utf-8')
    # tmpfile.write(File.read("#{Rails.root.join('public', 'swg.csv')}").gsub!("\r", ''))
    # tmpfile.rewind
    # # file_path = File.read("#{Rails.root.join('public', 'swg.csv')}")
    # spreadsheet = Roo::CSV.new("#{Rails.root.join('public', 'swg.csv')}", csv_options: {col_sep: ";", quote_char: "\x00"})
#
# spreadsheet.each_with_pagename do |name, sheet|
#   # # last = sheet.last_row
#   # sheet.parse(headers: true).each do |row|
#   #   pp row["\"Длинное наименование [OLD_NAME]\""] if row["﻿\"Внешний код\""] == "\"00-00000874\""
#   # end
#   # p sheet.row(1)
# end


    # download_link = "https://swgshop.ru/upload/swgshop_export_full.csv"
    # download_path = "#{Rails.public_path}"+"swg.csv"
    # download_response = open(download_link).read()
    # IO.copy_stream(download_response, download_path)

    # url = "https://swgshop.ru/upload/swgshop_export_full.csv"
    # download_path = "#{Rails.public_path}"+"/swg.csv"
    # download_response = open(url).read().gsub!("\r", '').force_encoding("UTF-8")
    # IO.copy_stream(download_response, download_path)

    # uri = "https://swgshop.ru/upload/swgshop_export_full.csv"

    # File.open("#{Rails.root.join('public', 'swg.csv')}", 'w') {|f|
    #   block = proc { |response|
    #     body = response.body
    #     f.write body
    #   }
    #   RestClient::Request.new(method: :get, url: uri, block_response: block).execute
    # }
    #
    # rows = CSV.read("#{Rails.root.join('public', 'swg.csv')}", headers: true, col_sep: ';', :quote_char => "\x00").map do |row|
    #   row.to_hash
    # end
    # pp rows


#     headers = rows[0]
# i = 0
#
#     CSV.read("#{Rails.root.join('public', 'swg.csv')}", headers: true, col_sep: ';', :quote_char => "\x00").map do |row|
#       pp row["\"Заголовок окна браузера [TITLE]\""].gsub(/"/, "")
#       # p "-----------------------------------"
#       # headers.each do |header|
#       #   p '================='
#       #   pp "#{header} --- #{row[header]}"
#       #   p '+++++++++++++++++'
#       # end
#       break if i == 2
#       i += 1
#     end
    # rows = CSV.read("#{Rails.root.join('public', 'swg.csv')}", headers: true, col_sep: ';', :quote_char => "\x00").map do |row|
    #   # p row["\"Фотографии галереи [MORE_PHOTO]\""]
    #   # p row["Фотографии галереи [MORE_PHOTO]"]
    #   row.to_hash
    # end
    # pp rows[0]

    # url = "https://swgshop.ru/upload/swgshop_export_full.csv"
    # rows = CSV.read(open(url), headers: true, col_sep: ';', :quote_char => "\x00").map do |row|
    #   p row.to_hash
    # end
    # pp rows
  # end




    # File.open("#{Rails.root.join('public', 'proba.csv')}", 'w') {|f|
    #   block = proc { |response|
    #     f.write response.body.force_encoding('UTF-8')
    #     # response.read_body do |chunk|
    #     #   puts "Working on response"
    #     #   f.write chunk.force_encoding('UTF-8')
    #     # end
    #   }
    #   RestClient::Request.new(method: :get, url: 'https://onec-dev.s3.amazonaws.com/upload/public/documents/all.csv', block_response: block).execute
    # }
    #
    # rows = CSV.read("#{Rails.root.join('public', 'proba.csv')}", headers: true, col_sep: ';').map do |row|
    #   row.to_hash
    # end
    # p rows[1]["﻿id"]

    # File.open(Rails.root.join('public', 'proba.csv'), 'wb') do |file|
    #   file.write(response.body)
    # end

    # csv = CSV.parse("#{Rails.root.join('public', 'map_params.csv')}", headers: true, col_sep: ";")
    # csv = CSV.parse("#{Rails.root.join('public', 'map_params.csv')}", headers: true, col_sep: ";")
    # p csv
    # csv.each do |row|
    #   # p "------------"
    #   # row.each do |r|
    #   # p "- - - - -"
    #   #   puts r
    #   # end
    #   puts row[0]
    # end
    # Services::GettingProductDistributer::Maytoni.call
  end

  task param_xls: :environment do
    file = "#{Rails.public_path}/product_Elevel_output.xls"
    book_prep = Spreadsheet.open(file)
    sheet_prep = book_prep.worksheet("Output")
    headers = sheet_prep.row(0)
    p headers.count
    p headers & ['Параметр: Тип монтажа', 'Параметр: Цоколь', 'Параметр: Кол-во ламп, шт', 'Параметр: Общая мощность, Вт', 'Параметр: Мощность ленты на 1м, Вт/м', 'Параметр: Выходное напряжение, В', 'Параметр: Материал корпуса/арматуры', 'Параметр: Номин. Ток, А', 'Параметр: Коммутируем. Мощность, Вт', 'Параметр: Общая длина, м (мм)', 'Параметр: Коммутируем. Нагрузка, Вт', 'Параметр: Коммутируем. Напряжение, В' ]
  end

  task delete_insales: :environment do
    response = Services::DeleteProductInsales.new('304812839').call
    pp response
  end

  # вычисление лишних в магазине относительно приложения
  task insales_diff_insales: :environment do
    rows_insales = CSV.read("#{Rails.public_path}/compare/shop_data.csv", headers: true)
    fids_app = CSV.read("#{Rails.public_path}/compare/product_selected.csv", headers: true).map {|row| row["fid"]}

    CSV.open("#{Rails.public_path}/compare/app_diff_insales.csv", "a+") do |csv|
      csv << rows_insales.first.to_hash.keys
      rows_insales.each do |row_insales|
        fid_row = row_insales["Параметр: fid"]
        next if fid_row.nil?
        csv << row_insales unless fids_app.include?(fid_row)
      end
    end
  end

  # вычисление лишних в приложении относительно магазина
  task app_diff: :environment do
    fids_insales = CSV.read("#{Rails.public_path}/compare/shop_data.csv", headers: true).map {|row| row["Параметр: fid"]}
    rows_app = CSV.read("#{Rails.public_path}/compare/product_selected.csv", headers: true)

    CSV.open("#{Rails.public_path}/compare/app_diff.csv", "a+") do |csv|
      csv << rows_app.first.to_hash.keys
      rows_app.each do |row_app|
        fid_row = row_app["fid"]
        csv << row_app unless fids_insales.include?(fid_row)
      end
    end
  end

  task insales_fid_nil: :environment do
    rows_insales = CSV.read("#{Rails.public_path}/compare/shop_data.csv", headers: true)
    fids_app = CSV.read("#{Rails.public_path}/compare/product_selected.csv", headers: true).map {|row| row["fid"]}

    CSV.open("#{Rails.public_path}/compare/insales_fid_nil.csv", "a+") do |csv|
      csv << rows_insales.first.to_hash.keys
      rows_insales.each do |row_insales|
        fid_row = row_insales["Параметр: fid"]
        cat_row = row_insales["Корневая"]
        next if fid_row.present? || cat_row.nil?
        csv << row_insales unless fids_app.include?(fid_row)
      end
    end
  end

  task fav: :environment do
    # uri = "https://loftit.ru/catalog.xml"
    uri = "https://wbs.e-teleport.ru/Catalog_GetSharedCatalog?contact=antsiferovds%40s-svet.ru&catalog_type=yandex&only_stocks=true"

    response = RestClient.get uri, :accept => :xml, :content_type => "application/xml"
    doc_data = Nokogiri::XML(response)
    doc_offers = doc_data.xpath("//offer")
    result = []
    doc_offers.each do |doc_offer|
      doc_params = doc_offer.xpath("param")
      result += doc_params.map do |doc_param|
        doc_param['name']
      end
    end
    result = result.uniq
    File.open("#{Rails.public_path}/favourite_params.txt", "a+") {|f| f.write "#{result}\n"}
  end
end

