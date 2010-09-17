class SomaticLinkRenderer < WillPaginate::ViewHelpers::LinkRenderer
  
  def prepare(collection, options, template)
    super
    @collection_name = template.controller.controller_name
    @param_name = "#{@collection_name}_page"
    @options[:previous_label] = I18n.t(:previous)
    @options[:next_label] = I18n.t(:next)
  end
  
  private
  
  def link(text, target, attributes = {})
    if target.is_a? Fixnum
      attributes[:rel] = rel_value(target)
      target = url(target)
    end
    attributes[:href] = target
    # tag(:a, text, attributes)
    @template.link_to(text,target, attributes.merge({:remote => true}))
  end


end