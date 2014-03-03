require 'securerandom'
require 'thrift'
require_relative "executor"

require File.join(File.dirname(__FILE__), 'adapter', 'hbase')

module HipsterSqlToHbase
  
  # This class provides the method necessary to execute the Thrift result
  # generated after parsing the SQL sentence.
  class ThriftCallGroup < Array
    def initialize(arr)
      arr.each do |v|
        self << v
      end
    end
    def execute(host=nil,port=nil)
      HipsterSqlToHbase::Executor.new().execute(self,host,port)
    end
  end
  
  # This class takes care of all HBase (Thrift) conversion magic by transforming
  # the ResultTree objects into ThriftCallGroup objects.
  class ResultTreeToHbaseConverter
  
    # Depending on the SQL sentence type, call the appropriate function.
    def convert(result_tree)
      send("#{result_tree[:query_type].to_s}_sentence",result_tree[:query_hash])
    end
    
    # When SQL sentence is an INSERT query generate the Thrift mutations according
    # to the specified query values.
    def insert_sentence(hash)
      thrift_method = "mutateRow"
      thrift_table = hash[:into]
      thrift_calls = []
      hash[:values].each do |value_set|
        thrift_row = SecureRandom.uuid
        thrift_mutations = []
        i = 0
        hash[:columns].each do |col|
          thrift_mutations << HBase::Mutation.new(column: col, value: value_set[i].to_s)
          i += 1
        end
        thrift_calls << {:method => thrift_method,:arguments => [thrift_table,thrift_row,thrift_mutations,{}]}
      end
      HipsterSqlToHbase::ThriftCallGroup.new(thrift_calls)
    end
    
    # When SQL sentence is a SELECT query generate the Thrift filters according
    # to the specified query values.
    def select_sentence
      
    end
    
    # When SQL sentence is a CREATE TABLE query generate the Thrift column descriptors/families
    # in accordance to the specified query values.
    def create_table_sentence
      
    end
    
    private
    def qualifier_filters_from_cols(cols)
      
    end
    def value_filters_from_vals(vals)
      
    end
    
  end
end