#encoding:utf-8
require 'zip/zip'
class InterruptsReportController < ApplicationController

  include ReportsFuncs

  layout "ir"

  def index
  end

  #POST /ir/get_result
  def get_result

    data_source = {};

    case params[:data_type]
    when "zip"

      if params[:zip_file]
        zip_file = params[:zip_file].tempfile

        tz = Zip::ZipFile.open(zip_file)

        data_source = load_reports_from_zip tz, LmInterruptsReport.new.data_source_shema
      end

    else
      tp_report_file = params[:tp_report].tempfile unless params[:tp_report].blank?
      fp_report_file = params[:fp_report].tempfile unless params[:fp_report].blank?
      pp_report_file = params[:pp_report].tempfile unless params[:pp_report].blank?
      gl_report_file = params[:gl_report].tempfile unless params[:gl_report].blank?

      data_source[:tp_report] = LmTpReport.new(tp_report_file.read) unless tp_report_file.nil?
      data_source[:fp_report] = LmFpReport.new(fp_report_file.read) unless fp_report_file.nil?
      data_source[:pp_report] = LmPpReport.new(pp_report_file.read) unless pp_report_file.nil?
      data_source[:gl_report] = LmGlReport.new(gl_report_file.read) unless gl_report_file.nil?
    end

    ir = LmInterruptsReport.new source_reports: data_source,
                                      options: {
                                        rayon: params[:rayon],
                                        report_date: Date.today
                                      }

    flash[:interrupts_report] = ir

    #flash[:debug] = data_source[:pp_report]
    redirect_to action: "result"
  end

  #GET /ir/result
  def result
    flash[:interrupts_report] = ir = flash[:interrupts_report]
    #flash[:debug]=ir.details
    render locals: {report: ir}
  end

  #GET /ir/print/:report(.:format)
  def print
    flash[:interrupts_report] = ir = flash[:interrupts_report]
    data=""
    unless ir.nil?
      case params[:report]
      when "recom"
        data = render_to_string "interrupts_report/report_templs/xls/recom",layout:nil, locals: {report: ir}
      when "ovd"
        data = render_to_string "interrupts_report/report_templs/xls/ovd",layout:nil, locals: {report: ir}
      else
        redirect_to root_path
      end
      send_data data, file_name: "#{params[:report]}.#{params[:format]}"
    else
      redirect_to root_path
    end
  end
end
