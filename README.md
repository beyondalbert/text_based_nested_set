[![Build Status](https://travis-ci.org/beyondalbert/text_based_nested_set.png?branch=master)](https://travis-ci.org/beyondalbert/text_based_nested_set)

# TextBasedNestedSet

this acts provides Text Based Nested Set functionality.

Text Based Nested Set is another way to implementation of an SQL Nested Set created by Trever Shick(http://threebit.net/tutorials/nestedset/varcharBasedNestedSet.html).

Compare to lft and rgt Nested Set, this implementation can updates and deletions without require all of the nodes to be updated.

The methods provided by this gem can found in spec/text_based_nested_set_spec.rb

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'text_based_nested_set'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install text_based_nested_set

## Usage

### set up:

* Add parent_id, path, position column to exsiting model
```ruby
class AddTextBasedNestedSetToDemo < ActiveRecord::Migration
  def change
    add_column :demos, :parent_id, :integer, default: 0
    add_column :demos, :path, :string, default: '/0/'
    add_column :demos, :position, :integer, default: 0
  end
end
```

* add acts_as_text_based_nested_set method to target model
```ruby
class Demo < ActiveRecord::Base
  acts_as_based_nested_set
end
```

### convert from awesome_nested_set

this gem provide a function to help you convert awesome_nested_set table to text based_nested_set table

* Make sure to add path and position column to target model. Then should change parent_id's default value to 0
* start up a rails console and run:
```ruby
  Demo.convert_from_awesome_nested_set
```

## Contributing

1. Fork it ( https://github.com/[my-github-username]/text_based_nested_set/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
