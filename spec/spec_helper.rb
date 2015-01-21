require 'bundler/setup'
Bundler.setup

require 'factory_girl'
require 'active_record'
require 'yaml'
require 'combustion/database'

ActiveRecord::Base.establish_connection(YAML.load_file(File.dirname(__FILE__) + '/db/database.yml')['mysql'])
Combustion::Database.create_database(YAML.load_file(File.dirname(__FILE__) + '/db/database.yml')['mysql'])
load File.dirname(__FILE__) + '/db/schema.rb'

require 'text_based_nested_set'
require 'support/models'
require 'factories/categories'
require 'database_cleaner'

RSpec.configure do |config|
	config.include FactoryGirl::Syntax::Methods

	config.before(:suite) do
		DatabaseCleaner.strategy = :transaction
		DatabaseCleaner.clean_with(:truncation)
	end

	config.before(:each) do
		DatabaseCleaner.start
	end

	config.after(:each) do
		DatabaseCleaner.clean
	end
end