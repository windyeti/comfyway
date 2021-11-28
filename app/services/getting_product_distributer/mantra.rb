class Services::GettingProductDistributer::Mantra

  def self.call
    puts '=====>>>> START Mantra YML '+Time.now.to_s

    Product.where(distributor: "Mantra").each {|tov| tov.update(quantity: 0, check: false)}

    uri = "https://mantra-opt.ru/bitrix/catalog_export/export_wDF.xml"


    response = RestClient.get uri, :accept => :xml, :content_type => "application/xml"
    doc_data = Nokogiri::XML(response)
    doc_offers = doc_data.xpath("//offer")

    doc_categories = doc_data.xpath("//category")
    categories = hash_categories(doc_categories)

    param_name = Services::CompareParams.new("MANTRA")

    doc_offers.each do |doc_offer|
      doc_params = doc_offer.xpath("param")
      hash_arr_params = hash_params(doc_params)
      params = product_params(hash_arr_params, param_name)

      catId = doc_offer.xpath("categoryId").text
      cats = get_cats(categories[catId])

      data = {
        fid: doc_offer["id"] + "___mantra",
        title: doc_offer.xpath("model") ? doc_offer.xpath("model").text : nil,
        sku: hash_arr_params["Артикул"] ? hash_arr_params["Артикул"].join("") : nil,
        url: doc_offer.xpath("url") ? doc_offer.xpath("url").text : nil,
        distributor: "Mantra",
        vendor: doc_offer.xpath("vendor") ? doc_offer.xpath("vendor").text : nil,
        image: doc_offer.xpath("picture").map(&:text).join(' '),
        cat: "Mantra",
        cat1: cats[0],
        cat2: cats[1],
        price: doc_offer.xpath("price") ? doc_offer.xpath("price").text : nil,
        quantity: hash_arr_params["Остаток"] ? hash_arr_params["Остаток"].join("") : 0,
        barcode: doc_offer.xpath("barcode") ? doc_offer.xpath("barcode").text : nil,
        desc: doc_offer.xpath("description") ? doc_offer.xpath("description").text.gsub("\n", " ") : nil,
        p1: params,
        video: nil,
        currency: doc_offer.xpath("currencyId") ? doc_offer.xpath("currencyId").text : nil,
        check: true
      }

      product = Product.find_by(fid: data[:fid])
      product ? product.update(data) : Product.create(data)
      puts "ok"
    end
    puts '=====>>>> FINISH Mantra YML '+Time.now.to_s
  end

  def self.product_params(hash_arr_params, param_name)
    arr_exclude = ["Артикул", "Остаток"]
    result = hash_arr_params.map do |key, value|
      next if arr_exclude.include?(key)
      name = param_name.compare(key)
      "#{name}: #{value.join("##")}"
    end.reject(&:nil?)
    result.join(" --- ")
  end

  def self.hash_params(doc_params)
    arr_arr_params = doc_params.map do |doc_param|
      [
        doc_param["name"], doc_param.text
      ]
    end
    Hash[ arr_arr_params.group_by(&:first).map{ |k,a| [k,a.map(&:last)] } ]
  end

  def self.hash_categories(doc_categories)
    categories = {}
    doc_categories.each do |doc_category|
      categories[doc_category["id"]] = structure_category(doc_categories, doc_category)
    end
    categories
  end

  def self.structure_category(doc_categories, doc_category)
    doc_parent_category = doc_categories.find {|doc_c| doc_c["id"] == doc_category["parentId"]}
    {
      name: doc_category.text,
      parentId: doc_category["parentId"] ? structure_category(doc_categories, doc_parent_category) : nil
    }
  end

  def self.get_cats(category, arr_cats = [])
    arr_cats << category[:name]

    if category[:parentId].present?
      get_cats(category[:parentId], arr_cats)
    end
    arr_cats.reverse
  end

end
