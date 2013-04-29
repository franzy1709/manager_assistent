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

      report_date = options[:report_date] || Date.today

      first_date = ppr.details.select{|ds|
        ds.order_num.match(/#{det.order_num}/)
      }.map{|ds|ds.supply_date}.min || (options[:report_date] || Date.today)
      #}.map{|ds|ds.supply_date}.min || Date.today

      det_hash = det.to_hash

      det_hash[:product_info] = product_info

      r_codes = [3] # код отчета 3 - позиция из списка физических перебоев

      #if det.stock_total > 0 # проверка на наличие товара на остатке
      if det.stock_total > product_info.reserve_expo
        r_codes.push 4 #код 4 - товар, имеющий положительный остаток
        r_codes.push 104 # код 104 - товар, который необходимо выставить
        #r_code = 4
        if ((det.stock_total) <= product_info.stock_min+product_info.reserve_expo) && det.order_num.empty?
          r_codes.push 109 # код 109 - необходимо сделать заказ
          #r_code = 9
        end
        #r_codes.push r_code
      else
        if det.stock_total > 0
          r_codes.push 104 # код 104 - товар, который необходимо выставить
        end
        # если при прохождении алгоритма попали сюда,
        # значит запаса товара нет
        if det.order_num.empty? #проверка на наличие заказа
          # заказа нет
          r_codes.push 6 # Код 6 - все товары без заказа
          #if det.top_restocking != '1'
          if det.top_restocking[/^(0|2)$/] # если товар в ТОПе 0 или 2
            r_codes.push 8 # Код 8 - физический перебой с ТОП 0 или 2
          else
            r_codes.push 9    # Код 9 - физический перебой без заказа и ТОП 1
            r_codes.push 109  # Код 109 - необходимо сделать заказ
          end
        else
          # если попали сюда, значит у позиции есть заказ
          r_codes.push 5 # код 5 - физический перебой с заказом
          if (det.cmd_date && det.cmd_date <= (first_date || report_date)) # соотношение даты ожидания поставки с наибоее
                                                                          # ранней датой записи в плане поставок,
                                                                          # либо c датой составения отчета
            # если дата ожидания поставки меньше, любой из сравниваемых дат
            r_codes.push 10 # код 10 - поставщик задержал поставку
          #elsif !pp_records.empty?
          else
            r_codes.push 11 # код 11 - у поставщика есть еще время по условиям договора
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

      r_codes = [1] # код 1 - позиция из списка теоретических перебоев

      if  det.order_num.empty? # проверка на наличие заказа
        r_codes.push 109 # код 109 - необходимо сделать заказ
      end

      r_codes.push(2) if det.stock_total < 0 # код 2 - отрицательный остаток

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
