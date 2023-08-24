# frozen_string_literal: true

class UsersController < ApplicationController
  def new
    @user = User.new
    @gender_options = User.genders_i18n.invert.to_a
  end

  def create
    @user = User.new(user_params)
    if @user.save
      auto_login(@user)
      redirect_to events_path, success: 'ユーザー登録が完了しました'
    else
      @gender_options = User.genders_i18n.invert.to_a
      flash.now[:danger] = 'ユーザー登録に失敗しました'
      render :new
    end
  end

  def user_params
    params.require(:user).permit(:email, :name, :gender, :password, :password_confirmation)
  end
end
