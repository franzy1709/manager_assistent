#coding:utf-8
require 'models/reports/report_detail'
class LmFpReport < Report

  DefaultRootSelector = 'Report[@Name="Список перебоев физического запаса OST"]'

  def init_details doc
    if doc
      REXML::XPath.each(doc, "//#{options[:xml_root_selector]}/descendant::Detail") do |det|

        @details.push LmFpTpReportDetail.new det

      end
    end
  end

end
