require 'labeling_form_helper_helper'

module ActionView
module Helpers
module LabelingFormTagHelper
  include LabelingFormHelperHelper
  
  # A list of labelable helpers. We exclude password and file fields because they use text field,
  # so we would get double labels including them.
  LABELABLE = FormTagHelper.public_instance_methods.reject { |h| h =~ /form|submit|hidden|unlabeled|password|file/ }
  
  new_helpers = LABELABLE.inject('') do |defs, helper|    
    defs << %{
      # def #{helper}_with_label(*args)
      def #{helper}(*args)
        label = extract_label_options! args
                
        handle_disparate_args! :#{helper}, args
        
        # allow access to old behavior with :label => false
        # unlabeled_tag = #{helper}_without_label *args
        unlabeled_tag = FormTagHelper.#{helper} *args
        return unlabeled_tag if label[:disabled]
        
        name = args.first.to_s
        label[:text] ||= name.humanize
        label[:for]  ||= extract_id name
        
        label_html = extract_label_html! label
        
        if label[:wrap]
          label_and_tag = if label[:after]
            [unlabeled_tag, label[:text]]
          else
            [label[:text], unlabeled_tag]
          end.join("\n")
          
          content_tag(:label, label_and_tag, label_html)
        else
          validate_after_option! label
          
          [content_tag(:label, label[:text], label_html), unlabeled_tag].join("\n")
        end
      end
      
      # alias_method_chain :#{helper}, :label
    }
  end
  
  module_eval new_helpers, __FILE__, __LINE__
  
  private    
    def extract_id(name)
      name.gsub(/[^a-z0-9_-]+/,'_').gsub(/^_+|_+$/,'')
    end

end
end
end
