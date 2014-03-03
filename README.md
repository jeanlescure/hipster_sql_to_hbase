![hipster_sql_to_hbase logo](https://github.com/jeanlescure/hipster_sql_to_hbase/raw/master/misc/hipster_sql_to_hbase_logo.png)

# Hipster SQL To HBase
### parsing sql to hbase (thrift) before it was cool

This project was born out of the need to migrate rapidly and efficiently a MySQL based application over to Hadoop's own HBase.

The HipsterSqlToHbase module provides the ability to produce Thrift compatible queries for HBase from SQL valid statements and execute them; and as if that wasn't cool enough I've also incorporated methods which give you access to each step of the transformation process, as in, the Treetop syntax tree, and the hashed parsing output relevant to each of the following query types:

* CREATE type queries
* SHOW type queries
* INSERT type queries
* SELECT type queries
* UPDATE type queries
* DROP/DELETE type queries

## Getting Started

You can install it via RubyGems:

  `$ gem install hipster_sql_to_hbase`

## Usage

This is a no bullshit, straight as an arrow, to the point gem.

Simply require the gem and execute your SQL query. It's that simple:

`require 'hipster_sql_to_hbase'`

`HipsterSqlToHbase.execute("INSERT INTO `users` (`user`,`pass`) VALUES ('andy','w00dy'),('zaphod','b33bl3br0x')"`,'www.my-hbase-server.com',9090)

And boom! You've got your result; which varies depending on the SQL query type you executed (i.e. SELECT, INSERT, etc).

## Complexity

This gem provides a wide array of functionalities besides just parsing SQL to HBase (Thrift).

I'll eventually get around to listing some of the awesomeness withheld within these humble lines of code (especially as I play around with the gem and come up with some test cases), but in the meantime if you're curious about the added functionality of HipsterSqlToHbase, you'll surely want to checkout the RDoc I've generated and uploaded [here.](http://www.jlescure.com/hipster)