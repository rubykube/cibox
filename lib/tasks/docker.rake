namespace :docker do
  desc 'Build container based on git commit tag'
  task :build do
    system %{ docker build -t rubykube/robox:$(git rev-parse --short HEAD) . }
  end
end
