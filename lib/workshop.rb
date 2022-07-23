require 'thread'

class Worker
  attr :name, :group
  def initialize(name)
    @name = "worker@#{name}"
    @queue = Queue.new
    @thr = Thread.new { perfom }
  end

  def <<(job)
    @queue.push(job)
  end

  def join
    @thr.join
  end

  def perfom
    while (job = @queue.deq)
      break if job == :done
      puts "worker@#{name}: job:#{job}"
      job.call
    end
  end

  def size
    @queue.size
  end
end


class NormalMaster
  def initialize(workers)
    @workers = workers
  end

  def assign(job)
    @workers.sort{|a,b| a.size <=> b.size}.first << job
  end
end

class ICU996Master
  def initialize(workers)
    @current_worker = workers.cycle # 迭代器
  end

  def assign(job)
    @current_worker.next << job
  end
end

class GroupMaster
  GROUPS = [:group1, :group2, :group3]

  def initialize(workers)
    @workers = {}
    workers_per_group = workers.length / GROUPS.size
    workers.each_slice(workers_per_group).each_with_index do |slice, index|
      group_id = GROUPS[index]
      @workers[group_id] = slice
    end
  end

  def assign(job)
    worker = @workers[job.group].sort_by(&:size).first
    worker << job
  end
end

Masters = {
  normal: NormalMaster,
  ICU996: ICU996Master,
  group: GroupMaster
}

class Workshop
  def initialize(count, master_name)
    @worker_count = count
    @workers = @worker_count.times.map do |i|
      Worker.new(i)
    end
    @master = Masters[master_name].new(@workers)
  end

  def <<(job)
    if job == :done
      @workers.map {|m| m << job}
    else
      @master.assign(job)
    end
  end

  def join
    @workers.map {|m| m.join}
  end
end

class MiniWorkshop
  def initialize(count)
    @worker_count = count
    @workers = @worker_count.times.map do |i|
      Worker.new(i)
    end
  end

  def <<(job)
    if job == :done
      @workers.map {|m| m << job}
    else
      @workers.sample << job
    end
  end

  def join
    @workers.map {|m| m.join}
  end
end
