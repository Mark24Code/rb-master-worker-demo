require 'minitest/autorun'
require 'thread'
require_relative '../lib/workshop'

describe Worker do

  it "check worker name" do
    w = Worker.new("ruby01")
    assert_equal w.name, "worker@ruby01"
  end

  it "check worekr do sth job" do
    w = Worker.new("ruby02")

    finished = []
    w << lambda { puts "do job 1"; finished.push "job1"}
    w << lambda { puts "do job 2"; finished.push "job2"}
    w << :done
    w.join

    assert_equal finished, ["job1","job2"]
  end

  it "check MiniWorkshop work" do
    ws = MiniWorkshop.new(2)

    finished = []
    ws << lambda { puts "job1"; finished.push "job1"}
    ws << lambda { puts "job2"; finished.push "job2"}
    ws << lambda { puts "job3"; finished.push "job3"}
    ws << lambda { puts "job4"; finished.push "job4"}
    ws << :done

    ws.join

    assert_equal finished.size, 4
  end

  it "check Workshop work" do
    ws = Workshop.new(2, :busy)

    finished = []
    ws << lambda { puts "job1"; finished.push "job1"}
    ws << lambda { puts "job2"; finished.push "job2"}
    ws << lambda { puts "job3"; finished.push "job3"}
    ws << lambda { puts "job4"; finished.push "job4"}
    ws << :done

    ws.join

    assert_equal finished.size, 4
  end
end

