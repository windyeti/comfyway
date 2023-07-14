class Services::GettingProductDistributer::Elevel
  extend Utils

  BRANDS_FULL = ["Arlight", "Arte Lamp", "Divinare"].freeze
  BRANDS_PARTIAL = ["Schneider Electric", "Legrand"].freeze

  CATEGORIES_PARTIAL = [
    "Выключатели с дистанционным управлением",
    "Инфракрасный выключатель (ИК ДУ)",
    "Выключатели, переключатели и диммеры",
    "Накладка для выключателей/ диммеров/ жалюзийных переключателей/ таймеров",
    "Кнопка / Кнопочный выключатель",
    "Жалюзийный выключатель/ переключатель/ кнопка",
    "Шнуровой выключатель / светорегулятор (диммер)",
    "Выключатель с электронной коммутацией",
    "Блок комбинированный - кнопка/ выключатель/ розетка",
    "Блок комбинированный (комбинация выключателя и розеток)",
    "Диммер/светорегулятор шинной системы",
    "Усилитель мощности диммера",
    "Диммер (светорегулятор)",
    "Вывод кабеля (розетка потолочная) для потолочных светильников",
    "Мультимедийная розетка / многофункциональная соединительная коробка ",
    "Монтажная коробка с предустановленными силовыми розетками (для монтажа в пол)",
    "Настольный розеточный блок ",
    "Основание (розетка) для установки энергетической стойки",
    "Розетки антенные, информационные, коммуникационные",
    "Розетка/коробка коммуникационная (для передачи данных медной витой парой)",
    "Розетка антенная (TV/ТВ/SAT/FM/R/Радио)",
    "USB розетка (зарядное устройство)",
    "Розетка для выравнивания потенциалов",
    "Розеточный таймер",
    "Выключатель / Переключатель",
    "Рамки, суппорты, адаптеры и декоративные элементы для ЭУИ",
    "Рамка для электроустановочных устройств",
    "Европейская розетка/вилка без защитного контакта",
    "Таймеры",
    "Мультимедиа накладка/вставка для коммуникационных устройств",
    "Переходник-адаптер/рамка промежуточная для электроустановочных устройств",
    "Суппорт/монтажное основание для ЭУИ скрытого монтажа",
    "Корпус (адаптер) для накладного монтажа ЭУИ скрытой установки",
    "Декоративный элемент/ вставка/ накладка для электроустановочных изделий",
    "Электроустановочные устройства различного назначения",
    "Кластер ЭУИ",
    "Устройство управления рольставнями/жалюзи",
    "Сенсорная клавиша для информационной шины",
    "Электроустановочные изделия",
    "Устройства управления жалюзи, звуком, сигнализацией, климатом",
    "Комнатный терморегулятор / термостат",
    "Терморегулятор комнатный (термостат)",
    "Термостат с таймером",
    "Комнатный термостат с таймером (хронотермостат)",
    "Розетка силовая (штепсельная)",
    "Накладка/вставка/механизм для коммуникационных устройств"
  ].freeze

  BRAND_GAUSS_PARTIAL = ['Gauss'].freeze

  CATEGORIES_GAUSS_PARTIAL = ['Лампа светодиодная (LED)'].freeze

  EXCLUDE_KELVIN = [
    '(более 5000)', '5000', '5300', '5400', '5500', '5600', '5700', '5750', '5800', '6000', '6250',
    '6500', '7000', '7300', '7500', '7700', '8000', '9000', '10000', '11000', '15000'
  ].freeze

  EXCLUDE_CATEGORIES = [
    'Кабель для связи и передачи данных', 'Клемма безвинтовая (розеточная)',
    'Модуль светодиодный (LED)', 'Одно- и многополюсная клемма/ клеммная колодка',
    'Светильник для освещения высоких пролетов (хайбей)',
    'Светильник переносной (ручной)', 'Светодиод одиночный (LED)',
    'Фонарь ручной', 'Фонарь-прожектор переносной (ручной)'
  ].freeze

  attr_reader :param_name
  def initialize
    @auth = 'Basic ' + Base64.strict_encode64("#{Rails.application.credentials.krokus[:user]}:#{Rails.application.credentials.krokus[:password]}").chomp
    @param_name = Services::CompareParams.new("Elevel")
  end

  def call
    puts '=====>>>> СТАРТ Elevel API '+Time.now.to_s
    arr_brands_categories =
      [
        {
          brands: BRANDS_FULL,
          categories: nil
        },
        {
          brands: BRANDS_PARTIAL,
          categories: get_ids_categories(CATEGORIES_PARTIAL)
        },
        {
          brands: BRAND_GAUSS_PARTIAL,
          categories: get_ids_categories(CATEGORIES_GAUSS_PARTIAL)
        },
      ]

    Product.where(distributor: "Elevel").each {|tov| tov.update(quantity: 0, quantity_add: 0, check: false)}

    arr_brands_categories.each do |brands_categories|
      brands_categories[:brands].each do |brand|
        products = get_products_by_brand(brand)

        products.each do |product|
          p "2642151" if product["id"] == "2642151"
        end

        if brands_categories[:categories].present?
          products = get_product_by_category(products, brands_categories[:categories])
        else
          products = get_product(products)
        end
        products_for_create = get_products_for_create(products)
        create_new_products(products_for_create)
        products_for_update = products - products_for_create
        update_price_quantity(products_for_update)
      end
    end
    puts '=====>>>> FINISH Elevel API '+Time.now.to_s
  end

  private

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

  def get_product(products)
    ids = products.pluck("id")
    products_full = []
    page = 1
    page_size = 100

    loop do
      payload = {
        "ids": ids
      }
      url = "http://swop.krokus.ru/ExchangeBase/hs/catalog/nomenclature?fieldSet=max&pageSize=#{page_size}&page=#{page}"
      new_product_full = api_elevel(url, payload)["nomenclatures"]
      break if new_product_full.nil?
      products_full += new_product_full
      page += 1
    end
    products_full
  end

  def get_product_by_category(products, categories)
    products = products.select do |product|
      categories.include?(product["categoryid"])
    end
    get_product(products)
  end

  def get_products_for_create(products)
    app_ids = Product.where(distributor: "Elevel").map {|t| t.fid.gsub("___elevel","")}
    products_ids = products.pluck("id")
    ids_for_create = products_ids - app_ids
    result = products.select {|t| ids_for_create.include?(t["id"]) }
    result
  end

  def create_new_products(products)
    prices = get_prices(products)
    quantities = get_quantities(products)
    categories = get_categories(products)

    hash_id_price = get_id_price(prices)
    hash_id_quantity = get_id_quantity(quantities)
    hash_id_category = get_id_category(categories)

    products.each do |product|
      id = product["id"]
      arr_all_params_product = arr_all_params(product) # ==> [[name1, value1],[name2, value2]]
      id_cat = product["categoryId"]
      hash_arr_params_product = arr_arr_params(arr_all_params_product, param_name) # ==> Hash {name1: [value12, value12], name2: [value21, value22]}

      # товар не берем, условия для исключения товара
      next if exclude_product?(id_cat, hash_id_category, hash_arr_params_product)

      params = product_params(hash_arr_params_product) # ==> + проверка на исключение параметров "Параметр1: значени1, значени2 ---  Параметр2: значени3, значени4 --- ..."

      prices = get_prices_product(hash_id_price, product)

      data = {
        fid:  "#{product["id"]}___elevel",
        title: product["name"],
        sku: product["manufacturerCode"],
        desc: product["description"],
        vendor: product["manufacturerName"],
        distributor: "Elevel",
        image: product["images"].map {|image| image["link"]}.join(" "),
        video: product["youtube"]["link"],
        barcode: product["barcodes"].join(", "),
        unit: product["unit"]["name"],
        cat: "Elevel",
        cat1: hash_id_category[id_cat][0],
        cat2: hash_id_category[id_cat][1],
        cat3: hash_id_category[id_cat][2],
        cat4: hash_id_category[id_cat][3],
        price: prices[:price],
        purchase_price: prices[:purchase_price],
        quantity: hash_id_quantity[id][:stockamount].to_i + hash_id_quantity[id][:stockamount_add].to_i,
        quantity_add: hash_id_quantity[id][:stockamount_add],
        p1: params,
        weight: product["weight"] ? product["weight"]["unitCount"] : nil,
        currency: "RUR",
        check: true
      }
      Product.create(data)
    end
    p '---------'
  end

  def exclude_product?(id_cat, hash_id_category, hash_arr_params_product)
    (hash_arr_params_product["Цветовая температура, K"] & EXCLUDE_KELVIN).present? || (hash_id_category[id_cat] & EXCLUDE_CATEGORIES).present?
  end

  def product_params(hash_arr_params_product)
    arr_exclude = []
    result = hash_arr_params_product.map do |name, value|
      next if arr_exclude.include?(name)
      value = value.join(", ").gsub(/true/, "Да").gsub(/false/, "Нет")
      value = self.class.replace_semi_to_dot(name, value)
      "#{name.gsub("/","&#47;")}: #{value}" if value.present?
    end.compact
    result << "Статус у поставщика: true"
    result.join(" --- ")
  end

  def arr_all_params(product)
    result = []
    product["attributes"].each do |attribute|
      name = attribute["name"].gsub("/","&#47;")
      value = attribute["value"] || attribute["valueId"]["value"]
      result << [ name, value ] if value.present?
    end
    if product["metaproperties"].present?
      product["metaproperties"].each do |attribute|
        name = attribute["name"].gsub("/","&#47;")
        value = attribute["valueText"] || attribute["valueId"]["value"]
        result << [ name, value ] if value.present?
      end
    end
    result << [ "Вес, кг", product["weight"]["unitCount"] ] if product["weight"]
    result << [ "Бренд", product["brandName"] ]
    result << ["Поставщик", "Elevel"]
    result.uniq
  end

  def arr_arr_params(arr_arr, param_name)
    new_arr_arr_params = []
    arr_arr.map do |arr|
      common_name_param = param_name.compare(arr[0])
      new_arr_arr_params << [common_name_param, arr[1]] if common_name_param.present?
    end.compact
    Hash[ new_arr_arr_params.group_by(&:first).map{ |k,a| [k,a.map(&:last).uniq] } ]
  end

  def get_id_price(prices)
    result = {}
    prices.each do |price|
      key = price["id"]
      result[key] = {
        price_basic: price["priceBasic"],
        price: price["price"]
      }
    end
    result
  end

  def get_id_quantity(quantities)
    result = {}
    quantities.each do |quantity|
      key = quantity["id"]
      result[key] = {
        stockamount: quantity["stockamount"],
        stockamount_add: quantity["stockamountAdd"]
      }
    end
    result
  end

  def get_id_category(categories)
    result = {}
    categories.each do |list|
      list_categories = list["categories"]
      key = list_categories[0]["id"]
      next if result[key].present?
      result[key] = list_categories.map { |category| category["name"] }.reverse
    end
    result
  end

  def get_prices_product(hash_id_price, product)
    batch_quantity = nil
    # передаем цену как есть, без деления на "Кратность заказа постащику"
    # product["attributes"].each do |attribute|
    #   if attribute["name"] == "Кратность заказа поставщику"
    #     batch_quantity = attribute["value"].to_f
    #   end
    # end

    id = product["id"]

    if batch_quantity
      # price = hash_id_price[id][:price_basic].to_f / batch_quantity
      # purchase_price = hash_id_price[id][:price].present? ? hash_id_price[id][:price].to_f / batch_quantity : 0
    else
      price = hash_id_price[id][:price_basic]
      purchase_price = hash_id_price[id][:price].present? ? hash_id_price[id][:price] : 0
    end
    {
      price: price,
      purchase_price: purchase_price
    }
  end

  def update_price_quantity(products)
    prices = get_prices(products)
    quantities = get_quantities(products)

    hash_id_price = get_id_price(prices)
    hash_id_quantity = get_id_quantity(quantities)

    products.each do |product|
      arr_all_params_product = arr_all_params(product) # ==> [[name1, value1],[name2, value2]]
      hash_arr_params_product = arr_arr_params(arr_all_params_product, param_name) # ==> Hash {name1: [value12, value12], name2: [value21, value22]}
      params = product_params(hash_arr_params_product) # ==> + проверка на исключение параметров "Параметр1: значени1, значени2 ---  Параметр2: значени3, значени4 --- ..."

      id = product["id"]
