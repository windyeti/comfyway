namespace :parsing do
  task update_product: :environment do
    products = []
    page = 1
    loop do
      response = api_get_products(page)
      body = JSON.parse(response.body)
      p body.size
      break if body.size == 0
      products += body
      page += 1
      p products.count
    end
    p "OK"
    titles = CSV.read("#{Rails.public_path}/delete.csv",headers: true).map {|t| t["Название товара"]}
    count = 0
    del_arr = []
    products.each do |product|
      if titles.include?(product["title"])
        del_arr << product["title"]
        count += 1
        api_delete_product(product["id"])
      end
    end
    p titles - del_arr
    p count
  end

  def api_get_products(page)
    api_key = Rails.application.credentials[:shop][:api_key]
    password = Rails.application.credentials[:shop][:password]
    domain = Rails.application.credentials[:shop][:domain]

    url_api_category = "http://#{api_key}:#{password}@#{domain}/admin/products.json?per_page=100&page=#{page}"

    RestClient.get( url_api_category )
  end

  def api_update_product(data)
    api_key = Rails.application.credentials[:shop][:api_key]
    password = Rails.application.credentials[:shop][:password]
    domain = Rails.application.credentials[:shop][:domain]

    id = data[:id]

    p data = {
      "product": {
        "title": data[:title]
      }
    }

    url_api_category = "http://#{api_key}:#{password}@#{domain}/admin/products/#{id}.json"

    RestClient.put( url_api_category, data.to_json, {:content_type => 'application/json', accept: :json}) do |response, request, result, &block|
      sleep 0.5
      case response.code
      when 200
        p 'code 200 - ok'
      when 422
        p 'code 422'
        File.open("#{Rails.public_path}/errors_update.txt", 'a') do |file|
          file.write "#{id}\n"
        end
      else
        response.return!(&block)
      end
    end
  end

  def api_delete_product(id)
    result_body = {}
    id_product = id
    url_api_category = "http://#{Rails.application.credentials[:shop][:api_key]}:#{Rails.application.credentials[:shop][:password]}@#{Rails.application.credentials[:shop][:domain]}/admin/products/#{id_product}.json"

    RestClient.delete( url_api_category, :accept => :json, :content_type => "application/json") do |response, request, result, &block|
      case response.code
      when 200
        puts "sleep 1 #{id_product} товар удалили"
        sleep 1
        result_body = JSON.parse(response.body)
      when 422
        puts "error 422"
        puts response
      when 404
        puts 'error 404'
        puts response
      when 503
        sleep 1
        puts 'sleep 1 error 503'
      else
        puts 'UNKNOWN ERROR'
      end
    end
    p 'ответ на удаление END --------------------------------'
    p result_body
  end
end
