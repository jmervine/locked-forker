require 'fileutils'
class LockedForker
  
  LOK = "fork.lock"
  LOG = "fork.log"

  @@locked = false
  @@tmp    = "/tmp"
  @@store  = "/tmp/fork-store"

  def self.run

    return false if self.locked? or self.running?

    # ensure necessary directories exist
    FileUtils.mkdir_p @@tmp   unless File.directory? @@tmp
    FileUtils.mkdir_p @@store unless File.directory? @@store
    
    # create lock
    FileUtils.touch lock_file or raise "couldn't create lock file (#{self.lock_file})"

    # start fork
    fork do 
      begin
        # write pid to lock file
        self.pid = Process.pid
        
        # redirect to log
        FileUtils.touch log_file or raise "couldn't create log file (#{self.log_file})"
        $stdout.reopen( log_file, "w" )
        $stdout.sync = true
        $stderr.reopen($stdout)

        yield # run code

        # clean up after code
      ensure
        if File.exists? log_file
          dest_logs = File.join( @@store, "run-logs" )
          FileUtils.mkdir_p dest_logs unless File.directory? dest_logs
          FileUtils.mv( log_file, File.join( dest_logs, "#{self.time_stamp}.log" ) )
        end
        delete_lock_file 
      end
    end

    # say good by
    Process.detach pid
  end
  
  def self.locked?
    lock_file?
  end

  def self.running?
    lock_file? and is_running?
  end

  def self.kill
    if self.running?
      begin
        p = pid
        if File.exists? log_file
          dest_logs = File.join( @@store, "run-logs" )
          FileUtils.mkdir_p dest_logs unless File.directory? dest_logs
          FileUtils.mv( log_file, File.join( dest_logs, "#{self.time_stamp}.log" ) )
        end
        delete_lock_file 
        Process.kill 9, p
        Process.wait
      rescue Errno::ESRCH
        return false
      rescue Errno::ECHILD
        return true
      rescue SignalException
        return true
      ensure
      end
    end
    delete_lock_file 
  end

  def self.time_stamp
    Time.now.to_i
  end

  def self.tmp=( path )
    @@tmp = path
  end

  def self.tmp
    @@tmp
  end

  def self.store=( path )
    @@store = path 
  end

  def self.store
    @@store
  end

  def self.pid
    if lock_file?
      @@pid = File.open( lock_file, "r" ).read.strip.to_i
    else
      @@pid = nil
    end
    @@pid
  end

  private
  def self.pid=id
    if File.open( self.lock_file, "w" ) { |f| f.write id }
      @@pid = id
    else
      raise "couldn't write pid (#{id}) to lock file (#{self.lock_file})"
    end
  end

  def self.delete_lock_file
    if lock_file?
      File.delete lock_file
    else
      false
    end
  end

  def self.lock_file?
    File.exists? lock_file
  end

  def self.lock_file
    File.join( @@tmp, LOK )
  end

  def self.log_file
    File.join( @@tmp, LOG )
  end

  def self.is_running?
    begin 
      return true if Process.getpgid pid
    rescue Errno::ESRCH
      return false
    end
  end

end
