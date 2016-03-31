# config/unicorn.rb

# Set the working application directory
# working_directory '/path/to/your/app'
working_directory '/www/funnyway.ru'

# Unicorn PID file location
# pid '/path/to/pids/unicorn.pid'
pid '/www/funnyway.ru/pids/unicorn.pid'

# Path to logs
# stderr_path '/path/to/log/unicorn.log'
# stdout_path '/path/to/log/unicorn.log'
stderr_path '/www/funnyway.ru/log/unicorn.log'
stdout_path '/www/funnyway.ru/log/unicorn.log'

# Unicorn socket
# listen '/tmp/unicorn.[application name].sock'
listen '/tmp/unicorn.funnyway.ru.sock'

# Number of processes
# worker_processes 4
worker_processes 3

# Time-out
timeout 600
