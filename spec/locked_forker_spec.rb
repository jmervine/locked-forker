require 'spec_helper'

describe LockedForker do

  describe "WHEN IDLE" do
 
    describe ".locked?" do
      it "shouldn't be locked" do
        LockedForker.locked?.should be_false
      end
    end

    describe ".running?" do
      it "shouldn't be running" do
        LockedForker.running?.should be_false
      end
    end

    describe ".pid" do
      it "shouldn't have a pid" do
        LockedForker.pid.should be_nil
      end
    end

    describe ".kill" do
      it "should return false" do
        LockedForker.kill.should be_false
      end
    end

    describe ".kill!" do
      it "should return false" do
        LockedForker.kill.should be_false
      end
    end

    describe ".tmp" do
      it "should return correct string" do
        LockedForker.tmp.should eq(LockedForker.class_variable_get(:@@tmp))
      end
    end

    describe ".tmp=" do
      it "should set correct string" do
        LockedForker.tmp = "/foo"
        LockedForker.class_variable_get(:@@tmp).should eq("/foo")
        LockedForker.tmp = "/tmp" # cleanup
      end
    end

    describe ".store" do
      it "should return correct string" do
        LockedForker.store.should eq(LockedForker.class_variable_get(:@@store))
      end
    end

    describe ".store=" do
      it "should set correct string" do
        LockedForker.store = "/foo"
        LockedForker.class_variable_get(:@@store).should eq("/foo")
        LockedForker.store = "/tmp/store" # cleanup
      end
    end

  end

  describe "WHEN RUNNING" do
    before do
      Time.stub(:now).and_return(100000000)
      # set store to rpsec store
      LockedForker.store = "/tmp/rspec/store"
      # set tmp to rspec tmp
      LockedForker.tmp   = "/tmp/rspec/tmp"
      if File.directory? "/tmp/rpsec"
        FileUtils.remove_dir "/tmp/rspec", true 
      end
    end

    describe ".run -- 10 second test" do
      it "should run" do
        LockedForker.run do
          (1..10).each do |item|
            sleep 1 and puts "sleep number #{item}"
          end
        end.should be
      end
      it "should create a lock file" do
        File.exists? "/tmp/rspec/fork.lock"
      end
      it "should create a log file" do
        File.exists? "/tmp/rspec/fork.log"
      end
    end

    describe ".locked?" do
      it "should be locked" do
        LockedForker.locked?.should be_true
      end
    end

    describe ".running?" do
      it "should be running" do
        LockedForker.running?.should be_true
      end
    end

    describe ".pid" do
      it "should have a pid" do
        LockedForker.pid.should be
        LockedForker.pid.should be_a_kind_of Fixnum
      end
    end

    describe ".kill" do

      before do
        @pid = LockedForker.pid
      end

      describe " running? (before kill)" do
        it " should be true " do
          LockedForker.running?.should be_true
        end
      end

      describe " kill " do
        it " should return true " do
          LockedForker.kill.should be_true
        end
      end

      describe " locked? " do
        it " should be false " do 
          LockedForker.locked?.should be_false
        end
      end

      describe " running? (after kill) " do
        it " should be false " do
          LockedForker.running?.should be_false
        end
      end

      describe " pid (after kill) " do
        it "should be nil " do
          LockedForker.pid.should be_nil
        end
      end

      it "should stop the running process" do
        expect { Process.getpgid pid }.should raise_error
      end

    end

  end

  describe "AFTER RUNNING" do
    before do
      Time.stub(:now).and_return(200000000)
      # set store to rpsec store
      LockedForker.store = "/tmp/rspec/store"
      # set tmp to rspec tmp
      LockedForker.tmp   = "/tmp/rspec/tmp"
      if File.directory? "/tmp/rpsec"
        FileUtils.remove_dir "/tmp/rspec", true 
      end
    end

    describe "I need to spawn a new test process... " do
      it "I spawned it..." do
        LockedForker.run do
          (1..10).each do |item|
            sleep 1 and puts "sleep number #{item}"
          end
        end.should be_true
        sleep 1 # pause
      end
    end

    describe "I need to sleep for 10 seconds to complete the spawned process..." do
      it "Time to wake up..." do
        sleep 10
      end
    end

    describe ".locked?" do
      it "shouldn't be locked" do
        LockedForker.locked?.should be_false
      end
    end

    describe ".running?" do
      it "shouldn't be running" do
        LockedForker.running?.should be_false
      end
    end

    describe ".pid" do
      it "shouldn't have a pid" do
        LockedForker.pid.should be_nil
      end
    end

    describe ".run -- did what it should have" do

      it "removed lock file" do
        File.exists?("/tmp/rspec/tmp/fork.lock").should be_false
      end
      it "moved log file" do
        File.exists?("/tmp/rspec/tmp/fork.log").should be_false
        File.exists?("/tmp/rspec/store/run-logs/200000000.log").should be_true
      end

    end

  end

end
