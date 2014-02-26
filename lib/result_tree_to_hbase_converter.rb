module HipsterSqlToHbase
  class ResultTreeToHbaseConverter
    def convert(result_tree)
      send("#{result_tree[:query_type]}_sentence",result_tree[:query_tree])
    end
    def insert_sentence
      put
    end
  end
end