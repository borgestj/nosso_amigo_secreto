class MembersController < ApplicationController
  before_action :authenticate_user!, except: [:opened]
  before_action :set_member, only: [:show, :destroy, :update]
  before_action :is_owner?, only: [:destroy, :update]
  before_action :set_member_by_token, only: [:opened]

  def create
    @member = Member.new(name: params[:name], email: params[:email], campaign_id: params[:campaign_id])

    respond_to do |format|
      if @member.save
        format.json { render json: @member }
      else
        format.json { render json: @member.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @member.destroy

    respond_to do |format|
      format.json { render json: true }
    end
  end

  def update
    respond_to do |format|
      if @member.update(member_params)
        format.json { render json: true }
      else
        format.json { render json: @member.errors, status: :unprocessable_entity }
      end
    end
  end

  def opened
    gif = Base64.decode64("R0lGODlhAQABAPAAAAAAAAAAACH5BAEAAAAALAAAAAABAAEAAAICRAEAOw==")
    @member.update(open: true)
    render text: gif, type: 'image/gif'
  end

  private

  def set_member
    @member = Member.find(params[:id])
  end

  def set_member_by_token
    @member = Member.find_by!(token: params[:token])
  end

  def member_params
    params.require(:member).permit(:name, :email, :campaign_id)
  end

  def is_owner?
    unless current_user == @member.campaign.user
      respond_to do |format|
        format.json { render json: false, status: :forbidden }
      end
    end
  end
end
