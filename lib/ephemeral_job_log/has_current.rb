module EphemeralJobLog
  module HasCurrent
    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods
      def current
        Thread.current[:"#{name.underscore}_current"]
      end

      def current=(instance)
        Thread.current[:"#{name.underscore}_current"] = instance
      end
    end

    def with_current
      raise 'block is required' unless block_given?

      self.class.current = self
      yield
    ensure
      self.class.current = nil
    end
  end
end
