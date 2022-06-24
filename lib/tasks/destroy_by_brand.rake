namespace :destroy_by_brand do
  task :start, [:brand] => :environment do |_t, args|
    @auth = 'Basic ' + Base64.strict_encode64("#{Rails.application.credentials.krokus[:user]}:#{Rails.application.credentials.krokus[:password]}").chomp
    brand = args[:brand]

    create_hash_fid_id_var

    products = get_products_by_brand(brand)
    products.each do |product|
      fid = "#{product['id']}__elevel"
      product_app = Product.find_by(fid: fid)

      next if product_app.nil?

      insales_product_id = get_id_var(fid)

      response = Services::DeleteProductInsales.new(insales_product_id).call
      if response["status"] == 'ok'
        product_app.destroy
      end
    end
  end

  def create_hash_fid_id_var
    CSV.read("#{Rails.public_path}/shop.csv",headers: true).each do |row|
      key = row["Параметр: fid"]
      value = row["ID варианта"]
      @fid_id_var[key] = value
    end
  end

  def get_id_var(fid)
    @fid_id_var[fid] # ==> {"123 (asd)"=> 345}
  end

  def get_products_by_brand(brand)
    p brand
    url = 'http://swop.krokus.ru/ExchangeBase/hs/catalog/getidbyarticles'
    payload = {
      "articles": [
        brand
      ],
      "typeOfSearch": "Бренд"
    }
    api_elevel(url, payload)["result"]
  end

  def api_elevel(url, payload)
    RestClient.post( url, payload.to_json, timeout: 120, :accept => :json, :content_type => "application/json", :Authorization => @auth) do |response, request, result, &block|
      case response.code
      when 200
        # puts 'Okey'
        # pp response.body
        response.body.present? ? JSON.parse(response.body) : {}
      when 422
        puts "error 422 - не добавили категорию"
        puts response
      when 404
        puts 'error 404'
        puts response
      when 503
        puts 'error 503'
      else
        puts 'UNKNOWN ERROR'
      end
    end
  end
end
