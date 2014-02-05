require "spec_helper"

describe ImagesController do
  describe "GET index" do
    it "renders the index page" do
      get :index
      expect(response).to be_success
      expect(response).to render_template("index")
    end
  end

  describe "GET new" do
    it "renders the upload page" do
      get :new
      expect(response).to be_success
      expect(response).to render_template("new")
    end
  end

  describe "POST create" do
    it "creates an image from a local file" do
      expect {
        post :create, :image => {:name => fixture_file_upload("files/image.png", "image/png")}
      }.to change { Image.count }.by(1)      
      expect(response).to be_redirect
    end

    it "creates an image from a URL" do
      expect {
        post :create, :image => {:url => "http://i.imgur.com/1qmiGpA.png"}
      }.to change {Image.count }.by(1)
      expect(response).to be_redirect
    end

    it "fails when the image is blank" do
      expect {
        post :create
      }.not_to change { Image.count }
      expect(response).to be_success
      expect(response).to render_template("new")
    end

    it "fails when uploading an image that is too large" do
      expect {
        post :create, :image => {:name => fixture_file_upload("files/big.jpg", "image/jpeg")}
      }.not_to change { Image.count }
      expect(response).to be_success
      expect(response).to render_template("new")
    end

    it "fails when uploading a non image" do
      expect {
        post :create, :image => {:name => fixture_file_upload("files/text.txt", "text/plain")}
      }.not_to change { Image.count }
      expect(response).to be_success
      expect(response).to render_template("new")
    end
  end

  describe "GET image" do
    before do
      expect {
        post :create, :image => {:name => fixture_file_upload("files/image.png", "image/png")}
      }.to change { Image.count }.by(1)
      @image = Image.first
    end

    it "shows an image" do
      get :show, :id => @image.id
      expect(response).to be_success
      expect(response).to render_template("show")
    end
  end

  describe "GET edit" do
    it "updates the title" do
      #get :edit, :id => @image.id, :title => "New title"
    end
  end
end