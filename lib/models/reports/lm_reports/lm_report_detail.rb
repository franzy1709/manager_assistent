class LmReportDetail

  def initialize data={}

    @data_hash = data.is_a?(Hash) ? data : {}

  end

  def method_missing meth, *args, &block

    case meth.to_s
    when has_key?(meth.to_sym)
      @data_hash[meth]
    when /^(.*)=$/
      @data_hash[$1.to_sym] = args
    else
      super
    end
  end

  def to_s
    @data_hash.to_s
  end

  def to_hash
    @data_hash
  end

private

  def has_key? val
    (@data_hash.has_key? val.to_sym) ? val.to_s : nil
  end
end
