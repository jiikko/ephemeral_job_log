require_relative 'has_current'

# TODO: shellランナーを提供する?
# TODO: ログを書き出す最長保持サイズを設定する
# TODO: 進捗率にも対応したい
# TODO: 制御文字を出したい
# TODO: read-multiを使う
# TODO: EphemeralJobLog.configureでstoreを設定できるようにする

module EphemeralJobLog
  class Base
    include EphemeralJobLog::HasCurrent

    cattr_accessor :store, :history_size, :store_prefix_key

    # NOTE: recommended to use Rails.cache
    # self.store = Rails.cache
    self.history_size = 10

    attr_accessor :status, :error_message, :finished_at
    attr_writer :logs, :progress
    attr_reader :id, :created_at, :position

    def self.inherited(subclass)
      super
      subclass.store_prefix_key = subclass.name.underscore
    end

    def self.all
      history_size.times.map do |position|
        store.read(to_store_key(position))
      end.compact.sort_by(&:created_at).reverse
    end

    def self.find_by_id(id)
      all.select { |job_log| job_log.id == id }&.first
    end

    def self.find_by_position(position)
      all.select { |job_log| job_log.potision == position }&.first
    end

    def self.create!
      record = new
      record.save!
      record
    end

    def self.remove_oldest_entry
      all.min_by(&:created_at)&.delete!
    end

    def self.to_store_key(position)
      [store_prefix_key, position]
    end

    def initialize(id: nil)
      @id = id || SecureRandom.uuid
      raise "Job log with id #{@id} already exists" if self.class.find_by_id(@id)
      @created_at = Time.current

      begin
        @position = available_position
      rescue NoAvailablePositionError
        self.class.remove_oldest_entry
        retry
      end
    end

    def store_key
      raise 'position is not set' if @position.nil?

      self.class.to_store_key(position)
    end

    def save!
      self.class.store.write(store_key, self)
    end

    def delete!
      self.class.store.delete(store_key)
    end

    def progress
      return 100 if finished_at.present?

      @progress ||= 0
    end

    def append_log(log)
      @logs ||= []
      @logs << log
      save!
    end

    def logs
      @logs&.last(10)&.join("\n")
    end

    def update!(attrs)
      attrs.each do |key, value|
        send("#{key}=", value)
      end
      save!
    end

    private

    def available_position
      result = self.class.history_size.times.select do |position|
        break(position) if self.class.store.read(self.class.to_store_key(position)).nil?
      end
      return result if result.present?

      raise NoAvailablePositionError
    end
  end
end
