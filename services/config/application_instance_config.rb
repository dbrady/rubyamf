##################################
#=>APPLICATION INSTANCES
#=>Application Instances are for RubyAMF Lite only.
#
# Application Instances define an Application Scope that allows RubyAMF to initialize ActiveRecord 
# and load models. They also create a scope for ValueObject definitions. If you have multiple applications 
# running in RubyAMF Lite with the same model names, you can declare a ValueObject to part of an 
# ApplicationInstance so that it will always use the right model.
#
# APPLICATION INSTANCE DEFINITIONS ARE NOT REQUIRED FOR RUBYAMF LITE TO FUNCTION PROPERLY.
# App instances main purpose is for incoming (from flex / flash) ActiveRecord value objects. Because 
# ActiveRecord must be connected before instantiating an AR instance. App instances allow RubyAMF to 
# catch requests, and do the neccessary active record connecting before you receive anything in your 
# service method. So if you're using ActiveRecord value objects and are expecting ActiveRecord value objects
# you MUST define an application instance.
#
# If you are not using ActiveRecord value objects, no application instances are neccessary, and 
# RubyAMF Lite will function as normal
#
# Application Instance Definitions include the name, source package path, EX: (org.myservice.*), database_config yaml file, 
# database_node (which defines which node from the yaml file to use), and a models_path
#
# For every request, RubyAMF Lite tries to match the target path (org.package.SomeService.getUsers) against
# an Application Instance. If a matching App Instance is found for that request, ActiveRecord is initialized, 
# models are loaded and the database is connected to based on the matching Application Instance definition.
#
# You can use * in source definitions to include many class files that get initialized as an application.
# Here is an example application definition and what requsts it would match against.
# EX:
#  Application::Instance.register({
#     :name => 'universalremoting',
#     :initialize => 'active_record'
#     :source => 'org.universalremoting.browser.*',
#     :database_config => 'org/universalremoting/browser/test.yaml',
#     :database_node => 'development',
#     :models_path => 'org/universalremoting/browser/support/ar_models/*'
#   })
#  
#  :source => 'org.universalremoting.*.Testing
#  MATCHES:         org.universalremoting.hello.Testing.getString
#                   org.unversalremoting.whatever.Testing.whatever
#  NOT MATCHED:     org.universalremoting.some.package.Testing.getString
#  :source => 'org.universalremoting.*.*.Testing
#  MATCHES:         org.universalremoting.some.package.Testing.getString
#  NOT MATCHED:     org.universalremoting.some.package.another.Testing.getString
#
##################################
#APPLICATION INSTANCE DEFINITIONS HERE