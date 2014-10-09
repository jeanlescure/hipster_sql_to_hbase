# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "hipster_sql_to_hbase"
  s.version = "0.3.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Jean Lescure"]
  s.date = "2014-02-21"
  s.description = "SQL to HBase parser using Treetop (output based on Thrift). Doing all this before it was cool."
  s.email = "jeanmlescure@gmail.com"
  s.extra_rdoc_files = [
    "LICENSE",
    "LICENSE.txt",
    "README.md",
    "README.rdoc"
  ]
  s.files = Dir.glob("{lib,spec}/**/*") + %w(.document Gemfile LICENSE LICENSE.txt README.md README.rdoc Rakefile VERSION hipster_sql_to_hbase.gemspec)
  s.homepage = "http://github.com/jeanlescure/hipster_sql_to_hbase"
  s.licenses = ["MIT"]
  s.require_paths = ["lib"]
  s.rubygems_version = "2.0.3"
  s.summary = "SQL to HBase parser using Treetop (output based on Thrift)."

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<treetop>, [">= 0"])
      s.add_runtime_dependency(%q<jml_thrift>, [">= 0"])
      s.add_runtime_dependency(%q<json>, [">= 0"])
      s.add_development_dependency(%q<bundler>, [">= 0"])
      s.add_development_dependency(%q<rspec>, [">= 0"])
      s.add_development_dependency(%q<rdoc>, ["~> 4.0.0"])
      s.add_development_dependency(%q<jfish>, [">= 0.1.1"])
    else
      s.add_dependency(%q<treetop>, [">= 0"])
      s.add_dependency(%q<jml_thrift>, [">= 0"])
      s.add_dependency(%q<json>, [">= 0"])
      s.add_dependency(%q<bundler>, [">= 0"])
      s.add_dependency(%q<rspec>, [">= 0"])
      s.add_dependency(%q<rdoc>, ["~> 4.0.0"])
      s.add_dependency(%q<jfish>, [">= 0.1.1"])
    end
  else
    s.add_dependency(%q<treetop>, [">= 0"])
    s.add_dependency(%q<jml_thrift>, [">= 0"])
    s.add_dependency(%q<json>, [">= 0"])
    s.add_dependency(%q<bundler>, [">= 0"])
    s.add_dependency(%q<rspec>, [">= 0"])
    s.add_dependency(%q<rdoc>, ["~> 4.0.0"])
    s.add_dependency(%q<jfish>, [">= 0.1.1"])
  end
end

