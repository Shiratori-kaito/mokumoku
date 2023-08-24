# frozen_string_literal: true

class EventsController < ApplicationController
  def index
    @q = Event.future.ransack(params[:q])
    @events = @q.result(distinct: true).includes(:bookmarks, :prefecture, user: { avatar_attachment: :blob })
                .order(created_at: :desc).page(params[:page])
  end

  def future
    @q = Event.future.ransack(params[:q])
    @events = @q.result(distinct: true).includes(:bookmarks, :prefecture, user: { avatar_attachment: :blob })
                .order(held_at: :asc).page(params[:page])
    @search_path = future_events_path
    render :index
  end

  def past
    @q = Event.past.ransack(params[:q])
    @events = @q.result(distinct: true).includes(:bookmarks, :prefecture, user: { avatar_attachment: :blob })
                .order(held_at: :desc).page(params[:page])
    @search_path = past_events_path
    render :index
  end

  def new
    @event = Event.new
    @user = current_user
  end

  def create
    @event = current_user.events.build(event_params)
    if @event.save
      User.all.find_each do |user|
        NotificationFacade.created_event(@event, user)
      end

      redirect_to event_path(@event)
    else
      @user = current_user
      render :new
    end
  end

  def show
    @event = Event.find(params[:id])
  end

  def edit
    @event = current_user.events.find(params[:id])
    @user = current_user
  end

  def update
    @event = current_user.events.find(params[:id])
    if @event.update(event_params)
      redirect_to event_path(@event)
    else
      @user = current_user
      render :edit
    end
  end

  private

  def event_params
    params.require(:event).permit(:title, :content, :held_at, :prefecture_id, :thumbnail, :only_woman)
  end
end
