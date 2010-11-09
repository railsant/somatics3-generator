# Methods added to this helper will be available to all templates in the application.
module Admin::AdminHelper
  def content_for(name, content = nil, &block)
    @has_content ||= {}
    @has_content[name] = true
    super(name, content, &block)
  end
  
  def has_content?(name)
    (@has_content && @has_content[name]) || false
  end

  def match_controller?(name)
    controller.controller_name == name
  end

  def match_action?(name)
    controller.action_name == name
  end

  def sort_asc_desc_helper(model_name, param)
    result = image_tag('somatics/sort_asc.png') if params[:"#{model_name}_sort"] == param
    result = image_tag('somatics/sort_desc.png') if params[:"#{model_name}_sort"] == param + "_reverse"
    return result || ''
  end

  def sort_link_helper(text, model_name ,param)
    key = param
    key += "_reverse" if params[:"#{model_name}_sort"] == param
    html_options = {
      :title => I18n.t("sort_by",:field => text),
      :remote=>true
    }
    link_to(text, params.merge({:"#{model_name}_sort" => key}), html_options)  + sort_asc_desc_helper(model_name,param)
  end
  
  def paper_trail_for(object)
    render 'admin/shared/versions', :obj => object
  end
  
  def excel_document(xml, &block)
    xml.instruct! :xml, :version=>"1.0", :encoding=>"UTF-8" 
    xml.Workbook({
      'xmlns'      => "urn:schemas-microsoft-com:office:spreadsheet", 
      'xmlns:o'    => "urn:schemas-microsoft-com:office:office",
      'xmlns:x'    => "urn:schemas-microsoft-com:office:excel",    
      'xmlns:html' => "http://www.w3.org/TR/REC-html40",
      'xmlns:ss'   => "urn:schemas-microsoft-com:office:spreadsheet" 
    }) do
      xml.Styles do
        xml.Style 'ss:ID' => 'Default', 'ss:Name' => 'Normal' do
          xml.Alignment 'ss:Vertical' => 'Bottom'
          xml.Borders
          xml.Font 'ss:FontName' => 'Arial'
          xml.Interior
          xml.NumberFormat
          xml.Protection
        end
      end
      yield block
    end
  end
end
