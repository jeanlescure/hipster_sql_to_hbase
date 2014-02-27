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
end
HBase = Hbase
