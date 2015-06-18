# -*- encoding : utf-8 -*-
module Parse
  class Model < Parse::Object
    def initialize(data = nil, client = nil)
      client ||= Parse.client
      super(self.class.to_s, data, client)
    end

    def self.find(object_id)
      new Parse::Query.new(to_s).eq('objectId', object_id).first
    end
  end
end
