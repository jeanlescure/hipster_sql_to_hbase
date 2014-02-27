require 'securerandom'
require 'thrift'

require File.join(File.dirname(__FILE__), 'adapter', 'hbase')

module HipsterSqlToHbase
  class ResultTreeToHbaseConverter
    def convert(result_tree)
      send("#{result_tree[:query_type].to_s}_sentence",result_tree[:query_hash])
    end
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
      thrift_calls
    end
    def select_sentence
      
    end
    def create_table_sentence
      
    end
    
    private
    def qualifier_filters_from_cols(cols)
      
    end
    def value_filters_from_vals(vals)
      
    end
    
  end
end