# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run the gemspec command
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{mappum}
  s.version = "0.2.3"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Jan Topi\305\204ski"]
  s.date = %q{2009-12-15}
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
     "java-api/pom.xml",
     "java-api/src/main/java/pl/ivmx/mappum/JavaMappumException.java",
     "java-api/src/main/java/pl/ivmx/mappum/JavaTransform.java",
     "java-api/src/main/java/pl/ivmx/mappum/MappumApi.java",
     "java-api/src/main/java/pl/ivmx/mappum/TreeElement.java",
     "java-api/src/main/java/pl/ivmx/mappum/WorkdirLoader.java",
     "java-api/src/test/java/iv/Client.java",
     "java-api/src/test/java/iv/Person.java",
     "java-api/src/test/java/pl/ivmx/mappum/MappumTest.java",
     "java-api/src/test/resources/map/error_map.rb",
     "java-api/src/test/resources/map/example_map.rb",
     "lib/mappum.rb",
     "lib/mappum/autoconv_catalogue.rb",
     "lib/mappum/dsl.rb",
     "lib/mappum/java_transform.rb",
     "lib/mappum/map.rb",
     "lib/mappum/map_space.rb",
     "lib/mappum/mappum_exception.rb",
     "lib/mappum/mapserver/mapgraph.rb",
     "lib/mappum/mapserver/mapserver.rb",
     "lib/mappum/mapserver/maptable.rb",
     "lib/mappum/mapserver/views/doc.erb",
     "lib/mappum/mapserver/views/error.erb",
     "lib/mappum/mapserver/views/main.erb",
     "lib/mappum/mapserver/views/maptable.erb",
     "lib/mappum/mapserver/views/rubysource.erb",
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
     "sample/example_context.rb",
     "sample/example_conversions.rb",
     "sample/example_map.rb",
     "sample/example_notypes.rb",
     "sample/example_when.rb",
     "sample/person_fixture.xml",
     "sample/person_fixture_any.xml",
     "sample/server/map/example_any.rb",
     "sample/server/map/example_soap4r.rb",
     "sample/server/mapserver.sh",
     "sample/server/schema/crm_client.xsd",
     "sample/server/schema/erp/erp_person.xsd",
     "test/test_context.rb",
     "test/test_conversions.rb",
     "test/test_example.rb",
     "test/test_openstruct.rb",
     "test/test_soap4r.rb",
     "test/test_when.rb",
     "test/test_xml_any.rb"
  ]
  s.homepage = %q{http://wiki.github.com/simcha/mappum}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.5}
  s.summary = %q{Mappum is the tree to tree (object, bean etc.) mapping DSL.}
  s.test_files = [
    "test/test_example.rb",
     "test/test_openstruct.rb",
     "test/test_when.rb",
     "test/test_conversions.rb",
     "test/test_xml_any.rb",
     "test/test_soap4r.rb",
     "test/test_context.rb"
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<facets>, [">= 2.5.2"])
      s.add_runtime_dependency(%q<soap4r>, [">= 1.5.8"])
      s.add_runtime_dependency(%q<sinatra>, [">= 0.9.2"])
      s.add_runtime_dependency(%q<thin>, [">= 1.2.2"])
      s.add_runtime_dependency(%q<syntax>, [">= 1.0.0"])
    else
      s.add_dependency(%q<facets>, [">= 2.5.2"])
      s.add_dependency(%q<soap4r>, [">= 1.5.8"])
      s.add_dependency(%q<sinatra>, [">= 0.9.2"])
      s.add_dependency(%q<thin>, [">= 1.2.2"])
      s.add_dependency(%q<syntax>, [">= 1.0.0"])
    end
  else
    s.add_dependency(%q<facets>, [">= 2.5.2"])
    s.add_dependency(%q<soap4r>, [">= 1.5.8"])
    s.add_dependency(%q<sinatra>, [">= 0.9.2"])
    s.add_dependency(%q<thin>, [">= 1.2.2"])
    s.add_dependency(%q<syntax>, [">= 1.0.0"])
  end
end

