require 'thread'

class Worker
  attr :name
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


class BusyMaster
  def initialize(workers)
    @workers = workers
  end

  def assign(job)
    @workers.sort{|a,b| a.size <=> b.size}.first << job
  end
end

Masters = {
  busy: BusyMaster,
  default: BusyMaster
}

class Workshop
  def initialize(count, scheduler_name)
    @worker_count = count
    @workers = @worker_count.times.map do |i|
      Worker.new(i)
    end
    @master = Masters[scheduler_name].new(@workers)
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
