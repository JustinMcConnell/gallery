require "spec_helper"

describe Image do
  describe "Does validations" do
    before do
      @image = Image.new      
    end
    it "requires a name" do
      expect(@image).not_to be_valid
      expect(@image.errors[:name]).not_to be_empty
    end
    it "requires a width" do
      expect(@image).not_to be_valid
      expect(@image.errors[:width]).not_to be_empty
    end
    it "requires a height" do
      expect(@image).not_to be_valid
      expect(@image.errors[:height]).not_to be_empty
    end
    it "does not add non-images" do
      @image.content_type = "text/plain"
      expect(@image).not_to be_valid
    end
    it "limits maximum image size" do
      @image.size = 600000
      expect(@image).not_to be_valid
    end
  end
end