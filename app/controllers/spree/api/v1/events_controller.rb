module Spree
  module Api
    module V1
      class EventsController < Spree::Api::BaseController
        def create
          authorize! :create, Observer::Event
          @event = Observer::Event.new(map_nested_attributes_keys(Observer::Event, event_params))
          if @event.save
            respond_with(@event, status: 201, default_template: :show)
          else
            invalid_resource!(@event)
          end
        end

        def destroy
          authorize! :destroy, event
          event.destroy
          respond_with(event, status: 204)
        end

        def index
          @events = Observer::Event.accessible_by(current_ability, :read).ransack(params[:q]).result.page(params[:page]).per(params[:per_page])
          respond_with(@events)
        end

        def show
          respond_with(event)
        end

        def update
          authorize! :update, event
          if event.update_attributes(map_nested_attributes_keys(Observer::Event, event_params))
            respond_with(event, status: 200, default_template: :show)
          else
            invalid_resource!(event)
          end
        end

        private
        def event_params
          params.require(:event).permit!
        end

        def event
          @event ||= Observer::Event.accessible_by(current_ability, :read).find(params[:id])
        end
      end
    end
  end
end
