class LmFpTpReportDetail < LmReportDetail
  def initialize data={}

    super data

    case data.class.to_s
      when 'Hash'
        @data_hash = data
      when 'REXML::Element'
        @data_hash[:product_name] = data.attributes['Code_Ean']   # название товара
        @data_hash[:product_code] = data.attributes['Product_Code'].to_s[/\b\S*\b/]      # LM-код
        @data_hash[:top_restocking] = data.attributes['textbox9']           # топ пополнения (1, 2, 0)
        @data_hash[:stock_total] = data.attributes['Stock_Total'].to_i
        @data_hash[:q_ordered] = (data.attributes['textbox42'][/^\d+ - (\d+)$/]) ?  $1.to_i : 0  # заказаное колличество
        @data_hash[:order_num] = (data.attributes['textbox11'][/^\d+ - (\d+)$/]) ?  $1 : ''       # номер последнего заказа
        begin
          @data_hash[:cmd_date] = data.attributes['Cmd_Date'].empty? ? nil : Date.strptime( data.attributes['Cmd_Date'], '%d/%m/%y')# дата поставки по договору
        rescue => e
          if e.is_a? ArgumentError
            @data_hash[:cmd_date] = nil
          else
            raise e
          end

        end

        suppl = REXML::XPath.first(data,'ancestor::table1_Group2').attributes['textbox26'][/^(\d*)? ?(\D*)?$/]

        @data_hash[:suppl_code] = $1              # код поставщика
        @data_hash[:suppl_name] = $2
    end
  end

end
