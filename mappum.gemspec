# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{mappum}
  s.version = "0.1.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Jan Topi\305\204ski"]
  s.date = %q{2009-06-29}
  s.default_executable = %q{mapserver.rb}
  s.description = %q{}
  s.email = %q{jtopinski@chatka.org}
  s.executables = ["mapserver.rb"]
  s.extra_rdoc_files = [
    "LICENSE",
     "README"
  ]
  s.files = [
    ".gitignore",
     "LICENSE",
     "README",
     "Rakefile",
     "VERSION",
     "bin/mapserver.rb",
     "lib/mappum.rb",
     "lib/mappum/dsl.rb",
     "lib/mappum/map.rb",
     "lib/mappum/mapserver/mapgraph.rb",
     "lib/mappum/mapserver/mapserver.rb",
     "lib/mappum/mapserver/views/transform-ws.wsdl.erb",
     "lib/mappum/mapserver/views/ws-error.erb",
     "lib/mappum/open_xml_object.rb",
     "lib/mappum/ruby_transform.rb",
     "lib/mappum/xml_transform.rb",
     "mappum.gemspec",
     "sample/address_fixture.xml",
     "sample/crm.rb",
     "sample/crm_client.xsd",
     "sample/erp.rb",
     "sample/erp_person.xsd",
     "sample/example_map.rb",
     "sample/example_notypes.rb",
     "sample/person_fixture.xml",
     "sample/person_fixture_any.xml",
     "sample/server/map/example_any.rb",
     "sample/server/map/example_soap4r.rb",
     "sample/server/mapserver.sh",
     "sample/server/schema/crm_client.xsd",
     "sample/server/schema/erp/erp_person.xsd",
     "test/test_example.rb",
     "test/test_openstruct.rb",
     "test/test_soap4r.rb",
     "test/test_xml_any.rb"
  ]
  s.has_rdoc = true
  s.homepage = %q{http://wiki.github.com/simcha/mappum}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.1}
  s.summary = %q{Mappum is the tree to tree (object, bean etc.) mapping DSL.}
  s.test_files = [
    "test/test_example.rb",
     "test/test_openstruct.rb",
     "test/test_xml_any.rb",
     "test/test_soap4r.rb"
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<facets>, [">= 2.5.2"])
      s.add_runtime_dependency(%q<soap4r>, [">= 1.5.8"])
      s.add_runtime_dependency(%q<sinatra>, [">= 0.9.2"])
      s.add_runtime_dependency(%q<thin>, [">= 1.2.2"])
    else
      s.add_dependency(%q<facets>, [">= 2.5.2"])
      s.add_dependency(%q<soap4r>, [">= 1.5.8"])
      s.add_dependency(%q<sinatra>, [">= 0.9.2"])
      s.add_dependency(%q<thin>, [">= 1.2.2"])
    end
  else
    s.add_dependency(%q<facets>, [">= 2.5.2"])
    s.add_dependency(%q<soap4r>, [">= 1.5.8"])
    s.add_dependency(%q<sinatra>, [">= 0.9.2"])
    s.add_dependency(%q<thin>, [">= 1.2.2"])
  end
end
