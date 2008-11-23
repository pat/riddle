TabTab::Definition.register("searchd") do |c|
  c.flag :help, :h
  c.flag :config, :c
  c.flag :stop
  c.flag :iostats
  c.flag :console
  c.flag :port, :p
  c.flag :index, :i
end

TabTab::Definition.register("indexer") do |c|
  c.flag :config, :c
  c.flag :all
  c.flag :rotate
end