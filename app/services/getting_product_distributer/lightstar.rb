class Services::GettingProductDistributer::Lightstar
  extend Utils

  def self.call
    puts "=====>>>> START Lightstar YML #{Time.now}"

    Product.where(distributor: "Lightstar").each {|tov| tov.update(quantity: 0, check: false)}

    uri_quantity = "https://lightstar.ru/today/stock.htm"
    response_quantity = RestClient.get uri_quantity
    doc_data_quantity = Nokogiri::HTML(response_quantity)
    doc_trs = doc_data_quantity.css("tr")

    sku_quantity = {}
    doc_trs.each_with_index do |doc_tr, index|
    next if index == 0 || index == 1
    doc_tds = doc_tr.css("td")
    sku_quantity[doc_tds[0].text.strip.gsub(/ /, "")] = {
                                  quantity: doc_tds[5].text.strip,
                                  date: doc_tds[6].text.strip
                                }
    end

    uri = "https://lightstar.ru/image/yml/lightstar_rozn.yml"

    response = RestClient.get uri, :accept => :xml, :content_type => "application/xml"
    doc_data = Nokogiri::XML(response)
    doc_offers = doc_data.xpath("//offer")

    doc_categories = doc_data.xpath("//category")
    categories = hash_categories(doc_categories)


    param_name = Services::CompareParams.new("LIGHTSTAR")

    doc_offers.each do |doc_offer|
      doc_params = doc_offer.xpath("param")
      hash_arr_params = hash_params(doc_params, param_name)
      params = product_params(hash_arr_params)

      catId = doc_offer.xpath("categoryId").text
      cats = get_cats(categories[catId])

      next if guard_exclude(hash_arr_params, cats)

      data = {
        fid: doc_offer["id"] + "___lightstar",
        title: hash_arr_params["Наименование"] ? hash_arr_params["Наименование"].join("") : nil,
        sku: hash_arr_params["Артикул"] ? hash_arr_params["Артикул"].join("").gsub(/\s$/, "") : nil,
        url: doc_offer.xpath("url") ? doc_offer.xpath("url").text : nil,
        distributor: "Lightstar",
        vendor: doc_offer.xpath("vendor") ? doc_offer.xpath("vendor").text : nil,
        image: doc_offer.xpath("picture").map(&:text).join(' '),
        cat: "Lightstar",
        cat1: cats[0],
        cat2: cats[1],
        cat3: cats[2],
        price: doc_offer.xpath("price") ? doc_offer.xpath("price").text : 0,
        purchase_price: 0,
        quantity: sku_quantity[hash_arr_params["Артикул"].join("").gsub(/\s$/, "")] ? sku_quantity[hash_arr_params["Артикул"].join("").gsub(/\s$/, "")][:quantity] : 0,
        barcode: doc_offer.xpath("barcode") ? doc_offer.xpath("barcode").text : nil,
        desc: nil,
        p1: params,
        video: nil,
        currency: doc_offer.xpath("currencyId") ? doc_offer.xpath("currencyId").text : nil,
        manual: hash_arr_params["Инструкция"] ? hash_arr_params["Инструкция"].join("") : nil,
        manuals: hash_arr_params["Инструкции"] ? hash_arr_params["Инструкции"].join(" ") : nil,
        preview_3d: hash_arr_params["3D preview"] ? hash_arr_params["3D preview"].join("") : nil,
        foto: hash_arr_params["Фото"] ? hash_arr_params["Фото"].join("") : nil,
        draft: hash_arr_params["Чертёж"] ? hash_arr_params["Чертёж"].join("") : nil,
        model_3d: hash_arr_params["3D-модель"] ? hash_arr_params["3D-модель"].join("") : nil,
        date_arrival: sku_quantity[hash_arr_params["Артикул"].join("").gsub(/\s$/, "")] ? sku_quantity[hash_arr_params["Артикул"].join("").gsub(/\s$/, "")][:date] : nil,
        weight: hash_arr_params["Вес брутто, кг"] ? hash_arr_params["Вес брутто, кг"].join("") : nil,
        check: true
      }

      product = Product.find_by(fid: data[:fid])
      product ? product.update(data) : Product.create(data)
    puts 'ok'
    end
    puts "=====>>>> FINISH Lightstar YML #{Time.now}"
  end

  def self.product_params(hash_arr_params)
    arr_exclude = ["Наименование", "Артикул", "Цена", "Валюта", "Штрихкод", "Остаток", "Инструкция", "Инструкции", "3D preview", "Фото", "Чертёж", "3D-модель"]
    result = hash_arr_params.map do |key, value|
      next if arr_exclude.include?(key)
      value = value.join(", ").gsub(/true/, "Да").gsub(/false/, "Нет")
      value = replace_semi_to_dot(key, value)
      "#{key.gsub("/","&#47;")}: #{value}" if value.present?
    end.compact
    result << "Поставщик: Lightstar"
    result << "Бренд: Lightstar"
    result << "Статус у поставщика: true"
    result.join(" --- ")
  end

  def self.hash_params(doc_params, param_name)
    arr_arr_params = doc_params.map do |doc_param|
      [
        doc_param["name"].gsub(/ \/ /, "/"), doc_param.text
      ]
    end
    new_arr_arr_params = []
    arr_arr_params.map do |arr|
      common_name_param = param_name.compare(arr[0])
      new_arr_arr_params << [common_name_param, arr[1]] if common_name_param.present?
    end.compact
    Hash[ new_arr_arr_params.group_by(&:first).map{ |k,a| [k,a.map(&:last).uniq] } ]
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

  def self.guard_exclude(hash_arr_params, cats)
    intersection = cats & ["Лента светодиодная на 220В и аксессуары", "Гибкий неон 220В и аксессуары"]
    intersection.present? || hash_arr_params["Стиль"] == "Классический"
  end
end
