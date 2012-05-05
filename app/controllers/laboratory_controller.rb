class LaboratoryController < ApplicationController
  def show
    @laboratory = Laboratory.find(params[:id])
    render :layout => false
  end
end
