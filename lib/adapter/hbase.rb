require 'thrift'

require File.join(File.dirname(__FILE__), 'hbase', 'hbase_constants')
require File.join(File.dirname(__FILE__), 'hbase', 'hbase_types')
require File.join(File.dirname(__FILE__), 'hbase', 'hbase')

# Try to make the crazy nesting that Thrift generates a little less painful
module Hbase
  Client = ::Apache::Hadoop::Hbase::Thrift::Hbase::Client

  Apache::Hadoop::Hbase::Thrift.constants.each do |constant|
    const_set(constant, Apache::Hadoop::Hbase::Thrift.const_get(constant))
  end
  
  class Client
    def incrementAndReturn(table_name,amount)
      c_row = get('table_indices','0',table_name,{})[0].value.to_i
      n_row = c_row+amount
      mutateRow('table_indices','0',[HBase::Mutation.new(column: table_name, value: n_row.to_s)],{})
      c_row
    end
    def getRowsByScanner(table,columns,filters,obj={})
      scan = HBase::TScan.new
      filters = "(RowFilter(>=, 'binary:0'))" if filters == ''
      scan.filterString = filters
      scanner = scannerOpenWithScan(table, scan, obj)
      
      results = []
      scan_end = false
      rows = []
      
      while !scan_end
        scan_result = scannerGet(scanner)
        if scan_result.length > 0
          rows << scan_result[0].row
        else
          scan_end = true
        end
      end
      
      rows.each do |row|
        row_results = []
        if columns[0] == '*'
          getRow(table,row,{})[0].columns.each do |val|
            row_results << { 'id' => row, val[0] => val[1].value }
          end
        else
          columns.each do |col|
            row_results << { 'id' => row, col => getRow(table,row,{})[0].columns["#{col}:"].value } rescue row_results << nil
          end
        end
        results << row_results
      end
      
      results
    end
  end
end
HBase = Hbase
