require "date"
require "time"
require "treetop"

require_relative "sql_treetop_load"

module HipsterSqlToHbase
  
  class SqlParser::ItemsNode < Treetop::Runtime::SyntaxNode
    def values
      items.values.unshift(item.value)
    end
  end

  class SqlParser::ItemNode < Treetop::Runtime::SyntaxNode
    def values
      [value]
    end
    
    def value
      text_value.to_sym
    end
  end
end