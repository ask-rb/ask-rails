# frozen_string_literal: true

require_relative "test_helper"
require "active_record"
require "tmpdir"

class SchemaGraphTest < Minitest::Test
  def setup
    @tool = Ask::Rails::Tools::SchemaGraph.new
  end

  def test_defines_correct_name
    assert_equal "schema_graph", @tool.name
  end

  def test_defines_detail_param
    assert @tool.parameters.key?(:detail)
  end

  def test_inherits_from_ask_rails_tool
    assert Ask::Rails::Tools::SchemaGraph.ancestors.include?(Ask::Rails::Tool)
  end

  def test_returns_hash_with_summary
    result = @tool.execute
    assert_instance_of Hash, result
    assert result.key?(:summary)
    assert_kind_of Integer, result[:summary][:model_count]
  end

  def test_all_detail_returns_all_keys
    result = @tool.execute(detail: "all")
    assert result.key?(:models)
    assert result.key?(:associations)
    assert result.key?(:tables)
  end

  def test_models_detail_returns_only_models
    result = @tool.execute(detail: "models")
    assert result[:models].is_a?(Array), "models should be an array"
    assert_nil result[:tables], "models detail should not include tables"
    assert_nil result[:associations], "models detail should not include associations"
  end

  def test_associations_detail_returns_only_associations
    result = @tool.execute(detail: "associations")
    assert result[:associations].is_a?(Array), "associations should be an array"
    assert_nil result[:models], "associations detail should not include models"
    assert_nil result[:tables], "associations detail should not include tables"
  end

  def test_tables_detail_returns_only_tables
    result = @tool.execute(detail: "tables")
    assert result[:tables].is_a?(Hash), "tables should be a hash"
    assert_nil result[:models], "tables detail should not include models"
    assert_nil result[:associations], "tables detail should not include associations"
  end

  # --- Live database tests with real models ---

  def test_reports_models_and_tables_from_live_db
    with_real_models do |models|
      result = @tool.execute(detail: "all")

      assert_operator result[:summary][:model_count], :>=, 3,
        "Should detect at least the 3 test models"

      model_names = result[:models].map { |m| m[:name] }
      assert_includes model_names, "SchemaGraphTest::TestUser"
      assert_includes model_names, "SchemaGraphTest::TestPost"
      assert_includes model_names, "SchemaGraphTest::TestComment"
    end
  end

  def test_columns_have_correct_types
    with_real_models do |models|
      result = @tool.execute(detail: "all")
      user = result[:models].find { |m| m[:name] == "SchemaGraphTest::TestUser" }

      refute_nil user, "TestUser should be in the schema"
      assert user.key?(:columns), "User should have columns"

      email_col = user[:columns].find { |c| c[:name] == "email" }
      refute_nil email_col, "User should have an email column"
      assert_equal :string, email_col[:type]
      refute email_col[:null], "email should be NOT NULL"

      score_col = user[:columns].find { |c| c[:name] == "score" }
      refute_nil score_col, "User should have a score column"
      assert_equal :integer, score_col[:type]
      assert score_col[:null], "score should be nullable"
    end
  end

  def test_associations_are_detected
    with_real_models do |models|
      result = @tool.execute(detail: "associations")
      edges = result[:associations]

      # User has_many :posts
      assert edges.any? { |e| e[:from] == "SchemaGraphTest::TestUser" && e[:to] == "SchemaGraphTest::TestPost" && e[:type] == :has_many },
        "Should detect User has_many :posts"

      # Post belongs_to :user
      assert edges.any? { |e| e[:from] == "SchemaGraphTest::TestPost" && e[:to] == "SchemaGraphTest::TestUser" && e[:type] == :belongs_to },
        "Should detect Post belongs_to :user"

      # Post has_many :comments
      assert edges.any? { |e| e[:from] == "SchemaGraphTest::TestPost" && e[:to] == "SchemaGraphTest::TestComment" && e[:type] == :has_many },
        "Should detect Post has_many :comments"
    end
  end

  def test_foreign_keys_in_associations
    with_real_models do |models|
      result = @tool.execute(detail: "associations")
      edges = result[:associations]

      post_to_user = edges.find { |e| e[:from] == "SchemaGraphTest::TestPost" && e[:type] == :belongs_to }
      refute_nil post_to_user, "Post belongs_to User edge should exist"
      assert post_to_user[:foreign_key].to_s.end_with?("user_id"),
        "Expected foreign_key ending with user_id, got #{post_to_user[:foreign_key]}"
    end
  end

  def test_validators_are_detected
    with_real_models do |models|
      result = @tool.execute(detail: "models")
      user = result[:models].find { |m| m[:name] == "SchemaGraphTest::TestUser" }

      refute_nil user, "TestUser should be in results"
      assert user.key?(:validators), "User should have validators"

      email_presence = user[:validators].find { |v| v[:attribute] == "email" && v[:kind] == :presence }
      refute_nil email_presence, "User should validate presence of email"
    end
  end

  def test_tables_include_indexes
    with_real_models do |models|
      result = @tool.execute(detail: "tables")
      tables = result[:tables]

      users_table = tables.values.find { |t| t[:model] == "SchemaGraphTest::TestUser" }
      refute_nil users_table, "TestUser table should be present"

      assert users_table.key?(:indexes), "Table should have indexes"
      assert users_table[:indexes].any? { |idx| idx[:columns].include?("email") && idx[:unique] },
        "Should detect unique index on email"
    end
  end

  private

  def with_real_models
    # Create a database connection
    ActiveRecord::Base.establish_connection(adapter: "sqlite3", database: ":memory:")

    # Create schema
    ActiveRecord::Base.connection.create_table(:test_users, force: true) do |t|
      t.string :email, null: false
      t.string :name
      t.integer :score
      t.timestamps
    end
    ActiveRecord::Base.connection.add_index(:test_users, :email, unique: true)

    ActiveRecord::Base.connection.create_table(:test_posts, force: true) do |t|
      t.references :test_user, null: false
      t.string :title, null: false
      t.text :body
      t.timestamps
    end

    ActiveRecord::Base.connection.create_table(:test_comments, force: true) do |t|
      t.references :test_post, null: false
      t.text :content, null: false
      t.timestamps
    end

    # Define model classes using Module const_set so they persist
    user_class = Class.new(ActiveRecord::Base) do
      self.table_name = "test_users"
      has_many :test_posts, foreign_key: :test_user_id
      validates :email, presence: true, uniqueness: true
    end
    self.class.const_set(:TestUser, user_class)

    post_class = Class.new(ActiveRecord::Base) do
      self.table_name = "test_posts"
      belongs_to :test_user
      has_many :test_comments, foreign_key: :test_post_id
      validates :title, presence: true
    end
    self.class.const_set(:TestPost, post_class)

    comment_class = Class.new(ActiveRecord::Base) do
      self.table_name = "test_comments"
      belongs_to :test_post
      validates :content, presence: true
    end
    self.class.const_set(:TestComment, comment_class)

    # Touch each model so they register in descendants
    [user_class, post_class, comment_class].each(&:table_name)

    yield

  ensure
    # Clean up AR descendants
    [self.class::TestUser, self.class::TestPost, self.class::TestComment].each do |klass|
      ActiveRecord::Base.descendants.delete(klass) rescue nil
    end
    # Remove constants
    [:TestUser, :TestPost, :TestComment].each { |c| self.class.send(:remove_const, c) rescue nil }
    ActiveRecord::Base.connection.disconnect! rescue nil
    ActiveRecord::Base.remove_connection rescue nil
  end
end
