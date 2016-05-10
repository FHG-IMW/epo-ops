module EpoOps
  class Util
    # the path should be an array of strings indicating the path you want to go in the hash
    def self.find_in_data(epo_hash, path)
      path.reduce(epo_hash) { |res, c| parse_hash_flat(res, c) }
    end

    def self.parse_hash_flat(hash_layer, target)
      result = []
      if hash_layer.nil?
        return []
      elsif hash_layer.class == String
        return []
      elsif hash_layer.class == Array
        result.concat(hash_layer.map { |x| parse_hash_flat(x, target) })
      elsif hash_layer[target]
        result << hash_layer[target]
      elsif hash_layer.class == Hash || hash_layer.respond_to?(:to_h)
        result.concat(hash_layer.to_h.map { |_x, y| parse_hash_flat(y, target) })
      end
      result.flatten
    end

    def self.dig(data,*path)
      path.flatten.inject(data) do |d,key|
        if d.is_a? Hash
          d[key]
        else
          nil
        end
      end
    end

    def self.flat_dig(data,*path)
      path.flatten.inject(data) do |d,key|
        if d.is_a? Hash
          d[key].is_a?(Array) ? d[key] : [d[key]]
        elsif d.is_a? Array
          d.select {|element| element.is_a? Hash}.flat_map {|element| element[key]}
        else
          []
        end
      end.reject(&:nil?)
    end

    def self.parse_change_gazette_num(num)
      res = /^(?<year>\d{4})\/(?<week>\d{2})$/.match(num)
      return nil if res.nil?
      Date.commercial(Integer(res[:year], 10), week = Integer(res[:week], 10))
    end
  end
end
