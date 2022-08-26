# namespace :gauss do
#   task start: :environment do
# p '-------------'
#     p categories = get_ids_categories(['Лампа светодиодная (LED)', "Лампы светодиодные", 'Лампы специального назначения'])
# p '-------------'
#     products = get_products_by_brand("Gauss")
#     p products.count
#     products = get_product_by_category(products, categories)
#     p products.count
#   end
#
#   # task cat: :environment do
#   #   p get_ids_categories(["Лампа светодиодная (LED)"])
#   # end
#
#   def get_ids_categories(name_categories)
#     url = 'http://swop.krokus.ru/ExchangeBase/hs/catalog/allcategory'
#     payload = {}
#     categories_response = api_elevel(url, payload)
#
#     # categories_response.map do |c|
#     #   File.open("#{Rails.public_path}/cat.txt", "a+") {|f| f.write("#{c["name"]}\n")}
#     # end
#     categories_response.map {|c| c["id"] if name_categories.include?(c["name"])}.compact
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
#   def get_product_by_category(products, categories)
#     products = products.select do |product|
#       categories.include?(product["categoryid"])
#     end
#     get_product(products)
#   end
#
#   def get_product(products)
#     ids = products.pluck("id")
#     products_full = []
#     page = 1
#     page_size = 100
#
#     loop do
#       payload = {
#         "ids": ids
#       }
#       url = "http://swop.krokus.ru/ExchangeBase/hs/catalog/nomenclature?fieldSet=max&pageSize=#{page_size}&page=#{page}"
#       new_product_full = api_elevel(url, payload)["nomenclatures"]
#       break if new_product_full.nil?
#       products_full += new_product_full
#       page += 1
#     end
#     products_full
#   end
# end
