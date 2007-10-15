module LabelingFormHelperHelper #:nodoc:
    
private
  def extract_label_options!(args) #:nodoc:
    options = args.last.is_a?(Hash) ? args.last : {}
    
    label = options.delete :label
    
    return label if label == false
    
    label = case label
    when Hash   then label
    when String then { :text => label }
    when nil    then {}
    end
    
    label[:for] = options[:id]
    
    label
  end
  
  def extract_label_html!(label) #:nodoc:
    [:id, :class, :for].inject({}) { |html,k| html.merge k => label.delete(k) }
  end
  
  def validate_after_option!(label) #:nodoc:
    raise ArgumentError, ':label_after works in conjunction with :label_wrap => true' if label[:after]
  end
  
  def check_or_radio?(helper) #:nodoc:
    [:check_box_tag, :radio_button_tag].include? helper.to_sym
  end
end
