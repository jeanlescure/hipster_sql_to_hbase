require "date"
require "time"
require "treetop"

Dir["#{File.dirname(__FILE__)}/sql_parser/*.treetop"].each{|treetop_file| Treetop.load treetop_file}

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