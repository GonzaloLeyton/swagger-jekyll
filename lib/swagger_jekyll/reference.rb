require 'hana'

module SwaggerJekyll
  class Reference
    def initialize(name, hash, specification)
      @name = name
      @hash = hash
      @specification = specification

      fail "This isn't a reference: #{hash.inspect}" unless hash['$ref']
    end

    def to_liquid
      {
        'name' => name,
        'display_type' => display_type
      }
    end

    %w(name title description summary).each do |field|
      define_method(field) do
        dereference.send(field)
      end
    end

    def ref
      @hash['$ref'].gsub(/^#/, '')
    end

    def dereference
      if @_dereferenced.nil?
        pointer = Hana::Pointer.new(ref)
        target = pointer.eval(@specification.json)
        raise "Unable to dereference #{ref}" if target.nil?
        @_dereferenced = Schema.factory(@name, target, @specification)
      end

      @_dereferenced
    end

    def properties
      dereference.properties
    end

    def display_type
      "#{@hash['$ref'].gsub('#/definitions/', '')} object"
    end

    def example
      ''
    end
  end
end
