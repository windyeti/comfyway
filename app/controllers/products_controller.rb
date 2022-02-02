class ProductsController < ApplicationController
  before_action :set_product, only: [:edit, :update, :destroy, :show]

  def index
    if params[:q]
      @params = params[:q]

      @params.delete(:deactivated_true) if @params[:deactivated_true] == '0'
      @params.delete(:deactivated_false) if @params[:deactivated_false] == '0'

      # делаем доступные параметры фильтров, чтобы их поместить их в параметр q «кнопки создать csv по фильтру»
      @params_q_to_csv = @params.permit(
                                        :title_or_sku_cont,
                                        :check_eq,
                                        :distributor_eq,
                                        :quantity_eq,
                                        :quantity_not_eq,
                                        :quantity_add_not_eq,
                                        :price_gteq,
                                        :price_lteq,
                                        :deactivated_eq,
                                        :insales_check_eq,
                                        :cat_or_cat1_or_cat2_or_cat3_or_cat4_cont
                                        )
    else
      @params = []
    end

    @search = Product.ransack(@params)
    @search.sorts = 'id desc' if @search.sorts.empty?

    # данные для «кнопки создать csv по фильтру», все данные в отличии от @products, который ограничен 100
    if @params.present?
      @search_id_by_q = Product.ransack(@params_q_to_csv)
    else
      @search_id_by_q = Product.all
    end

    @products = @search.result.paginate(page: params[:page], per_page: 100)

    if params['otchet_type'] == 'selected'
      CreateCsvSelectedJob.perform_later(@search_id_by_q.result.pluck(:id))
      # Services::CsvSelected.call(@search_id_by_q)
      respond_to do |format|
        format.js
      end
      # redirect_to '/product_selected.csv'
    end
  end

  def show; end
  def edit; end

  def update
    respond_to do |format|
      if @product.update(product_params)
        format.html { redirect_to(@product, :notice => 'Product was successfully updated.') }
        format.json { respond_with_bip(@product) }
      else
        format.html { render :action => "edit" }
        format.json { respond_with_bip(@product) }
      end
    end
  end

  def destroy
    insales_product_id = @product.insales_id
    if insales_product_id.present?
      response = Services::DeleteProductInsales.new(insales_product_id).call
      if response["status"] == 'ok'
        product.update(
          deactivated: true,
          insales_id: nil,
          insales_var_id: nil,
          insales_link: nil
        )
        @product.destroy
        respond_to do |format|
          format.html { redirect_to products_url, notice: 'Product was successfully destroyed.' }
          format.json { render json: { title: @product.title }, status: :ok }
          format.js
        end
      else
      end
    end
  end

  def deactivated_selected
    @products = Product.find(params[:ids])
    @products.each do |product|
      insales_product_id = product.insales_id

      if insales_product_id.present?
        response = Services::DeleteProductInsales.new(insales_product_id).call
        if response["status"] == 'ok'
          product.update(
            deactivated: true,
            insales_id: nil,
            insales_var_id: nil,
            insales_link: nil
          )
        end
      else
        product.update(
          deactivated: true,
          insales_id: nil,
          insales_var_id: nil,
          insales_link: nil
        )
      end
    end
    respond_to do |format|
      format.html { redirect_to products_url, notice: 'Товары удалёны' }
      format.json { render json: {status: "okey", message: "Товары удалёны", ids: params[:ids]} }
    end
  end

  def show_selected
    @products = Product.find(params[:ids])
    @products.each do |product|
      product.update(deactivated: false)
    end
    respond_to do |format|
      format.html { redirect_to products_url, notice: 'Товары восстановлены' }
      format.json { render json: {status: "okey", message: "Товары восстановлены", ids: params[:ids]} }
    end
  end

  def create_xls_with_params
    distributor = params[:distributor]
    CreateXlsJob.perform_later(distributor: distributor)
    respond_to do |format|
      format.js
    end
  end

  def create_csv_update
    CreateCsvUpdateJob.perform_later
    respond_to do |format|
      format.js
    end
  end

  def import_ledron
    ActionCable.server.broadcast 'status_process', {distributor: "ledron", process: "update_distributor", status: "start", message: "Обновление товаров поставщика Ledron"}

    FileUtils.rm_rf(Dir.glob('public/ledron/*.*'))
    uploaded_io = params[:file]

    File.open(Rails.root.join('public', 'ledron', uploaded_io.original_filename), 'wb') do |file|
      file.write(uploaded_io.read)
    end

    path_file = Rails.root.join('public', 'ledron', uploaded_io.original_filename).to_s
    extend_file = uploaded_io.original_filename.to_s
    # Services::GettingProductDistributer::Ledron.call(path_file, extend_file)
    LedronImportJob.perform_later(path_file, extend_file)
    respond_to do |format|
      format.js
    end
  end

  def update_distributor
    MaytoniImportJob.perform_later
    MantraImportJob.perform_later
    LightstarImportJob.perform_later
    SwgImportJob.perform_later
    ElevelImportJob.perform_later

    respond_to do |format|
      format.js
    end
  end

  def import_insales_xml
    ImportInsalesXmlJob.perform_later
    respond_to do |format|
      format.js
    end
  end

  private

  def set_product
    @product = Product.find(params[:id])
  end

  def product_params
    params.require(:product).permit(:fid, :link, :title, :desc, :price, :pict, :cat, :p1, :p2, :p3, :linkins, :cat1, :oldprice, :p4, :insid, :mtitle, :mdesc, :mkeyw, :sku, :check, :sdesc, :cat2, :cat3)
  end
end
