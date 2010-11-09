class <%=namespace_class%>::<%= controller_class_name %>Controller < <%=namespace_class%>::AdminController
  # GET /<%= plural_table_name %>
  # GET /<%= plural_table_name %>.xml
  def index
    @fields = <%= attributes.collect {|attribute| attribute.name}.inspect %>
    @headers = <%= attributes.collect {|attribute| attribute.name.humanize}.inspect %>
    respond_to do |format|
      format.html {
        @<%= plural_table_name %> = <%= class_name %>.apply_query(params).paginate(:page => params[:<%= plural_table_name %>_page], :order => (params[:<%= singular_name %>_sort].gsub('_reverse', ' DESC') unless params[:<%= singular_name %>_sort].blank?))
      }
      format.xml { 
        @<%= plural_table_name %> = <%= class_name %>.apply_query(params)
      }
      format.csv {
        @<%= plural_table_name %> = <%= class_name %>.apply_query(params)
        csv_string = FasterCSV.generate do |csv|
        	csv << @headers
        	@<%= plural_table_name %>.each do |<%= singular_name %>|
        	  csv << @fields.collect { |f| <%= singular_name %>.send(f) }        	    
      	  end
      	end
      	send_data csv_string, :type => 'text/csv; charset=iso-8859-1; header=present', 
  				:disposition => "attachment; filename=<%= plural_table_name %>.csv"
      }
      format.xls {
        @<%= plural_table_name %> = <%= class_name %>.apply_query(params)
        render :xls => @<%= plural_table_name %>
      }
    end
  end

  # GET /<%= plural_table_name %>/1
  # GET /<%= plural_table_name %>/1.xml
  def show
    @<%= file_name %> = <%= class_name %>.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @<%= file_name %> }
    end
  end

  # GET /<%= plural_table_name %>/new
  # GET /<%= plural_table_name %>/new.xml
  def new
    @<%= file_name %> = <%= class_name %>.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @<%= file_name %> }
    end
  end

  # GET /<%= plural_table_name %>/1/edit
  def edit
    @<%= file_name %> = <%= class_name %>.find(params[:id])
  end

  # POST /<%= plural_table_name %>
  # POST /<%= plural_table_name %>.xml
  def create
    @<%= file_name %> = <%= class_name %>.new(params[:<%= file_name %>])

    respond_to do |format|
      if @<%= file_name %>.save
        flash[:notice] = '<%= class_name %> was successfully created.'
        format.html { redirect_to(params[:return_to] || [:admin,@<%= file_name %>]) }
        format.xml  { render :xml => @<%= file_name %>, :status => :created, :location => @<%= file_name %> }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @<%= file_name %>.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /<%= plural_table_name %>/1
  # PUT /<%= plural_table_name %>/1.xml
  def update
    @<%= file_name %> = <%= class_name %>.find(params[:id])

    respond_to do |format|
      if @<%= file_name %>.update_attributes(params[:<%= file_name %>])
        flash[:notice] = '<%= class_name %> was successfully updated.'
        format.html { redirect_to([:admin,@<%= file_name %>]) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @<%= file_name %>.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /<%= plural_table_name %>/1
  # DELETE /<%= plural_table_name %>/1.xml
  def destroy
    @<%= file_name %> = <%= class_name %>.find(params[:id])
    @<%= file_name %>.destroy
    flash[:notice] = '<%= class_name %> was successfully deleted.'
    respond_to do |format|
      format.html { redirect_to(admin_<%= plural_table_name %>_url) }
      format.xml  { head :ok }
    end
  end
  
  # def bulk
  #   unless params[:ids].blank?
  #     <%= plural_table_name %> = <%= class_name %>.find(params[:ids])
  #     success = true
  #     params[:<%= file_name %>].delete_if {|k, v| v.blank?}
  #     <%= plural_table_name %>.each do |<%= file_name %>|
  #       success &&= <%= file_name %>.update_attributes(params[:<%= file_name %>])
  #     end
  #     success ? flash[:notice] = '<%= class_name.pluralize %> were successfully updated.' : flash[:error] = 'Bulk Update Failed.'
  #   else
  #     flash[:error] = 'No <%= class_name %> record is selected.'
  #   end
  #   
  #   respond_to do |format|
  #     format.html { redirect_to(admin_<%= plural_table_name %>_path) }
  #     format.xml  { head :ok }
  #   end
  # end
end
