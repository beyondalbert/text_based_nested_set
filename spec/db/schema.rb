ActiveRecord::Schema.define do
	self.verbose = false

	create_table :categories, :force => true do |t|
		t.string :name
		t.integer :parent_id, default: 0
		t.string :path, default: '/0/'
		t.integer :position, default: 0
	end
end
