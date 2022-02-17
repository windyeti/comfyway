namespace :p do
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

  task swg: :environment do
    uri = "https://swgshop.ru/upload/swgshop_export_full_price_qty.csv"

    File.open("#{Rails.root.join('public', 'swg.csv')}", 'w') {|f|
      block = proc { |response|

        body = response.body.gsub!("\r", '').force_encoding('UTF-8')
#         body = response.body.gsub!("\r", '').force_encoding('UTF-8').gsub(/\b;/, "##").gsub(/\);/, ")##").gsub(/$
# /,"\n")
        f.write body
      }
      RestClient::Request.new(method: :get, url: uri, block_response: block).execute
    }


  end

  task qqq: :environment do
    download_link = "https://assets.transistor.ru/catalog/v3/sites/products.json?brandID=4&categoryID=668"
    p download_path = "#{Rails.public_path}/test.json"
    download_response = open(download_link).read()
    IO.copy_stream(download_response, download_path)
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

  task run_eval: :environment do

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
   Product.all.each do |product|
     if [product.cat, product.cat1, product.cat2, product.cat3, product.cat4, product.cat5].include?("Розетка силовая (штепсельная)")
       p product.title
       return
     end
   end
  end



  task uniq: :environment do
    # names = CSV.read("#{Rails.public_path}/map_params.csv") do |row|
    #   row
    # end
    # a = names.map {|row| row[1]}
    a = Product.where(distributor: "Elevel").map(&:sku)
    p a.uniq.
      map { | e | [a.count(e), e] }.
      select { | c, _ | c > 1 }.
      sort.reverse.
      map { | c, e | "#{e}:#{c}" }.count
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
end
