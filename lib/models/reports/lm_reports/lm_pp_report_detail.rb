class LmPpReportDetail < LmReportDetail

  def initialize data={}

    super data

    case data.class.to_s
      when 'Hash'
        @data_hash = data
      when 'REXML::Element'
        @data_hash[:order_num] = data.attributes['Nomer'] || ''
        @data_hash[:supply_date] = data.attributes['MyDate'].empty? ? nil : Date.strptime( data.attributes['MyDate'], '%d/%m/%y') if data.attributes['MyDate']
        @data_hash[:mesto] = data.attributes['mesto'] || ''
        @data_hash[:status] = data.attributes['status'] || ''
      end
  end

end
