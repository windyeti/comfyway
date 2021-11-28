working_directory '/var/www/comfyway/current'
pid '/var/www/comfyway/current/tmp/pids/unicorn.pid'
stderr_path '/var/www/comfyway/log/unicorn.log'
stdout_path '/var/www/comfyway/log/unicorn.log'
listen '/tmp/unicorn.comfyway.sock'
worker_processes 2
timeout 30
before_fork do |server, worker|
  old_pid = "/var/www/microsweepstakes/current/tmp/pids/unicorn.pid.oldbin"
  if old_pid != server.pid
    begin
      sig = (worker.nr + 1) >= server.worker_processes ? :QUIT : :TTOU
      Process.kill(sig, File.read(old_pid).to_i)
    rescue Errno::ENOENT, Errno::ESRCH
    end
  end
end
