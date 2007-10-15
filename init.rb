require 'labeling_form_builder'
require 'labeling_form_tag_helper'

module ActionView::Helpers::FormTagHelper
  # Use to overwrite the default, non-instance based form helpers.
  def self.enable_labeling_form_helper!
    module_eval { include LabelingFormTagHelper }
  end
end
