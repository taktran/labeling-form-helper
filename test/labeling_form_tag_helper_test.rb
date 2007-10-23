require File.join(File.dirname(__FILE__), 'test_helper')
require 'set'
require 'labeling_form_tag_helper'

class LabelingFormTagHelperTest < Test::Unit::TestCase
  include ActionView::Helpers::TagHelper,
          ActionView::Helpers::FormTagHelper

  def test_original_behavior
    labelable.each do |helper|
      assert_no_match %r(<label), send(helper, :foo)
    end
  end

  def test_custom_id_affects_label_for_attribute
    labelable.each do |helper|
      assert_match %r(<label.+for="bar"[^>]*>), send(helper, :foo, :id => :bar, :label => true)
    end
  end
  
  def test_label_id
    labelable.each do |helper|
      assert_match %r(<label.+id="foo"[^>]*>), send(helper, :foo, :label => { :id => :foo })
    end
  end
  
  def test_label_class
    labelable.each do |helper|
      assert_match %r(<label.+class="foo"[^>]*>), send(helper, :foo, :label => { :class => :foo })
    end
  end
  
  def test_label_wrap
    labelable.each do |helper|
      assert_match %r(</label>\Z), send(helper, :foo, :label => { :wrap => true })
    end
  end
  
  def test_label_after_with_wrap
    label_after_options = [
      { :wrap => true, :after => true },
      { :wrap => :after }
    ]
    
    label_after_options.each do |opts|
      labelable.each do |helper|
        tag = send helper, :foo, :label => opts
        assert_match    %r(Foo</label>\Z),    tag
        assert_no_match %r(<label[^>]*?>Foo), tag
      end
    end
  end
  
  def test_label_after
    labelable.each do |helper|
      tag = send helper, :foo, :label => { :after => true }
      assert_match    %r(Foo</label>\Z), tag
      assert_no_match %r(\A<label>), tag
    end
  end
  
  def test_labels_once
    labelable.each do |helper|      
      label_tags = send(helper, :foo, :label => true).scan(%r(</?label)).size      
      assert_equal 2, label_tags, ":#{helper} labeled #{label_tags / 2} times"
    end
  end
  
private
  def labelable
    ActionView::Helpers::FormTagHelper.labelable
  end
end
