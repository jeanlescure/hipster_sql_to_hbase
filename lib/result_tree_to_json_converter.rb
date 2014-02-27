require 'json'

require File.join(File.dirname(__FILE__), 'adapter', 'hbase')

module HipsterSqlToHbase
  class ResultTreeToJsonConverter
    def convert(result_tree)
      send("#{result_tree[:query_type].to_s}_sentence",result_tree[:query_hash])
    end
    def insert_sentence(hash)
      table = hash[:into]
      objects = []
      hash[:values].each do |value_set|
        object = {}
        i = 0
        hash[:columns].each do |col|
          object[col.to_sym] = value_set[i]
          i += 1
        end
        objects << object
      end
      JSON.generate({:write=>{:table=>table,:objects=>objects}})
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