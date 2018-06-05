require 'fog'

module Executor
  module CloudStorage
    def storage_init
      @provider = Fog::Storage.new(@job.options.cloud_storage || Executor::settings.cloud_storage.to_h)
    end

    def stage_in
      @bucket = @provider.directories.get(@job.options.bucket)
      @job.inputs.each do |file|
        Executor::logger.debug "[#{@id}] Downloading #{file.name}"
        File.open(@workdir+"/"+file.name, File::RDWR|File::CREAT) do |local_file|
          @bucket.files.get(@job.options.prefix+file.name) do |chunk, remaining_bytes, total_bytes|
            local_file.write(chunk)
            # print "\rDownloading #{file.name}: #{100*(total_bytes-remaining_bytes)/total_bytes}%"
          end
        end
      end
    end

    def stage_out
      @job.outputs.each do |file|
        Executor::logger.debug "[#{@id}] Uploading #{file.name}"
        @bucket.files.create(key: @job.options.prefix+file.name, body: File.open(@workdir+"/"+file.name))
      end
    end

    def workdir(&block)
      Dir::mktmpdir(&block)
    end
  end
end