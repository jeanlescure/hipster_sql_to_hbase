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
      start_time = Time.now
      scan = HBase::TScan.new
      filters = "(RowFilter(>=, 'binary:0'))" if filters == ''
      scan.filterString = filters
      scanner = scannerOpenWithScan(table, scan, obj)
      
      results = []
      scan_end = false
      
      while !scan_end
        scan_result = scannerGet(scanner)
        if scan_result.length > 0
          if columns == '*'
            results << scan_result[0].columns.each{ |k,v| scan_result[0].columns[k] = v.value }
          else
            row_result = {}
            columns.each{ |k| row_result[k] = scan_result[0].columns[k].value }
            results << row_result
          end
        else
          scannerClose(scanner)
          scan_end = true
        end
      end
#      
      end_time = Time.now
      results << (end_time - start_time) * 1000
      results
    end
  end
end
HBase = Hbase
