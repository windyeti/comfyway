class Services::GettingProductDistributer::Maytoni

  def self.call
    puts '=====>>>> СТАРТ Maytoni SCV '+Time.now.to_s

    Product.where(distributor: "Maytoni").each {|tov| tov.update(quantity: 0, check: false)}

    uri = "https://mais-upload.maytoni.de/YML/all.csv"

    FileUtils.rm_rf(Dir.glob('public/maytoni.csv'))
    FileUtils.rm_rf(Dir.glob('public/aws/*.*'))

    File.open("#{Rails.root.join('public', 'maytoni.csv')}", 'w') {|f|
      block = proc { |response|
        f.write response.body.force_encoding('UTF-8')
      }
      RestClient::Request.new(method: :get, url: uri, block_response: block).execute
    }

    rows = CSV.read("#{Rails.root.join('public', 'maytoni.csv')}", headers: true, col_sep: ';').map do |row|
      row.to_a
    end

    param_name = Services::CompareParams.new("Maytoni")

    rows.each do |row|
      hash_arr_params = hash_params(row, param_name)

      params = product_params(hash_arr_params)

      photos = []
      (1..8).each do |num|
        row.each do |item|
          if item[0] == "Фото#{num}" && item[1].present?
            photo = item[1]
            photo = get_image_aws(item[1]) if item[1].match(/onec-dev.s3/)
            photos << photo unless photo.nil?
          end
        end
      end

      quantity = hash_arr_params["Остаток"].join("").present? ? (hash_arr_params["Остаток"].join("").to_i > 0 ? hash_arr_params["Остаток"].join("") : 0) : 0
      data = {
        fid: hash_arr_params["Артикул"].join("") + "___maytoni",
        title: hash_arr_params["Наименование"].join(""),
        url: hash_arr_params["url"].join(", "),
        sku: hash_arr_params["Артикул"].join(""),
        distributor: "Maytoni",
        vendor: hash_arr_params["Бренд"].join(""),
        image: photos.join(" "),
        cat: "Maytoni",
        cat1: hash_arr_params["Категория"].join(""),
        barcode: hash_arr_params["Штрихкод"].join(""),
        price: hash_arr_params["Цена"].join("").present? ? hash_arr_params["Цена"].join("") : 0,
        purchase_price: 0,
        quantity: quantity,
        currency: hash_arr_params["Валюта"].join(""),
        weight: hash_arr_params["Вес нетто, кг"] ? hash_arr_params["Вес нетто, кг"].join("") : nil,
        p1: params.join(" --- "),
        check: true
      }

      product = Product.find_by(fid: data[:fid])
      product ? product.update(data) : Product.create(data)
      puts "ok"
    end
    puts '=====>>>> FINISH Maytoni CSV '+Time.now.to_s
  end

  def self.get_image_aws(url)
    filename = url.split('/').last.gsub(/.jpeg$/, ".jpg")
    File.open("#{Rails.root.join('public', 'aws', filename)}", 'w') {|f|
      block = proc { |response|
        f.write response.body.force_encoding('UTF-8')
      }
      begin
        attampts ||= 0
        RestClient::Request.new(method: :get, url: url, block_response: block).execute
      rescue
        retry if (attampts += 1) < 3
      end
    }
    "http://5.63.155.35/aws/#{(filename)}"
  end

  def self.product_params(hash_arr_params)
    arr_exclude_key = [
      "Наименование", "Артикул", "Цена", "Валюта", "Штрихкод", "Остаток", "﻿id", "available", "name", "Stock", "barcode", "vendorCode", "price", "Категория", "url", "currencyId",
      "Фото1", "Фото2", "Фото3", "Фото4", "Фото5", "Фото6", "Фото7", "Фото8"
    ]
    result = hash_arr_params.map do |key, value|
      value = value.join(", ")
      next if arr_exclude_key.include?(key) || value == ""

      if key == "Тип лампы"
        if value == "Да"
          value = "LED"
        else
          next
        end
      end
      "#{key.gsub("/","&#47;")}: #{value.gsub(/true/, "Да").gsub(/false/, "Нет")}"
    end.compact
    result << "Поставщик: Maytoni"
    result
  end

  # [[k1, v1], [k2, v2], [k1, v3]] ==> {k1: [v1, v3], k2: [v2]}
  def self.hash_params(row, param_name)
    new_arr_arr_params = []
    row.map do |arr|
      common_name_param = param_name.compare(arr[0])
      new_arr_arr_params << [common_name_param, arr[1]] if common_name_param.present?
    end.compact
    Hash[ new_arr_arr_params.group_by(&:first).map{ |k,a| [k,a.map(&:last).uniq] } ]
  end
end
