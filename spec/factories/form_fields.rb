# == Schema Information
#
# Table name: form_fields
#
#  id         :integer          not null, primary key
#  form_id    :integer
#  title      :string(255)
#  data_type  :string(255)
#  options    :text
#  required   :boolean          default(FALSE)
#  position   :integer
#  created_at :datetime
#  updated_at :datetime
#

FactoryGirl.define do
  factory :form_field do
    form_id 1
title "MyString"
data_type "MyString"
options "MyText"
required false
position 1
  end

end