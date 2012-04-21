require 'spec_helper'

describe LockedForker do

  describe "WHEN IDLE" do

    describe ".time_stamp=" do
      it "should force the time_stamp" do
        LockedForker.time_stamp="1000000000"
      end
    end
 
    describe ".time_stamp" do
      it "should force the time_stamp" do
        LockedForker.time_stamp.should eq(1000000000)
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

    describe ".kill" do
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

    describe ".run" do
      it "should run" do
        LockedForker.store = "/tmp/rspec/store"
        LockedForker.tmp   = "/tmp/rspec/tmp"
        LockedForker.run do
          puts "test 1"
          (1..10).each do |item|
            sleep 1 and puts "sleep number #{item}"
          end
        end.should be_true
      end
      it "should return false when already running" do
        LockedForker.run do
          # code that doesn't get run
          sleep 1
        end.should be_false
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
        LockedForker.pid.should_not eq(Process.pid)
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
          sleep 1
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

    describe "checking the log" do
      it "should exist" do
        `grep "test 1" /tmp/rspec/store/run-logs/*.log`.should eq("test 1\n")
        `grep "No such file or directory" /tmp/rspec/store/run-logs/*.log`.should eq("")
      end
    end

  end

  describe "AFTER RUNNING" do

    describe "I need to spawn a new test process... " do
      it "I spawned it..." do
        LockedForker.store = "/tmp/rspec/store"
        LockedForker.tmp   = "/tmp/rspec/tmp"
        LockedForker.run do
          puts "test 2"
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

    describe ".run (clean up tasks) " do

      it "should have removed lock file" do
        File.exists?("/tmp/rspec/tmp/fork.lock").should be_false
      end
      it "should have moved log file" do
        File.exists?("/tmp/rspec/tmp/fork.log").should be_false
        `grep "test 2" /tmp/rspec/store/run-logs/*.log|cut -d":" -f2`.should eq("test 2\n")
        `grep "No such file or directory" /tmp/rspec/store/run-logs/*.log`.should eq("")
      end

    end

  end

end
