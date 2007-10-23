module LabelingFormHelperHelper #:nodoc:
private
  def extract_label_options!(args) #:nodoc:
    options = args.last.is_a?(Hash) ? args.last : {}
    
    return false unless label = options.delete(:label )
    
    label = case label
    when Hash     then label
    when String   then { :text => label }
    when nil,true then {}
    end
    
    label[:for] = options[:id]
    
    label
  end
  
  def extract_label_html!(label) #:nodoc:
    [:id, :class, :for].inject({}) { |html,k| html.merge k => label.delete(k) }
  end
  
  def check_or_radio?(helper) #:nodoc:
    [:check_box_tag, :radio_button_tag].include? helper.to_sym
  end
end
