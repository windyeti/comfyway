class Services::GettingProductDistributer::Maytoni

  def self.call
    puts '=====>>>> СТАРТ Maytoni SCV '+Time.now.to_s

    Product.where(distributor: "Maytoni").each {|tov| tov.update(quantity: 0, check: false)}

    uri = "https://onec-dev.s3.amazonaws.com/upload/public/documents/all.csv"

    FileUtils.rm_rf(Dir.glob('public/maytoni.csv'))
    FileUtils.rm_rf(Dir.glob('public/aws/*.*'))

    File.open("#{Rails.root.join('public', 'maytoni.csv')}", 'w') {|f|
      block = proc { |response|
        f.write response.body.force_encoding('UTF-8')
      }
      RestClient::Request.new(method: :get, url: uri, block_response: block).execute
    }

    rows = CSV.read("#{Rails.root.join('public', 'maytoni.csv')}", headers: true, col_sep: ';').map do |row|
      row.to_hash
    end

    param_name = Services::CompareParams.new("Maytoni")
    arr_exclude_key = [
      "﻿id", "available", "name", "Stock", "barcode", "vendorCode", "price", "Категория", "url", "currencyId",
      "Фото1", "Фото2", "Фото3", "Фото4", "Фото5", "Фото6", "Фото7", "Фото8"
    ]
    arr_exlude_one_value = [
      "Вес нетто, кг", "Вес брутто, кг"
    ]
    rows.each do |row|
      params = []
      row.each do |key, value|

        if value.present? && !arr_exclude_key.include?(key)
          name = param_name.compare(key)

          if name == "Тип лампы"
            if value == "Да"
              value = "LED"
            else
              next
            end
          end
          if !arr_exlude_one_value.include?(name)
            value = value.gsub(",","##")
          end
          params << "#{name}: #{value}"
        end
      end

      photos = []
      (1..8).each do |num|
        photo = row["Фото#{num}"]
        if photo&.match(/onec-dev.s3/)
          p photo = get_image_aws(photo)
        end
        photos << photo unless photo.nil?
      end

      data = {
        fid: row["vendorCode"] + "___maytoni",
        title: row["name"],
        url: row["url"],
        sku: row["vendorCode"],
        distributor: "Maytoni",
        vendor: row["vendor"],
        image: photos.join(" "),
        cat: "Maytoni",
        cat1: row["Категория"],
        barcode: row["barcode"],
        price: row["price"].present? ? row["price"] : 0,
        quantity: row["Stock"],
        currency: row["currencyId"],
        p1: params.join(" --- "),
        check: true
      }

      product = Product.find_by(fid: data[:fid])
      product ? product.update(data) : Product.create(data)
    end
    puts '=====>>>> FINISH Maytoni CSV '+Time.now.to_s
  end

  def self.get_image_aws(url)
    filename = url.split('/').last.gsub(/.jpeg$/, ".jpg")
    File.open("#{Rails.root.join('public', 'aws', filename)}", 'w') {|f|
      block = proc { |response|
        f.write response.body.force_encoding('UTF-8')
      }
      RestClient::Request.new(method: :get, url: url, block_response: block).execute
    }
    "http://164.92.252.76/aws/#{(filename)}"
  end
end
