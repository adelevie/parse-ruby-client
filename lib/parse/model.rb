# -*- encoding : utf-8 -*-
module Parse
  class Model < Parse::Object
    def initialize(data=nil)
      super(self.class.to_s,data)
    end
  end
end
