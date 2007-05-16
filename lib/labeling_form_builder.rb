require 'labeling_form_helper_helper'

class LabelingFormBuilder < ActionView::Helpers::FormBuilder
  include LabelingFormHelperHelper
  
  # A list of labelable helpers. We exclude password and file fields because they use text field,
  # so we would get double labels including them.
  LABELABLE = (field_helpers + public_instance_methods.grep(/select/)) - 
              %w( form_for fields_for hidden_field password_field file_field )
  
  new_helpers = LABELABLE.inject('') do |defs,helper|
    defs << %{
      def #{helper}(*args)
        label = extract_label_options! args
        
        handle_disparate_args! :#{helper}, args

        # allow access to original behavior using :label => false
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
    }
  end
  
  class_eval new_helpers, __FILE__, __LINE__
  
  private
    def extract_for(tag)
      tag.slice %r{id="([^"]+)"}, 1
    end
end