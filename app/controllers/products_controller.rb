class ProductsController < ApplicationController
  before_action :set_product, only: [:edit, :update, :destroy, :show]

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
    @product.destroy
    respond_to do |format|
      format.html { redirect_to products_url, notice: 'Product was successfully destroyed.' }
      format.json { render json: { title: @product.title }, status: :ok }
      format.js
    end
  end

  def delete_selected
    @products = Product.find(params[:ids])
    @products.each do |product|
      insales_product_id = product.insales_id

      if insales_product_id.present?
        response = Services::DeleteProductInsales.new(insales_product_id).call
        if response["status"] == 'ok'
          product.update(deactivated: true)
        end
      else
        product.update(deactivated: true)
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

  def create_csv_with_params
    distributor = params[:distributor]
    CreateCsvJob.perform_later(distributor)
    redirect_to products_path, notice: "CREATE CSV WITH PARAMS OK"
    # redirect_to products_path, notice: "CREATE CSV WITH PARAMS OK"
  end

  def import_ledron
    ActionCable.server.broadcast 'state_process', {distributor: "Ledron", state: "start", message: "Запущен процесс импорта товаров Ledron"}

    FileUtils.rm_rf(Dir.glob('public/ledron/*.*'))
    uploaded_io = params[:file]

    File.open(Rails.root.join('public', 'ledron', uploaded_io.original_filename), 'wb') do |file|
      file.write(uploaded_io.read)
    end

    path_file = Rails.root.join('public', 'ledron', uploaded_io.original_filename).to_s
    extend_file = uploaded_io.original_filename.to_s
    # Services::GettingProductDistributer::Ledron.call(path_file, extend_file)
    LedronImportJob.perform_later(path_file, extend_file)
    # flash[:notice] = 'Задача импорта Товаров Ledron запущена'
    # redirect_to products_path
  end

  def update_distributor
    MaytoniImportJob.perform_later
    MantraImportJob.perform_later
    LightstarImportJob.perform_later
    SwgJob.perform_later
    ElevelImportJob.perform_later
    redirect_to products_path
  end

  # def import_product
  #   ImportProductJob.perform_later
  #   redirect_to products_path, notice: 'Запущен процесс Обновление Товаров InSales'
  # end
  #
  # def syncronaize
  #   SyncronaizeJob.perform_later
  #   flash[:notice] = 'Задача синхронизации каталога запущена'
  #   redirect_to products_path
  # end
  #
  # def export_csv
  #   ExportCsvJob.perform_later
  #   flash[:notice] = 'Задача создания CSV для экспорта запущена'
  #   redirect_to products_path
  # end

  private

  def set_product
    @product = Product.find(params[:id])
  end

  def product_params
    params.require(:product).permit(:fid, :link, :title, :desc, :price, :pict, :cat, :p1, :p2, :p3, :linkins, :cat1, :oldprice, :p4, :insid, :mtitle, :mdesc, :mkeyw, :sku, :check, :sdesc, :cat2, :cat3)
  end
end
