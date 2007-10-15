require 'labeling_form_builder'
require 'labeling_form_tag_helper'

class ActionView::Base
  # Use to overwrite the default, non-instance based form helpers.
  def self.enable_labeling_form_tag_helper!
    ActionView::Helpers::FormTagHelper.module_eval { include LabelingFormTagHelper }
  end
end
