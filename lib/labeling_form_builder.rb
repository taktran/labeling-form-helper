require 'labeling_form_helper_helper'

class  LabelingFormBuilder < ActionView::Helpers::FormBuilder
  include LabelingFormHelperHelper
  
  LABELABLE = (field_helpers + public_instance_methods.grep(/select/)) - 
              %w( form_for fields_for hidden_field )
  
  new_helpers = LABELABLE.inject('') do |defs,helper|
    defs << %{
      # def #{helper}(*args)
      def #{helper}_with_label(*args)
        label = extract_label_options! args
        
        # handle_disparate_args! :#{helper}, args

        # allow access to original behavior using :label => false
        unlabeled_tag = super # #{helper}_without_label *args
        return unlabeled_tag if label[:disabled]
        
        label[:for]  ||= extract_id unlabeled_tag
        label[:text] ||= label[:for].humanize
        
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
      
      alias_method_chain :#{helper}, :label
    }
  end
  
  class_eval new_helpers, __FILE__, __LINE__
  
  private
    def extract_id(tag)
      from_id   = /\s+id="([^"]+)"/.match(tag).captures[0]
      from_name = /\s+name="([^"]+)"/.match(tag).captures[0].scan(/\w+/).join('_')
      from_id || from_name
    end

end