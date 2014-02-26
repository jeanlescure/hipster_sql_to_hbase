require "date"
require "time"
require "treetop"
require_relative "datatype_extras"
require_relative "sql_treetop_load"
require_relative "executor"

module HipsterSqlToHbase
  class SyntaxParser < SQLParser
    class ItemsNode < Treetop::Runtime::SyntaxNode
      def values
        items.values.unshift(item.value)
      end
    end

    class ItemNode < Treetop::Runtime::SyntaxNode
      def values
        [value]
      end
      
      def value
        text_value.to_sym
      end
    end
  end
  class ResultTree < Hash
    def initialize(hash)
      hash.each do |k,v|
        self[k] = v
      end
    end
    def to_hbase
      HipsterSqlToHbase::ResultTreeToHbaseConverter.new().convert self
    end
    def to_json
      
    end
    def execute
      HipsterSqlToHbase::Executor.new().execute self.to_hbase
    end
  end
  
  class << self
    def parse_syntax(string)
      HipsterSqlToHbase::SyntaxParser.new.parse(string.squish)
    end
    def parse_tree(string)
      syntax_tree = parse_syntax(string)
      return nil if syntax_tree.nil?
      HipsterSqlToHbase::ResultTree.new({:query_type => syntax_tree.query_type, :query_hash => syntax_tree.tree})
    end
    def parse(string)
      result_tree = parse_tree(string)
      return nil if result_tree.nil?
      result_tree.to_hbase
    end
    def execute(string)
      hbase_command = parse(string)
      return nil if hbase_command.nil?
      hbase_command.execute
    end
  end
end