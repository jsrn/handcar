require_relative "test_helper"
require 'securerandom'

class Quote < Handcar::Model::SQLite; end
class MyApp < Handcar::Application; end

class SqliteModelTest < Minitest::Test
  def setup
    @test_db_path = "test/db/#{SecureRandom.hex}.db"
    @test_db = SQLite3::Database.new(@test_db_path)
    reset_test_database(@test_db)
    Quote.database = @test_db
  end

  def test_create_model
    quote = Quote.new(
      'author' => 'Bill',
      'submitter' => 'James',
      'body' => 'Hi!'
    )

    assert_equal 'Bill', quote.author
    assert_equal 'James', quote.submitter
    assert_equal 'Hi!', quote.body
  end

  def test_assign_value_to_model
    quote = Quote.new
    quote['author'] = 'Bill'
    assert_equal 'Bill', quote.author
  end

  def test_database_switching
    Quote.database = SQLite3::Database.new('quotes.db')
    assert_equal true, File.exists?('quotes.db')
    File.delete('quotes.db')
  end

  def test_save_previously_unsaved_record_returns_true
    quote = Quote.new
    quote['author'] = 'Bill'
    assert_equal true, quote.save
  end

  def test_saving_previously_unsaved_record_changes_count
    quote = Quote.new('author' => 'bill')

    count = Quote.count
    quote.save!

    assert_equal count + 1, Quote.count
  end

  def test_all
    Quote.create('author' => 'bill')
    Quote.create('author' => 'ben')

    assert_equal ['bill', 'ben'], Quote.all.collect(&:author)
  end

  def test_find
    quote = Quote.create('author' => 'bill')
    assert_equal quote.id, Quote.find(quote.id).id
  end

  def test_update_an_existing_record
    quote = Quote.create('author' => 'bill')
    quote['author'] = 'maria'
    quote.save

    reloaded_quote = Quote.find(quote.id)
    assert_equal 'maria', reloaded_quote.author
  end

  def teardown
    File.delete(@test_db_path)
  end
end
