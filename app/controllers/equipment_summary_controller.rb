class EquipmentSummaryController < ApplicationController
  def index

  	if !params[:eq_sum_unit].blank?
  	  @equipment = Equipment.joins(:laboratory)
      if !params[:eq_sum_lab].blank? && params[:eq_sum_lab].to_i > 0
        @equipment = @equipment.where(:laboratory_id => params[:eq_sum_lab])
      end

      if !params[:eq_sum_unit].blank? && params[:eq_sum_unit] != '*'
        @equipment = @equipment.where('laboratories.business_unit_id' => params[:eq_sum_unit])
      end
      @equipment = @equipment.order('equipment.name')
    end

  	
    if params[:end].blank?
  	  t =  Date.today 
  	  # tp = 1.year.ago
  	  @start = "#{t.year}-01-01"
  	  @end = "#{t.year}-#{t.month}-#{t.day}"
  	else 
  	  @start = params[:start]
  	  @end = params[:end]
    end
    @days = weekdays_in_date_range(Date.parse(@start)..Date.parse(@end))
    render :layout => false
  end

  protected
  def weekdays_in_date_range(range)
    # You could modify the select block to also check for holidays
    range.select { |d| (1..5).include?(d.wday) }.size
  end
end
