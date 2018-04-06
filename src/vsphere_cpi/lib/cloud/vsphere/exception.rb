module VSphereCloud
  class VMPowerOnError < StandardError
    attr_reader :fault

    def initialize(fault)
      @fault = fault
    end

    def to_s
      "#{super}: #{fault.msg}"
    end
  end
end