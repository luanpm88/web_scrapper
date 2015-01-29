class LinksController < ApplicationController
  before_action :set_link, only: [:show, :edit, :update, :destroy, :enable, :disable]

  # GET /links
  # GET /links.json
  def index
    @links = Link.all
  end
  
  def datatable
    result = Link.datatable(params)
    
    render json: result
  end

  # GET /links/1
  # GET /links/1.json
  def show
  end

  # GET /links/new
  def new
    @link = Link.new
  end

  # GET /links/1/edit
  def edit
  end

  # POST /links
  # POST /links.json
  def create
    @link = Link.new(link_params)

    respond_to do |format|
      if @link.save
        format.html { redirect_to links_url, notice: 'Link was successfully created.' }
        format.json { render :show, status: :created, location: @link }
      else
        format.html { render :new }
        format.json { render json: @link.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /links/1
  # PATCH/PUT /links/1.json
  def update
    respond_to do |format|
      if @link.update(link_params)
        format.html { redirect_to links_url, notice: 'Link was successfully updated.' }
        format.json { render :show, status: :ok, location: @link }
      else
        format.html { render :edit }
        format.json { render json: @link.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /links/1
  # DELETE /links/1.json
  def destroy
    @link.destroy
    respond_to do |format|
      format.html { redirect_to links_url, notice: 'Link was successfully destroyed.' }
      format.json { head :no_content }
    end
  end
  
  def enable
    
    respond_to do |format|
      if @link.enable
        format.html { redirect_to links_url, notice: 'Link was successfully enabled.' }
        format.json { head :no_content }
      else
        format.html { redirect_to links_url, notice: 'Link is invalid.' }
        format.json { head :no_content }
      end
    end    
  end
  
  def disable
    @link.disable

    respond_to do |format|
      format.html { redirect_to links_url, notice: 'Link was successfully disabled.' }
      format.json { head :no_content }
    end
  end
  
  def test_link
    if !params[:id].nil?
      @link = Link.find(params[:id])
    else
      @link = Link.new(link_params)
    end
    
    @log = Task.test_link(@link)[:log]
    
    @result = Task.is_valid_link(@log) 
    
    render :layout => false
    
    #render :json => Feature.find(link_params[:feature_id])
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_link
      @link = Link.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def link_params
      params.require(:link).permit(:name, :source_url, :page_id, :category_id, :feature_id)
    end
end
