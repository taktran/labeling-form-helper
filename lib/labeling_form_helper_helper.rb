module LabelingFormHelperHelper  
  def self.included(base)
    instance_methods.each { |name| base.send :protected, name }
  end  
  
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
    raise ArgumentError, ':label_after works in conjunction with :label_wrap => true' if label[:after]
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