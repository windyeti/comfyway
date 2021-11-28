class ProductsController < ApplicationController
  before_action :set_product, only: [:show, :edit, :update, :destroy]
  # before_action :authorize

  # GET /products
  # GET /products.json
  def index
    @search = Product.ransack(params[:q]) #используется gem ransack для поиска и сортировки
    @search.sorts = 'id asc' if @search.sorts.empty? # сортировка таблицы по алфавиту по умолчанию
    @products = @search.result.paginate(page: params[:page], per_page: 100)
    @product_all = Product.all.order(:id)#.limit(10)#.where.not(:insid => nil).order(:id)
    if params['file_type'] == 'redir'
      filename = "insales_redir.xls"
      respond_to do |format|
        format.html
        format.xls { headers["Content-Disposition"] = "attachment; filename=\"#{filename}\"" }
        format.json
        format.xml
      end
    else
      filename = "insales.csv"
      respond_to do |format|
        format.html
        format.csv { headers["Content-Disposition"] = "attachment; filename=\"#{filename}\"" }
        format.json
        format.xml
      end
    end
  end

  def create_csv_with_params
    CreateCsvJob.perform_later
    redirect_to products_path, notice: "CREATE CSV WITH PARAMS OK"
    # redirect_to products_path, notice: "CREATE CSV WITH PARAMS OK"
  end

  def csv_param
    Product.csv_param
    flash[:notice] = "Запустили"
    redirect_to products_path
  end

  # GET /products/1
  # GET /products/1.json
  def show
  end

  # GET /products/new
  def new
    @product = Product.new
  end

  # GET /products/1/edit
  def edit
  end

  # POST /products
  # POST /products.json
  def create
    @product = Product.new(product_params)

    respond_to do |format|
      if @product.save
        format.html { redirect_to @product, notice: 'Product was successfully created.' }
        format.json { render :show, status: :created, location: @product }
      else
        format.html { render :new }
        format.json { render json: @product.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /products/1
  # PATCH/PUT /products/1.json
  def update
    respond_to do |format|
      if @product.update(product_params)
        format.html { redirect_to @product, notice: 'Product was successfully updated.' }
        format.json {head :no_content }#{ render :show, status: :ok, location: @product }
      else
        format.html { render :edit }
        format.json { render json: @product.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /products/1
  # DELETE /products/1.json
  def destroy
    @product.destroy
    respond_to do |format|
      format.html { redirect_to products_url, notice: 'Product was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def download
    @product = Product.download
    flash[:notice] = 'Products was successfully updated'
    redirect_to products_path
  end

  def import
    Product.import(params[:file])
    flash[:notice] = 'Products was successfully import'
    redirect_to products_path
  end

  def xml
    @products = Product.where(:check => [true] ).order(:id).limit(1000) #Product.where("cat2" => "Комплектующие для сантехники")
    respond_to do |format|
      format.xml
    end
  end

  def delete_selected
    puts params[:ids]
    @products = Product.find(params[:ids])
    @products.each do |item|
      item.destroy
    end
    respond_to do |format|
      format.html { redirect_to products_url, notice: 'Записи удалёны' }
      format.json { render json: {:status => "ok", :message => "Записи удалёны"} }
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_product
    @product = Product.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def product_params
    params.require(:product).permit(:fid, :link, :title, :desc, :price, :pict, :cat, :p1, :p2, :p3, :linkins, :cat1, :oldprice, :p4, :insid, :mtitle, :mdesc, :mkeyw, :sku, :check, :sdesc, :cat2, :cat3)
  end
end
