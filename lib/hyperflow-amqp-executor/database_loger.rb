require "influxdb"

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

      end
      
  end