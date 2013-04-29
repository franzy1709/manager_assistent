#coding: utf-8

class LmInterruptsReport < ConsolidatedReport

  def initialize data = {}
    @data_source_shema = {
      pp_report: LmPpReport,
      tp_report: LmTpReport,
      fp_report: LmFpReport,
      gl_report: GammaList
    }
    super data
  end

  def init_details
    # обработка отчета ФП
    ppr = @data[:source_reports][:pp_report]
    glr = @data[:source_reports][:gl_report]
    fpr = @data[:source_reports][:fp_report]
    fpr.details.each do |det|

      product_info = glr.details.select{|gl_det|
        gl_det.product_code == det.product_code
      }.first || Good.new(product_code: det.product_code)


      pp_records = ppr.details.select{ |pd|
          pd.order_num.match(/\b#{det.order_num}\b/)
      } unless det.order_num.empty?
      pp_records ||= []


      first_date = ppr.details.select{|ds|
        ds.order_num.match(/#{det.order_num}/)
      }.map{|ds|ds.supply_date}.min || (options[:report_date] || Date.today)
      #}.map{|ds|ds.supply_date}.min || Date.today

      det_hash = det.to_hash

      det_hash[:product_info] = product_info

      r_codes = [3]

      if det.stock_total > 0
        r_codes.push 4
        if (det.stock_total <= product_info.stock_min) && det.order_num.empty?
          r_codes.push 9
        end
      else
        if det.order_num.empty?
          r_codes.push 6
          if det.top_restocking != '1'
            r_codes.push 8
          else
            r_codes.push 9
          end
        else
          r_codes.push 5
          if (det.cmd_date && det.cmd_date < first_date)
            r_codes.push 10
          elsif !pp_records.empty?
            r_codes.push 11
          end
        end
      end
        det_hash = det.to_hash
        det_hash[:report_codes] = r_codes


        det_hash[:pp_records] ||= pp_records || []

        @details[det.product_code.to_sym] = LmReportDetail.new det_hash

    end

    # обработка отчета ТП
    tpr = @data[:source_reports][:tp_report]
    glr = @data[:source_reports][:gl_report]

    tpr.details.each do |det|

      pp_records = ppr.details.select{ |pd|
          pd.order_num.match(/\b#{det.order_num}\b/)
      } unless det.order_num.empty?
      pp_records ||= []

      product_info = glr.details.select{|gl_det|
        gl_det.product_code == det.product_code
      }.first || Good.new(product_code: det.product_code)

      det_hash = det.to_hash
      det_hash[:product_info] = product_info

      det_hash[:pp_records] = pp_records
      

      r_codes = [1]

      if  det.order_num.empty?
        r_codes.push 9
      end

      r_codes.push(2) if det.stock_total < 0

      if !@details[det.product_code.to_sym].blank?

        @details[det.product_code.to_sym].report_codes += r_codes
        @details[det.product_code.to_sym].report_codes.flatten!

      else

        det_hash = det.to_hash
        r_codes.push(12) if det.top_restocking == '1'
        det_hash[:report_codes] = r_codes
        @details[det.product_code.to_sym] = LmReportDetail.new det_hash

      end
    end

  end

end
