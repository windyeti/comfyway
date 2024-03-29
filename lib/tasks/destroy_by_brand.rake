# namespace :destroy_by_brand do
#   task :start, [:brand] => :environment do |_t, args|
#     @fid_id_var = {}
#     brand = args[:brand]
#
#     create_hash_fid_id_var
#
#     products = get_products_by_brand(brand)
#     p products.count
#     products.each do |product|
#       fid = "#{product['id']}___elevel"
#       product_app = Product.find_by(fid: fid)
#
#       insales_product_id = get_id_var(fid)
#
#       next if insales_product_id.nil?
#
#       response = Services::DeleteProductInsales.new(insales_product_id).call
#
#       if response["status"] == 'ok' && product_app.present?
#         product_app.destroy
#       end
#     end
#   end
#
#   task :only_store, [:brand] => :environment do |_t, args|
#     brand = args[:brand]
#
#     products = get_products_by_brand(brand)
#     p products.count
#     products.each do |product|
#       fid = "#{product['id']}___elevel"
#       product_app = Product.find_by(fid: fid)
#
#       product_app.destroy if product_app.present?
#
#     end
#   end
#
#   task check: :environment do
#     ["Loft it", "Favourite", "F-Promo", "Kink light"].each do |brand|
#       products = get_products_by_brand(brand)
#       p brand
#       p products.count
#     end
#   end
#
#   def create_hash_fid_id_var
#     CSV.read("#{Rails.public_path}/shop.csv",headers: true).each do |row|
#       key = row["Параметр: fid"]
#       value = row["ID товара"]
#       @fid_id_var[key] = value
#     end
#   end
#
#   def get_id_var(fid)
#     @fid_id_var[fid] # ==> {"123 (asd)"=> 345}
#   end
#
#   def get_products_by_brand(brand)
#     p brand
#     url = 'http://swop.krokus.ru/ExchangeBase/hs/catalog/getidbyarticles'
#     payload = {
#       "articles": [
#         brand
#       ],
#       "typeOfSearch": "Бренд"
#     }
#     api_elevel(url, payload)["result"]
#   end
#
#   def api_elevel(url, payload)
#     auth = 'Basic ' + Base64.strict_encode64("#{Rails.application.credentials.krokus[:user]}:#{Rails.application.credentials.krokus[:password]}").chomp
#     RestClient.post( url, payload.to_json, timeout: 120, :accept => :json, :content_type => "application/json", :Authorization => auth) do |response, request, result, &block|
#       case response.code
#       when 200
#         # puts 'Okey'
#         # pp response.body
#         response.body.present? ? JSON.parse(response.body) : {}
#       when 422
#         puts "error 422 - не добавили категорию"
#         puts response
#       when 404
#         puts 'error 404'
#         puts response
#       when 503
#         puts 'error 503'
#       else
#         puts response
#         puts 'UNKNOWN ERROR'
#       end
#     end
#   end
# end
