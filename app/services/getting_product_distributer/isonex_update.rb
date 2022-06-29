class Services::GettingProductDistributer::IsonexUpdate
  def self.call
    puts '=====>>>> START Isonex XML '+Time.now.to_s
    Product.where(distributor: "Isonex").each {|tov| tov.update(quantity: 0, check: false)}

    uri = "http://isonex.ru/upload/stocks.xml"

    response = RestClient.get uri, :accept => :xml, :content_type => "application/xml"
    doc_data = Nokogiri::XML(response)
    doc_items = doc_data.xpath("//item")

    doc_items.each do |doc_item|
      fid = doc_item.xpath("article") + "___isonex"
      quantity = doc_item.xpath("stock")
      discount = doc_item.xpath("discount").gsub(/,/,".")
      oldprice = discount > 0 ? doc_item.xpath("price").gsub(/,/,".") : nil
      price = oldprice.to_f - discount.to_f

      data = {
        price: price,
        oldprice: oldprice,
        quantity: quantity,
        check: true
      }

      product = Product.find_by(fid: fid)
      product.update(data) if product.present?
      puts "ok"
    end
    puts '=====>>>> FINISH Isonex XLM '+Time.now.to_s
  end
end
