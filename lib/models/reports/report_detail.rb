class ReportDetail
  # attr_accessible :title, :body
  attr_accessor :product_code, :product_name, :top, :stok_total, :q_ordered, :order_num, :cmd_date
  attr_accessor :c, :supplier_code, :supplier_name

  def initialize(attrs)
    @product_code = attrs['Product_Code'].scan(/(\d*)/).flatten[0] # LM-код
    @product_name = attrs['Code_Ean']     # наименование
    @top = attrs['textbox9']              # топ пополнения
    @stok_total = attrs['Stock_Total'].to_i     # общий запас
    @q_ordered = attrs['textbox42'].scan(/^\d+ - (\d+)$/).flatten[0].to_i  # заказаное колличество
    @order_num = attrs['textbox11'].scan(/^\d+ - (\d+)$/).flatten[0] || ''       # номер последнего заказа
    begin
      @cmd_date = attrs['Cmd_Date'].empty? ? nil : Date.strptime( attrs['Cmd_Date'], '%d/%m/%y')# дата поставки по договору
    rescue => e
      if e.is_a? ArgumentError
        @cmd_date = nil
      else
        raise e
      end
    end
    @supplier_code = attrs['supplier_code']
    @supplier_name = attrs['supplier_name']
  end

  def to_hash
    {
      product_code: @product_code,
      product_name: @product_name,
      stock_total: @stock_total,
      order_num: @order_num,
      q_ordered: @q_ordered,
      cmd_date: @cmd_date,
      supplier_code: @supplier_code,
      supplier_name: @suplier_name,
      top: @top
    }
  end
end
