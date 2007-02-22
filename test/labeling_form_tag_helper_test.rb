require 'test_helper'

class LabelingFormTagHelperTest < Test::Unit::TestCase
  include ActionView::Helpers::TagHelper
  include ActionView::Helpers::FormTagHelper

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
      assert_match %r(<label.+id="foo"[^>]*>), send(helper, :foo, :label_id => :foo)
    end
  end
  
  def test_label_class
    labelable_helpers.each do |helper|
      assert_match %r(<label.+class="foo"[^>]*>), send(helper, :foo, :label_class => :foo)
    end
  end
  
  def test_label_wrap
    labelable_helpers.each do |helper|
      assert_no_match %r(</label>\Z), send(helper, :foo)
      assert_match    %r(</label>\Z), send(helper, :foo, :label_wrap => true)
    end
  end
  
  def test_label_after_requires_wrap
    labelable_helpers.each do |helper|
      assert_raise ArgumentError do
        send helper, :foo, :label_after => true
      end
    end
  end
  
  def test_label_after
    labelable_helpers.each do |helper|
      assert_match %r(Foo</label>\Z),
        send(helper, :foo, :label_wrap => true, :label_after => true)
    end
  end
  
  private
    def labelable_helpers
      ActionView::Helpers::FormTagHelper::LABELABLE
    end
end
