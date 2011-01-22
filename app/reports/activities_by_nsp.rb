require 'fastercsv'

class Reports::ActivitiesByNsp
  include Reports::Helpers

  def initialize(activities, report_type, show_organization = false)
    @activities        = activities
    @report_type       = report_type
    @show_organization = show_organization
    @leaves            = Nsp.leaves

    @csv_string = FasterCSV.generate do |csv|
      csv << build_header
      Nsp.roots.reverse.each{|nsp_root| add_rows(csv, nsp_root)}
    end
  end

  def csv
    @csv_string
  end

  private

    def build_header
      row = []

      Nsp.deepest_nesting.times{|i| row << "NSP Code"}
      row << "Budget"
      row << "Activity Description"
      row << "Funding Source"
      row << "Q1"
      row << "Q2"
      row << "Q3"
      row << "Q4"
      row << "Districts"
      row << "Data Source" if @show_organization
      row << "Implementer"
      row << "Institutions Assisted"
      row << "# of HC's Sub-implementing"
      row << "Beneficiaries"
      row << "ID"

      row
    end

    def add_rows(csv, code)
      add_code_summary_row(csv, code)
      add_code_row(csv, code, @activities, @report_type)
      code.children.with_type("Nsp").each{|c| add_rows(csv, c)}
    end

    def add_code_summary_row(csv, code)
      code_total = code.sum_of_assignments_for_activities(@report_type, @activities)
      if code_total > 0
        row = []
        add_nsp_codes_hierarchy(row, code)
        row << "Total Budget - " + n2c(code_total) #put total in Q1 column

        csv << row
      end
    end

    def add_code_row(csv, code, activities, report_type)
      cas = code.leaf_assigns_for_activities(report_type,activities)
      cas.each do |assignment|
        if assignment.cached_amount
          activity = assignment.activity
          row      = []
          add_nsp_codes_hierarchy(row, code)

          row << n2c(assignment.cached_amount)
          row << activity_description(activity)
          row << get_funding_source_name(activity)
          row << activity.spend_q1 ? 'x' : nil
          row << activity.spend_q2 ? 'x' : nil
          row << activity.spend_q3 ? 'x' : nil
          row << activity.spend_q4 ? 'x' : nil
          row << activity.locations.join(' | ')
          row << activity.organization.try(:short_name) if @show_organization
          row << get_provider_name(activity) # TODO: use provider_name(assignment.activity)
          row << activity.organizations.join(' | ')
          row << number_of_health_centers(activity)
          row << activity.beneficiaries.join(' | ')
          row << activity.id

          csv << row
        end
      end
    end

    def get_provider_name(activity)
      activity.provider ? activity.provider.try(:short_name) : "No Implementer Specified"
    end
end
