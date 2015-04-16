configure :development do
	set :database, 'sqlite3:dev.db'
	set :show_exceptions, true
end

configure :production do
	ActiveRecord::Base.establish_connection(ENV['DATABASE_URL'] || 'postgres://localhost/mydb')
end