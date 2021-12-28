class InsalesController < ApplicationController
  def index
    if params[:q]
      @params = params[:q]
      # @params[:combinator] = 'or'

      @params.delete(:abc_id_not_null) if @params[:abc_id_not_null] == '0'
      @params.delete(:abc_id_null) if @params[:abc_id_null] == '0'

      # делаем доступные параметры фильтров, чтобы их поместить их в параметр q «кнопки создать csv по фильтру»
      @params_q_to_csv = @params.permit(:sku_or_title_cont,
                                        :distributor_eq,
                                        :quantity_eq,
                                        :price_gteq,
                                        :price_lteq,
                                        :abc_id_eq,
                                        :faro_id_eq,
                                        :abc_id_or_faro_id_not_null,
                                        :abc_id_and_faro_id__null,
                                        )
    else
      @params = []
    end

    @search = Product.ransack(@params)
    @search.sorts = 'id desc' if @search.sorts.empty?

    # данные для «кнопки создать csv по фильтру», все данные в отличии от @products, который ограничен 100
    @search_id_by_q = Product.ransack(@params_q_to_csv).result.pluck(:id)

    @products = @search.result.paginate(page: params[:page], per_page: 100)

    if params['otchet_type'] == 'selected'
      Services::CsvSelected.call(@search_id_by_q)
      redirect_to '/product_selected.csv'
    end
  end
end
