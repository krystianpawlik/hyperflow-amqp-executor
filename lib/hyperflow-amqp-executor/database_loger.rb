require "influxdb"
require 'thread'

module Executor

    class DatabaseLoger
        
        @@timers = Hash.new
        @@downloadtimer = Hash.new
        @@executiontimer = Hash.new

        def self.start_ecutiontimer(database_url,id,hfId,wfid)
            @@downloadtimer[id]=Time.now
        end

        def self.stop_ecutiontimer(database_url,id,hfId,wfid)
            unless @@executiontimer[id].nil?
                execution_time = Time.now - @@executiontimer[id]
                data = {
                  values: { value: execution_time, id:id, hfId:hfId, wfid:wfid },
                  tags:   { state: "finished" }
                }
                print execution_time
                self.write_to_database(database_url,'jobs_execution_time',data)
              end
        end

        def self.start_downloadtimer(database_url,id,hfId,wfid)
            @@downloadtimer[id]=Time.now
        end

        def self.stop_downloadtimer(database_url,id,hfId,wfid)
            unless @@downloadtimer[id].nil?
                download_time = Time.now - @@downloadtimer[id]
                data = {
                  values: { value: download_time, id:id, hfId:hfId, wfid:wfid },
                  tags:   { state: "finished" }
                }
                print download_time
                self.write_to_database(database_url,'jobs_download_time',data)
              end
        end

        def self.start_job_notyfication(database_url,id,hfId,wfid)
            #DatabaseLoger.write_data(ENV['INFLUXDB_URL'],'jobs',@id,1,'start');
            self.write_data(database_url,'jobs',id,hfId,wfid,'start')
            @@timers[id]=Time.now
            print @@timers[id]
        end
        
        def self.finish_job_notyfication(database_url,id,hfId,wfid)
            self.write_data(database_url,'jobs',id,hfId,wfid,'finish')
            unless @@timers[id].nil?
              execution_time = Time.now - @@timers[id]
              data = {
                values: { value: execution_time, id:id, hfId:hfId, wfid:wfid },
                tags:   { state: "finished" }
              }
              print execution_time
              self.write_to_database(database_url,'jobs_execution',data)
            end
        end
      
        def self.write_data(database_url,metric,id,hfId,wfid,tag)
      
            influxdb = InfluxDB::Client.new url: database_url
            data = {
                values: { id: id , wfid: wfid, hfId: hfId  },
                tags:   { state: tag }
            }
      
            influxdb.write_point(metric, data)
        end
      
        def self.write_to_database(database_url,metric,data)
          influxdb = InfluxDB::Client.new url: database_url
          influxdb.write_point(metric, data)
        end

        
        def initialize(database_url,id,jobId,procId,hfId,wfid)
            @id = id
            @jobId = jobId
            @hfId = hfId
            @wfid = wfid
            @procId =procId

            @curentStage = "idle"
            @subStage = "idle"

            @startTime = nil
            @stagesTime = nil
            @stageStartTime =nil

            if database_url.nil?
                @influxdb = nil
            else
                @influxdb = InfluxDB::Client.new url: database_url
            end
        end

        # def self.start_ecutiontimer(database_url,id,hfId,wfid)
        #     @@downloadtimer[id]=Time.now
        # end

        def changeStageAndSubStage(stage,subStage)
            self.write_data("execution_log", @curentStage,"finish")
            #self.write_data("execution_log_sub_stage", @subStage,"finish")

            @curentStage = stage
            @subStage = subStage

            self.write_data("execution_log_sub_stage", @subStage,"start")
            self.write_data("execution_log", @curentStage,"start")
        end

        def changeSubStage(subStage)
            #self.write_data("execution_log_sub_stage", @subStage,"finish")

            @subStage = subStage

            self.write_data("execution_log_sub_stage", @subStage,"start")
        end

        @semaphore = Mutex.new

        def log_start_job()
            
                @startTime =Time.now
                @stagesTime = Hash.new
                self.log_time_of_stage_change
                self.changeStageAndSubStage("running","init")
            
        end

        def log_finish_job()
         
                self.log_time_of_stage_change
                self.changeStageAndSubStage("idle","idle")

                self.report_times "execution_times"

                @stagesTime = nil
                @startTime = nil
            
        end

        # def log_start_downloading()
        #     self.log_time_of_stage_change
        #     self.changeSubStage("downloading")
        # end

        # def log_start_executing()
        #     self.log_time_of_stage_change
        #     self.changeSubStage("executing")
        # end

        # def log_start_uploading()
        #     self.log_time_of_stage_change
        #     self.changeSubStage("uploading")
        # end

        def log_time_of_stage_change()
            if (@subStage =="idle")
                @stageStartTime=Time.now
            else 
                @stagesTime[@subStage] = Time.now - @stageStartTime
                @stageStartTime=Time.now
            end
        end

        def write_data(metric, stage , start_or_finish)
            unless @influxdb.nil?
                data = {
                    values: { wfid: @wfid, hfId: @hfId, stage: stage, stage_name: start_or_finish},
                    tags:   { workerId: @id ,jobId: @jobId , procId: @procId}
                }
                Executor::logger.debug "write to database #{data}"
                @influxdb.write_point(metric, data)
            end
        end

        def report_times(metric)
            unless @influxdb.nil?
                runing_time = Time.now - @startTime

                data = {
                    values: { wfid: @wfid, hfId: @hfId, runing_time: runing_time, downloading_time: @stagesTime["stage_in"] , 
                    execution_time: @stagesTime["execution"] , uploading_time: @stagesTime["stage_out"]},
                    tags:   { workerId: @id , jobId: @jobId, procId: @procId}
                }
        
                @influxdb.write_point(metric, data)
            end
        end

        def log_start_subStage(subStage)
 
                self.log_time_of_stage_change
                self.changeSubStage(subStage)
            
            # self.log_time_of_stage_change
            # self.changeSubStage("downloading")
        end



      end
      
  end