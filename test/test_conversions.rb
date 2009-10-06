$:.unshift File.join(File.dirname(__FILE__),'..','lib')

require 'mappum/ruby_transform'
require 'test/unit'
require 'sample/example_conversions'

class TestConversions < Test::Unit::TestCase
  def test_conv
    catalogue = Mappum.catalogue
    rt = Mappum::RubyTransform.new(catalogue)
    typed = OpenStruct.new
    typed.date = Date.today
    typed.time = Time.parse "Tue, 06 Oct 2009 10:12:32 +0200"
    typed.fixnum = 982147
    typed.float = 219830.398274
    stringed = rt.transform(typed,catalogue[:typed])
    assert_equal(Date.today.to_s,stringed.date)
    assert_equal("Tue, 06 Oct 2009 10:12:32 +0200",stringed.time)
    assert_equal("982147",stringed.fixnum)
    assert_equal("219830.398274",stringed.float)
    typed2 = rt.transform(stringed,catalogue[:stringed])
    assert_equal(typed,typed2)
  end
end
