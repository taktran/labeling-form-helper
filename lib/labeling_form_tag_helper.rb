require 'labeling_form_helper_helper'

module LabelingFormTagHelper
  include LabelingFormHelperHelper, ActionView::Helpers::FormTagHelper
  
  # A list of labelable helpers. We exclude password and file fields because they use text field,
  # so we would get double labels including them.
  def self.labelable
    public_instance_methods.reject { |h| h =~ /form|submit|hidden|password|file/ }
  end
  
  new_helpers = labelable.inject('') do |defs, helper|    
    defs << %{
      def #{helper}_with_label(*args)
      # def #{helper}(*args)
        label = extract_label_options! args
                
        handle_disparate_args! :#{helper}, args
        
        # allow access to old behavior with :label => false
        # unlabeled_tag = #{helper}_without_label *args
        unlabeled_tag = #{helper}_without_label *args
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
      
      alias_method_chain :#{helper}, :label
    }
  end
  
  module_eval new_helpers, __FILE__, __LINE__
  
  private    
    def extract_id(name)
      name.gsub(/[^a-z0-9_-]+/,'_').gsub(/^_+|_+$/,'')
    end
    
    # We need to account for certain optional arguments
    # that can occur before the options hash in the unlabeled helpers.
    #
    # Specifically, we want to be able to ignore them and say things like:
    #     check_box_tag :bulk_delete, :label => false
    def handle_disparate_args!(helper, args)
      # Ignore the options hash, if present, until we are done munging the args.
      options = args.pop if args.last.is_a? Hash

      if args.size == 1
        if check_or_radio? helper
          args.insert 1, 1
        # Everything except :file_field_tag takes something as its second
        # argument which can be safely defaulted to +nil+.
        elsif helper != :file_field_tag
          args.insert 1, nil
        end
      end

      # :check_box_tag and :radio_button_tag can take another argument
      # to determine if they are 'checked' or not.
      if args.size == 2
        if check_or_radio? helper
          args.insert 2, false
        end
      end

      # Reunite the options with the rest of the args.
      args << options if options
    end

    def check_or_radio?(helper)
      [:check_box_tag, :radio_button_tag].include? helper.to_sym
    end

end
