#coding:utf-8
class LmTpReport < Report

  DefaultRootSelector = 'Report[@Name="Список перебоев теоретич. запаса"]'

  def init_details doc
    if doc
      REXML::XPath.each(doc, "//#{options[:xml_root_selector]}//Detail") do |det|

        @details.push LmFpTpReportDetail.new det

      end
    end
  end

end
