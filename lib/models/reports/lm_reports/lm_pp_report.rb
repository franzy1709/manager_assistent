#coding:utf-8
class LmPpReport < Report

  DefaultRootSelector = 'Report[@Name="План_поставок V3"]'

  def init_details doc
    if doc
      REXML::XPath.each(doc, "//#{@options[:xml_root_selector]}/descendant::Detail") do |det|

        @details.push LmPpReportDetail.new det

      end
    end
  end

end
