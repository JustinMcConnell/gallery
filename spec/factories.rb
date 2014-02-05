FactoryGirl.define do 
  factory :image do
    name "image.png"
    content_type "image/png"
    size 600000
    width 800
    height 500
  end
end