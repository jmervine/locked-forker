require 'fileutils'
class LockedForker
  
  LOK = "stress.lock"
  LOG = "stress.log"

  @@locked = false
  @@tmp    = "/tmp"
  @@store  = "/tmp/store"
  #@@store  = "/home/jmervine/Development/stress-store"
  @@pid

  def self.run

    # ensure necessary directories exist
    FileUtils.mkdir_p @@tmp   unless File.directory? @@tmp
    FileUtils.mkdir_p @@store unless File.directory? @@store
    
    # create lock
    FileUtils.touch lock_file
  
    # redirect to log
    $stdout = File.new( log_file, "w" )

    # start fork
    fork do 
      yield # run code

      # clean up after code
      #
      # move logs
      dest_logs = File.join( @@store, "run-logs" ) #, "#{Time.now.to_i}.log" )
      FileUtils.mkdir_p dest_logs 
      FileUtils.mv( log_file, File.join( dest_logs, "#{Time.now.to_i}.log" ) )

      delete_lock_file if lock_file?
    end

    # write pid to lock file
    pid = Process.pid
    
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
        Process.kill "QUIT", pid 
        Process.wait
      rescue Errno::ESRCH
        false
      rescue SignalException
        true
      end
    end
    delete_lock_file if lock_file?
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
      @@pid ||= File.open( lock_file, "r" ).read.strip.to_i
    else
      @@pid = nil
    end
    @@pid
  end

  private
  def self.pid=id
    File.open( lock_file, "w" ).puts id
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
