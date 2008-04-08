module LabelingFormHelper
  mattr_accessor :wrap_checks_and_radios
  self.wrap_checks_and_radios = true
end

require 'labeling_form_builder'
require 'labeling_form_tag_helper'

class ActionView::Base
  include LabelingFormHelperHelper
end
