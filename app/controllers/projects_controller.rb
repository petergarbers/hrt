require 'set'
class ProjectsController < Reporter::BaseController
  SORTABLE_COLUMNS = ['name', 'spend', 'budget']

  inherit_resources
  helper_method :sort_column, :sort_direction
  before_filter :load_response
  before_filter :strip_commas_from_in_flows, :only => [:create, :update]
  belongs_to :data_response, :route_name => 'response', :instance_name => 'response'
  before_filter :warn_if_not_current_request, :only => [:index, :new, :edit]


  def index
    redirect_to response_workplans_path(@response)
    ### due to https://www.pivotaltracker.com/story/show/13759613
    ### Not quite sure we should remove all this yet

    # scope = @response.projects.scoped({})
    #   scope = scope.scoped(:conditions => ["UPPER(name) LIKE UPPER(:q)",
    #                                        {:q => "%#{params[:query]}%"}]) if params[:query]
    #   @projects = scope.paginate(:page => params[:page], :per_page => 10,
    #                              :order => sort_column + " " + sort_direction) # rails 2
  end

  def new
    @project = @response.projects.new
    respond_to do |format|
      format.html
      format.json { render :json => {:html => render_to_string(:partial => 'new_inline.html.haml') } }
    end
  end

  def show
    @project = Project.find(params[:id])
    load_comment_resources(@project)
    respond_to do |format|
      format.html {}
      format.js {render :json => @project.to_json}
    end
  end

  def edit
    load_comment_resources(resource)
    edit!
  end

  def create
    @project = Project.new(params[:project].merge(:data_response => @response))
    create! do |success, failure|
      success.html { redirect_to response_workplans_path(@response) }
      success.js do
        render :json => {:status => @project.valid?,
                         :html => render_to_string({:partial => 'workplans/project_row',
                                              :locals => {:project => @project}})}
      end
      failure.js do
        render :json => {:status => @project.valid?,
                         :html => render_to_string({:partial => 'new_inline',
                                              :locals => {:project => @project}})}
      end
    end
  end

  def update
    success = FundingFlow.create_flows(params)
    update! do |success, failure|
      success.html {
        flash[:error] = "We were unable to save your funding flows, please check your data and try again" if !success
        flash.keep
        redirect_to response_workplans_path(@response)
      }
      failure.html do
        load_comment_resources(resource)
        render :action => 'edit'
      end
    end
  end

  def bulk_edit
    @projects = @response.projects
  end

  def bulk_update
    success = FundingFlow.create_flows(params)
    flash[:notice] = "Your projects have been successfully updated"
    redirect_to response_projects_url
  end

  def download_template
    template = Project.download_template
    send_csv(template, 'projects_template.csv')
  end

  def bulk_create
    begin
      if params[:file].present?
        doc = FasterCSV.parse(params[:file].open.read, {:headers => true})
        if doc.headers.to_set == Project::FILE_UPLOAD_COLUMNS.to_set
          saved_proj, error_proj, saved_activ, error_activ = Project.create_from_file(doc, @response)
          flash[:notice] = "Successfully imported #{saved_proj} of #{saved_proj + error_proj} projects 
                            and created/updated #{saved_activ} of #{saved_activ + error_activ} activities"
        else
          flash[:error] = 'Wrong fields mapping. Please download the CSV template'
        end
      else
        flash[:error] = 'Please select a file to upload'
      end

      redirect_to response_projects_url(@response)
    rescue
      flash[:error] = "There was a problem with your file. Did you use the template and save it after making changes as a CSV file instead of an Excel file? Please post a problem at <a href='https://hrtapp.tenderapp.com/kb'>TenderApp</a> if you can't figure out what's wrong."
      redirect_to response_projects_path(@response)
    end
  end

  def destroy
    destroy! do |success, failure|
      success.html do
        if request.referrer.match('workplan')
          redirect_to response_workplans_path(@response)
        else
          redirect_to response_projects_url(@response)
        end
      end
    end
  end
  
  def download_workplan
    filename = "#{@response.organization.name.split.join('_').downcase.underscore}_workplan.csv"
    send_csv(Reports::OrganizationWorkplan.new(@response).csv, filename)
  end

  protected

    def sort_column
      SORTABLE_COLUMNS.include?(params[:sort]) ? params[:sort] : "name"
    end

    def sort_direction
      %w[asc desc].include?(params[:direction]) ? params[:direction] : "desc"
    end

    def begin_of_association_chain
      @response
    end

    def strip_commas_from_in_flows
      if params[:project].present? && params[:project][:in_flows_attributes].present?
        in_flows = params[:project][:in_flows_attributes]
        in_flows.each_pair do |id, in_flow|
          [:spend, :budget].each do |field|
            in_flows[id][field] = convert_number_column_value(in_flows[id][field])
          end
        end
      end
    end

    def convert_number_column_value(value)
      if value == false
        0
      elsif value == true
        1
      elsif value.is_a?(String)
        if (value.blank?)
          nil
        else
          value.gsub(",", "")
        end
      else
        value
      end
    end
end
