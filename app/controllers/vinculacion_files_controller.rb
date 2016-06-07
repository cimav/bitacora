class VinculacionFilesController < ApplicationController
  before_filter :auth_required
  def file
    a = VinculacionFile.find(params[:id])
    send_file a.archivo.to_s, :x_sendfile=>true
  end
end
