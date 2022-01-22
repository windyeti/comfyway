class Services::ImportInsalesXml
  def self.call
    puts '=====>>>> СТАРТ InSales YML '+Time.now.to_s

    Product.all.each {|tov| tov.update(insales_check: false)}

    uri = "https://myshop-bqx711.myinsales.ru/marketplace/89637.xml"
    response = RestClient.get uri, :accept => :xml, :content_type => "application/xml"
    data = Nokogiri::XML(response)
    offers = data.xpath("//offer")

    offers.each do |pr|
      fid = pr.xpath("fid").text

      pp data_first_update = {
        insales_link: pr.xpath("url").text,
        desc: pr.xpath("description").text,
        image: pr.xpath("picture").map(&:text).join(' '),
        quantity: pr.xpath("quantity").text.to_f,
        insales_id: pr["group_id"],
        insales_var_id: pr["id"],
        insales_check: true
      }
      pp data_update = {
        insales_link: pr.xpath("url").text,
        desc: pr.xpath("description").text,
        image: pr.xpath("picture").map(&:text).join(' '),
        quantity: pr.xpath("quantity").text.to_f,
        insales_check: true
      }

      product = Product.find_by(fid: fid)

      if product.present?
        product.insales_var_id.present? ? product.update(data_update) : product.update(data_first_update)
      end
      pp product
    end
    puts '=====>>>> FINISH InSales YML '+Time.now.to_s
  end
end
