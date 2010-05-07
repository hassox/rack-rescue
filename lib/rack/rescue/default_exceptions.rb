require 'rack/rescue/exceptions'

class Rack::Rescue::Exceptions
  DEFAULT_HANDLERS = [
   ["Pancake::Errors::NotFound",               {:status => 404}],
   ["DataMapper::ObjectNotFoundError",         {:status => 404}],
   ["ActiveRecord::RecordNotFound",            {:status => 404}],
   ["Pancake::Errors::NotFound",               {:status => 404}],
   ["Pancake::Errors::UnknownRouter",          {:status => 500}],
   ["Pancake::Errors::UnknownConfiguration",   {:status => 500}],
   ["Pancake::Errors::Unauthorized",           {:status => 401}],
   ["Pancake::Errors::Forbidden",              {:status => 403}],
   ["Pancake::Errors::Server",                 {:status => 500}],
   ["Pancake::Errors::NotAcceptable",          {:status => 406}]
  ].map{|(name, opts)| Handler.new(name, opts)}
end
