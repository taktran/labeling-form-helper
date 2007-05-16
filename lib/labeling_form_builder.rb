require 'labeling_form_helper_helper'

class LabelingFormBuilder < ActionView::Helpers::FormBuilder
  include LabelingFormHelperHelper
  
  # A list of labelable helpers. We exclude password and file fields because they use text field,
  # so we would get double labels including them.
  def self.labelable
    (field_helpers + public_instance_methods.grep(/select/)) - 
    %w( form_for fields_for hidden_field password_field file_field )
  end
  
  labelable.each do |helper|
    define_method helper do |*args|
      label = extract_label_options! args
      
      unlabeled_tag = super
      return unlabeled_tag if label[:disabled]
      
      label[:for]  ||= extract_for unlabeled_tag
      label[:text] ||= args.first.to_s.humanize
      
      label_html = extract_label_html! label
      
      # return label and tag according to custom options
      if label[:wrap]
        label_and_tag = if label[:after]
          [unlabeled_tag, label[:text]]
        else
          [label[:text], unlabeled_tag]
        end.join("\n")
        
        @template.content_tag(:label, label_and_tag, label_html)
      else
        validate_after_option! label
        
        [@template.content_tag(:label, label[:text], label_html), unlabeled_tag].join("\n")
      end
    end
  end
  
  private
    def extract_for(tag)
      tag.slice %r{id="([^"]+)"}, 1
    end
end