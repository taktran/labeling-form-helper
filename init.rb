require 'labeling_form_builder'
require 'labeling_form_tag_helper'

module ActionView::Base::Helpers
  # Use to overwrite the default, non-instance based form helpers.
  def self.use_labeling_form_helper!
    FormTagHelper.send :include, LabelingFormTagHelper
  end
end
