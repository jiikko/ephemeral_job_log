# frozen_string_literal: true

class TestJobLog < EphemeralJobLog::Base
end

RSpec.describe EphemeralJobLog::Base do
  let(:store) { ActiveSupport::Cache::MemoryStore.new }

  before do
    TestJobLog.store = store
    store.clear
  end

  describe '.update!' do
    it 'updates attributes' do
      job = TestJobLog.create!
      job.update!(status: 'running')

      reloaded_job = TestJobLog.find(job.id)
      expect(reloaded_job.status).to eq('running')
    end
  end

  describe '#append_log' do
    let(:job) { TestJobLog.create! }

    it 'appends logs' do
      job.append_log('log 1')
      job.append_log('log 2')

      reloaded_job = TestJobLog.find_by_id(job.id)
      expect(reloaded_job.logs).to eq("log 1\nlog 2")
    end

    context 'when logs exceed history_size' do
      before do
        TestJobLog.history_size = 3
      end

      it 'returns last 10 logs' do
        job.append_log('log 1')
        job.append_log('log 2 log 2.1')
        job.append_log('log 3')
        job2 = TestJobLog.find_by_id(job.id)
        job2.append_log('log 4')

        reloaded_job = TestJobLog.find_by_id(job.id)
        expect(reloaded_job.logs).to eq("log 1\nlog 2 log 2.1\nlog 3\nlog 4")
      end
    end
  end
end
