require File.join(File.dirname(__FILE__), 'test_helper')
require 'set'
require 'labeling_form_tag_helper'

class LabelingFormTagHelperTest < Test::Unit::TestCase
  include ActionView::Helpers::TagHelper
  include LabelingFormTagHelper

  def test_original_behavior
    labelable_helpers.each do |helper|
      # Split tag strings on whitespace, and convert to sets for comparison.
      # Stupid :radio_button_tag throws a wrench in the works.
      unlabeled_args = ["#{helper}_without_label", :foo]
      unlabeled_args << 1 if helper.to_sym == :radio_button_tag
      
      expected = send(*unlabeled_args).split(/\s+/).to_set
      actual   = send(helper, :foo, :label => false).split(/\s+/).to_set
      
      assert_equal expected, actual
    end
  end

  def test_custom_id_affects_label_for_attribute
    labelable_helpers.each do |helper|
      assert_match %r(<label.+for="bar"[^>]*>), send(helper, :foo, :id => :bar)
    end
  end
  
  def test_label_id
    labelable_helpers.each do |helper|
      assert_match %r(<label.+id="foo"[^>]*>), send(helper, :foo, :label => { :id => :foo })
    end
  end
  
  def test_label_class
    labelable_helpers.each do |helper|
      assert_match %r(<label.+class="foo"[^>]*>), send(helper, :foo, :label => { :class => :foo })
    end
  end
  
  def test_label_wrap
    labelable_helpers.each do |helper|
      assert_match    %r(</label>\Z), send(helper, :foo, :label => { :wrap => true })
    end
  end
  
  def test_label_after_with_wrap
    labelable_helpers.each do |helper|
      tag = send helper, :foo, :label => { :wrap => true, :after => true }
      assert_match    %r(Foo</label>\Z), tag
      assert_no_match %r(<label[^>]*?>Foo), tag
    end
  end
  
  def test_label_after
    labelable_helpers.each do |helper|
      tag = send helper, :foo, :label => { :after => true }
      assert_match    %r(Foo</label>\Z), tag
      assert_no_match %r(\A<label>),  tag
    end
  end
  
  def test_labels_once
    labelable_helpers.each do |helper|      
      label_tags = send(helper, :foo).scan(%r(</?label)).size      
      assert_equal 2, label_tags, ":#{helper} labeled #{label_tags / 2} times"
    end
  end
  
private
  def labelable_helpers
    LabelingFormTagHelper.labelable
  end
end