class Services::GettingProductDistributer::IsonexUpdate
  def self.call
    puts '=====>>>> START Isonex XML '+Time.now.to_s
    Product.where(distributor: "Isonex").each {|tov| tov.update(price: 0, quantity: 0, check: false)}

    uri = "http://isonex.ru/upload/stocks.xml"

    response = RestClient.get uri, :accept => :xml, :content_type => "application/xml"
    doc_data = Nokogiri::XML(response)
    doc_items = doc_data.xpath("//item")

    doc_items.each do |doc_item|
      fid = doc_item.xpath("article").text + "___isonex"
      quantity = doc_item.xpath("stock").text
      discount = doc_item.xpath("discount").text.gsub(/,/,".")
      if discount.to_f > 0
        oldprice = doc_item.xpath("price").text.gsub(/,/,".")
        price = oldprice.to_f - discount.to_f
      else
        oldprice = nil
        price = doc_item.xpath("price").text.gsub(/,/,".")
      end

      data = {
        price: price,
        oldprice: oldprice.to_f.ceil,
        quantity: quantity.to_f.ceil,
        check: true
      }

      product = Product.find_by(fid: fid)
      product.update(data) if product.present?
      puts "ok"
    end
    puts '=====>>>> FINISH Isonex XLM '+Time.now.to_s
  end
end
