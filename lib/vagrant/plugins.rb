def ensure_plugins(plugins)
  logger = Vagrant::UI::Colored.new
  installed = false

  plugins.each do |plugin|
    plugin_name = plugin["name"]
    manager = Vagrant::Plugin::Manager.instance

    next if manager.installed_plugins.key?(plugin_name)

    logger.warn("Installing plugin #{plugin_name}")

    manager.install_plugin(
      plugin_name,
      sources: plugin.fetch("source", %w[https://rubygems.org/ https://gems.hashicorp.com/]),
      version: plugin["version"]
    )

    installed = true
  end

  return unless installed

  logger.warn("`vagrant up` must be re-run now that plugins are installed")
  exit
end
