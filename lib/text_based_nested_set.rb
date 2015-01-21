require "text_based_nested_set/version"
require "text_based_nested_set/text_based_nested_set.rb"
ActiveRecord::Base.send :extend, BeyondAlbert::Acts::TextBasedNestedSet

module TextBasedNestedSet
  # Your code goes here...
end