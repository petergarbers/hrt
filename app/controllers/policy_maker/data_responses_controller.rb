class PolicyMaker::DataResponsesController < ApplicationController
  before_filter :require_admin
  skip_before_filter :load_help

  def index
    @submitted_data_responses = DataResponse.available_to(current_user).submitted.all
    @in_progress_data_responses = DataResponse.available_to(current_user).in_process
    @empty_data_responses = DataResponse.available_to(current_user).empty
  end

  def show
    @data_response = DataResponse.find(params[:id])
    @projects = @data_response.projects.find(:all, :order => "name ASC")
    @code_roots = Code.for_activities.roots
    @cost_cat_roots = CostCategory.roots
    @policy_maker = true #view helper
  end

end
