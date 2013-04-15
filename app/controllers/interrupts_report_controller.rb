class InterruptsReportController < ApplicationController

  layout "ir"

  def index
  end

  #POST /ir/get_result
  def get_result

    tp_report_file = params[:tp_report].tempfile unless params[:tp_report].blank?
    fp_report_file = params[:fp_report].tempfile unless params[:fp_report].blank?
    pp_report_file = params[:pp_report].tempfile unless params[:pp_report].blank?
    gl_report_file = params[:gl_report].tempfile unless params[:gl_report].blank?

    data_source = {};
    data_source[:tp_report] = LmTpReport.new(tp_report_file.read) unless tp_report_file.nil?
    data_source[:fp_report] = LmFpReport.new(fp_report_file.read) unless fp_report_file.nil?
    data_source[:pp_report] = LmPpReport.new(pp_report_file.read) unless pp_report_file.nil?
    data_source[:gl_report] = LmGlReport.new(gl_report_file.read) unless gl_report_file.nil?

    ir = LmInterruptsReport.new source_reports: data_source,
                                      options: {
                                        #rayon: @report_rayon,
                                        report_date: Date.strptime( '12.04.2013', '%d.%m.%Y')
                                      }

    flash[:interrupts_report] = ir

    #flash[:debug] = data_source[:pp_report]

    redirect_to action: "result"
  end

  #GET /ir/result
  def result
    ir = flash[:interrupts_report]
    #flash[:debug]=ir.details
    render locals: {report: ir}
  end
end
