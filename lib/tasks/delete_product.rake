namespace :product do
  task delete: :environment do
    get_products
  end

  task delete_from_file: :environment do
    CSV.read("#{Rails.public_path}/delete.csv", headers: true).each do |row|
      id = row["ID товара"]
      delete_product(id)
    end
  end

  task delete_product_app: :environment do
    CSV.read("#{Rails.public_path}/compare/app_diff.csv", headers: true).each do |row|
      fid = row["fid"]
      product = Product.find_by(fid: fid)
      product.destroy
    end
  end

  def get_products
    page = 1

    loop do
      list_resp = RestClient.get "http://#{Rails.application.credentials[:shop][:api_key]}:#{Rails.application.credentials[:shop][:password]}@#{Rails.application.credentials[:shop][:domain]}/admin/products.json?page=#{page}&per_page=250}"
      sleep 1
      list_data = JSON.parse(list_resp.body)
      p list_data.count

      list_data.each do |product|
        delete_product(product["id"])
      end

      break if list_data.count == 0
      page += 1
    end
  end

  def delete_product(id)
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
        puts "error 422 - не добавили категорию"
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
