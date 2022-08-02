class Services::GettingProductDistributer::Favourite
  extend Utils

    # def self.call
    #   puts '=====>>>> START Loftit XML '+Time.now.to_s
    #
    #   Product.where(distributor: "Loftit").each {|tov| tov.update(quantity: 0, check: false)}
    #
    #   uri = "https://loftit.ru/catalog.xml"
    #
    #
    #   response = RestClient.get uri, :accept => :xml, :content_type => "application/xml"
    #   doc_data = Nokogiri::XML(response)
    #   doc_offers = doc_data.xpath("//offer")
    #
    #   doc_categories = doc_data.xpath("//category")
    #   categories = hash_categories(doc_categories)
    #
    #   param_name = Services::CompareParams.new("Loftit")
    #
    #   doc_offers.each do |doc_offer|
    #     doc_params = doc_offer.xpath("param")
    #     hash_arr_params = hash_params(doc_params, param_name)
    #
    #     # next if guard_exclude(hash_arr_params, ["Ambiente", "Brizzi"])
    #
    #     params = product_params(hash_arr_params)
    #
    #     catId = doc_offer.xpath("categoryId").text
    #     cats = get_cats(categories[catId])
    #     cats << doc_params.search('[name="Категория"]').text
    #
    #     data = {
    #       fid: doc_offer["id"] + "___loftit",
    #       title: get_text_by_tag(doc_offer, "name"),
    #       sku: get_text_by_tag(doc_offer, "vendorCode"),
    #       url: get_text_by_tag(doc_offer, "url"),
    #       distributor: "Loftit",
    #       vendor: get_text_by_tag(doc_offer, "vendor"),
    #       image: doc_offer.xpath("picture").map(&:text).join(' '),
    #       cat: "Loftit",
    #       cat1: cats[0],
    #       cat2: cats[1],
    #       cat3: cats[2],
    #       cat4: cats[3],
    #       price: doc_offer.xpath("price") ? doc_offer.xpath("price").text : 0,
    #       oldprice: get_text_by_tag(doc_offer, "oldprice") == data[:price] ? nil : get_text_by_tag(doc_offer, "oldprice"),
    #       purchase_price: nil,
    #       quantity: doc_offer.xpath("stock") ? doc_offer.xpath("stock").text : 0,
    #       barcode: get_text_by_tag(doc_offer, "barcode"),
    #       desc: nil,
    #       p1: params.join(" --- "),
    #       video: nil,
    #       currency: nil,
    #       weight: hash_arr_params["Вес брутто, кг"] ? hash_arr_params["Вес брутто, кг"].join("") : nil,
    #       check: true
    #     }
    #
    #     product = Product.find_by(fid: data[:fid])
    #     product ? product.update(data) : Product.create(data)
    #     puts "ok"
    #   end
    #   puts '=====>>>> FINISH Loftit XML '+Time.now.to_s
    # end
    #
    # def self.get_text_by_tag(doc_offer, tag)
    #   doc_offer.xpath(tag) ? doc_offer.xpath(tag).text : nil
    # end
    #
    # def self.product_params(hash_arr_params)
    #   arr_exclude = []
    #   result = hash_arr_params.map do |key, value|
    #     next if arr_exclude.include?(key)
    #     value = value.join(", ").gsub(/true/, "Да").gsub(/false/, "Нет")
    #     value = replace_semi_to_dot(key, value)
    #     "#{key.gsub("/","&#47;")}: #{value}" if value.present?
    #   end.compact
    #   result << "Поставщик: Loftit"
    #   result << "Статус у поставщика: true"
    #   result
    # end
    #
    # def self.hash_params(doc_params, param_name)
    #   arr_arr_params = doc_params.map do |doc_param|
    #     [
    #       doc_param["name"], doc_param.text
    #     ]
    #   end
    #   new_arr_arr_params = []
    #   arr_arr_params.map do |arr|
    #     common_name_param = param_name.compare(arr[0])
    #     new_arr_arr_params << [common_name_param, arr[1]] if common_name_param.present?
    #   end.compact
    #   Hash[ new_arr_arr_params.group_by(&:first).map{ |k,a| [k,a.map(&:last).uniq] } ]
    # end
    #
    # def self.hash_categories(doc_categories)
    #   categories = {}
    #   doc_categories.each do |doc_category|
    #     categories[doc_category["id"]] = structure_category(doc_categories, doc_category)
    #   end
    #   categories
    # end
    #
    # def self.structure_category(doc_categories, doc_category)
    #   doc_parent_category = doc_categories.find {|doc_c| doc_c["id"] == doc_category["parentId"]}
    #   {
    #     name: doc_category.text,
    #     parentId: doc_category["parentId"] ? structure_category(doc_categories, doc_parent_category) : nil
    #   }
    # end
    #
    # def self.get_cats(category, arr_cats = [])
    #   arr_cats << category[:name]
    #
    #   if category[:parentId].present?
    #     get_cats(category[:parentId], arr_cats)
    #   end
    #   arr_cats.reverse
    # end

    # def self.guard_exclude(hash_arr_params, list_exclude)
    #   find_from = hash_arr_params["Бренд"]
    #   intersection = find_from & list_exclude
    #   intersection.present?
    # end

end
