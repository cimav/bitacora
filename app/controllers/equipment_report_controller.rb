class EquipmentReportController < ApplicationController
  before_filter :auth_required
  respond_to :html, :json

  def index
    render :layout => false
  end

  def live_search
    @equipment = Equipment.where('status = :s', {:s => Equipment::ACTIVE}).order('name')
    if !params['equipment-use-lab'].blank? && params['equipment-use-lab'] != '0'
      @equipment = @equipment.where("laboratory_id = :c", {:c => params['equipment-use-lab']}) 
    end
    if !params[:q].blank?
      @equipment = @equipment.where("(name LIKE :q OR description LIKE :q)", {:q => "%#{params[:q]}%"})
    end
    render :layout => false
  end

  def show
  	@equipment = Equipment.find(params[:id])
  	t =  Date.today 
  	tp = 1.year.ago
  	@start = "#{tp.year}-#{tp.month}-#{tp.day}"
  	@end = "#{t.year}-#{t.month}-#{t.day}"

  	render :layout => false
  end


end
