module ProductsHelper
  def addition_class(query)
    @search.send(query).nil? ? '' : ' option_selected'
  end
end
