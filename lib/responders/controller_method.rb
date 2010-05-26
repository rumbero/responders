module Responders
  module ControllerMethod
    # Adds the given responders to the current controller's responder, allowing you to cherry-pick
    # which responders you want per controller.
    # 
    #   class InvitationsController < ApplicationController
    #     responders :flash, :http_cache
    #   end
    #
    # Takes symbols and strings and translates them to VariableResponder (eg. :flash becomes FlashResponder).
    # Also allows passing in the responders modules in directly, so you could do:
    #
    #    responders FlashResponder, HttpCacheResponder
    #
    # Or a mix of both methods:
    #
    #    responders :flash, MyCustomResponder
    #
    def responders(*responders)
      self.responder = responders.inject(Class.new(responder)) do |klass, responder|
        responder = case responder
          when Module
            responder
          when String, Symbol
            "Responders::#{responder.to_s.classify}Responder".constantize
          else
            raise "responder has to be a string, a symbol or a module"
          end
        
        klass.send(:include, responder)
        klass
      end
    end
  end
end

# Fix for Rails <= 3.0.0.beta3
require "action_controller/metal/responder"

class ActionController::Responder
  def default_action
    @action ||= ACTIONS_FOR_VERBS[request.request_method_symbol]
  end
end

ActionController::Base.extend Responders::ControllerMethod
