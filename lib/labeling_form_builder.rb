require 'labeling_form_helper_helper'

class  LabelingFormBuilder < ActionView::Helpers::FormBuilder
  # include LabelingFormHelperHelper
  
  LABELABLE = (field_helpers + public_instance_methods.grep(/select/)) - 
              %w( form_for fields_for hidden_field )
  
  new_helpers = LABELABLE.inject('') do |defs,helper|
    defs << %{
      def #{helper}(*args)
      # def #{helper}_with_label(*args)
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
      
      # alias_method_chain :#{helper}, :label
    }
  end
  
  class_eval new_helpers, __FILE__, __LINE__
  
  private
    def extract_id(tag)
      tag.slice %r(\[([^]]+)\]), 1
    end
    
    ###
    
    def extract_label_options!(args)
      return {} unless args.last.is_a? Hash

      options = args.last
      {
        :disabled => (options[:label] == false ? true : false),     
        :text     => options.delete(:label),
        :class    => options.delete(:label_class),
        :id       => options.delete(:label_id),
        :for      => options[:id],
        :wrap     => options.delete(:label_wrap),
        :after    => options.delete(:label_after)
      }
    end

    def extract_label_html!(label)
      [:id, :class, :for].inject({}) { |html,k| html.merge k => label.delete(k) }
    end

    def validate_after_option!(label)
      if label[:after]
        raise ArgumentError, ':label_after works in conjunction with :label_wrap => true'
      end
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

    # Returns true for +helper+ == :check_box_tag and :radio_button_tag
    def check_or_radio?(helper)
      [:check_box_tag, :radio_button_tag].include? helper.to_sym
    end

end