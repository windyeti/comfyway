class Services::GettingProductDistributer::Elevel
  def self.call
    puts '=====>>>> СТАРТ Krokus API '+Time.now.to_s
    brands = [ "Arlight", "Arte Lamp", "Divinare", "Berker", "Evoluce", "Favourite", "F-PROMO", "Freya", "Gauss",
    "Kink Light", "Lightstar", "Lumion", "Maytoni", "Markslojd", "Novotech", "Odeon Light", "Sonex", "St Luce",
    "Voltega", "Quest Light", "ABB", "BIRONI", "Bticino", "Bticino Living Now", "GIRA", "JUNG", "legrand",
    "Schneider Electric", "Simon", "Zamel" ]

    # Product.where(distributor: "Krokus").each {|tov| tov.update(quantity: 0, check: false)}
count = 0
brands.each do |brand|
    auth = 'Basic ' + Base64.strict_encode64("#{Rails.application.credentials.krokus[:user]}:#{Rails.application.credentials.krokus[:password]}").chomp
    url = 'http://swop.krokus.ru/ExchangeBase/hs/catalog/getidbyarticles'
    payload = {
      "articles": [
        brand
      ],
      "typeOfSearch": "Бренд"
    }
    response_ids = Services::ApiElevel.call(url, auth, payload)["result"]
    # count += response_ids.count
    pp brand, response_ids.count
    p "======================="

    url = 'http://swop.krokus.ru/ExchangeBase/hs/catalog/nomenclature?fieldSet=max'
    pp payload = {
      "ids": [
        response_ids.first["id"]
      ]
    }
    pp response_product = Services::ApiElevel.call(url, auth, payload)
end
    # p count



    # rows = CSV.read(path_file, headers: true, col_sep: ';', encoding: 'windows-1251:utf-8').map do |row|
    #   row.to_a
    # end
    #
    # param_name = Services::CompareParams.new("Ledron")
    # arr_exclude_key = ["Тип строки", "Наименование", "Код артикула", "Валюта", "Цена", "Доступен для заказа",
    #                    "Изображения товаров", "Доступен для заказа",
    #                    "Закупочная цена", "В наличии", "Идентификатор 1С", "status", "ID товара", "Адрес видео на YouTube или Vimeo",
    #                    "Товар: Идентификатор 1С", "Категория", "META Keywords", "META Description", "Заголовок", "Ссылка на витрину",
    #                    "Остаток", "Краткое описание"]
    # rows.each do |row|
    #   hash_arr_params = hash_params(row, param_name)
    #
    #   params = ["Поставщик: Ledron"]
    #   hash_arr_params.map do |key, value|
    #     value = value.reject(&:nil?).join("##")
    #     next if arr_exclude_key.include?(key) || value == ""
    #     params << "#{key}: #{value.gsub(/:/, "&#58;").gsub(/-{3}/, "&#8722;&#8722;&#8722;")}"
    #   end
    #
    #   data = {
    #     fid: hash_arr_params["ID товара"].join(", ") + "___ledron",
    #     title: hash_arr_params["Наименование"].join(", "),
    #     url: "https://ledron.ru/product/" + hash_arr_params["Ссылка на витрину"].join(", "),
    #     sku: hash_arr_params["Артикул"].join(", "),
    #     desc: hash_arr_params["Краткое описание"].join("<br>"),
    #     distributor: "Ledron",
    #     image: hash_arr_params["Изображения товаров"].reject(&:nil?).join(" "),
    #     video: hash_arr_params["Адрес видео на YouTube или Vimeo"].join(", "),
    #     cat: "Ledron",
    #     cat1: hash_arr_params["Категория"].join(", "),
    #     price: hash_arr_params["Цена"].join(", ").present? ? hash_arr_params["Цена"].join(", ") : 0,
    #     purchase_price: hash_arr_params["Закупочная цена"].join(", "),
    #     currency: hash_arr_params["Валюта"].join(", "),
    #     mtitle: hash_arr_params["Заголовок"].join(", "),
    #     mkeywords: hash_arr_params["META Keywords"].join(", "),
    #     mdesc: hash_arr_params["META Description"].join(", "),
    #     p1: params.reject(&:nil?).join(" --- "),
    #     check: true
    #   }
    #
    #   product = Product.find_by(fid: data[:fid])
    #   product ? product.update(data) : Product.create(data)
    #   puts "ok"
    # end
    puts '=====>>>> FINISH Krokus API '+Time.now.to_s
  end

  # def self.hash_params(row, param_name)
  #   new_arr_arr_params = []
  #   row.map do |arr|
  #     new_arr_arr_params << [param_name.compare(arr[0]), arr[1]]
  #   end
  #   Hash[ new_arr_arr_params.group_by(&:first).map{ |k,a| [k,a.map(&:last)] } ]
  # end
end

