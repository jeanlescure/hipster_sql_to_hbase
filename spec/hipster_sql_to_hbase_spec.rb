$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), 'sql_sentence_types'))

require 'spec_helper'

describe "HipsterSqlToHbase.parse_syntax method" do 
  
  context "when parse_syntax is run against SELECT FROM query without table hierarchy or backticks" do
    let(:response) { HipsterSqlToHbase.parse_syntax("SELECT user FROM users") }
    it "succeeds" do
      expect(response.class).to eq(Treetop::Runtime::SyntaxNode)
    end
  end
  
  context "when parse_syntax is run against SELECT FROM query with backticks but no table hierarchy" do
    let(:response) { HipsterSqlToHbase.parse_syntax("SELECT `user` FROM `users`") }
    it "succeeds" do
      expect(response.class).to eq(Treetop::Runtime::SyntaxNode)
    end
  end
  
  context "when parse_syntax is run against SELECT FROM query with backticks and table hierarchy" do
    let(:response) { HipsterSqlToHbase.parse_syntax("SELECT `users`.`user` FROM `users`") }
    it "succeeds" do
      expect(response.class).to eq(Treetop::Runtime::SyntaxNode)
    end
  end
  
  context "when parse_syntax is run against INSERT INTO query without backticks" do
    let(:response) { HipsterSqlToHbase.parse_syntax("INSERT INTO utests (val, num) VALUES ('test', 1)") }
    it "succeeds" do
      expect(response.class).to eq(Treetop::Runtime::SyntaxNode)
    end
  end
  
  context "when parse_syntax is run against INSERT INTO query with backticks" do
    let(:response) { HipsterSqlToHbase.parse_syntax("INSERT INTO `utests` (`val`, `num`) VALUES ('test', 1)") }
    it "succeeds" do
      expect(response.class).to eq(Treetop::Runtime::SyntaxNode)
    end
  end
  
  context "when parse_syntax is run against CREATE TABLE query without backticks" do
    let(:response) { HipsterSqlToHbase.parse_syntax("CREATE TABLE users (user VARCHAR(10), pass VARCHAR(5))") }
    it "succeeds" do
      expect(response.class).to eq(Treetop::Runtime::SyntaxNode)
    end
  end
  
  context "when parse_syntax is run against CREATE TABLE query with backticks" do
    let(:response) { HipsterSqlToHbase.parse_syntax("CREATE TABLE `users` (`user` VARCHAR(10), `pass` VARCHAR(5))") }
    it "succeeds" do
      expect(response.class).to eq(Treetop::Runtime::SyntaxNode)
    end
  end
  
end

