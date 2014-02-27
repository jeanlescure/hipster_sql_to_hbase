require "date"
require "time"
require "treetop"
require_relative "datatype_extras"
require_relative "sql_treetop_load"
require_relative "result_tree_to_hbase_converter"
require_relative "result_tree_to_json_converter"
require_relative "executor"

# This module provides the methods necessary to parse valid SQL
# sentences into:
#
# * Treetop Syntax Trees
# * Hash Trees
# * JSON Trees
# * HBase (Thrift)
#
# It also allows to directly execute valid SQL sentences as Thrift methods.

module HipsterSqlToHbase
  
  # Treetop base SQL parser.
  #
  # Forked from Scott Taylor's guillotine and perfected by Jean Lescure.
  #
  # https://www.github.com/smtlaissezfaire/guillotine/tree/master/lib/guillotine/parser
  #
  # https://www.github.com/jeanlescure/hipster_sql_to_hbase
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
  # This class provides the initial parsed result with the methods
  # necessary to be transformed into HBase (Thrift) or JSON, as well
  # as to be executed as a Thrift method.
  class ResultTree < Hash
    def initialize(hash)
      hash.each do |k,v|
        self[k] = v
      end
    end
    
    # Transforms itself into an HBase (Thrift) method.
    # 
    # === example:
    # rt = HipsterSqlToHbase::ResultTree.new({...})
    #
    # rt.to_hbase #=> {:method => 'mutateRow', :arguments => {...}}
    def to_hbase
      HipsterSqlToHbase::ResultTreeToHbaseConverter.new().convert self
    end
    
    # Transforms itself into an HBase (Thrift) method.
    # 
    # === example:
    # user = HipsterSqlToHbase::ResultTree.new({...})
    #
    # user.to_hbase #=> {:user => {:user_name => 'bob', :pass => 'bob1234', ...}}
    def to_json
      HipsterSqlToHbase::ResultTreeToJsonConverter.new().convert self
    end
    
    # Executes itself as an HBase (Thrift) method.
    # Short for running .to_hbase and then sending the result to the executor.
    # 
    # === example:
    # my_call = HipsterSqlToHbase::ResultTree.new({...})
    #
    # my_call.execute 
    #
    # <em>if no arguments are passed the executor will use any previously set host 
    # and port.</em>
    def execute(host=nil,port=nil)
      HipsterSqlToHbase::Executor.new().execute(self.to_hbase,host,port)
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
    def execute(string,host=nil,port=nil)
      parsed_tree = parse_tree(string)
      return nil if parsed_tree.nil?
      parsed_tree.execute(host,port)
    end
  end
end