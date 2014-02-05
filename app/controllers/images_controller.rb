require 'pry'
require 'fastimage'

class ImagesController < ApplicationController

  def index
    @images = Image.all
  end

  def new
    @image = Image.new
  end

  def show
    @image = Image.find(params[:id])
    @image.views += 1 
    @image.save
  end

  def create
    uploaded_io = image_params && (image_params[:name] || image_params[:url])
    @image = Image.new
    @image.width, @image.height = FastImage.size(uploaded_io)

    # user uploaded a file
    if uploaded_io &&
       (uploaded_io.class.to_s == "Rack::Test::UploadedFile" ||
        uploaded_io.class.to_s == "ActionDispatch::Http::UploadedFile")
      @image[:name] = uploaded_io.original_filename
      @image[:size] = uploaded_io.size
      @image[:content_type] = uploaded_io.content_type
      @image_data = uploaded_io.read

    # user wants to grab a URL
    elsif uploaded_io && uploaded_io.class.to_s == "String"
      response = HTTParty.get(uploaded_io)
      if response.code == 200
        @image[:name] = get_filename_from_url(uploaded_io)
        @image[:size] = response.headers["content-length"]
        @image[:content_type] = response.headers["content-type"]
        @image_data = response.body
      end
    end

    if (@image.save) 
      save_file_to_filesystem(@image[:name], @image_data)
      flash[:notice] = "Image uploaded"
      respond_to do |format|
        format.html { redirect_to image_path(@image) }
        format.js { render :text => "Image uploaded" }
      end
    else
      render "new"
    end
  end

  private

  def save_file_to_filesystem(name, data)
    File.open(Rails.root.join('public', 'images', name), 'wb') do |file|
      file.write(data)
    end
  end

  def get_filename_from_url(url)
    uri = URI.parse(url)
    uri.path.slice(1 .. uri.path.length)
  end

  def image_params
    params.require(:image).permit(:url, :name) if params[:image] || params[:url]
  end
end