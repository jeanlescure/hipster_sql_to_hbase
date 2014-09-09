require "date"
require "time"
require "treetop"
require_relative "datatype_extras"
require_relative "sql_treetop_load"
require_relative "result_tree_to_hbase_converter"
require_relative "result_tree_to_json_converter"

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
    #   rt = HipsterSqlToHbase::ResultTree.new({...})
    #   rt.to_hbase #=> {:method => 'mutateRow', :arguments => {...}}
    def to_hbase
      HipsterSqlToHbase::ResultTreeToHbaseConverter.new().convert self
    end
    
    # Transforms itself into a JSON object.
    # 
    # === example:
    #   user = HipsterSqlToHbase::ResultTree.new({...})
    #   user.to_json #=> {:user => {:user_name => 'bob', :pass => 'bob1234', ...}}
    def to_json
      HipsterSqlToHbase::ResultTreeToJsonConverter.new().convert self
    end
    
    # Executes itself as an HBase (Thrift) method.
    # Short for running .to_hbase and then sending the result to the executor.
    # 
    # === example:
    #   my_call = HipsterSqlToHbase::ResultTree.new({...})
    #   my_call.execute 
    #
    # <em>if no arguments are passed the executor will use any previously set host 
    # and port.</em>
    def execute(host=nil,port=nil)
      self.to_hbase.execute(host,port)
    end
  end
  
  class << self
    # Generate a Treetop syntax tree from a valid, SQL string.
    #
    # === example:
    #   HipsterSqlToHbase.parse_syntax "INSERT INTO users (user,password) VALUES ('user1','pass123'),('user2','2girls1pass')"
    #
    # === outputs:
    #   #<Class:#<Treetop::Runtime::SyntaxNode:0x3274c98>>
    def parse_syntax(string)
      HipsterSqlToHbase::SyntaxParser.new.parse(string.squish)
    end
    
    # Generate a <b>HipsterSqlToHbase</b>::<b>ResultTree</b> from a valid, SQL string.
    #
    # === example:
    #   HipsterSqlToHbase.parse_tree "SELECT user,password FROM users WHERE id=1"
    #
    # === outputs:
    #   {
    #    :query_type=>:select,
    #    :query_hash=>{
    #      :select=>["user", "password"],
    #      :from=>"users",
    #      :where=>[{:column=>"id", :condition=>:"=", :value=>1}],
    #      :limit=>nil,
    #      :order_by=>nil
    #    }
    #   }
    def parse_tree(string)
      syntax_tree = parse_syntax(string)
      return nil if syntax_tree.nil?
      HipsterSqlToHbase::ResultTree.new({:query_type => syntax_tree.query_type, :query_hash => syntax_tree.tree})
    end
    
    # Generate a <b>HipsterSqlToHbase</b>::<b>ThriftCallGroup</b> from a valid, SQL string.
    #
    # === example:
    #    HipsterSqlToHbase.parse "INSERT INTO `users` (`user`,`pass`) VALUES ('andy','w00dy'),('zaphod','b33bl3br0x')"
    #
    # === outputs:
    #    [
    #      {
    #        :method=>"mutateRow", 
    #        :arguments=>[
    #          "users", 
    #          "c6af1d5b-01d7-477c-9539-f35a1e0758e2", 
    #          [<Apache::Hadoop::Hbase::Thrift::Mutation>, <Apache::Hadoop::Hbase::Thrift::Mutation>], 
    #          {}
    #        ]
    #      }, 
    #      {
    #        :method=>"mutateRow", 
    #        :arguments=>[
    #          "users",
    #          "b630cf3c-c969-420e-afd9-b646466a6743", 
    #          [<Apache::Hadoop::Hbase::Thrift::Mutation>, <Apache::Hadoop::Hbase::Thrift::Mutation>], 
    #          {}
    #        ]
    #      }
    #    ]
    #
    # === note:
    #
    # The resulting ThriftCallGroup can be executed simply by calling its <tt>.execute()</tt> method.
    def parse(string)
      result_tree = parse_tree(string)
      return nil if result_tree.nil?
      result_tree.to_hbase
    end
    
    # Generates and automatically executes a <b>HipsterSqlToHbase</b>::<b>ThriftCallGroup</b> 
    # from a valid, SQL string.
    #
    # The returned value varies depending on the SQL query type (i.e. SELECT, INSERT, etc).
    def execute(string,host=nil,port=nil)
      parsed_tree = parse_tree(string)
      return nil if parsed_tree.nil?
      parsed_tree.execute(host,port)
    end
  end
end