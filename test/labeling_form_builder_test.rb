require File.join(File.dirname(__FILE__), 'test_helper')

require 'labeling_form_builder'

# See ActionView's FormHelperTest to explain the following setup, and the test's use
# of setup() and things like setting _erbout to an empty string.
silence_warnings do
  Post = Struct.new("Post", :title, :author_name, :body, :secret, :written_on, :cost)
  Post.class_eval do
    alias_method :title_before_type_cast, :title unless respond_to?(:title_before_type_cast)
    alias_method :body_before_type_cast, :body unless respond_to?(:body_before_type_cast)
    alias_method :author_name_before_type_cast, :author_name unless respond_to?(:author_name_before_type_cast)
  end
end

class LabelingFormBuilderTest < Test::Unit::TestCase
  include ActionView::Helpers::FormHelper
  include ActionView::Helpers::FormTagHelper
  include ActionView::Helpers::UrlHelper
  include ActionView::Helpers::TagHelper
  include ActionView::Helpers::TextHelper
  
  def setup
    @post = Post.new
    def @post.errors() Class.new{ def on(field) field == "author_name" end }.new end

    def @post.id; 123; end
    def @post.id_before_type_cast; 123; end
    def @post.attributes; %w(title author_name body secret written_on); end

    @post.title       = "Hello World"
    @post.author_name = ""
    @post.body        = "Back to the hill and over it again!"
    @post.secret      = 1
    @post.written_on  = Date.new(2004, 6, 15)

    @controller = Class.new do
      attr_reader :url_for_options
      def url_for(options, *parameters_for_method_reference)
        @url_for_options = options
        "http://www.example.com"
      end
    end
    @controller = @controller.new
    
    ActionView::Base.default_form_builder = LabelingFormBuilder
  end
  
  def test_labeling_builder_is_used
    flunk "this test sucks, but the plugin works, i swear."
    
    _erbout = ''
    
    form_for :post, @post do |f|
      labelable_helpers.each do |h|
        a = random_attribute
        f.expects(h).with(a)
        f.expects("#{h}_without_label").with(a)
        f.send h, a
      end
    end    
  end
  
  private
    def labelable_helpers
      LabelingFormBuilder.labelable
    end
    
    def random_attribute
      @post.attributes[rand(@post.attributes.size)]
    end
end
