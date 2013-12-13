def appConfig = container.config

container.deployModule('io.vertx~mod-web-server~2.0.0-final', appConfig['web_server_conf'])
container.deployModule('org.crashub~vertx.shell~2.0.3',appConfig['crash_conf'])
