module Executor
  class Job
    attr_reader :metrics

    def initialize(id, job)
      @job = job
      @id = id
      @metrics = {
              timestamps: { },
              executor: Executor::id
            }

      storage_module = case (@job.options.storage or Executor::settings.storage)
      when 's3', 'cloud'
        CloudStorage
      when 'local'
        LocalStorage
      when 'nfs'
        NFSStorage
      when 'plgdata'
        PLGDataStorage
      when 'gridftp'
        GridFTPStorage
      else
        raise "Unknown storage #{@job.storage}"
      end
      self.extend(storage_module)

      init_replacements
    end

    def run
      @metrics[:timestamps]["job.started"] = Executor::publish_event 'job.started', "job.#{@id}.started", job: @id, thread: Thread.current.__id__
      @metrics[:thread] = Thread.current.__id__

      results = {}

      workdir do |tmpdir|
        @workdir = tmpdir
        raise "Couldn't get workdir" unless @workdir

        storage_init if self.respond_to? :storage_init

        File.write("#{@workdir}/signals.json", {inputs: @job.inputs.map(&:to_h), outputs: @job.outputs.map(&:to_h)}.to_json)

        if self.respond_to? :stage_in
          publish_events "stage_in" do
            _ , @metrics[:stage_in]     = time do
              
              @job.inputs.each do |input|
                stage_in input
              end
            end
            @metrics[:input_size]       = input_size
            {bytes: @metrics[:input_size], time: @metrics[:stage_in]}
          end
        else
          @metrics[:input_size] = input_size
        end

        publish_events "execution" do
          results, @metrics[:execution] = time { execute }
          { executable: @job.executable, exit_status: results[:exit_status], time: @metrics[:execution] }
        end

        if self.respond_to? :stage_out
          publish_events "stage_out" do
            _, @metrics[:stage_out]     = time do
              @job.outputs.each do |output|
                stage_out output
              end
            end
            @metrics[:output_size]      = output_size
            { bytes: @metrics[:output_size], time: @metrics[:stage_out] }
          end
        else
          @metrics[:output_size] = output_size
        end

      end
      @metrics[:timestamps]["job.finished"] = Executor::publish_event 'job.finished', "job.#{@id}.finished", job: @id, executable: @job.executable, exit_status: results[:exit_status], metrics: @metrics, thread: Thread.current.__id__

      results[:metrics] = @metrics
      results
    end

    def publish_events(name)
      @metrics[:timestamps]["#{name}.started"]  = Executor::publish_event "job.#{name}.started", "job.#{@id}.#{name}.started", job: @id, thread: Thread.current.__id__
      results = yield
      @metrics[:timestamps]["#{name}.finished"] = Executor::publish_event "job.#{name}.finished", "job.#{@id}.#{name}.finished", {job: @id, thread: Thread.current.__id__}.merge(results || {})
      results
    end

    def init_replacements
      replacements_map = ((@job.inputs + @job.outputs).map do |signal|
        name = signal.name
        signal.to_h.map do |k, v|
          val = if v.is_a? Array then v.join(",") else v end
          ["$#{name}_#{k}", val]
        end
      end).flatten(1)

      @replacements = Hash[replacements_map]
    end

    def cmdline
      line = if @job.args.is_a? Array
         ([@job.executable] + @job.args).map { |e| e.to_s }
      else
        "#{@job.executable} #{@job.args}"
      end
      line.map { |e| e.gsub(/\$[A-Za-z0-9_]+/, @replacements) }
    end

    def env
      Hash[@job.env.to_h.map{|k,str| [k, str.gsub(/\$[A-Za-z0-9_]+/, @replacements) ] }]
    end

    def execute
      begin
        Executor::logger.debug "[#{@id}] Executing #{cmdline} with env #{env}"
        stdout, stderr, status = Open3.capture3(env, *cmdline, chdir: @workdir)

        {exit_status: status, stderr: stderr, stdout: stdout}
      rescue Exception => e
        Executor::logger.error "[#{@id}] Error executing job: #{e}"
        Executor::logger.debug "[#{@id}] Backtrace\n#{e.backtrace.join("\n")}"
        {exit_status: -1, exceptions: [e]}
      end
    end

    def input_size
      @job.inputs.map{ |file| begin File.size(@workdir+"/"+file.name) rescue 0 end }.reduce(:+) or 0
    end

    def output_size
      @job.outputs.map{ |file| begin File.size(@workdir+"/"+file.name) rescue 0 end }.reduce(:+) or 0
    end
  end
end