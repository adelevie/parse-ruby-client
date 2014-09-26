# -*- encoding : utf-8 -*-
module Parse
  class Model < Parse::Object

    def initialize(data=nil)
      super(self.class.to_s,data)
    end

    def self.find(object_id)
      self.new Parse::Query.new(self.to_s).eq('objectId',object_id).first
    end

  end
end
