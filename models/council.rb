class Council < ActiveRecord::Base
  has_many :votes, foreign_key: 'council_id', dependent: :destroy
end
