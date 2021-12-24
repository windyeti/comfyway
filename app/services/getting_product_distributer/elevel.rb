class Services::GettingProductDistributer::Elevel
  def initialize
    @auth = 'Basic ' + Base64.strict_encode64("#{Rails.application.credentials.krokus[:user]}:#{Rails.application.credentials.krokus[:password]}").chomp
  end

  def call
    puts '=====>>>> СТАРТ Elevel API '+Time.now.to_s
    arr_brands_categories =
      [
        {
          brands: ["Arlight", "Arte Lamp", "Evoluce", "Favourite", "F-PROMO", "Kink Light", "Lumion", "Markslojd", "Novotech", "Odeon Light"],
          categories: nil
        },
        {
          brands: ["ABB", "Schneider Electric", "Legrand"],
          categories: get_ids_categories([
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
            "Комнатный термостат с таймером (хронотермостат)"
    ])
        },
      ]

    # Product.where(distributor: "Elevel").each {|tov| tov.update(quantity: 0, quantity_add: 0, check: false)}

    arr_brands_categories.each do |brands_categories|
      brands_categories[:brands].each do |brand|
        products = get_products_by_brand(brand)

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
      p1 = get_p1(product)
      id_cat = product["categoryId"]

        data = {
          fid:  "#{product["id"]}___elevel",
          title: product["name"],
          sku: product["articulElevel"],
          desc: product["description"],
          vendor: product["manufacturerName"],
          distributor: "Elevel",
          image: product["images"].map {|image| image["link"]}.join(" "),
          video: product["youtube"]["link"],
          barcode: product["barcodes"].join(", "),
          cat: "Elevel",
          cat1: hash_id_category[id_cat][0],
          cat2: hash_id_category[id_cat][1],
          cat3: hash_id_category[id_cat][2],
          cat4: hash_id_category[id_cat][3],
          price: hash_id_price[id][:price_basic],
          purchase_price: hash_id_price[id][:price],
          quantity: hash_id_quantity[id][:stockamount],
          quantity_add: hash_id_quantity[id][:stockamount_add],
          p1: p1.join(" --- "),
          check: true
        }
      Product.create(data)
    end
    p '---------'
  end

  def get_p1(product)
    # /
    # в product["feature"] должны быть характеристики, но здесь пусто у всех товаров
    # /
    result = []
    result << "Вес, кг: #{product["weight"]["unitCount"]}" if product["weight"]
    result << "Бренд: #{product["brandName"]}"
    result
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

  def update_price_quantity(products)
    prices = get_prices(products)
    quantities = get_quantities(products)

    hash_id_price = get_id_price(prices)
    hash_id_quantity = get_id_quantity(quantities)

    products.each do |product|
      id = product["id"]
      fid = "#{product["id"]}___elevel"
      product = Product.find_by(fid: fid)
      product.update(
        price: hash_id_price[id][:price_basic],
        purchase_price: hash_id_price[id][:price],
        quantity: hash_id_quantity[id][:stockamount],
        quantity_add: hash_id_quantity[id][:stockamount_add],
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

