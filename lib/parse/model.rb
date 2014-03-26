# -*- encoding : utf-8 -*-
module Parse
  class Model < Parse::Object
    def initialize
      super(self.class.to_s)
    end
  end
end
