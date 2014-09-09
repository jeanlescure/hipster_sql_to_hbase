require 'securerandom'
require 'thrift'
require_relative "executor"

require File.join(File.dirname(__FILE__), 'adapter', 'hbase')

module HipsterSqlToHbase
  
  # This class provides the method necessary to execute the Thrift result
  # generated after parsing the SQL sentence.
  class ThriftCallGroup < Array
    @incr = false
    def initialize(arr,incr=false)
      arr.each do |v|
        self << v
      end
      @incr = incr
    end
    def execute(host=nil,port=nil)
      HipsterSqlToHbase::Executor.new().execute(self,host,port,@incr)
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
      HipsterSqlToHbase::ThriftCallGroup.new(thrift_calls,true)
    end
    
    # When SQL sentence is a SELECT query generate the Thrift filters according
    # to the specified query values.
    def select_sentence(hash)
      thrift_method = "getRowsByScanner"
      thrift_table = hash[:from]
      thrift_columns = hash[:select]
      thrift_filters = recurse_where(hash[:where] || [])
      
      HipsterSqlToHbase::ThriftCallGroup.new([{:method => thrift_method,:arguments => [thrift_table,thrift_columns,thrift_filters,{}]}])
    end
    
    # When SQL sentence is a CREATE TABLE query generate the Thrift column descriptors/families
    # in accordance to the specified query values.
    def create_table_sentence(hash)
      thrift_method = "createTable"
      thrift_table = hash[:table]
      thrift_columns = []
      hash[:columns].each do |col_name|
        col_descriptor = Hbase::ColumnDescriptor.new
        col_descriptor.name = col_name
        thrift_columns << col_descriptor
      end
      
      HipsterSqlToHbase::ThriftCallGroup.new([{:method => thrift_method,:arguments => [thrift_table,thrift_columns]}])
    end
    
    private
    
    # Format the scanner filter for thrift based on the where clause(s)
    # of a SELECT query.
    def recurse_where(where_arr)
      result_arr = []
      where_arr.each do |val|
        if val.is_a? Hash
          result_arr << filters_from_key_value_pair(val)
        elsif val.is_a? Array
          result_arr << "(#{recurse_where(val)})"
        elsif val.is_a? String
          result_arr << val
        else
          raise "Recursive where undefined error."
        end
      end
      result_arr.join(" ")
    end
    
    # Generate a Thrift QualifierFilter and ValueFilter from key value pair.
    def filters_from_key_value_pair(kvp)
      if (kvp[:condition].to_s != "LIKE")
        "(ValueFilter(#{kvp[:condition]},'binary:#{kvp[:value]}') AND DependentColumnFilter('#{kvp[:column]}',''))"
      else
        kvp[:value] = Regexp.escape(kvp[:value])
        kvp[:value].sub!(/^%/,"^.*")
        kvp[:value].sub!(/%$/,".*$")
        while kvp[:value].match(/([^\\]{1,1})%/)
          kvp[:value].sub!(/([^\\]{1,1})%/,"#{$1}.*?")
        end
        kvp[:value].sub!(/^_/,"^.")
        kvp[:value].sub!(/_$/,".$")
        while kvp[:value].match(/([^\\]{1,1})_/)
          kvp[:value].sub!(/([^\\]{1,1})_/,"#{$1}.")
        end
        "(ValueFilter(=,'regexstring:#{kvp[:value]}') AND DependentColumnFilter('#{kvp[:column]}',''))"
      end
    end
    
  end
end