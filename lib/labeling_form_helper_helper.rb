module LabelingFormHelperHelper
    
private  
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
end