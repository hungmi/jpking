class UsersController < ApplicationController
  before_action :set_user, only: [:show, :edit, :update, :destroy]

  def validate
    @user = User.new(user_params)

    respond_to do |format|
      if @user.valid?
        format.json { render nothing: true, status: :ok }
      else
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end    
  end

  # GET /users
  # GET /users.json
  def index
    @users = User.all
  end

  # GET /users/1
  # GET /users/1.json
  def show
  end

  # GET /users/new
  def new
    @user = User.new
  end

  # GET /users/1/edit
  def edit
  end

  # POST /users
  # POST /users.json
  def create
    @user = User.new(user_params)

    respond_to do |format|
      if @user.save
        sign_in_as @user
        format.html {
          flash[:success] = "註冊成功！"
          redirect_to root_path
        }
      else
        format.html { render :new }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /users/1
  # PATCH/PUT /users/1.json
  def update
    # binding.pry
    respond_to do |format|
      if @user.authenticate(params[:user][:current_password])
        if @user.update(user_params)
          format.html {
            flash[:success] = "修改成功！"
            redirect_to @user
          }
          format.json { render :show, status: :ok, location: @user }
        else
          format.html { render :edit }
          format.json { render json: @user.errors, status: :unprocessable_entity }
        end
      else
        format.html {
          flash[:danger] = "請確認您的密碼。"
          render :edit
        }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /users/1
  # DELETE /users/1.json
  def destroy
    @user.destroy
    respond_to do |format|
      format.html { redirect_to users_url, notice: 'User was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      @user = User.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def user_params
      params.require(:user).permit(:phone, :name, :email, :password, :password_confirmation, :role)
    end
end
