#This class extends ActionController::Base
class ActionController::Base
  
  attr_accessor :is_amf
  attr_accessor :is_rubyamf #-> for simeon :)-
  attr_accessor :used_render_amf
  attr_accessor :amf_content
  attr_accessor :rubyamf_attempt_file_render
  
  def amf_credentials
    return RequestStore.rails_authentication
  end
  
  def render(options = nil, deprecated_status = nil, &block)
    raise DoubleRenderError, "Can only render or redirect once per action" if performed?
    if options.nil?
      return render_file(default_template_name, deprecated_status, true)
    else
      #Backwards compatibility
      unless options.is_a?(Hash)
        if options == :update
          options = { :update => true }
        else
          ActiveSupport::Deprecation.warn(
            "You called render('#{options}'), which is a deprecated API call. Instead you use " +
            "render :file => #{options}. Calling render with just a string will be removed from Rails 2.0.",
            caller
          )
          return render_file(options, deprecated_status, true)
        end
      end
    end

    if content_type = options[:content_type]
      response.content_type = content_type.to_s
    end

    if text = options[:text]
      render_text(text, options[:status])

    else
      if file = options[:file]
        render_file(file, options[:status], options[:use_full_path], options[:locals] || {})

      elsif template = options[:template]
        render_file(template, options[:status], true)

      elsif inline = options[:inline]
        render_template(inline, options[:status], options[:type], options[:locals] || {})

      elsif action_name = options[:action]
        ActiveSupport::Deprecation.silence do
          render_action(action_name, options[:status], options[:layout])
        end

      elsif xml = options[:xml]
        render_xml(xml, options[:status])

      elsif json = options[:json]
        render_json(json, options[:callback], options[:status])
        
      elsif amf = options[:amf]
        self.used_render_amf = true
        self.amf_content = amf

      elsif partial = options[:partial]
        partial = default_template_name if partial == true
        if collection = options[:collection]
          render_partial_collection(partial, collection, options[:spacer_template], options[:locals], options[:status])
        else
          render_partial(partial, ActionView::Base::ObjectWrapper.new(options[:object]), options[:locals], options[:status])
        end

      elsif options[:update]
        add_variables_to_assigns
        @template.send :evaluate_assigns

        generator = ActionView::Helpers::PrototypeHelper::JavaScriptGenerator.new(@template, &block)
        render_javascript(generator.to_s)

      elsif options[:nothing]
        # Safari doesn't pass the headers of the return if the response is zero length
        render_text(" ", options[:status])

      else
        render_file(default_template_name, options[:status], true)
      end
    end
  end
end