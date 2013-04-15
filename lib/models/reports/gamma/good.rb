class Good < LmReportDetail

  def initialize data={}

    super data

    case data.class.to_s
      when 'Hash'
        @data_hash = data
        @data_hash[:product_name] ||= ''   # название товара
        @data_hash[:product_code] ||= ''      # LM-код
        @data_hash[:product_barcode] ||= ''         # штрих-код
        @data_hash[:gamma_group] ||= ''           # гамма (A, B, P, S)
        @data_hash[:top_restocking] ||= ''           # топ пополнения (1, 2, 0)
        @data_hash[:restocking_type] ||= ''         # вид пополнения (M,S)
        @data_hash[:reserve_exposure] ||= ''        # резерв на экспозицию
        @data_hash[:stock_min] ||= 0          # минимальный запас
        @data_hash[:suppl_code] ||= ''              # код поставщика
        @data_hash[:cost_price] ||= 0        # закупочная цена
        @data_hash[:retail_price] ||= 0    # продажная цена
        @data_hash[:retail_margin] ||= 0  # маржа с продажи
        @data_hash[:recommended_price] ||= 0   # рекомендуемая цена
        @data_hash[:recommended_margin] ||= 0 # рекомендуемая маржа
      when 'REXML::Element'
        if data.attributes.is_a?(Hash)
        @data_hash[:product_name] = data.attributes['product_short_name'] || ''   # название товара
        @data_hash[:product_code] = data.attributes['product_LM_code'][/\b\S*\b/] || ''      # LM-код
        @data_hash[:product_barcode] = data.attributes['textbox62'] || ''         # штрих-код
        @data_hash[:gamma_group] = data.attributes['product_gam'] || ''           # гамма (A, B, P, S)
        @data_hash[:top_restocking] = data.attributes['top_repl'] || ''           # топ пополнения (1, 2, 0)
        @data_hash[:restocking_type] = data.attributes['textbox33'].to_s[/\b\S*\b/] || ''         # вид пополнения (M,S)
        @data_hash[:reserve_exposure] = data.attributes['textbox74'].to_i || 0        # резерв на экспозицию
        @data_hash[:stock_min] = data.attributes['textbox82'].to_i           # минимальный запас
        @data_hash[:suppl_code] = data.attributes['textbox19'] || ''              # код поставщика
        @data_hash[:cost_price] = data.attributes['cost_price'].to_f        # закупочная цена
        @data_hash[:retail_price] = data.attributes['retail_price'].to_f    # продажная цена
        @data_hash[:retail_margin] = data.attributes['retail_margin'].to_f  # маржа с продажи
        @data_hash[:recommended_price] = data.attributes['CA_price'].to_f   # рекомендуемая цена
        @data_hash[:recommended_margin] = data.attributes['CA_margin'].to_f # рекомендуемая маржа
        end
    end

  end

end
