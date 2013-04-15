require 'rexml/document'
class Report
  DefaultRootSelector = ''
  attr_accessor :details, :report_name, :options

  def initialize data = nil, process_report = true, opts = {}
    @details = []
    @report_name = ''
    @options = opts.is_a?(Hash) ? opts : {}
    @options[:xml_root_selector] = self.class::DefaultRootSelector unless @options.has_key? :xml_root_selector


    doc = case data.class.to_s
          when 'String'
            REXML::Document.new data unless data.empty?
          when 'REXML::Document', 'REXML::Element'
            data
          else
            nil
          end

    unless doc.nil?
      report_el = REXML::XPath.first(doc, "//#{options[:xml_root_selector]}")
      @report_name = report_el.nil? ? '' : report_el.attributes['Name']
      init_details doc
      processing_report if process_report
    end
  end

  def init_details doc = nil

  end

  def processing_report

  end

  def self.init doc
    case doc.class.to_s
    when 'REXML::Document'
      if REXML::XPath.first(doc, @options[:xml_root_selector]).nil?
        nil
      else
        self.new doc;
      end
    else
      nil
    end
  end

end
