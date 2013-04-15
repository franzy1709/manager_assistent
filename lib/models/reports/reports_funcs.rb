#coding:utf-8
require "rexml/document"
require "zip/zip"
require "erubis"

module ReportsFuncs

  def load_reports_from_zip zip_file, data_shema = {}

    res = {}

    if zip_file

      zf = zip_file.is_a?(Zip::ZipFile) ? zip_file : Zip::ZipFile.open(zip_file)

      doc = REXML::Document.new

      root = doc.add_element('Reports')
      zf.each do |f|

        if f.file? && f.name[/^[^\0\/]*\.xml$/] # xml-файлы должны находиться в корне архива
          xml = REXML::Document.new zf.read(f)
          el = REXML::XPath.first(xml, '//Report')
          root.add_element(el) if el.class == REXML::Element
        end
      end

      if root.size > 0

        res = {}

        data_shema.each do |key, report_class|
          res[key] = report_class.new doc
        end
      end
    end

    res
  end

  def report_to_xls templ_path, options = {}

    templ = File.read(templ_path)

    res = Erubis::Eruby.new(templ).result(options)
=begin
    if templ_path

      templ_book = Spreadsheet.open templ_path
      sheet = templ_book.worksheet 0
      sheet.each do |s_row|
        for i in s_row.first_used..(s_row.first_unused - 1)
          cel = s_row[i]
          res = nil
          #res = ERB.new(cel).result(binding) if cel && (cel.class == String)
          res = Erubis::Eruby.new(cel).result(options[:locals]) if cel && (cel.class == String)
          s_row[i] = res.to_s.match(/^(\d+$|\d+\.\d+)/) ? res.to_f : res if res
        end
      end

      buff = StringIO.new
      templ_book.write(buff)
      buff.string
    end
=end
  end
end
