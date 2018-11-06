class RakeGem::Railtie < Rails::Railtie
  rake_tasks do
    load 'tasks/stream_ci.rake'
  end
end