describe "HipsterSqlToHbase.parse_tree method" do 
  
  context "when parse_tree is run against SELECT FROM query without table hierarchy or backticks" do
    let(:response) { HipsterSqlToHbase.parse_tree("SELECT user FROM users") }
    it "returns a valid ResultTree" do
      expect(response.class).to eq(HipsterSqlToHbase::ResultTree)
      expect(response[:query_type]).to eq(:select)
      expect(response[:query_hash].class).to eq(Hash)
      expect(response[:query_hash][:select][:columns].class).to eq(Array)
      expect(response[:query_hash][:select][:columns].length).to eq(1)
      expect(response[:query_hash][:select][:columns][0]).to eq('user')
      expect(response[:query_hash][:from].class).to eq(Array)
      expect(response[:query_hash][:from][0]).to eq('users')
      expect(response[:query_hash][:where]).to be_nil
      expect(response[:query_hash][:limit]).to be_nil
      expect(response[:query_hash][:order]).to be_nil
    end
  end
  
  context "when parse_tree is run against SELECT FROM query with backticks but no table hierarchy" do
    let(:response) { HipsterSqlToHbase.parse_tree("SELECT `user` FROM `users`") }
    it "succeeds" do
      expect(response.class).to eq(HipsterSqlToHbase::ResultTree)
      expect(response[:query_type]).to eq(:select)
      expect(response[:query_hash].class).to eq(Hash)
      expect(response[:query_hash][:select][:columns].class).to eq(Array)
      expect(response[:query_hash][:select][:columns].length).to eq(1)
      expect(response[:query_hash][:select][:columns][0]).to eq('user')
      expect(response[:query_hash][:from].class).to eq(Array)
      expect(response[:query_hash][:from][0]).to eq('users')
      expect(response[:query_hash][:where]).to be_nil
      expect(response[:query_hash][:limit]).to be_nil
      expect(response[:query_hash][:order]).to be_nil
    end
  end
  
  context "when parse_tree is run against SELECT FROM query with backticks and table hierarchy" do
    let(:response) { HipsterSqlToHbase.parse_tree("SELECT `users`.`user` FROM `users`") }
    it "returns a HipsterSqlToHbase ResultTree" do
      expect(response.class).to eq(HipsterSqlToHbase::ResultTree)
      expect(response[:query_type]).to eq(:select)
      expect(response[:query_hash].class).to eq(Hash)
      expect(response[:query_hash][:select][:columns].class).to eq(Array)
      expect(response[:query_hash][:select][:columns].length).to eq(1)
      expect(response[:query_hash][:select][:columns][0]).to eq('user')
      expect(response[:query_hash][:from].class).to eq(Array)
      expect(response[:query_hash][:from][0]).to eq('users')
      expect(response[:query_hash][:where]).to be_nil
      expect(response[:query_hash][:limit]).to be_nil
      expect(response[:query_hash][:order]).to be_nil
    end
  end
  
  context "when parse_tree is run against INSERT INTO query without backticks" do
    let(:response) { HipsterSqlToHbase.parse_tree("INSERT INTO users (val, num) VALUES ('test', 1)") }
    it "returns a HipsterSqlToHbase ResultTree" do
      expect(response.class).to eq(HipsterSqlToHbase::ResultTree)
      expect(response[:query_type]).to eq(:insert)
      expect(response[:query_hash].class).to eq(Hash)
      expect(response[:query_hash][:into].class).to eq(String)
      expect(response[:query_hash][:into]).to eq('users')
      expect(response[:query_hash][:columns].class).to eq(Array)
      expect(response[:query_hash][:columns].length).to eq(2)
      expect(response[:query_hash][:columns][0]).to eq('val')
      expect(response[:query_hash][:columns][1]).to eq('num')
      expect(response[:query_hash][:values].class).to eq(Array)
      expect(response[:query_hash][:values].length).to eq(1)
      expect(response[:query_hash][:values][0].class).to eq(Array)
      expect(response[:query_hash][:values][0].length).to eq(2)
      expect(response[:query_hash][:values][0][0]).to eq('test')
      expect(response[:query_hash][:values][0][1]).to eq(1)
    end
  end
  
  context "when parse_tree is run against INSERT INTO query with backticks" do
    let(:response) { HipsterSqlToHbase.parse_tree("INSERT INTO `users` (`val`, `num`) VALUES ('test', 1)") }
    it "returns a HipsterSqlToHbase ResultTree" do
      expect(response.class).to eq(HipsterSqlToHbase::ResultTree)
      expect(response[:query_type]).to eq(:insert)
      expect(response[:query_hash].class).to eq(Hash)
      expect(response[:query_hash][:into].class).to eq(String)
      expect(response[:query_hash][:into]).to eq('users')
      expect(response[:query_hash][:columns].class).to eq(Array)
      expect(response[:query_hash][:columns].length).to eq(2)
      expect(response[:query_hash][:columns][0]).to eq('val')
      expect(response[:query_hash][:columns][1]).to eq('num')
      expect(response[:query_hash][:values].class).to eq(Array)
      expect(response[:query_hash][:values].length).to eq(1)
      expect(response[:query_hash][:values][0].class).to eq(Array)
      expect(response[:query_hash][:values][0].length).to eq(2)
      expect(response[:query_hash][:values][0][0]).to eq('test')
      expect(response[:query_hash][:values][0][1]).to eq(1)
    end
  end
  
  context "when query is only a lower-case 'select'" do
    let(:response) { HipsterSqlToHbase.parse_tree("select") }
    it "does not succeed" do
      expect(response).to be_nil
    end
  end
  
end

describe "HipsterSqlToHbase.parse method" do 
  
  context "when query is only a lower-case 'select'" do
    let(:response) { HipsterSqlToHbase.parse("select") }
    it "does not succeed" do
      expect(response).to be_nil
    end
  end
  
end