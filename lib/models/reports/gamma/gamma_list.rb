#coding:utf-8
require 'models/reports/report_detail'
class GammaList < Report

  DefaultRootSelector = 'Report[@Name="Список_гаммы"]'

  def init_details doc
    if doc
      REXML::XPath.each(doc, "//#{options[:xml_root_selector]}/descendant::Detail") do |det|
        @details.push Good.new det
      end
    end
  end

end
