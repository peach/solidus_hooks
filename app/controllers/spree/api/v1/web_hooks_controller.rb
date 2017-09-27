module Spree
  module Api
    module V1
      class WebHooksController < Spree::Api::BaseController
        def create
          authorize! :create, Hooks::WebHook
          @web_hook = Hooks::WebHook.new(map_nested_attributes_keys(Hooks::WebHook, web_hook_params))
          if @web_hook.save
            respond_with(@web_hook, status: 201, default_template: :show)
          else
            invalid_resource!(@web_hook)
          end
        end

        def destroy
          authorize! :destroy, web_hook
          web_hook.destroy
          respond_with(web_hook, status: 204)
        end

        def index
          @web_hooks = Hooks::WebHook.accessible_by(current_ability, :read).ransack(params[:q]).result.page(params[:page]).per(params[:per_page])
          respond_with(@web_hooks)
        end

        def show
          respond_with(web_hook)
        end

        def update
          authorize! :update, web_hook
          if web_hook.update_attributes(map_nested_attributes_keys(Hooks::WebHook, web_hook_params))
            respond_with(web_hook, status: 200, default_template: :show)
          else
            invalid_resource!(web_hook)
          end
        end

        private
        def web_hook_params
          params.require(:web_hook).permit!
        end

        def web_hook
          @web_hook ||= Hooks::WebHook.accessible_by(current_ability, :read).find(params[:id])
        end
      end
    end
  end
end