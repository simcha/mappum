$:.unshift File.join(File.dirname(__FILE__),'..','lib')

require 'mappum/ruby_transform'
require 'test/unit'
require 'sample/example_when'

class TestWhen < Test::Unit::TestCase
  def test_when
    catalogue = Mappum.catalogue
    rt = Mappum::RubyTransform.new(catalogue)
    foo = OpenStruct.new
    foo.age = 9
    foo.mem =11
    bar = rt.transform(foo, :foo)
    assert_equal(bar.tem, 11)
    assert_equal(bar.gem, nil)
    foo.mem = 2
    bar = rt.transform(foo, :foo)
    assert_equal(bar.gem, 2)
    assert_equal(bar.tem, nil)
   end
   def test_when_not
    catalogue = Mappum.catalogue
    rt = Mappum::RubyTransform.new(catalogue)
    foo = OpenStruct.new
    foo.age = 99
    bar = rt.transform(foo, :foo)
    assert_equal(bar, nil)
   end
end

