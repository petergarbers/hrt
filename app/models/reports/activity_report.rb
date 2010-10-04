require 'fastercsv'

class Reports::ActivityReport
  include Reports::Helpers

  attr_accessor :query, :cols, :conditions, :joins

  def initialize options = {}
#    cols = [ "project.name", "org.name", "org.type", "activity.name", "activity.description", 
#          "activity.text_for_beneficiaries", "activity.text_for_targets", "activity.target",
#          "activity.budget", "activity.spend", "currency","activity.start", "activity.end", 
#          "activity.provider"]
#    cols = (cols + options[:cols]).flatten if options[:cols]

    #add to cols only when you are doing a row join, not column join
    #dont do chaining yet, just one set of codes
    # TODO add beneficiaries as first instance of codes

  end

  def csv
    unless @csv_string
      @csv_string = FasterCSV.generate do |csv|
        csv << build_header()
        #print data
        Activity.all.each do |a|
          rows = build_rows(a)
          add_rows_to_csv rows, csv
          #print out a row for each project
        end
      end
    end
    @csv_string
  end

  protected

  def build_header
    #print header
    header = []
    header << [ "project", "org.name", "org.type", "activity.name", "activity.description" ]
    header << ["activity.text_for_beneficiaries", "activity.text_for_targets", "activity.target", "activity.budget", "activity.spend", "currency","activity.start", "activity.end", "activity.provider"]
    header.flatten
  end

  def add_rows_to_csv rows, csv
    if rows.first.class == Array
      rows.each {|r| add_rows_to_csv r, csv}
    else
      csv << rows
    end
  end

  def build_rows(activity)
    rows=[]
    org        = activity.data_response.responding_organization

    row = []
    row << [ "#{h org.name}", "#{org.type}", "#{h activity.name}", "#{h activity.description}" ]
    row << ["#{h activity.text_for_beneficiaries}", "#{h activity.text_for_targets}", "#{activity.target}", "#{activity.budget}", "#{activity.spend}", "#{activity.data_response.currency}",  "#{activity.start}", "#{activity.end}" ]
    row << (activity.provider.nil? ? " " : "#{h activity.provider.name}" )
    row.flatten
    if activity.projects.empty?
      row.unshift(" ")
      rows = [ row.flatten ]
    else
      activity.projects.each do |proj|
        proj_row = row.dup
        proj_row.unshift("#{h proj.name}")
        rows << proj_row.flatten
      end
    end
    rows
  end

end

