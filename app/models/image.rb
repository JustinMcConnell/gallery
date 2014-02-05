class Image < ActiveRecord::Base
  validates :name, :presence => { :message => "image uploaded" }
  validates :width, :presence => { :message => "width set"}
  validates :height, :presence => { :message => "height set"}
  validate :is_an_image?
  validate :size_ok?

  def is_an_image?
    if content_type && !content_type.start_with?("image/")
      errors.add(:not, "an image")
    end
  end

  def size_ok?
    if size && size > 600_000
      errors.add(:image, " is too large")
    end
  end

  HUMANIZED_ATTRIBUTES = {
    :name => "No",
    :width => "No",
    :height => "No"
  }

  def self.human_attribute_name(attr, options = {})
    HUMANIZED_ATTRIBUTES[attr.to_sym] || super
  end
end
