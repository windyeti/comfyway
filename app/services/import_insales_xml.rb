class Services::ImportInsalesXml
  def self.call
    puts '=====>>>> СТАРТ InSales YML '+Time.now.to_s

    Product.all.each {|tov| tov.update(check: false)}

    uri = "https://myshop-bqx711.myinsales.ru/marketplace/89637.xml"
    response = RestClient.get uri, :accept => :xml, :content_type => "application/xml"
    data = Nokogiri::XML(response)
    offers = data.xpath("//offer")

    categories = {}
    doc_category = data.xpath("//category")

    doc_category.each do |c|
      categories[c["id"]] = c.text
    end


    offers.each do |pr|
      params = []
      pr.xpath("param").each do |p|
        name = p["name"]
        text = p.text
        params << "#{name}: #{text}"
      end

      pp data_create = {
        sku: pr.xpath("vendorCode").text,
        title: pr.xpath("model").text,
        url: pr.xpath("url").text,
        desc: pr.xpath("description").text,
        distributor: pr.xpath("vendor").text,
        image: pr.xpath("picture").map(&:text).join(' '),
        cat: categories[pr.xpath("categoryId").text],
        price: pr.xpath("price").text.to_f,
        oldprice: pr.xpath("oldprice").text.to_f,
        p1: params.join(' --- '),
        insales_id: pr["group_id"],
        insales_var_id: pr["id"],
      }

      pp data_update = {
        sku: pr.xpath("vendorCode").text,
        title: pr.xpath("model").text,
        url: pr.xpath("url").text,
        desc: pr.xpath("description").text,
        distributor: pr.xpath("vendor").text,
        image: pr.xpath("picture").map(&:text).join(' '),
        cat: categories[pr.xpath("categoryId").text],
        price: pr.xpath("price").text.to_f,
        oldprice: pr.xpath("oldprice").text.to_f,
        p1: params.join(' --- '),
        check: true,
      }
      product = Product
                  .find_by(insales_var_id: data_create[:insales_var_id])

      product.present? ? product.update_attributes(data_update) : Product.create!(data_create)
      pp product
    end
    puts '=====>>>> FINISH InSales YML '+Time.now.to_s
  end
end