if id == "2642151"
  p '========================================================================================================================'
  p "2642151"
  p hash_id_quantity[id][:stockamount].to_i
  p hash_id_quantity[id][:stockamount_add].to_i
  p hash_id_quantity[id][:stockamount].to_i + hash_id_quantity[id][:stockamount_add].to_i
  p '========================================================================================================================'
end
      prices = get_prices_product(hash_id_price, product)

      fid = "#{product["id"]}___elevel"
      product_db = Product.find_by(fid: fid)

      product_db.update(
        price: prices[:price],
        purchase_price: prices[:purchase_price],
        image: product["images"].map {|image| image["link"]}.join(" "),
        quantity: hash_id_quantity[id][:stockamount].to_i + hash_id_quantity[id][:stockamount_add].to_i,
        quantity_add: hash_id_quantity[id][:stockamount_add],
        p1: params,
        check: true
      )
    end
    p '------++++++++------'
  end

  def get_prices(products_for_create)
    url = 'http://swop.krokus.ru/ExchangeBase/hs/catalog/pricesOffline'
    payload = {
      "ids": products_for_create.pluck("id")
    }
    result = api_elevel(url, payload)["prices"]
    result.present? ? result : []
  end

  def get_quantities(products_for_create)
    url = 'http://swop.krokus.ru/ExchangeBase/hs/catalog/stockOfGoodsOffline'
    payload = {
      "ids": products_for_create.pluck("id")
    }
    result = api_elevel(url, payload)["stockOfGoods"]
    result.present? ? result : []
  end

  def get_categories(products_for_create)
    url = 'http://swop.krokus.ru/ExchangeBase/hs/catalog/categoryPathToRoot'
    payload = {
      "ids": products_for_create.pluck("categoryId")
    }
    result = api_elevel(url, payload)["pathToRoot"]
    result.present? ? result : []
  end

  def get_ids_categories(name_categories)
    url = 'http://swop.krokus.ru/ExchangeBase/hs/catalog/allcategory'
    payload = {}
    categories_response = api_elevel(url, payload)

    categories_response.map {|c| c["id"] if name_categories.include?(c["name"])}.compact
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

