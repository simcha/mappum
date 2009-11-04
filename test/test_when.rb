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
    foo.pol =15
    bar = rt.transform(foo, :foo)
    assert_equal(bar.tem, 11)
    assert_equal(bar.gem, nil)
    assert_equal(bar.gol,15)
    foo.mem = 2
    foo.pol = 0
    bar = rt.transform(foo, :foo)
    assert_equal(bar.gem, 2)
    assert_equal(bar.tem, nil)
    assert_equal(bar.gol, nil)
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

