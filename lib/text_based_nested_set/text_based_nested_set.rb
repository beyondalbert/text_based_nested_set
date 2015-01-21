require 'text_based_nested_set/model'

module BeyondAlbert #:nodoc:
	module Acts #:nodoc:
		module TextBasedNestedSet #:nodoc:

      # this acts provides Text Based Nested Set functionality.
      # Text Based Nested Set is another way to implementation of an SQL Nested Set created by Trever Shick.
      # Compare to lft and rgt Nested Set, this implementation can updates and deletions without require all of the nodes to be updated.
      #
      # set up:
      # 1. Add parent_id, path, position column to exsiting model
      # class AddTextBasedNestedSetToDemo < ActiveRecord::Migration
      #   def change
      #     add_column :demos, :parent_id, :integer, default: 0
      #     add_column :demos, :path, :string, default: '/0/'
      #     add_column :demos, position, :integer, default: 0
      #   end
      # end
      # 2. add acts_as_text_based_nested_set method to target model
      #
      # See BeyondAlbert::Acts::TextBasedNestedSet::Model 
      # for a list ofclass methods and instance methods 
      # added to acts_as_text_based_nested_set models.
			def acts_as_text_based_nested_set(options = {})
				include Model

        before_destroy :destroy_descendants
			end
		end
	end
end
