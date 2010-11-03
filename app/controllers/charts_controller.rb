class ChartsController < ApplicationController

  def data_response_pie
    @data_response = DataResponse.available_to(current_user).find(params[:id])
    @assignments = @data_response.activity_coding(params[:codings_type], params[:code_type])

    send_data get_csv_string(@assignments), :type => 'text/csv; charset=iso-8859-1; header=present'
  end

  def project_pie
    @project = Project.available_to(current_user).find(params[:id])
    @assignments = @project.activity_coding(params[:codings_type], params[:code_type])

    send_data get_csv_string(@assignments), :type => 'text/csv; charset=iso-8859-1; header=present'
  end

  def data_response_treemap
    data_response = DataResponse.find(params[:id])

    respond_to do |format|
      format.json { render :json => get_activities_data_rows(data_response.activities, params[:chart_type]) }
    end
  end

  def project_treemap
    project = Project.find(params[:id])

    respond_to do |format|
      format.json { render :json => get_activities_data_rows(project.activities, params[:chart_type]) }
    end
  end

  def activity_treemap
    activity = Activity.find(params[:id])

    respond_to do |format|
      format.json { render :json => get_activity_data_rows(activity, params[:chart_type]) }
    end
  end

  private

  # csv format for AM pie chart:
  # title, value, ?, ?, ?, description
  def get_csv_string(records)
    other = 0
    csv_string = FasterCSV.generate do |csv|
      records.each_with_index do |record, index|
        if index < 10
          csv << [first_n_words(h(record.name), 3), record.value.to_f, nil, nil, nil, h(record.name) ]
        else
          other += record.value.to_f
        end
      end
      csv << ['Other', other, nil, nil, nil, 'Other']
    end
    csv_string
  end

  def h(str)
    if str
      str.gsub!(',', '  ')
      str.gsub!("\n", '  ')
      str.gsub!("\t", '  ')
      str.gsub!("\015", "  ") # damn you ^M
    end
    str
  end

  def first_n_words(string, n)
    string.split(' ').slice(0,n).join(' ') + '...'
  end

  def get_activities_data_rows(activities, chart_type)
    raise "Wrong chart type".to_yaml unless %w[mtef_budget mtef_spend nsp_budget nsp_spend].include? chart_type
    type = chart_type.include?("spend") ? "CodingSpend" : "CodingBudget"
    code_class = chart_type.include?("mtef") ? Mtef : Nsp
    if code_class == Mtef
      codes = Mtef.all + Nsp.all + Nha.all + Nasa.all
      roots = Mtef.roots
    else
      codes = code_class.all
      roots = code_class.roots
    end
    data_rows = Code.treemap_for_codes(roots, codes, type, activities)
  end

  def get_activity_data_rows(activity, chart_type)
    case chart_type
    when 'budget_coding'
      type = CodingBudget
    when 'budget_districts'
      type = CodingBudgetDistricts
    when 'budget_cost_categorization'
      type = CodingBudgetCostCategorization
    when 'spend_coding'
      type = CodingSpend
    when 'spend_districts'
      type = CodingSpendDistrict
    when 'spend_cost_categorization'
      type = CodingSpendCostCategorization
    else
      raise "Wrong chart type".to_yaml
    end

    data_rows = []
    treemap_root = "All Codes"
    data_rows << [treemap_root, nil, 0, 0] #todo amount

    code_roots  = Code.for_activities.roots
    assignments = type.with_activity(activity).all.map_to_hash{ |b| {b.code_id => b} }
    code_roots.each do |code|
      if assignments.has_key?(code.id)
        data_rows << [code.short_display, treemap_root, assignments[code.id].cached_amount, assignments[code.id].cached_amount]
        #unless code.leaf?
        #  code.children.each do |child|
        #    #recurse
        #end
      end
    end

    #TODO: districts
    return data_rows
  end

end
