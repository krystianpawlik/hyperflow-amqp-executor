module Executor
  module LocalStorage
    def workdir
        yield (ENV['EXECUTOR_MOUNT'] or @job.options.workdir)
    end
  end
end

