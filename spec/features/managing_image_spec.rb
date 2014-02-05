require "spec_helper"
include ActionDispatch::TestProcess

describe "Creating an image" do
  before do
    visit new_image_path
    fill_in "Grab URL", :with => "http://i.imgur.com/1qmiGpA.png"
    click_button "Upload"
  end

  it "Downloads a URL and creates an image" do
    expect(page).to have_content("Image uploaded")
    expect(page).not_to have_content("upload failed")
  end
end

describe "Showing an image" do    
  before do
    FileUtils.cp Rails.root.join('spec', 'fixtures', 'files', 'image.png'), 
                 Rails.root.join('public', 'images', 'image.png')
    @image = FactoryGirl.create(:image)
    visit image_path @image
  end

  it "has an image" do
    expect(page).to have_css("img")   
  end

  it "shows the right views" do
    expect(page).to have_content("1 view")
    visit image_path @image
    expect(page).to have_content("2 views")
  end


  it "shows the right bandwidth" do
    expect(page).to have_content("586 KB")
    visit image_path @image
    expect(page).to have_content("1.14 MB")
  end
end
