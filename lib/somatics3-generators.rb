require 'rails/generators'

module Somatics3Generators
end

Rails::Generators.hidden_namespaces << "rails"

%w(somatics).each do |template|
  Rails::Generators.hidden_namespaces <<
  [
#     "#{template}:controller",
#     "#{template}:scaffold",
    "#{template}:scaffold_controller",
    "#{template}:helper",
    "#{template}:authenticated",
    "#{template}:authenticated_controller",
  ]
end

Rails::Generators.hidden_namespaces.flatten!
