require 'minitest/autorun'
require './lib/document'

class TestDocument < Minitest::Test
  def setup
    @data1        = []
    @data2        = ['simple']
    @data3        = ['simple', 'double']
    @data4        = ['simple', 'double', 'simple']
    @data5        = ['']
    @data6        = [333, 'double']
    @string_data1 = ""
    @string_data2 = "simple"
    @string_data3 = "simple double"
    @string_data4 = "simple, double"
    @string_data5 = "simple, double. simple"
    @file_data1   = "./data/no_text"
    @file_data2   = "./data/simple_text"
  end

  def test_document_constructors_returns_document_object
    assert_equal Document.new().class.name,                   'Document'
    assert_equal Document.from_array(@data1).class.name,      'Document'
    assert_equal Document.from_string('test').class.name,     'Document'
    assert_equal Document.from_file(@file_data1).class.name,  'Document'
  end

  def test_document_constructors_returns_proper_document
    assert_equal  Document.new().length,                       0
    assert_equal  Document.from_array(@data4).length,          3
    assert_equal  Document.from_string(@string_data5).length,  3
    assert_equal  Document.from_file(@file_data2).length,      23
#   add the form file constructor
  end

  def test_add_array_fills_document
    my_TFH = Document.new()
    assert_equal my_TFH.add_array(@data4).length,  3
    assert_equal my_TFH.add_array(@data4).length,  6
  end

  def test_invalid_argument_raises_argument_exception
    assert_raises  ArgumentError do
      Document.from_array("string")
    end

    assert_raises  ArgumentError do
      Document.from_string(["some", "array"])
    end

    assert_raises  ArgumentError do
      Document.from_file(["some", "array"])
    end
  end

  def test_wrong_filenames_are_caught
    assert_raises Errno::ENOENT do
      Document.from_file("filename")
    end
  end

  def test_no_argument_raises_argument_exception
  # It is normally handled by default
    assert_raises ArgumentError do
      Document.from_array()
    end
  end
end
