class ConsolidatedReport < Report

  attr :data_source_shema # схема соответствия исходных отчетов определенным классам
  attr :options

  def initialize data = {}
    @data = data.is_a?(Hash) ? data : {}

    @data[:source_reports] ||= {}
    @options =  @data[:options] ||= {}

    @data_source_shema ||= {}

    @data_source_shema.each do |key, report_class|
      @data[:source_reports][key] ||= report_class.new
    end

    @details = {}
    init_details
  end

  def init_details

  end

end
