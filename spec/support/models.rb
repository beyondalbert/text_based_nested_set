class Category < ActiveRecord::Base
	acts_as_text_based_nested_set
end